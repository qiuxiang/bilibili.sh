#!/usr/bin/env bash
#
# (c) 2017 Qiu Xiang <i@7c00.cc> under MIT licence
#

BASE_PATH=$(cd $(dirname $0); pwd)
DANMAKU2ASS_PATH="$BASE_PATH/danmaku2ass.py"

shopt -s expand_aliases
alias danmaku2ass="python3 $DANMAKU2ASS_PATH"
alias request="curl -s -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:69.0) Gecko/20100101 Firefox/69.0'"
command -v md5 > /dev/null || alias md5=md5sum

xpath() {
  xmllint $1 --html --xpath $2 2>/dev/null
}

#
# 播放视频
#
# $1 aid
#
play() {
  echo "获取视频数据..."
  local video_json=$(request "http://api.bilibili.com/view?appkey=8e9fc618fbd41e28&id=$1")
  local cid=$(jq .cid <<< ${video_json})
  local title=$(jq -r .title <<< ${video_json})
  local params="_appver=424000&_device=android&_down=0&_hwid=$RANDOM&_p=1&_tid=0&appkey=452d3958f048c02a&cid=$cid&otype=json&platform=android"
  local sign=$(echo -n ${params}f7c926f549b9becf1c27644958676a21 | md5)

  echo "获取播放链接..."
  local play_json=$(request "https://interface.bilibili.com/playurl?$params&sign=${sign:0:32}")
  local length=$(jq ".durl | length" <<< ${play_json})

  if [ -z $length ] || [ $length == 0 ]; then
    echo $play_json
    exit
  fi

  local length=$(jq ".durl | length" <<< ${play_json})
  local playlist
  for (( i = 0; i < length; i++ )) do
    playlist+="$(jq -r .durl[${i}].url <<< ${play_json}) "
  done

  echo "获取弹幕..."
  local comments=$(request http://comment.bilibili.com/${cid}.xml --compressed)
  local ass=$(danmaku2ass -s 1280x720 -dm 20 -o >(cat) <(echo "$comments"))
  mpv --force-media-title "$title" -sub-file <(echo "$ass") --merge-files ${playlist}
}

#
# 获取番剧信息
#
# $1 番剧ID
#
bangumi() {
  echo "获取番剧信息..."
  local bangumi_info=$(request "https://api.bilibili.com/pgc/view/web/media?media_id=$1")
  local title=$(jq -r .result.title <<< ${bangumi_info})
  local staff=$(jq -r .result.staff <<< ${bangumi_info})
  local intro=$(jq -r .result.evaluate <<< ${bangumi_info})
  local brief=$(jq -r .result.brief <<< ${bangumi_info})
  printf "\n$title\n"
  printf "\n$staff\n"
  printf "\n$intro\n\n"
  local season_id=$(jq -r .result.season_id <<< ${bangumi_info})
  local sections=$(request "https://api.bilibili.com/pgc/web/season/section?season_id=$season_id")
  local length=$(jq ".result.main_section.episodes | length" <<< ${sections})
  for (( i = 0; i < length; i++)) do
    local index=$(jq -r .result.main_section.episodes[$i].title <<< ${sections})
    local title=$(jq -r .result.main_section.episodes[$i].long_title <<< ${sections})
    printf "%4d - %s %s\n" $[$i + 1] "第${index}话" "$title"
  done
  printf "\n请选择要播放的集数："
  read choice
  id=$(jq -r .result.main_section.episodes[$[$choice - 1]].id <<< ${sections})
  main https://www.bilibili.com/bangumi/play/ep$id
}

#
# 番剧搜索
#
# $1 关键字
#
search() {
  echo "搜索“$1”..."
  local html=$(request "http://search.bilibili.com/all" --get --data-urlencode "keyword=$1")
  local url=$(xpath <(echo "$html") "string(//a[@class='title']/@href)")
  if [ -z ${url} ]; then
    echo "未找到匹配的番剧"
  else
    main https:${url%\?*}
  fi
}

#
# 观看直播
#
# $1 直播间链接，如：https://live.bilibili.com/123
#
live() {
  local room_id=$(request $1 | grep -Po "ROOMID = \K\d+")
  local json=$(request "https://api.live.bilibili.com/api/playurl?cid=$room_id&otype=json")
  local url=$(echo ${json} | jq -r .durl[0].url)
  mpv ${url}
}

main() {
  local aid
  local video_pattern=https?://www.bilibili.com/video/av\([0-9]+\)/?
  local bangumi_pattern=https?://www.bilibili.com/bangumi/media/md\([0-9]+\)/?
  local bangumi_item_pattern=https?://www.bilibili.com/bangumi/play/ep[0-9]+
  local live_pattern=https?://live.bilibili.com/\([0-9]+\)/?
  if [[ $1 =~ $bangumi_item_pattern ]]; then
    echo "获取番剧数据..."
    local html=$(request --compressed $1)
    aid=$(echo "$html" | grep -Eo '"aid":([0-9]+)' | grep -Eo "[0-9]+" | tail -n 1)
  elif [[ $1 =~ $bangumi_pattern  ]]; then
    bangumi ${BASH_REMATCH[1]}
    exit
  elif [[ $1 =~ $video_pattern  ]]; then
    aid=${BASH_REMATCH[1]}
  elif [[ $1 =~ $live_pattern  ]]; then
    live $1
    exit
  else
    search "$1"
    exit
  fi

  play ${aid}
}

if [ -z $1 ]; then
  cat << EOF
Usage：bilibili 番剧名|视频地址|直播间地址
EOF
else
  main $1
fi
