# bilibili.sh

这是一个 Bash 实现的 bilibili 播放器，兼容 macOS 和 linux，比网页占用更少的资源。

视频地址解析参考了 [BiliDan](https://github.com/m13253/BiliDan)

## 截图

![screenshot from 2017-05-12 22-24-54](https://cloud.githubusercontent.com/assets/1709072/26002491/63e20cbc-3762-11e7-97e8-476b9c9b07cf.png)

![screenshot from 2017-05-12 22-26-34](https://cloud.githubusercontent.com/assets/1709072/26002494/66e9114e-3762-11e7-9070-be161b99317d.png)

## 用法

根据动漫名称搜索
```bash
$ bilibili.sh "夏目友人账"
```

或直接用网页链接作为参数
```bash
$ bilibili.sh https://bangumi.bilibili.com/anime/5788/play#101769
```

## 依赖
- mpv (视频播放器)
- jq (JSON 解析器)
- danmaku2ass.py (Bilibili 弹幕转 ASS 字幕)
- xmllint (HTML parser)
