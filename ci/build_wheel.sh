#!/bin/bash
# Copyright (c) 2023-2024, NVIDIA CORPORATION

set -euo pipefail

rapids-logger "Install CUDA Toolkit"
source "$(dirname "$0")/install_latest_cuda_toolkit.sh"

RAPIDS_PY_CUDA_SUFFIX="$(rapids-wheel-ctk-name-gen ${RAPIDS_CUDA_VERSION})"

# This is the version of the suffix with a preceding hyphen. It's used
# everywhere except in the final wheel name.
PACKAGE_CUDA_SUFFIX="-${RAPIDS_PY_CUDA_SUFFIX}"

# Patch project metadata files to include the CUDA version suffix.
sed -i "s/^name = \"pynvjitlink\"/name = \"pynvjitlink${PACKAGE_CUDA_SUFFIX}\"/g" pyproject.toml

rapids-logger "Build wheel"
mkdir -p ./dist
python -m pip wheel . --wheel-dir=./dist -vvv --disable-pip-version-check --no-deps

python -m auditwheel repair -w ./final_dist ./dist/*

rapids-logger "Upload Wheel"
RAPIDS_PY_WHEEL_NAME="pynvjitlink_${RAPIDS_PY_CUDA_SUFFIX}" rapids-upload-wheels-to-s3 ./final_dist
