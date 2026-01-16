# observability-stack-iac

A working, end-to-end example of how I run infrastructure in a homelab: **Ansible as the source of truth**, Docker Compose for durable services, and an optional local Kubernetes sandbox (KIND) for practicing the same operational habits in a cluster-shaped environment.

It’s intentionally opinionated:

- **IaC-first**: playbooks render config, create persistent directories, and drive service lifecycle.
- **Boring reliability**: explicit bind addresses, repeatable paths, idempotent tasks.
- **Real persistence**: containers are disposable, data directories are not.
- **Multi-distro mindset**: Ubuntu and RHEL-family targets are first-class.

If you’re curious what I can build and how I like to operate, this is a pretty representative slice of it.

## What this repo builds

### Monitoring stack (Docker Compose)

On a single “monitoring host”, this repo provisions a small-but-serious stack:

- **Prometheus** (metrics TSDB, scrape + rule evaluation)
- **Alertmanager** (routing + dedup + silences)
- **Grafana** (dashboards + provisioning by file)
- **Node Exporter** targets (Linux host metrics), managed via Ansible

Persistent state lives on the host under a configurable data root (see `monitoring_data_root`).

### Optional Kubernetes sandbox (KIND)

KIND is there for Kubernetes fluency work: contexts, kubeconfig handling, and a repeatable way to stand up a local cluster without rewriting your whole lab around it.

I treat it like a lab tool, not production. The point is to practice the same habits: declarative config, repeatable setup, and clean teardown.

## Topology and host roles

This repo uses generic hostnames and documentation IPs. Replace them with your own.

Typical layout:

- `monitoring1` (the monitoring host)
  - OS: Ubuntu 24.04 (recommended), but any modern Linux that runs Docker Engine + Compose plugin works
  - Runs: Prometheus + Alertmanager + Grafana via Docker Compose
  - Also a good place to run KIND if you want a single “lab box”

- `node1`, `node2`, ... (monitored targets)
  - OS: Ubuntu or RHEL-family (Rocky, Alma, RHEL, etc.)
  - Runs: Node Exporter as a service

The “monitoring host” is designed to be LAN-only. Services bind to a specific address (not `0.0.0.0`) so you control exposure.

## Repo layout

- `inventory/hosts.ini`
  - Your hostnames, IPs, and `ansible_user` placeholder
- `inventory/group_vars/all.yml`
  - Global knobs like bind address, project dirs, and persistence paths
- `playbooks/monitoring-stack.yml`
  - Renders Compose, creates directories, and runs `docker compose up -d`
- `playbooks/node_exporter.yml` / `playbooks/exporters.yml`
  - Installs and configures Node Exporter on Linux targets (service-managed)
- `playbooks/kind-cluster.yml`
  - Creates a local KIND cluster and writes a dedicated kubeconfig
- `playbooks/templates/`
  - Compose + Prometheus + Alertmanager + Grafana provisioning templates
- `site.yml`
  - Convenience entrypoint that ties the above together

## Key configuration knobs

These are the variables you’ll touch most often:

- `monitoring_bind_address` (example: `192.0.2.10`)
  - The explicit LAN address to bind services to
- `monitoring_project_dir` (example: `/opt/monitoring-stack`)
  - Where the rendered `docker-compose.yml` lands
- `monitoring_data_root` (example: `/srv/monitoring`)
  - Root of persistent data directories

The philosophy is simple: configs are deterministic, and persistent state has a clear home.

## Prerequisites

### Controller (where you run Ansible)

- Ansible 2.16.x (or close)
- SSH access to the target hosts
- Sudo on the target hosts
- Any collections in `requirements.yml` installed, for example:

```bash
ansible-galaxy collection install -r requirements.yml
```

### Monitoring host (Docker target)

- Docker Engine installed
- Docker Compose plugin available as `docker compose`
- Outbound network to pull images (`prom/*`, `grafana/*`, etc.)

### Exporter targets

- Systemd-based Linux (Ubuntu or RHEL-family are the primary paths in this repo)

### KIND (optional)

- `kind` binary
- `kubectl` binary
- Enough RAM/CPU to run a small local cluster

## Quickstart

1) Copy the example inventory placeholders into your real values:

- Edit `inventory/hosts.ini` to point to your hosts
- Edit `inventory/group_vars/all.yml` to set the bind address and paths

2) Install required Ansible collections:

```bash
ansible-galaxy collection install -r requirements.yml
```

3) Deploy the monitoring stack:

```bash
ansible-playbook -i inventory/hosts.ini playbooks/monitoring-stack.yml -K
```

4) Deploy Node Exporter to targets:

```bash
ansible-playbook -i inventory/hosts.ini playbooks/exporters.yml -K
```

5) (Optional) Create a local KIND cluster:

```bash
ansible-playbook -i inventory/hosts.ini playbooks/kind-cluster.yml
```

## Verification

Once the stack is up, you should be able to hit (adjust for your bind address):

- Prometheus: `http://<monitoring_bind_address>:9090/`
- Alertmanager: `http://<monitoring_bind_address>:9093/`
- Grafana: `http://<monitoring_bind_address>:3000/`

Basic health checks:

```bash
curl -fsS http://<monitoring_bind_address>:9090/-/ready
curl -fsS http://<monitoring_bind_address>:9093/-/ready
```

Prometheus targets should show up in:

- `http://<monitoring_bind_address>:9090/targets`

## What this demonstrates (in plain terms)

If you’re skimming this repo as a hiring manager or another engineer, the signal I’m trying to send is:

- I build things that are **repeatable** and **auditable**
- I care about **operational hygiene** (bind addresses, persistence layout, idempotence)
- I’m comfortable moving between Linux distributions, because the work is the same work:
  packages, services, users/permissions, network binding, and the boring details that make uptime real
- I write automation the way I want to inherit it:
  explicit paths, clear variables, and predictable outcomes

## Safety and security notes

- This is meant for a private network. Keep it behind a firewall.
- Bind to a specific LAN address (don’t publish on `0.0.0.0` unless you mean it).
- If you expose Grafana outside your LAN, put it behind an auth layer and TLS.

## Troubleshooting

- Validate connectivity and privilege escalation:

```bash
ansible -i inventory/hosts.ini all -m ping
ansible -i inventory/hosts.ini all -b -m command -a 'id -u'
```

- If Docker tasks fail on a host, confirm Docker is installed and `docker compose version` works.
- If Prometheus has no data, check `Targets` and confirm Node Exporter ports are reachable.

## License

GPLv3. See `LICENSE`.
