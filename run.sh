#!/usr/bin/env bash

set -e

exploit_folder="$1"
ext="$2"

echo "--------------------------------------------"
echo "Currently working on: $exploit_folder"

docker_file="$exploit_folder/dockerfile"

# Auto-detect exploit file
exploit_file=$(find "$exploit_folder" -maxdepth 1 -type f -name "*$ext" | head -n 1)

if [ -z "$exploit_file" ]; then
    echo "No exploit file found with extension: $ext"
    exit 1
fi

exploit_filename=$(basename "$exploit_file")

echo "Exploit File: $exploit_file"
echo "Exploit Filename: $exploit_filename"

case "$ext" in
  .py)
    base_image="python:3.12-slim"
    install_cmd="apt-get update && apt-get install -y strace && rm -rf /var/lib/apt/lists/*"
    run_cmd='[ -f /app/requirements.txt ] && pip install -r /app/requirements.txt; python3 $target'
    ;;

  .js)
    base_image="node:22-bookworm-slim"
    install_cmd="apt-get update && apt-get install -y strace python3 && rm -rf /var/lib/apt/lists/*"
    run_cmd='node $target'
    ;;

  .sh)
    base_image="debian:bookworm-slim"
    install_cmd="apt-get update && apt-get install -y strace python3 bash && rm -rf /var/lib/apt/lists/*"
    run_cmd='bash $target'
    ;;

  .rb)
    base_image="ruby:3.3-slim"
    install_cmd="apt-get update && apt-get install -y strace python3 && rm -rf /var/lib/apt/lists/*"
    run_cmd='ruby $target'
    ;;

  .php)
    base_image="php:8.3-cli"
    install_cmd="apt-get update && apt-get install -y strace python3 && rm -rf /var/lib/apt/lists/*"
    run_cmd='php $target'
    ;;

  .go)
    base_image="golang:1.24-bookworm"
    install_cmd="apt-get update && apt-get install -y strace python3 && rm -rf /var/lib/apt/lists/*"
    run_cmd='go run $target'
    ;;

  .rs)
    base_image="rust:1-bookworm"
    install_cmd="apt-get update && apt-get install -y strace python3 && rm -rf /var/lib/apt/lists/*"
    run_cmd='rustc $target -o /tmp/a.out && /tmp/a.out'
    ;;

  .java)
    base_image="eclipse-temurin:26-jdk"
    install_cmd="apt-get update && apt-get install -y strace python3 && rm -rf /var/lib/apt/lists/*"
    run_cmd='javac $target && classname=$(basename $target .java) && java -XX:UseSVE=0 -cp /app $classname'
    ;;

  .c)
    base_image="gcc:14"
    install_cmd="apt-get update && apt-get install -y strace python3 && rm -rf /var/lib/apt/lists/*"
    run_cmd='gcc $target -o /tmp/a.out && /tmp/a.out'
    ;;

  .cpp)
    base_image="gcc:14"
    install_cmd="apt-get update && apt-get install -y strace python3 && rm -rf /var/lib/apt/lists/*"
    run_cmd='g++ $target -o /tmp/a.out && /tmp/a.out'
    ;;

  *)
    echo "Unsupported extension: $ext"
    exit 1
    ;;
esac

dockerfile_text=$(cat <<EOF
FROM ${base_image}

RUN ${install_cmd}

WORKDIR /app

COPY ./* /app/

CMD ["sh", "-c", "export target=/app/${exploit_filename}; if [ -f /app/requirements.txt ]; then pip install -r /app/requirements.txt; fi; strace -ff -s 4096 -o /tmp/trace.log sh -c '$run_cmd'"]
EOF
)

extract_exploit_syscalls() {
  input_log="$1"
  output_log="$2"

  grep -E 'execve\(|ptrace\(|setuid\(|setgid\(|capset\(|chmod\(|chown\(|mount\(|umount2\(|clone\(|unshare\(|socket\(|connect\(|accept\(|sendto\(|recvfrom\(|open\(|openat\(' "$input_log" \
    | grep -E '(/etc/|/root/|/home/|/proc/|/sys/|/dev/|wget|curl|nc |bash -c|sh -c|python|node|/tmp/pwned|execve\(|ptrace\(|setuid\(|setgid\(|capset\(|mount\(|socket\(|connect\()' \
    > "$output_log" || true
}

printf '%s\n' "$dockerfile_text" > "$docker_file"

echo "Dockerfile created at: $docker_file"

echo "--------------------------------------------"

trace_path_in_container="${TRACE_PATH_IN_CONTAINER:-/tmp/trace.log}"

image_tag=$(printf '%s' "exploit" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9._-' '-')

container_name="${image_tag}-trace-$$"

docker build --no-cache -t "$image_tag" -f "$docker_file" "$exploit_folder"

echo "--------------------------------------------"
echo "Docker Image: $image_tag"
echo "--------------------------------------------"

set +e
docker run --name "$container_name" "$image_tag"
run_status=$?
set -e

echo "--------------------------------------------"
trace_copied=0

if docker cp "$container_name:$trace_path_in_container" "$exploit_folder/trace.log" 2>/dev/null; then
    echo "Trace log copied to $exploit_folder/trace.log"

    trace_copied=1

    extract_exploit_syscalls \
        "$exploit_folder/trace.log" \
        "$exploit_folder/exploit_syscalls.log"

elif docker cp "$container_name:/tmp" "$exploit_folder/trace" 2>/dev/null; then
    echo "Trace directory copied to $exploit_folder/trace"

    trace_copied=1

    find "$exploit_folder/trace" -type f -name "trace.log*" -print0 \
        | xargs -0 cat \
        > "$exploit_folder/trace_combined.log" 2>/dev/null

    extract_exploit_syscalls \
        "$exploit_folder/trace_combined.log" \
        "$exploit_folder/exploit_syscalls.log"

else
    echo "No trace logs found at $trace_path_in_container or /tmp"
fi

if [ "$trace_copied" -eq 1 ]; then
    echo "Filtered exploit syscall log: $exploit_folder/exploit_syscalls.log"
fi

docker rm -f "$container_name" >/dev/null 2>&1 || true

if [ "$run_status" -ne 0 ]; then
    echo "Container exited with non-zero status: $run_status"
fi