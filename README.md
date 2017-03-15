# stolon-boshrelease

**This release is WIP**

This is a [bosh release](https://bosh.io) using [postgres](https://www.postgresql.org/), [stolon](https://github.com/sorintlab/stolon) & [consul](https://www.consul.io/) to deploy postgres in a highly available manner.

## Hints

- This release is dependant on [consul-boshrelease](https://github.com/cloudfoundry-community/consul-boshrelease) (tested with version `21.0.0`).
- An example deployment manifest can be found in `examples/manifest.yml` which has been used to deploy to bosh-lite/warden

## TODOs

- [ ] More testing, smoketest, CI
- [ ] test with `pg_rewind`
- [ ] include some backup solution (`wal-e`, `pgbackrest`, `barman`, ...)
- [ ] loadbalance mutltiple proxies (?)

## Attention

This is work in progress. This is first bosh release, more of a playground and should be treated as such ...you have been warned!

