# GovCMS Scaffolding
A collection of standard config, scripts and packages to support GovCMS scaffold.

[![GitlabCI](https://projects.govcms.gov.au/dof-dev/scaffold-tooling/badges/9.x/pipeline.svg)](https://projects.govcms.gov.au/dof-dev/scaffold-tooling/-/pipelines)

## Run tests

Your local composer auth.json can be loaded by copying
`docker-compose.override.example.yml` to `docker-compose.override.yml`.

```sh
# Integration tests.
docker compose run --rm test -- bash -c "bats tests/bats/integration.bats"

# All the tests.
docker compose run --rm test -- bash -c ".ci/bats.sh"
```
