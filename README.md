# bilibili.sh

这是一个 Bash 实现的 bilibili 播放器，支持 macOS 和 linux，比网页占用更少的资源。

视频地址解析参考了 [BiliDan](https://github.com/m13253/BiliDan)

## 截图

![screenshot from 2017-05-18 16-40-17](https://cloud.githubusercontent.com/assets/1709072/26193986/753e5db8-3be9-11e7-8c21-3041e7e4a537.png)
![screenshot from 2017-05-18 16-43-28](https://cloud.githubusercontent.com/assets/1709072/26193992/77d03cd6-3be9-11e7-8955-46927eeea760.png)


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
