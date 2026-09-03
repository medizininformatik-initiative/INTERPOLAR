#!/usr/bin/env bash
set -euo pipefail

pgformatter_version="${PGFORMATTER_VERSION:-5.10}"
install_prefix="${PGFORMATTER_INSTALL_PREFIX:-/usr/local}"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

curl -fsSL \
  "https://github.com/darold/pgFormatter/archive/refs/tags/v${pgformatter_version}.tar.gz" |
  tar -xz -C "$tmp_dir" --strip-components=1

install -d "${install_prefix}/bin"
install -d "${install_prefix}/bin/lib/pgFormatter"
install -m 0755 "${tmp_dir}/pg_format" "${install_prefix}/bin/pg_format"
install -m 0644 "${tmp_dir}/lib/pgFormatter/"*.pm "${install_prefix}/bin/lib/pgFormatter/"

"${install_prefix}/bin/pg_format" --version
