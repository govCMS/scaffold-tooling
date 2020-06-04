#!/usr/bin/env bats
# shellcheck disable=SC2002

load _helpers_govcms

@test "Integration: assert that all.settings.php included during bootstrap" {
  # The directory with current repository.
  REPO_DIR="${TEST_APP_DIR}/repo"
  # The directory with the scaffold.
  SCAFFOLD_DIR="${TEST_APP_DIR}/scaffold"
  # The latest commit to the current repository to be used for version and as a
  # unique token
  LATEST_COMMIT="$(git rev-parse HEAD)"
  # The version to be used for local inclusion.
  LATEST_DEV_VERSION="test-${LATEST_COMMIT}-$(date +%s)"

  debug "${REPO_DIR}"
  prepare_fixture_dir "${REPO_DIR}"
  copy_code "${REPO_DIR}"
  # Checkout code into unique branch. This branch is later used by Composer
  # to include as a version.
  git --git-dir="${REPO_DIR}/.git" --work-tree="${REPO_DIR}" checkout -b "${LATEST_DEV_VERSION}"
  # Add unique token to be printed on drush bootstrap when settings file is
  # included.
  echo 'print "'"${LATEST_COMMIT}"'";' >> "${REPO_DIR}/drupal/settings/all.settings.php"

  debug "${SCAFFOLD_DIR}"
  prepare_fixture_dir "${SCAFFOLD_DIR}"

  pushd "${SCAFFOLD_DIR}" || exit 1

  # Download PaaS scaffold to be able to bootstrap the site.
  download_code_from_github "govCMS" "govCMS8-scaffold-paas"

  # Override scaffold repo path with a path to our version.
  composer config repositories.test path "${REPO_DIR}"

  # Update composer.lock to pick up the changes to repositories.
  export COMPOSER_MEMORY_LIMIT=-1
  composer update --ignore-platform-reqs --lock

  # Add the repo at the checked out version.
  composer require govcms/scaffold-tooling:dev-"${LATEST_DEV_VERSION}" --ignore-platform-reqs

  # Assert that modified settings file was included after 'composer update'.
  assert_file_contains vendor/govcms/scaffold-tooling/drupal/settings/all.settings.php "${LATEST_COMMIT}"

  # Assert that bootstrapping Drupal includes settings file.
  run vendor/bin/drush -l default core:status
  assert_output_contains "${LATEST_COMMIT}"

  # Assert that running Drush command includes settings file.
  run vendor/bin/drush -l default php:eval ' '
  assert_output_contains "${LATEST_COMMIT}"

  popd || exit 1
}
