# bilibili.sh
Bash 实现的 bilibili 播放器，视频地址解析参考了 [BiliDan](https://github.com/m13253/BiliDan)

![screenshot](https://cloud.githubusercontent.com/assets/1709072/25817154/0d264552-3459-11e7-9ae2-b28f80ed967e.png)

## 用法
```bash
$ ./bilibili.sh https://bangumi.bilibili.com/anime/5788/play#101769
```

## 依赖
- mpv (视频播放器)
- jq (JSON 解析器)
- danmaku2ass.py (Bilibili 弹幕转 ASS 字幕)
