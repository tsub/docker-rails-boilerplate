#!/bin/sh

set -e

host="$1"
shift
cmd="$@"

echo "Waiting for mysql"
until mysql -h "$host" -u root -e "show databases" &> /dev/null
do
  >&2 echo -n "."
  sleep 1
done

>&2 echo "MySQL is up - executing command"
exec $cmd
