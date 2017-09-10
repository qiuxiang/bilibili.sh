# bilibili.sh

这是一个 Bash 实现的 bilibili 播放器，支持 macOS 和 linux，比网页占用更少的资源。

视频地址解析参考了 [BiliDan](https://github.com/m13253/BiliDan)

## 截图

<img src="https://user-images.githubusercontent.com/1709072/30249439-4d4dd5a0-966f-11e7-9dcf-c46c1e8758e4.png" width=400/>

![screenshot from 2017-09-10 21-29-27](https://user-images.githubusercontent.com/1709072/30249454-9a01f2b4-966f-11e7-9935-e57437727afd.png)


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
