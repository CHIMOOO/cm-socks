# cm-socks

在新服务器上用一条指令装好 [GOST 3](https://github.com/go-gost/gost)，创建 SOCKS5 代理：服务器的公网 IPv4 一条，每个公网 IPv6 各一条。装好之后输入 `cm` 进入管理面板。

## 一键安装

用 root 执行：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/CHIMOOO/cm-socks/main/install.sh)
```

安装脚本会依次：

1. 安装依赖（curl、python3、iproute2）
2. 下载最新版 GOST 3 到 `/usr/local/bin/gost`
3. 询问代理的分配方式（直接回车就是默认值）
4. 生成配置，注册并启动 `gost` 系统服务
5. 逐条通过代理访问外网，核对出口 IP，只打印验证通过的 `socks5://账号:密码@地址:端口`

支持 Debian、Ubuntu、CentOS、Rocky、AlmaLinux 等使用 systemd 的发行版，CPU 架构支持 amd64、arm64、armv7、386。

## 管理面板

```text
========================================
   cm-socks  ·  GOST SOCKS5 管理面板
========================================
   GOST：v3.3.0    服务：运行中    代理：3 条
----------------------------------------
   1) 安装 / 更新 GOST
   2) 创建 / 重建 SOCKS5 代理
   3) 查看代理列表
   4) 修改统一账号 / 端口
   5) 服务状态
   6) 重启服务
   7) 停止服务
   8) 查看日志
   9) 更新 cm 面板
  10) 卸载
   0) 退出
```

每一项也能直接当子命令用：`cm install`、`cm create`、`cm list`、`cm account`、`cm status`、`cm restart`、`cm stop`、`cm log`、`cm update`、`cm uninstall`。运行 `cm help` 可以看到全部用法。

## 分配方式

| 代理 | 选项 | 说明 |
| --- | --- | --- |
| IPv4 | 统一（默认） | 使用统一账号和统一端口 |
| | 随机 | 随机端口和随机账号密码 |
| | 沿用 | 已有代理时，保留原来的端口和账号密码 |
| IPv6 | 顺序（默认） | 从 IPv6 起始端口开始递增，账号密码与统一账号相同 |
| | 随机 | 每个 IPv6 使用随机端口和随机账号密码 |
| IPv6 连接地址 | IPv6（默认） | 用每条代理自己的 IPv6 连接，进出同一个 IPv6，客户端需要有 IPv6 网络 |
| | IPv4 | 统一用服务器公网 IPv4 连接，出口仍是各自的 IPv6 |

仓库里不包含任何账号、密码或端口。统一账号会在第一次创建时随机生成（账号、20 位密码、20000–60000 之间的端口），只保存在服务器本机的 `/etc/gost-auto/cm.conf`，之后可以用 `cm account` 修改。如果服务器上已经有旧版脚本生成的配置，会直接沿用原来的 IPv4 端口和账号。

## 免交互安装

在一键安装指令前加环境变量，就不会再询问。

用自己的账号密码（只写在你执行的命令里，不会上传到仓库）：

```bash
CM_USER=myname CM_PASS=mypassword CM_PORT=30000 bash <(curl -fsSL https://raw.githubusercontent.com/CHIMOOO/cm-socks/main/install.sh)
```

全部随机：

```bash
V4_MODE=rand V6_MODE=rand ENTRY=v6 bash <(curl -fsSL https://raw.githubusercontent.com/CHIMOOO/cm-socks/main/install.sh)
```

| 变量 | 取值 | 作用 |
| --- | --- | --- |
| `V4_MODE` | `keep` / `fixed` / `rand` | IPv4：沿用 / 统一 / 随机 |
| `V6_MODE` | `seq` / `rand` | IPv6：顺序 / 随机 |
| `ENTRY` | `v6` / `v4` | IPv6 代理的连接地址 |
| `CM_USER` `CM_PASS` | 字符串 | 统一账号和密码 |
| `CM_PORT` `CM_V6_PORT` | 端口号 | IPv4 端口、IPv6 起始端口（不填就用 IPv4 端口 +20） |
| `GOST_VERSION` | 如 `v3.3.0` | 安装指定版本的 GOST，不填就装最新版 |

这些变量同样适用于 `cm create`，例如 `V4_MODE=rand cm create`。

## 文件位置

| 路径 | 内容 |
| --- | --- |
| `/usr/local/bin/cm` | 管理面板 |
| `/usr/local/bin/gost` | GOST 程序 |
| `/etc/gost-auto/config.json` | GOST 配置（上一版备份为 `config.json.bak`） |
| `/etc/gost-auto/cm.conf` | 统一账号和端口 |
| `/etc/gost-auto/proxies.txt` | 验证通过的代理列表 |
| `/etc/systemd/system/gost.service` | 系统服务 |

## 注意

- 云服务器要在安全组或防火墙里放行代理端口（TCP），否则外部连不上。本机验证通过只说明代理本身可用。
- 代理列表里有明文密码，`/etc/gost-auto` 下的文件权限都是 600，只有 root 能读。
