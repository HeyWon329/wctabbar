# wcliquidglass27 original modules style v7

只包含 GitHub Actions 编译 `wcliquidglass27.dylib` 的必要文件。

## 内容

- `.github/workflows/build.yml`
- `wcliquidglass27_project_v5/`
- `README.md`

## 这版重点

按原插件风格继续重写这些模块，并保留独立开关：

1. 底部 TabBar 原插件风格稳定版
2. 聊天标题胶囊
3. 聊天输入栏玻璃
4. 长按菜单玻璃
5. 搜索框 / 主页搜索按钮 / 底部搜索按钮
6. 聊天气泡/卡片玻璃

## 实现风格

- 系统 hook 优先，不硬 hook 一堆微信私有类
- 通过 className / view 尺寸 / 屏幕位置过滤真实控件
- 使用独立 glass host，不移动原控件
- 默认所有功能关闭
- 每个模块独立开关，方便逐个排查
- 不包含 cleaner
- 不强制 headerpad
