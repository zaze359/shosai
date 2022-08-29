# 阅读器项目

最近阅读学习了一些Flutter相关的知识,  不过纸上得来终觉浅，所以准备写一个项目练练手。

目标是一款开源的全平台全能阅读器。

[zaze359/shosai (github.com)](https://github.com/zaze359/shosai)

## 常用脚本记录

```shell
# 查看所有分支
flutter channel
# 切换分支
flutter channel master

# 更新flutter sdk 和依赖包
flutter upgrade
# 仅更新packages
flutter pub upgrade
# 查看需要更新内容
flutter pub outdated

# 查看可用模拟器
flutter emulators
# 启动指定模拟器
flutter emulators --launch apple_ios_simulator
# macos也可使用一下命令打开ios模拟器
open -a Simulator
# 运行flutter项目
flutter run
```

### 更新Json

> 执行失败，删除*.g.dart

```shell
## 项目脚本
./build_json.sh
## flutter指令
flutter pub run build_runner build
```



## 项目功能规划列表

*   [x] 书架
    *   [x] 书籍列表显示
    *   [x] 本地书籍导入
    *   [x] 书源书籍导入
    *   [x] 移除书籍
    *   [x] 加入书籍
    *   [x] 本地书籍文件删除

*   [x] txt文件编码格式

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
*   [x] 菜单页
*   [ ] 字体样式编辑
*   [ ] 阅读背景（夜间模式）
*   [ ] 书源相关
    *   [ ] 在线书源导入
    *   [x] 书源编辑
    *   [x] 书源内搜索
    *   [x] 书籍详情页展示
    *   [x] 章节下载和存储
    *   [x] 章节内容解析
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

### 书源网页内容解析

- 爬取网页内容
- dom解析
- 网页内容特征提取

### 书源规则

> 规则参考了开源阅读的书源规则。

#### 规则分隔符`@`

```dart
a@[[0]]@$text
```

#### 标签选择规则

默认使用`css selector`规则。

标签位置以`[[]]`包裹, 排除使用`[[!]]`。

从`0`开始, `-1`表示倒数第一个，位置依次类推, 以`:`分割。

连续区间使用 `..`连接。

```dart
// 选择index为0和2的a标签
a@[[0:2]]
// 排除index为0和2
a@[[!0:2]]
// 从index=0 开始到末尾
a@[[0 .. -1]]
```

#### 属性选择

以`$`开头表示获取属性

```dart
// 获取a标签包裹的内容
a@[[0]]@$text
// 获取href内容
$href
```

#### 正则相关规则

格式：`###正则表达式##替换内容###`

group获取：`$`表示正则匹配到的group。

```dart
// $1 = group[1]
// $2 = group[2]
a@[[0]]@$href@###.+\D((\d+)\d{3})\D##https://www.xbiquwx.la/files/article/image/$2/$1/$1s.jpg###
```




## 感谢

参考了以下开源项目：

[gedoor/legado: 阅读3.0, 阅读是一款可以自定义来源阅读网络内容的工具，为广大网络文学爱好者提供一种方便、快捷舒适的试读体验。 (github.com)](https://github.com/gedoor/legado)

[ssssssss-team/spider-flow: 新一代爬虫平台，以图形化方式定义爬虫流程，不写代码即可完成爬虫。 (github.com)](https://github.com/ssssssss-team/spider-flow)

