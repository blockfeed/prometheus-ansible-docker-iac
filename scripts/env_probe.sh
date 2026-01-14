#!/usr/bin/env bash
set -euo pipefail

echo "== System =="
uname -a || true
echo
echo "== OS =="
cat /etc/os-release || true
echo
echo "== User =="
id || true
echo
echo "== Ansible (if present) =="
command -v ansible >/dev/null 2>&1 && ansible --version || echo "ansible: not found"
echo
echo "== Docker (if present) =="
command -v docker >/dev/null 2>&1 && docker --version || echo "docker: not found"
command -v docker >/dev/null 2>&1 && sudo docker info >/dev/null 2>&1 && echo "docker info: ok (via sudo)" || echo "docker info: not available (need sudo or docker not installed)"
echo
echo "== Compose (plugin) (if present) =="
command -v docker >/dev/null 2>&1 && sudo docker compose version || echo "docker compose: not found"
