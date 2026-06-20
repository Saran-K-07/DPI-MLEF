<div align="center">

# Dynamic Payload Instrumentation and Multi-Language Exploit Framework

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/Saran-K-07/DPI-MLEF/blob/main/LICENSE)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Docker](https://img.shields.io/badge/Docker-Required-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Python](https://img.shields.io/badge/Python-Exploits-3776AB?logo=python&logoColor=white)](https://python.org)
[![Java](https://img.shields.io/badge/Java-Exploits-ED8B00?logo=openjdk&logoColor=white)](https://www.java.com)
[![JavaScript](https://img.shields.io/badge/JavaScript-Exploits-F7DF1E?logo=javascript&logoColor=black)](https://developer.mozilla.org/en-US/docs/Web/JavaScript)
[![Go](https://img.shields.io/badge/Go-Exploits-00ADD8?logo=go&logoColor=white)](https://golang.org)

**A research-grade automated framework for dynamic analysis of multi-language exploit techniques via Docker-sandboxed strace instrumentation.**

[Overview](#overview) · [Features](#features) · [Project Structure](#project-structure) · [Getting Started](#getting-started) · [Usage](#usage) · [Exploit Catalogue](#exploit-catalogue) · [Research Context](#research-context) · [Contributing](#contributing) · [License](#license)

</div>

---

## Overview

**DPI-MLEF** is an automated dynamic analysis framework designed for **cybersecurity research**. It executes exploit code across multiple programming languages inside isolated Docker containers, captures kernel-level system call traces via `strace`, and filters them for security-relevant signals — providing structured raw data for downstream machine learning models, intrusion detection systems (IDS), and deep packet inspection (DPI) research.

The tool currently supports exploit techniques written in **Python, Java, JavaScript, and Go**, spanning a wide range of obfuscation and evasion strategies, all driven by a single shell script runner.

> ⚠️ **For Research & Educational Use Only.** All exploit payloads are sandboxed inside isolated Docker containers. No exploit in this repository is intended or designed to cause harm to production systems. See the [Disclaimer](#disclaimer) section.

---

## Features

- **Multi-Language Support** — Run exploits written in Python, Java, JavaScript, Go, Bash, Ruby, PHP, Rust, and C/C++.
- **Fully Automated Docker Sandboxing** — Dynamically generates a language-appropriate Dockerfile, builds the image, and runs the exploit in a clean, isolated environment — no manual setup per exploit.
- **strace-Based System Call Capture** — Instruments the exploit at the OS level via `strace -ff`, capturing fine-grained system call activity across all child processes.
- **Exploit-Specific Syscall Filtering** — Automatically extracts security-sensitive syscalls (`execve`, `ptrace`, `setuid`, `socket`, `connect`, `openat`, etc.) and writes them to a dedicated `exploit_syscalls.log` for downstream ML pipelines.
- **Extensible Catalogue** — Add new exploit techniques by dropping a file into a language folder — no changes to the runner required.
- **Research-Ready Output** — Produces `trace.log` (full trace) and `exploit_syscalls.log` (filtered) for each run, compatible with any ML feature extraction pipeline.

---

## Project Structure

```
DPI-MLEF/
├── run.sh                    # Main orchestration script
├── ascii.art                 # ASCII art banner
├── .gitignore
│
├── python/                   # Python exploit techniques
│   ├── ast bypass/
│   ├── base64/
│   ├── builtins/
│   ├── bytes/
│   ├── code/
│   ├── decorators/
│   ├── getattr restricted/
│   ├── hex string/
│   ├── package_alteration/
│   └── pickle/
│
├── java/                     # Java exploit techniques
│   ├── byte/
│   ├── methodHandles/
│   ├── reflection/
│   └── serialization/
│
├── js/                       # JavaScript exploit techniques
│   ├── function/
│   ├── getter/
│   ├── microtask/
│   ├── monkey/
│   ├── prototype pollution/
│   ├── proxy/
│   ├── setInterval/
│   ├── setTimeout/
│   └── setter/
│
└── go/                       # Go exploit techniques
    ├── CGO/
    ├── goroutine/
    ├── plugin/
    ├── reflection/
    ├── tmpl/
    ├── unmarshalJSON/
    └── wasm/
```

Each exploit folder contains:
- `exploit.<ext>` — The exploit source file
- `dockerfile` — Auto-generated at runtime
- `trace.log` — Full strace output
- `exploit_syscalls.log` — Filtered suspicious syscalls

---

## Getting Started

### Prerequisites

| Requirement | Notes |
|---|---|
| Linux (Ubuntu recommended) | Or any Ubuntu-based distro; a VM is fine |
| [Docker](https://docs.docker.com/engine/install/) | Must be installed and running |
| `bash` | v4.0+ |
| `strace` | Installed automatically inside Docker — not required on the host |

### Installation

Clone the repository to your machine or VM:

```bash
git clone https://github.com/Saran-K-07/DPI-MLEF.git
cd DPI-MLEF
```

Make the runner executable:

```bash
chmod +x run.sh
```

That's it. No additional dependencies are needed on the host — Docker handles everything else.

---

## Usage

### Basic Syntax

```bash
bash ./run.sh <path/to/exploit/folder> <.extension>
```

| Argument | Description | Example |
|---|---|---|
| `<exploit_folder>` | Path to the folder containing the exploit file | `./python/bytes` |
| `<.extension>` | File extension of the exploit | `.py`, `.js`, `.java`, `.go` |

### Examples

**Run a Python exploit:**
```bash
bash ./run.sh ./python/bytes .py
```

**Run a JavaScript exploit:**
```bash
bash ./run.sh ./js/proxy .js
```

**Run a Java exploit:**
```bash
bash ./run.sh ./java/reflection .java
```

**Run a Go exploit:**
```bash
bash ./run.sh ./go/goroutine .go
```

### Output Files

After each run, two files are written to the exploit folder:

| File | Description |
|---|---|
| `trace.log` | Complete `strace` output — all syscalls made by the exploit and its children |
| `exploit_syscalls.log` | Filtered subset of `trace.log` containing only security-relevant syscalls |

The filtered syscalls include calls to: `execve`, `ptrace`, `setuid`, `setgid`, `capset`, `chmod`, `chown`, `mount`, `clone`, `unshare`, `socket`, `connect`, `accept`, `sendto`, `recvfrom`, `open`, `openat`.

### How It Works

```
run.sh
  │
  ├─ 1. Detects exploit file by extension
  ├─ 2. Selects Docker base image for that language
  ├─ 3. Generates Dockerfile (strace + language runtime)
  ├─ 4. Builds Docker image (--no-cache)
  ├─ 5. Runs container with the exploit under strace -ff
  ├─ 6. Copies /tmp/trace.log from the container
  ├─ 7. Filters for exploit-relevant syscalls
  └─ 8. Writes exploit_syscalls.log + cleans up container
```

---

## Exploit Catalogue

All exploits target a canonical proof-of-concept action: `touch /tmp/pwned`. This is deliberately benign — it demonstrates code execution without causing harm, and produces a detectable filesystem syscall pattern.

### Python

| Technique | Description |
|---|---|
| `ast bypass` | Bypass AST-level static analysis via code object manipulation |
| `base64` | Obfuscate commands using Base64 encoding with subclass traversal |
| `builtins` | Abuse Python's `__subclasses__()` chain to access `os.system` |
| `bytes` | Encode the payload as a byte array and pass to `eval()` |
| `code` | Inject raw CPython bytecode via `types.CodeType` and `exec()` |
| `decorators` | Exploit `__init_subclass__` hooks to trigger code on class definition |
| `getattr restricted` | Use `getattr` chains to reach restricted built-ins |
| `hex string` | Encode commands as hex strings to evade string-based detection |
| `package_alteration` | Overwrite a stdlib module via `sys.modules` manipulation |
| `pickle` | Arbitrary code execution via `__reduce__` in a pickled object |

### Java

| Technique | Description |
|---|---|
| `byte` | Load a Base64-encoded class at runtime via `MethodHandles.defineHiddenClass` |
| `methodHandles` | Deserialize a malicious object using `MethodHandles` lookup |
| `reflection` | Trigger code execution via Java deserialization with `ObjectInputStream` |
| `serialization` | Classic `Serializable` gadget chain via `readObject()` |

### JavaScript (Node.js)

| Technique | Description |
|---|---|
| `function` | Abuse `[].filter.constructor` to access the `Function` constructor |
| `getter` | Hijack a property getter to execute code on property access |
| `microtask` | Smuggle execution through the Promise microtask queue |
| `monkey` | Monkey-patch a trusted built-in (`JSON.parse`) with malicious code |
| `prototype pollution` | Pollute `Object.prototype` to alter application behaviour |
| `proxy` | Intercept method calls via ES6 `Proxy` traps |
| `setInterval` | Delay and hide execution using timer-based scheduling |
| `setTimeout` | Execute a payload asynchronously after a timeout |
| `setter` | Hijack a property setter to execute code on property assignment |

### Go

| Technique | Description |
|---|---|
| `CGO` | Call C's `system()` directly via CGo's foreign function interface |
| `goroutine` | Use a goroutine + channel to dispatch arbitrary shell commands |
| `plugin` | Load a malicious shared object (`.so`) via Go's `plugin` package |
| `reflection` | Use `reflect.Value.MethodByName` to invoke arbitrary methods by name |
| `tmpl` | Inject `os/exec` into Go's `html/template` via a custom `FuncMap` |
| `unmarshalJSON` | Embed a command execution gadget inside a custom `UnmarshalJSON` |
| `wasm` | Export a host `exec` function to a WebAssembly module via wazero |

---

## Supported Languages

The runner supports the following file extensions out of the box:

| Extension | Runtime | Base Image |
|---|---|---|
| `.py` | Python 3.12 | `python:3.12-slim` |
| `.js` | Node.js 22 | `node:22-bookworm-slim` |
| `.sh` | Bash | `debian:bookworm-slim` |
| `.rb` | Ruby 3.3 | `ruby:3.3-slim` |
| `.php` | PHP 8.3 | `php:8.3-cli` |
| `.go` | Go 1.26 | `golang:1.26.3-bookworm` |
| `.rs` | Rust 1 | `rust:1-bookworm` |
| `.java` | Java 26 (Temurin JDK) | `eclipse-temurin:26-jdk` |
| `.c` | GCC 14 | `gcc:14` |
| `.cpp` | GCC 10 | `gcc:10.3` |

---

## Adding New Exploits

1. Create a new folder under the relevant language directory, e.g. `python/my_technique/`
2. Add your exploit file, e.g. `exploit.py`
3. Run it with `bash ./run.sh ./python/my_technique .py`

No modifications to `run.sh` are needed.

For languages already listed in [Supported Languages](#supported-languages), the runner picks up the correct image automatically.

---

## Research Context

This framework was developed during a research internship at the **HPRCSE Laboratory**, [IIITD&M Kancheepuram](https://www.iiitdm.ac.in/), Chennai, India.

| Field | Details |
|---|---|
| **Institution** | IIITD&M Kancheepuram, Chennai |
| **Laboratory** | HPRCSE Laboratory |
| **Domain** | Cybersecurity — Dynamic Analysis |
| **Duration** | 15 May 2026 – 29 May 2026 |
| **Supervisor** | [Mr. Mohit Bhasme](https://www.linkedin.com/in/mohit-bhasme-8263891b1/) |
| **In-Charge** | [Mr. Noor Mahammad Sk](https://www.linkedin.com/in/noor-mahammad-sk-494a9211/) |

The primary research goal was to generate labelled dynamic behavioural traces (via strace) from a diverse set of exploit techniques across multiple programming languages, to serve as training data for machine learning-based exploit classification and anomaly detection systems.

---

## Disclaimer

> **This repository is intended strictly for academic research, cybersecurity education, and authorised security testing.**
>
> All exploit code executes inside isolated Docker containers on a local machine. The canonical payload (`touch /tmp/pwned`) is a harmless proof-of-concept chosen specifically because it produces a detectable syscall pattern without causing damage.
>
> **Do not use any code from this repository against systems you do not own or have explicit written permission to test.** Unauthorised use of these techniques may violate applicable laws including, but not limited to, the Computer Fraud and Abuse Act (CFAA), the Computer Misuse Act (CMA), or equivalent legislation in your jurisdiction.
>
> The author and contributors bear no responsibility for misuse.

---

## Contributing

Contributions are welcome! If you have a new exploit technique, a language runtime addition, or improvements to the filtering logic, feel free to open a pull request.

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/my-technique`
3. Add your exploit under the appropriate language folder
4. Test it with `run.sh`
5. Submit a pull request with a brief description of the technique

Please ensure any new exploit uses the canonical `touch /tmp/pwned` payload (or a similarly harmless equivalent) to maintain consistency across the dataset.

---

## License

This project is licensed under the **MIT License**.

```
MIT License

Copyright (c) 2026 Saran K

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

See [LICENSE](LICENSE) for the full text.

---

## Author

**Saran K** · [sarankanakavel.me](https://sarankanakavel.me)

---

<div align="center">
<sub>Built for Cybersecurity Research at HPRCSE Lab, IIITD&M Kancheepuram</sub>
</div>
