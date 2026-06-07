# proxy-configs

自用的代理客户端配置合集，覆盖 **Surge**、**Shadowrocket** 与 **Mihomo / Clash** 生态。所有内容都以「叠加 / 增强」为原则，与你已有的主配置或订阅安全合并，**不替你做节点与订阅管理**。

聚焦"小而稳"：公开版均不含节点、订阅链接、本机端口、外部控制器、证书材料、本地 iCloud 路径等隐私信息。

## 目录结构

| 目录 | 内容 |
|---|---|
| `surge/` | Surge 可复用干净配置与公开规则集 |
| `shadowrocket/` | Shadowrocket 可复用干净配置 |
| `modules/` | Surge 功能增强模块（`.sgmodule`），独立可开关，通过 `%APPEND%` / `%INSERT%` 与主配置合并 |
| `mihomo/` | Mihomo / Clash 覆写模板（`.yaml`），作为 override 叠加到订阅配置之上 |

## 可复用配置模板

| 客户端 | 配置 URL |
|---|---|
| Surge | `https://fastly.jsdelivr.net/gh/qidewei2004/proxy-configs@main/surge/Surge.clean.conf` |
| Shadowrocket | `https://fastly.jsdelivr.net/gh/qidewei2004/proxy-configs@main/shadowrocket/shadowrocket.conf` |

公开模板使用仓库内规则集：

| 规则集 | 作用 |
|---|---|
| `surge/rules/ai-major.list` | 官方或大规模 AI 服务，避免把普通小站或共享基础设施塞进 AI 策略 |
| `surge/rules/pre-ai-infra.list` | Stripe、Cloudflare Challenge、Google 通用后台等共享基础设施，放在 AI 前匹配 |
| `surge/rules/direct-cn.list` | 高频中国大陆网站和 CDN 直连兜底 |

> 模板不包含任何真实节点或订阅链接。请在客户端内添加自己的节点/订阅后，再使用策略组进行筛选或选择。
> 私有 Emby/Jellyfin 服务器、元数据与字幕规则建议放在本地模块或私有规则集中，不放入公开仓库。

## Surge 模块

| 模块 | 作用 |
|---|---|
| `google-redirect.sgmodule` | Google CN 全套重定向至国际版（搜索 / 地图 / 学术 / 翻译 / 书籍） |
| `redirect-enhance.sgmodule` | Bing 国内版跳国际版、维基百科移动版跳桌面版、知乎/微博/简书外链直跳 |
| `dns-mapping.sgmodule` | 为阿里系 / 腾讯系核心域名指定对应厂商的加密 DNS（DoH） |

### 安装

在 Surge 中：**Modules → 安装新模块 → 从 URL 安装**，填入对应模块的 jsdelivr 地址：

```text
https://fastly.jsdelivr.net/gh/qidewei2004/proxy-configs@main/modules/google-redirect.sgmodule
https://fastly.jsdelivr.net/gh/qidewei2004/proxy-configs@main/modules/redirect-enhance.sgmodule
https://fastly.jsdelivr.net/gh/qidewei2004/proxy-configs@main/modules/dns-mapping.sgmodule
```

> 走 jsdelivr CDN 而非 raw.githubusercontent.com，国内访问更稳定。

#### 设计说明

- **合并而非覆盖**：模块用 `%APPEND%`（追加到列表）/ `%INSERT%`（插入到列表头部）与主配置合并。例如 `google-redirect` 的 MITM hostname 用 `%INSERT%`，只新增 Google 相关主机，不动你已有的 hostname 列表。
- **MITM 自包含**：凡需要解密 HTTPS 才能生效的重写，模块自带对应的 `[MITM] hostname` 声明，开箱即用。
- **可被校验**：本仓库所有 Surge 模块均通过 [surge-doctor](https://github.com/qidewei2004/surge-doctor) 校验（`#!name` 元数据完整、重写源主机均已在 MITM 声明）。

校验任一模块：

```bash
surge-doctor check modules/google-redirect.sgmodule
```

## Mihomo / Clash 覆写

`mihomo/mihomo-override.yaml` 是一份覆写模板：包含 DNS（fake-ip + 分流 nameserver-policy）、sniffer、tun、地区节点筛选锚点、策略组与按场景分流的 `rule-providers` / `rules`。

作为 **override / 覆写规则** 在客户端中叠加到你的订阅配置之上即可使用：

```text
https://fastly.jsdelivr.net/gh/qidewei2004/proxy-configs@main/mihomo/mihomo-override.yaml
```

> 公开版不含节点、订阅链接、本机端口和外部控制器配置，请在客户端侧自行补充。

## License

MIT
