#!/usr/bin/env bash

set -eu
set -o pipefail

export PGPORT='<%= link('conn').p('stolon.port') %>'
export PGUSER='<%= link('users').p('pg.su_user') %>'
export PGPASSWORD='<%= link('users').p('pg.su_pass') %>'

export PATH="${PATH}:/var/vcap/packages/postgres/bin"

getRandom() {
  cat /proc/sys/kernel/random/uuid
}

runSql() {
  psql -A -t -q -c "$1"
}

simpleSelect() {
  runSql "SELECT 1"
}

mkUser() {
  runSql "CREATE ROLE \"$1\" WITH LOGIN PASSWORD '$2'"
}

delUser() {
  runSql "DROP ROLE \"$1\""
}

mkDb() {
  runSql "CREATE DATABASE \"$1\" WITH OWNER \"$2\""
}

delDb() {
  PGDATABASE=postgres runSql "DROP DATABASE \"$1\""
}

createTable() {
  runSql "CREATE TABLE \"$1\" (id serial, payload text)"
}

putData() {
  runSql "INSERT INTO \"$1\" (payload) VALUES ('$2')"
}

getData() {
  runSql "SELECT payload FROM \"$1\""
}

msgOk() {
  echo '[🗸]' "$@"
}

msgErr() {
  echo '[🗴]' "$@"
}

testSuite() {
  local proxy="$1"

  echo "----[ proxy: ${proxy} ]----"

  export PGHOST="$proxy"

  local new_user="smoke_test_user_$( getRandom )"
  local new_db="smoke_test_db_$( getRandom )"
  local new_pass="smoke_test_pass_$( getRandom )"
  local new_table="smoke_test_table_$( getRandom )"
  local new_data="smoke_test_some_data_$( getRandom )_atad_emos"

  simpleSelect >/dev/null
  msgOk 'connect and query'

  mkUser "$new_user" "$new_pass"
  trap "delUser '$new_user'" EXIT
  msgOk 'create user'

  mkDb "$new_db" "$new_user"
  trap "delDb '$new_db' ; delUser '$new_user'" EXIT
  msgOk 'create db'

  (
    export PGPASSWORD="$new_pass"
    export PGUSER="$new_user"
    export PGDATABASE="$new_db"

    createTable "$new_table"
    msgOk 'create table'

    putData "$new_table" "$new_data"
    msgOk 'put data'

    local data_read="$(getData "$new_table")"
    msgOk 'get data'

    [ "$data_read" = "$new_data" ] || {
      msgErr 'data not matching'
      echo "      expected: ${new_data}"
      echo "          read: ${data_read}"

      exit 1
    }
  )

  delDb "$new_db"
  trap "delUser '$new_user'" EXIT
  msgOk 'delete database'

  delUser "$new_user"
  trap '' EXIT
  msgOk 'delete user'
}

<% link('conn').instances.each do |proxy| %>
testSuite '<%= proxy.address %>'
<% end %>

