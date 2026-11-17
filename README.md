# Gatekeeper

*Got 429 problems? ...Server overload aint one!*

![Gatekeeper demo](demo.gif)

## Description

Gatekeeper is a Go reverse proxy that enforces per-request rate limiting using a hand-built, concurrency-safe token bucket algorithm, forwarding allowed traffic to a configurable upstream while rejecting excess load with a proper 429 and Retry-After.
