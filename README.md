
# 🧩 Observability Stack — Prometheus, Grafana, Redis, Thanos, cAdvisor, Node Exporter

A ready-to-deploy **Observability Stack** designed for developers, DevOps engineers, and system administrators who want a lightweight, modular monitoring setup that can be expanded across servers and services.

---

## 🚀 Overview

This stack provides:
- **Real-time metrics collection** using Prometheus
- **Container-level monitoring** via cAdvisor
- **Host-level metrics** via Node Exporter
- **Time-series data storage and querying** powered by Thanos
- **Dashboarding and alerts** using Grafana
- **Optional Redis exporter** for monitoring Redis performance

It’s built for portability — running locally (e.g., WSL2, Docker Desktop) or remotely on any VPS (e.g., AlmaLinux, Ubuntu, Debian).

---

## 🔄 Update Log

- 2025-11-03: Consolidated the stack into `docker/docker-compose.observability.yml`, added a shared Caddy reverse proxy (`configs/caddy/`), and routed Grafana/Prometheus/Thanos/MinIO via `*.localhost` hostnames.
- 2025-11-03: Reintroduced explicit names with an `observability-*` prefix so every container is easy to identify (e.g., `observability-prometheus`).
- 2025-11-03: Relaxed the node-exporter root mount to work on Docker Desktop / WSL (removed `rslave` requirement).
- 2025-11-03: Added `configs/prometheus/targets/vps.sample.yml` and moved real targets to `file_sd` (copy to `vps.yml`) so remote IPs stay local-only.
- 2025-11-03: Externalized Grafana/MinIO credentials via `.env` (see `.env.example`) so secrets never land in git.

---

## 🧩 Diagram

```
          ┌──────────────────────────┐
          │        Grafana           │
          │  (Dashboards & Alerts)   │
          └──────────┬───────────────┘
                     │
                     ▼
          ┌──────────────────────────┐
          │      Thanos Query        │
          │ Combines all metric data │
          └──────┬─────────┬────────┘
                 │         │
     ┌───────────┘         └────────────┐
     ▼                                 ▼
┌──────────────┐               ┌─────────────────┐
│ Thanos Sidecar│               │ Thanos Store    │
│ (live metrics)│               │ (historical)    │
└──────┬────────┘               └──────┬──────────┘
       │                               │
       ▼                               ▼
┌──────────────┐               ┌─────────────────┐
│  Prometheus  │               │     MinIO        │
│  (scraping)  │◄───Metrics───►│ S3 Bucket        │
└──────────────┘               │ thanos-metrics   │
                              └─────────────────┘
```

-----

## 📁 Directory Structure

```
observability-stack/
├── .env.example
├── configs
│   ├── caddy
│   │   ├── Caddyfile
│   │   └── conf.d/
│   │       └── observability.caddy
│   ├── prometheus
│   │   ├── prometheus.yml
│   │   └── targets/
│   │       ├── README.md
│   │       └── vps.sample.yml
│   └── thanos
│       └── objstore.yaml
├── docker
│   └── docker-compose.observability.yml
└── scripts
    └── seed_redis.sh
```

---

## 🧱 Core Services

| Service | Description | Access | Credentials / Notes |
|----------|--------------|--------|---------------------|
| **Caddy** | Shared reverse proxy for observability + other projects | `http(s)://*.localhost` | Configured via `configs/caddy/`, publishes network `reverse-proxy` |
| **Prometheus** | Core metrics collection and scraping | `http://prometheus.localhost` | Configure local targets in `prometheus.yml`; copy `configs/prometheus/targets/vps.sample.yml` → `vps.yml` for remote IPs |
| **Grafana** | Dashboards and visualizations | `http://grafana.localhost` | Credentials from `.env` (`GF_SECURITY_ADMIN_*`), change after first sign-in |
| **Thanos Query** | Unified long-term + live metrics API | `http://thanos.localhost` | Fan-in for sidecar + store |
| **MinIO Console** | Browser UI for MinIO object storage | `http://minio.localhost` | Credentials from `.env` (`MINIO_ROOT_*`), rotate immediately if exposed |
| **MinIO API** | S3-compatible endpoint for metrics storage | `http://minio-api.localhost` | Uses the same MinIO credentials |
| **Redis** | Example data source for metrics | `redis:6379` (internal) | No auth by default |
| **Redis Exporter** | Exposes Redis metrics to Prometheus | `redis-exporter:9121` (internal) | Targets Redis automatically |
| **Node Exporter** | Exposes host (CPU, memory, disk, network) metrics | `node-exporter:9100` (internal) | Scraped by Prometheus |
| **cAdvisor** | Monitors Docker containers (CPU, memory, FS, network) | `http://cadvisor.localhost` | Exposed through Caddy |

---

## ⚙️ How to Run

### 1️⃣ Prepare secrets
```bash
cp .env.example .env
```
Edit `.env` with secure values for MinIO and Grafana before starting the stack.

### 2️⃣ (Optional) Point Prometheus at remote exporters
```bash
cp configs/prometheus/targets/vps.sample.yml configs/prometheus/targets/vps.yml
```
Edit `vps.yml` and replace `your-vps-ip` with the real address(es) of your node-exporter and cAdvisor instances. The file is gitignored on purpose so secrets stay local. You can reload Prometheus at any time with:
```bash
curl -X POST http://prometheus.localhost/-/reload
```

### 3️⃣ Start or stop the entire stack
```bash
docker compose -f docker/docker-compose.observability.yml up -d
docker compose -f docker/docker-compose.observability.yml down
```

### 4️⃣ Access Dashboards & APIs via Caddy
- Grafana → [http://grafana.localhost](http://grafana.localhost)
- Prometheus → [http://prometheus.localhost](http://prometheus.localhost)
- Thanos Query → [http://thanos.localhost](http://thanos.localhost)
- MinIO Console → [http://minio.localhost](http://minio.localhost)
- MinIO API (S3) → [http://minio-api.localhost](http://minio-api.localhost)
- cAdvisor → [http://cadvisor.localhost](http://cadvisor.localhost)

### 5️⃣ Verify scrapes (especially remote `vps` targets)
- Prometheus UI → **Status ▸ Targets** should report `vps-node` and `vps-cadvisor` as `UP`.
- CLI check:
  ```bash
  curl -s http://prometheus.localhost/api/v1/targets | grep '"job":"vps'
  ```

---

## 📊 Grafana Overview

### ✅ Default Dashboard: *My Infrastructure*
- Displays container **Status (UP/DOWN)** from cAdvisor.
- Shows host CPU, RAM, and Disk usage via Node Exporter.
- Uses instant queries with color-coded UP/DOWN states.

---

## 🧠 Credentials and Config Locations

| Component | Config File | Notes |
|------------|--------------|-------|
| Prometheus | `configs/prometheus/prometheus.yml` | Targets for exporters |
| Thanos | `configs/thanos/objstore.yaml` | Object storage connection |
| Remote targets | `configs/prometheus/targets/vps.sample.yml` | Copy to `vps.yml` locally to avoid committing real IPs |
| Caddy | `configs/caddy/` | Reverse proxy entrypoints (`*.caddy` files) |
| Docker Compose | `docker/docker-compose.observability.yml` | Single command to start/stop entire stack |
| Grafana dashboards | `dashboards/` | Import JSON from Grafana → Dashboards → Import |
| Scripts | `scripts/` | Helper automation utilities |


> 🔐 **Tip:** Use `.env` files to securely manage credentials.

---

## 🧩 Extending the Stack

### ➕ Add More Containers
All Docker containers are auto-discovered via **cAdvisor**.  
To make them visible in Grafana, ensure the container runs on the same Docker network as the stack.

### ➕ Add More Servers
Add new servers with `node-exporter` and `cadvisor`, then extend Prometheus targets in `prometheus.yml`:

```yaml
- job_name: "remote-node"
  static_configs:
    - targets: ["192.168.1.22:9100", "192.168.1.22:8085"]
```
Reload Prometheus:
```bash
curl -X POST http://localhost:9090/-/reload
```

### ➕ Add APIs or Custom Metrics
Create new jobs inside Prometheus config to scrape any `/metrics` endpoint.

### ➕ Add Other Projects Behind Caddy
1. Attach the new service to the shared `reverse-proxy` network in its own compose file:
   ```yaml
   networks:
     reverse-proxy:
       external: true
       name: reverse-proxy
   ```
2. Drop a site definition (for example `my-app.caddy`) into `configs/caddy/conf.d/` that reverse proxies to the service container name.
3. Reload Caddy so it reads the new site: `docker compose -f docker/docker-compose.observability.yml restart caddy`.

All `*.localhost` hostnames resolve to `127.0.0.1`, so every project can get its own local domain without touching `/etc/hosts`.

### ⚠️ Node Exporter on Desktop Hosts
- Docker Desktop (macOS/Windows) and some WSL distros don’t support `rslave` bind propagation, so the compose file mounts the host root as read-only without propagation. That keeps the container portable but means new host mount points may not appear instantly in metrics.
- On pure Linux you can opt back into recursive mounts by editing `docker/docker-compose.observability.yml` to add `,rslave` and running `sudo mount --make-shared /` before `docker compose up`.

---

## 🛠 Example Dashboard Table

| Container | Status | Description |
|------------|--------|--------------|
| ws-n8n | 🟢 UP | Workflow automation |
| ws-caddy | 🟢 UP | Reverse proxy + SSL |
| ws-postgres | 🟢 UP | Database |
| ws-watchtower | 🟢 UP | Auto-updates |
| node-exporter | 🟢 UP | Host metrics |
| cadvisor | 🟢 UP | Container metrics |

---

<img width="404" height="427" alt="signin" src="https://github.com/user-attachments/assets/53d82260-4939-439e-ab0a-444a8c80d087" />

<img width="1915" height="906" alt="Screenshot 2025-10-12 181319" src="https://github.com/user-attachments/assets/8c2356d5-11b7-4532-b198-2e34ff8d01ef" />



---

## 🧰 Scripts

| Script | Description |
|---------|--------------|
| `seed_redis.sh` | Populates Redis with test data for monitoring |

---

## 🤝 Contributing

1. Fork this repository  
2. Add new exporters, scripts, or dashboards  
3. Open a PR with a short description of your changes

---

## 📜 License

MIT License — Free to use, modify, and extend.

---

## 💡 Summary

This project serves as a **base observability platform** — ready to be expanded with new exporters, servers, and APIs.  
Whether monitoring one VPS or a multi-node setup, this architecture scales effortlessly.

---
