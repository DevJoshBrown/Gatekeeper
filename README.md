# Gatekeeper

*Got 429 problems? ...Server overload ain't one!*



## Description

Gatekeeper is a Go reverse proxy that enforces per-request rate limiting using a hand-built, concurrency-safe token bucket algorithm, forwarding allowed traffic to a configurable upstream while rejecting excess load with a proper 429 and Retry-After.

![Gatekeeper demo](demo.gif)

## Motivations

This token bucket rate limiter supports short, legitimate bursts of client traffic while smoothly throttling sustained overload back down to a sustainable rate, the kind of pattern common in API-driven services like CRM sync tools or other batch-request workloads. I built it to serve exactly that purpose in my own HubSpot ↔ ERP sync microservices, and as a learning exercise to cement my understanding of concurrency safety and proper unit testing along the way.

## Quick Start
### 1. Clone and enter the repo

```bash
git clone https://github.com/DevJoshBrown/Gatekeeper.git
cd Gatekeeper
```

### 2. Start something to proxy to
Use the included dummy upstream, or point at any real HTTP service you already have:
```bash
go run ./cmd/dummyupstream
```

### 3. Start the proxy, in a second terminal
```bash
UPSTREAMSCHEME=http UPSTREAMHOST=localhost:8080 PROXYPORT=8081 go run ./cmd/main.go
```

### 4. Send it some traffic 
```bash
curl http://localhost:8081/count
```
Keep firing requests past the configured burst capacity and you'll start seeing 429 Too Many Requests with a Retry-After header instead — /healthz and /metrics are also live on the same proxy for liveness checks and Prometheus scraping.

## Usage
### Configuration

Gatekeeper is configured entirely through environment variables (loaded automatically from a `.env` file in local development, or supplied directly by the platform in Docker/Kubernetes):

| Variable                 | Required | Description                                        | Default |
|--------------------------|----------|----------------------------------------------------|---------|
| `UPSTREAMSCHEME`         | Yes      | Scheme of the upstream service (`http`/`https`)    | —       |
| `UPSTREAMHOST`           | Yes      | Host (and port) of the upstream service            | —       |
| `PROXYPORT`              | No       | Port Gatekeeper itself listens on                  | `8081`  |
| `TOKENBUCKET_CAPACITY`   | No       | The total token capacity of the bucket             | `75.0`  |
| `TOKENBUCKET_REFILLRATE` | No       | The refill rate in tokens per second               | `25.0`  |


Missing a required variable causes Gatekeeper to fail fast at startup with a clear error, rather than starting in a broken state.

### Endpoints

- **`/*` (everything else)** — the actual proxy. Allowed requests are forwarded unmodified to your configured upstream; denied requests receive a `429 Too Many Requests` with a `Retry-After` header indicating how many seconds until a token will be available.
- **`/healthz`** — a liveness check. Deliberately bypasses the rate limiter, so a burst of real traffic can never cause Kubernetes (or any health-checking system) to mistake correct throttling for an unhealthy service.
- **`/metrics`** — a Prometheus-format endpoint exposing `requests_total`, labeled by `outcome` (`allowed`/`denied`), ready to be scraped by a Prometheus server.

### Examples

A normal, allowed request:

```bash
curl http://localhost:8081/your-path
```

A denied request, once the bucket is exhausted:

```bash
curl -i http://localhost:8081/your-path
# HTTP/1.1 429 Too Many Requests
# Retry-After: 2
```

Checking liveness:
```bash
curl http://localhost:8081/healthz
```

Scraping metrics:
```bash
curl http://localhost:8081/metrics
```

