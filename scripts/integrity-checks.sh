# PoC script to show early validation of a push.

# Currently triggered from ./gitlab-ci.yml but it seems to be something that we would
# want to apply from external, and best solved with an instance template coming soon
# https://gitlab.com/gitlab-org/gitlab-ee/issues/8429

SATIS="https://satis.govcms.gov.au/beta6"
code=0

flavour=$(egrep  "^type: " .version.yml | awk -F ": " '{print $2}')
if [ "$flavour" = "saas" ] || [ "$flavour" = "paas" ] || [ "$flavour" = "saasplus" ] ; then
    echo "GovCMS build flavour: $flavour"
else
    echo "Not a relevant SaaS/PaaS project."
    exit 0
fi

## SaaS logic.

if [ "$flavour" = "saas" ] ; then

    # There must be two repos, on is our satis and the other sets packagist to false.
    repos_count=$(cat composer.json | jq '.repositories | length')
    repos_govcms=$(cat composer.json | jq -r '.repositories.govcms.url')
    repos_packagist=$(cat composer.json | jq -c '.repositories["packagist.org"]')

    if [ "$repos_count" != "2" ] || [ "$repos_govcms" != "$SATIS" ] || [ "$repos_packagist" != "false" ] ; then
        echo -e "\033[0;91mFor $flavour, there should be two composer repository entries: one for '$SATIS' and one sets 'packagist.org' to 'false'.\033[0m"
        # echo $(cat composer.json | jq '.repositories')
        code=1
    else
        echo "Composer repositories are valid for $flavour."
    fi

    # Check locations where user can add modules (other locations would be overridden with composer install.
    modules_custom=$(find web/modules/custom -type f -name *.info.yml)
    modules_default=$(find web/sites/default -type f -name *.info.yml)

    if [[ $modules_custom ]] || [[ $modules_default ]] ; then
        echo -e "\033[0;91mFor $flavour, custom modules are not supported.\033[0m"
        code=1
    else
        echo "No custom modules found (as expected) for $flavour."
    fi

fi

exit $code
