# Contributing to DPI-MLEF

Contributions are welcome — new exploit techniques, new language runtimes,
or improvements to the runner script.

## Adding a New Exploit Technique

1. Fork the repository and create a branch:
```bash
   git checkout -b feat/my-technique
```

2. Create a folder under the appropriate language directory using **hyphens, not spaces**:
```
python/my-technique/
└── exploit.py
```

3. Use the canonical proof-of-concept payload — `touch /tmp/pwned` — or any
   equivalently harmless action that produces detectable syscalls.

4. Add a single-line comment at the top of the exploit explaining the technique:
```python
   # Technique: abuse __init_subclass__ hook to execute code on class definition
```

5. Test with the runner and verify output is generated:
```bash
   bash ./run.sh ./python/my-technique .py
   # Check that exploit_syscalls.log is produced
```

6. Submit a pull request with a brief description of the technique and what
   evasion or obfuscation strategy it demonstrates.

## Adding a New Language Runtime

1. Add a `case` block in `run.sh` with:
   - The file extension
   - An appropriate Docker base image (slim/minimal preferred)
   - An install command that includes `strace`
   - The correct run command for that language

2. Add corresponding gitignore patterns to `.gitignore`.

3. Include at least one working sample exploit.

## Standards

- Folder names must use hyphens (`ast-bypass`), not spaces (`ast bypass`)
- Every exploit file must be named `exploit.<ext>`
- All payloads must be safe proof-of-concept actions — no destructive commands
- Exploits must run to completion inside Docker without requiring interactive input

## Commit Style

Use conventional commits:
```
feat: add python/unicode-escape exploit
fix: handle missing trace log gracefully
refactor: rename spaced folder names to hyphens
docs: update README with new technique
chore: update .gitignore patterns
```
## Questions

Open a [Discussion](https://github.com/Saran-K-07/DPI-MLEF/discussions) —
no question is too small.
