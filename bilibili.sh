#!/usr/bin/env bash
#
# (c) 2017 Qiu Xiang <i@7c00.cc> under MIT licence
#

ASS_FILE=/tmp/comments.ass

convert_time() {
    time=(${1//./ })
    second=$(printf %0.2f 0.${time[1]})
    date -d @${time[0]} +00:%M:%S${second:1}
}

echo '下载弹幕中……'
html=$(curl -s $1)
episode_id=$(expr "$html" : '.*first_ep_id = "\(.*\)";')
episode=$(curl -s http://bangumi.bilibili.com/web_api/episode/${episode_id}.json)
danmaku_id=$(expr "$episode" : '.*"danmaku":"\(.*\)","episodeId')
comments=$(curl -s http://comment.bilibili.com/${danmaku_id}.xml --compressed)
ass=$(cat << EOT
[Script Info]

[V4 Styles]
Format: Name, Fontname
Style: Default, Sens-serif

[Events]
Format: Start, End, Effect, Text
EOT
)

echo '生成字幕文件……'
while read -r line; do
    p=$(expr "$line" : '.*p="\(.*\)"')
    if [ -n "$p" ]; then
        data=(${p//,/ })
        content=$(expr "$line" : '.*>\(.*\)</d>')
        start_time=$(convert_time ${data[0]})
        end_time=$(convert_time $(bc <<< "${data[0]} + 8"))
        effect="Banner;$[20 - ${#content} / 2];0"
        format="{\c$(printf %06x ${data[3]})\\\fs$[${data[2]} / 2]}"
        ass+="\nDialogue: $start_time, $end_time, $effect, $format$content"
    fi
done <<< "$comments"
printf "$ass" > ${ASS_FILE}

echo '请求播放……'
you-get -p "mpv -sub-file ${ASS_FILE}" $1
