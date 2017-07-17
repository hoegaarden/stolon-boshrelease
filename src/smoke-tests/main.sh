#!/usr/bin/env bash

set -eu
set -o pipefail

export PGPORT='<%= link('conn').p('stolon.port') %>'
export PGUSER='<%= link('users').p('pg.su_user') %>'
export PGPASSWORD='<%= link('users').p('pg.su_pass') %>'

export PATH="${PATH}:/var/vcap/packages/postgres/bin"

getRandom() {
  set +e
  cat /dev/urandom \
    | tr -dc 'a-zA-Z0-9' \
    | fold -w 32 \
    | head -n 1
  set -e
}

runSql() {
  psql -A -q -t
}

simpleSelect() {
  echo "SELECT 'connected and got result'" \
    | runSql
}

mkUser() {
  echo "CREATE ROLE \"$1\" WITH LOGIN PASSWORD '$2'" \
    | runSql
}

delUser() {
  echo "DROP ROLE \"$1\"" \
    | runSql
}

mkDb() {
  echo "CREATE DATABASE \"$1\" WITH OWNER \"$2\"" \
    | runSql
}

delDb() {
  echo "DROP DATABASE \"$1\"" \
    | runSql
}

createTable() {
  echo "CREATE TABLE \"$1\" (id serial, payload text)" \
    | runSql
}

fillTable() {
  echo "BEGIN; INSERT INTO \"$1\" (payload) VALUES ('$2'); COMMIT;" \
    | runSql
}

getData() {
  echo "SELECT payload FROM \"$1\"" \
    | runSql
}

main() {
  local proxy="$1"

  echo "----[ proxy: ${proxy} ]----"

  export PGHOST="$proxy"

  simpleSelect

  local new_user="user_$( getRandom )"
  local new_db="db_$( getRandom )"
  local new_pass="pass_$( getRandom )"
  local new_table="table_$( getRandom )"
  local new_data="some_data_$( getRandom )_atad_emos"

  mkUser "$new_user" "$new_pass" || {
    delUser "$new_user"
    exit 1
  }

  mkDb "$new_db" "$new_user" || {
    delDb "$new_db"
    delUser "$new_user"
    exit 1
  }

  (
    export PGPASSWORD="$new_pass"
    export PGUSER="$new_user"
    export PGDATABASE="$new_db"

    createTable "$new_table"
    fillTable   "$new_table" "$new_data"

    local data_read="$(getData "$new_table")"
    [ "$data_read" = "$new_data" ] || {
      echo "Data expected: ${new_data}"
      echo "Data read:     ${data_read}"
      exit 1
    }
  )

  delDb "$new_db"
  delUser "$new_user"
}

<% link('conn').instances.each do |proxy| %>
main '<%= proxy.address %>'
<% end %>

