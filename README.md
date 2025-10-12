
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
├── configs
│   ├── prometheus
│   │   └── prometheus.yml
│   └── thanos
│       └── objstore.yaml
├── docker
│   └── compose.redis.yml
└── scripts
    └── seed_redis.sh
```

---

## 🧱 Core Services

| Service | Description | Port | Credentials / Notes |
|----------|--------------|------|---------------------|
| **Prometheus** | Core metrics collection and scraping | `9090` | Configured via `configs/prometheus/prometheus.yml` |
| **Grafana** | Dashboards and visualizations | `3000` | Default login: `admin / admin` |
| **Redis** | Example data source for metrics | `6379` | No auth by default |
| **Redis Exporter** | Exposes Redis metrics to Prometheus | `9121` | Targets Redis automatically |
| **Node Exporter** | Exposes host (CPU, memory, disk, network) metrics | `9100` | Runs on VPS |
| **cAdvisor** | Monitors Docker containers (CPU, memory, FS, network) | `8085` | Used for container status |
| **Thanos** | Prometheus federation, long-term storage | `10902` | Connects multiple Prometheus nodes |
| **Watchtower** | Auto-updates running Docker images | `8080` | Optional component |

---

## ⚙️ How to Run

### 1️⃣ Start the stack
```bash
cd docker
docker compose -f compose.redis.yml up -d
```

### 2️⃣ Access Dashboards
- Grafana → [http://localhost:3000](http://localhost:3000)
- Prometheus → [http://localhost:9090](http://localhost:9090)
- cAdvisor → [http://localhost:8085](http://localhost:8085)
- Node Exporter → [http://localhost:9100](http://localhost:9100)

---

## 📊 Grafana Overview

### ✅ Default Dashboard: *My Infrastructure*
- Displays container **Status (UP/DOWN)** from cAdvisor.
- Shows host CPU, RAM, and Disk usage via Node Exporter.
- Uses instant queries with color-coded UP/DOWN states.

### 🟢 Example Query: Container Uptime
```promql
(time()
 - max by (name) (container_last_seen{job="cadvisor", instance="68.168.218.84:8085", image!=""})
) < bool 60
```

---

## 🧠 Credentials and Config Locations

| Component | Config File | Notes |
|------------|--------------|-------|
| Prometheus | `configs/prometheus/prometheus.yml` | Targets for exporters |
| Thanos | `configs/thanos/objstore.yaml` | Object storage connection |
| Docker Compose | `docker/compose.redis.yml` | Service orchestration |
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
