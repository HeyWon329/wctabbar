# wcliquidglass27 original style safe reset v9

这是回退到之前能打开的 `original_style_tabbar` 稳定结构后的安全重置版。

## 重点

- 基于之前能打开的版本，不基于 v7/v8 闪退分支
- 不加入新的 aggressive hook
- 不加入全局 UIView hook
- 不修改启动流程
- 不强制 headerpad
- 不包含 cleaner
- 只保留 GitHub Actions 编译必要文件
- 配置前缀改为 `wclg27safe_`，避免读取旧版本已经开启的异常配置

## 测试

首次安装后所有功能重新默认关闭。先确认微信能打开，再只开：

1. 总开关
2. 底部 TabBar 原插件风格

确认稳定后再开其他功能。
