#!/usr/bin/env bash
set -euo pipefail

commit_sha="${1:-${GITHUB_SHA:-local}}"
output_dir="${2:-artifacts}"
artifact_name="app-${commit_sha}.tar.gz"
build_dir="$(mktemp -d)"

cleanup() {
  rm -rf "${build_dir}"
}
trap cleanup EXIT

mkdir -p "${output_dir}" "${build_dir}/wheels"

python -m pip install --upgrade pip
python -m pip install -r requirements.txt
python manage.py collectstatic --noinput
python -m pip freeze > "${build_dir}/requirements.txt"
python -m pip wheel --wheel-dir "${build_dir}/wheels" -r "${build_dir}/requirements.txt"

cp -R books book_shop templates manage.py users.json book.json staticfiles "${build_dir}/"

tar -czf "${output_dir}/${artifact_name}" -C "${build_dir}" .
echo "${output_dir}/${artifact_name}"
