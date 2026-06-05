#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/pulumi/pulumi"
TOOL_NAME="pulumi"
TOOL_TEST="pulumi version"

fail() {
  echo -e "asdf-${TOOL_NAME}: $*"
  exit 1
}

curl_opts=(-fsSL)

# NOTE: pulumi is hosted on GitHub releases. A token raises the API rate limit.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
  curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
  git ls-remote --tags --refs "$GH_REPO" |
    grep -o 'refs/tags/v.*' | cut -d/ -f3- |
    sed 's/^v//'
}

list_all_versions() {
  list_github_tags
}

latest_version() {
  # Only consider final releases (drop alpha/beta/rc/dev pre-releases).
  list_all_versions | grep -ivE 'alpha|beta|rc|dev|pre' |
    sort_versions | tail -n1 | xargs echo
}

get_platform() {
  case "$(uname -s)" in
    Darwin) echo "darwin" ;;
    Linux) echo "linux" ;;
    MINGW* | MSYS* | CYGWIN*) echo "windows" ;;
    *) fail "Platform '$(uname -s)' is not supported." ;;
  esac
}

get_architecture() {
  case "$(uname -m)" in
    arm64 | aarch64) echo "arm64" ;; # Apple Silicon and Linux ARM
    x86_64 | amd64) echo "x64" ;;
    *) fail "Architecture '$(uname -m)' is not supported." ;;
  esac
}

release_filename() {
  local version="$1"
  local platform archive_ext
  platform="$(get_platform)"
  archive_ext="tar.gz"
  [ "$platform" = "windows" ] && archive_ext="zip"

  echo "${TOOL_NAME}-v${version}-${platform}-$(get_architecture).${archive_ext}"
}

release_url() {
  local version="$1"
  echo "${GH_REPO}/releases/download/v${version}/$(release_filename "$version")"
}

download_release() {
  local version="$1"
  local filename="$2"
  local url
  url="$(release_url "$version")"

  echo "* Downloading ${TOOL_NAME} release ${version}..."
  curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

install_version() {
  local install_type="$1"
  local version="$2"
  local install_path="${3%/bin}/bin"

  if [ "$install_type" != "version" ]; then
    fail "asdf-${TOOL_NAME} supports release installs only"
  fi

  (
    mkdir -p "$install_path"
    cp -r "${ASDF_DOWNLOAD_PATH}"/* "$install_path"

    # Assert the pulumi executable exists and is runnable.
    local tool_cmd
    tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
    [ "$(get_platform)" = "windows" ] && tool_cmd="${tool_cmd}.exe"
    test -x "${install_path}/${tool_cmd}" || fail "Expected ${install_path}/${tool_cmd} to be executable."

    echo "$TOOL_NAME $version installation was successful!"
  ) || (
    rm -rf "$install_path"
    fail "An error occurred while installing $TOOL_NAME $version."
  )
}
