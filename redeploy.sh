#!/usr/bin/env bash

set -e
set -u

D="$( dirname "$0" )"

find "$D" -name \*~ -delete

bosh create release --force
bosh upload release

bosh deploy ${RECREATE+--recreate}
