# Remote Target Configuration

1. Copy `vps.sample.yml` to `vps.yml` in this directory.
2. Replace `your-vps-ip` with the actual IP or hostname for each exporter.
3. Reload Prometheus (e.g., `curl -X POST http://prometheus.localhost/-/reload`).

`vps.yml` is gitignored so your real infrastructure details never leave the local machine.
