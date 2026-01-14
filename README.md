# Prometheus Monitoring Stack (Ansible + Docker Compose)

## Overview

This repository provides a **working, end-to-end example** of deploying a small but complete monitoring stack using:

- **Ansible** for host configuration and orchestration
- **Docker Compose** for service lifecycle management
- **Prometheus** for metrics collection and storage
- **Grafana** for visualization
- **Alertmanager** for alert routing
- **Node Exporter** and **cAdvisor** for host and container metrics

---

## Architecture Summary

- Services are deployed via Docker Compose on a single host
- Persistent data is stored on the host filesystem
- All configuration is rendered and managed by Ansible
- Service ports can be bound explicitly to a chosen interface
- No secrets or environment-specific values are committed

---

## Requirements

### Control Node
- Ansible **2.16+**
- Python **3.10+**
- SSH access to the target host

### Target Host
- Linux (tested on Ubuntu 24.04)
- Docker Engine
- Docker Compose v2 (plugin)

---

## Ansible Collections

This project depends on the `community.general` collection.

Install it before running the playbooks:

```bash
ansible-galaxy collection install community.general
```

---

## Inventory Layout

Example inventory structure:

```
inventory/
├── hosts.ini
└── group_vars/
    └── all.yml
```

Key variables are defined in `group_vars/all.yml`, including:
- Bind address for exposed services
- Host ports for each service
- Data directories

No real hostnames, IP addresses, or credentials are included in this repository.

---

## Usage

Run the full deployment:

```bash
ansible-playbook -i inventory/hosts.ini site.yml -K
```

This will:
1. Prepare the host
2. Render configuration files
3. Deploy the monitoring stack
4. Start all services via Docker Compose

---

## Exposed Services

Typical components exposed by this stack:

- Prometheus
- Grafana
- Alertmanager
- Node Exporter
- cAdvisor

Exact addresses and ports are controlled via inventory variables.

---

## Design Notes

- Uses explicit configuration files rather than auto-discovery
- Keeps Docker Compose files generated, not hand-edited
- Separates orchestration (Ansible) from runtime (Docker)

---

## License

GPLv3. See `LICENSE` for details.
