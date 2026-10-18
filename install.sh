#!/usr/bin/env bash
# cm-socks 一键安装：安装依赖和 GOST 3，创建 SOCKS5 代理，之后输入 cm 进入管理面板。
#
#   bash <(curl -fsSL https://raw.githubusercontent.com/CHIMOOO/cm-socks/main/install.sh)
#
# 免交互示例：V4_MODE=rand V6_MODE=rand ENTRY=v6 bash <(curl -fsSL ...)
set -euo pipefail

REPO_RAW='https://raw.githubusercontent.com/CHIMOOO/cm-socks/main'
CM_BIN=/usr/local/bin/cm

# 整个脚本包在函数里，下载不完整时不会执行半截。
main() {
    [[ $EUID -eq 0 ]] || { echo '请使用 root 执行' >&2; exit 1; }

    if ! command -v curl >/dev/null; then
        if command -v apt-get >/dev/null; then
            apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq curl ca-certificates
        elif command -v dnf >/dev/null; then
            dnf install -y -q curl
        elif command -v yum >/dev/null; then
            yum install -y -q curl
        else
            echo '请先安装 curl' >&2
            exit 1
        fi
    fi

    tmp="$(mktemp)"
    trap 'rm -f -- "$tmp"' EXIT
    curl -fsSL "$REPO_RAW/cm" -o "$tmp"
    bash -n "$tmp"
    install -m 755 "$tmp" "$CM_BIN.new"
    mv -f "$CM_BIN.new" "$CM_BIN"

    "$CM_BIN" install
    "$CM_BIN" create

    printf '\n安装完成，以后输入 cm 即可进入管理面板\n' >&2
}

main "$@"
