#!/usr/bin/env bash

set -euo pipefail

case $(uname) in
  Darwin)
    DEVICE='macos'
    ;;
  *)
    echo "Did not implement uname=$(uname)!"
    exit 1
    ;;
esac

nvim_path=$(realpath ../third_party/neovim/build/bin/nvim)

exec flutter run -d "$DEVICE" "--dart-define=nvim_path=$nvim_path"
