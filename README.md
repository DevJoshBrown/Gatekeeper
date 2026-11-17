<h1>Gatekeeper</h1>
<p><i>Got 429 problems? ...Server overload aint one!</i></p>

<h2>Description</h2>
<p>Gatekeeper is a Go reverse proxy that enforces per-request rate limiting using a hand-built, concurrency-safe token bucket algorithm, forwarding allowed traffic to a configurable upstream while rejecting excess load with a proper 429 and Retry-After.</p>

