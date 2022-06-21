# 阅读器项目

最近阅读学习了一些Flutter相关的知识,  不过纸上得来终觉浅，所以准备写一个项目练练手。

目标是一款开源的全平台全能阅读器。

[zaze359/shosai (github.com)](https://github.com/zaze359/shosai)

## 项目功能规划列表

*   [x] 书架列表
*   [x] 本地书籍导入
*   [ ] txt文件编码格式

    *   [x] utf-8

    *   [x] utf-16le

    *   [x] utf-16be

    *   [x] utf-32le

    *   [x] utf-32be

    *   [x] gb2312
*   [x] txt文本解析

    *   [x] 目录章节匹配
    *   [x] 文本宽高测量
    *   [x] 章节分行解析
    *   [x] 章节按行分页
*   [ ] 内容展示

    *   [x] 阅读内容展示
    *   [ ] prev、next页预加载
*   [x] 章节目录页
*   [ ] 翻页
    *   [x] 区块划分和事件响应
    *   [ ] 滑动翻页
    *   [x] 左右点击翻页
    *   [ ] 翻页动画

*   [ ] 菜单页
*   [ ] 字体样式编辑
*   [ ] 阅读背景（夜间模式）
*   [ ] 在线书源导入
*   [ ] 在线书源搜索
*   [ ] 阅读历史
*   [ ] epub支持
*   [ ] pdf支持
*   [ ] 漫画支持
*   [ ] 图片
*   [ ] 压缩包
*   [ ] 文件分享
*   [ ] 点对点分享
*   [ ] 微信分享
*   [ ] QQ分享
*   [ ] wifi导入
*   [ ] 文本导出
*   [ ] 有声阅读
*   [ ] 云端同步
*   [ ] 书源编辑器

## Flutter相关知识点

### 基本组件的掌握

### 项目权限申请

- permission_handler

### 文件选择器

- file_picker

### 数据持久化

- sqlite数据库
- 文件读写

### 数据状态共享

- Provider

### 主题配置

## 开发期间的梳理记录

### 书籍解析

- 解析书籍 存储章节信息(标题、start、end)。
- 解析章节，拆分成书页。(根据)

1. 读取文件流，一边读取一边匹配换行符，记录换行符的位置``blankIndex``, 在未获取到第2个blankIndex时，需要将读取到字节流暂存。

2. 读取到新的blankIndex时，将2个blankIndex间的字节内容组装成。并解码转成字符串``line``。

3. 对``line``进行章节标题对正则匹配。若匹配则将blankIndex作为上一章节的结束点，新章节的开始点。

4. 若未匹配成功则继续``第一步``，知道读完数据。更新最后一章的结束点为，文件的大小。

### 阅读页面

1. 测量当前显示界面的尺寸width和height。
2. 将章节数据根据宽度分行。
3. 将行数据根据高度分页。
4. 留白部分的处理。




## 感谢

项目参考了 [开源阅读](https://github.com/gedoor/legado)

