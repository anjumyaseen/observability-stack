#!/usr/bin/env bash
set -e
: "${COUNT:=100}"
for i in $(seq 1 "$COUNT"); do
  redis-cli -h 127.0.0.1 -p 6379 SET demo:$i "val-$i" EX 300 >/dev/null
done
echo "Seeded $COUNT keys with 5m TTL"
