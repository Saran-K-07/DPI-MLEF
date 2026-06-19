# Security Policy

## Supported Versions

| Version | Supported |
|---|---|
| 1.x | ✅ |

## Sandbox Notice

All exploit code in this repository runs **exclusively inside isolated Docker containers**.
The canonical payload (`touch /tmp/pwned`) is a harmless proof-of-concept that produces
detectable syscall patterns without causing damage to the host system.

## Reporting a Vulnerability

If you find a vulnerability in `run.sh` or the Docker sandboxing that could allow
container escape or host compromise, please report it responsibly.

**Do not open a public GitHub issue for security vulnerabilities.**

Contact me directly through
[contact@sarankanakavel.me](mailto:contact@sarankanakavel.me).

Please include:
- A description of the vulnerability
- Steps to reproduce
- Potential impact

I aim to respond within 48 hours.

## Intended Use

This tool is designed for academic research and cybersecurity education only.
See the [Disclaimer](README.md#disclaimer) in the README for full details.
