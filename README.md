# stolon-boshrelease

**This release is WIP**

This is a [bosh release](https://bosh.io) using [postgres](https://www.postgresql.org/), [stolon](https://github.com/sorintlab/stolon) & [consul](https://www.consul.io/) to deploy postgres in a highly available manner.

## Hints

- This release is dependant on [consul-release](http://bosh.io/releases/github.com/cloudfoundry-incubator/consul-release) (tested with version `170`).
- This release can be deployed with consul-servers inclueded or without them by leveraging a different deployment which provide the `consul_common` and `consul_client` links.
- There are some ops- and vars-files included to deploy via `bosh2`
  - Deployment with external consul cluster:
    ```
    bosh2 -e bosh-lite -d stolon \
      deploy \
        --vars-file manifest/vars.default.yml \
      manifest/deployment.stolon.yml
    ```
  - Deployment with a consul cluster included:
    ```
    bosh2 -e bosh-lite -d stolon_consul
      deploy \
        --ops-file manifest/ops.include-consul.yml \
        --vars-file manifest/vars.default.yml \
        --vars-file manifest/vars.include-consul.yml \
      manifest/deployment.stolon.yml
    ```

  Some of the settings (`consul_common_link_name`, `consul_deployment_name`, ...) may need to be changed either by a vars-file or by specifying them via command line option like `... --var 'consul_deployment_name=this_is_my_consul_cluster' ...`.
- You can also spin up a separate consul server deployment which you can then use to link to the actual stolon deployment:
  ```
  bosh2 -e bosh-lite -d consul \
    deploy \
      --vars-file manifest/vars.include-consul.yml \
    manifest/deployment.consul.yml
  ```

## TODOs

- [ ] More testing, smoketest, CI
- [ ] test with `pg_rewind`
- [ ] include some backup solution (`wal-e`, `pgbackrest`, `barman`, ...)
- [ ] loadbalance mutltiple proxies (?)

## Attention

This is work in progress. This is first bosh release, more of a playground and should be treated as such ...you have been warned!

