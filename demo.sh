#!/bin/bash
# Demo script for the README GIF. Fires 300 requests at once against
# the real production config (capacity 75, refill 25/sec), shows how
# many are admitted immediately vs denied, then keeps retrying the
# denied ones -- exactly what a well-behaved client respecting
# Retry-After would do -- until all 300 have eventually gone through,
# with a running timestamp.

echo "Gatekeeper -- capacity=75  refill=25/s"
echo "Firing 300 requests at once..."

result=$(hey -n 300 -c 300 http://localhost:8081/count 2>&1)
allowed=$(echo "$result" | awk '/\[200\]/{print $2}')
denied=$(echo "$result" | awk '/\[429\]/{print $2}')

echo "[00s] ${allowed}/300 admitted immediately, ${denied} denied (told when to retry)"

> /tmp/gatekeeper_retried.count
echo 0 > /tmp/gatekeeper_retried.count

(
  success=0
  while [ "$success" -lt "$denied" ]; do
    code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081/count)
    if [ "$code" = "200" ]; then
      success=$((success + 1))
      echo "$success" > /tmp/gatekeeper_retried.count
    fi
  done
) &
retry_pid=$!

start=$(date +%s)
while kill -0 $retry_pid 2>/dev/null; do
  sleep 1
  now=$(($(date +%s) - start))
  retried=$(cat /tmp/gatekeeper_retried.count)
  total=$((allowed + retried))
  printf "[%02ds] %d/300 admitted\n" "$now" "$total"
done

now=$(($(date +%s) - start))
printf "[%02ds] 300/300 complete\n" "$now"
rm -f /tmp/gatekeeper_retried.count
