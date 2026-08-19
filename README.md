# RuoQi Flutter UI

RuoQi 多项目 Flutter 巨仓（monorepo），基于 Dart 原生 pub workspace 与 [melos](https://melos.invertase.dev) 管理。

## 目录结构

```
apps/
  platform/          # 平台 App（Dart 包名 ruoqi_platform）
  iam_user/          # IAM 用户 App（Dart 包名 ruoqi_iam_user）
packages/
  ruoqi_common/      # 共享包（品牌主题、通用组件、工具）
```

> 说明：`platform` 与 pub.dev 上的 `platform` 包同名，会与 workspace 解析冲突，
> 因此目录保持 `apps/platform`、`apps/iam_user`，Dart 包名使用 `ruoqi_` 前缀。

## 环境准备

需要 Flutter 3.44+（Dart 3.12+）。若 `flutter` / `melos` 不在 PATH 中：

```bash
export PATH="$PATH":"$HOME/opt/flutter/bin":"$HOME/.pub-cache/bin"
melos --version   # 首次使用前：dart pub global activate melos 6.3.3
```

## 常用命令

```bash
# 安装依赖（在仓库根目录执行一次，解析整个 workspace）
flutter pub get

# 分析 / 测试全部包
melos analyze
melos test

# 运行某个 App（需连接设备或模拟器）
melos run run:platform
melos run run:iam_user
```

## 新增项目

```bash
flutter create --org com.ruoqi --platforms android,ios,web apps/<name>
```

随后：

1. 在 `apps/<name>/pubspec.yaml` 中把包名改为 `ruoqi_<name>`，并添加 `resolution: workspace`；
2. 在根 `pubspec.yaml` 的 `workspace:` 列表中加入新目录；
3. 在 `melos.yaml` 中按需添加运行脚本。

共享代码放到 `packages/` 下，各 App 通过 `path` 依赖引用。

## 平台支持

每个 App 默认生成 Android、iOS、Web 三端工程，其他平台可用
`flutter create --platforms=macos,windows,linux .` 按需补充。
