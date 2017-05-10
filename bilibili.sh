#!/usr/bin/env bash
#
# (c) 2017 Qiu Xiang <i@7c00.cc> under MIT licence
#

ASS_FILE=/tmp/comments.ass
COMMENTS_FILE=/tmp/comments.xml
BASE_PATH=$(cd $(dirname $0); pwd)
DANMAKU2ASS_PATH="$BASE_PATH/danmaku2ass.py"

shopt -s expand_aliases
alias danmaku2ass="python3 $DANMAKU2ASS_PATH"
alias request="curl -s -H 'User-Agent: Mozilla/5.0 BiliDroid/5.2.3 (bbcallen@gmail.com)'"
command -v md5 > /dev/null || alias md5=md5sum

main() {
  local av_id
  local video_pattern=https?://www.bilibili.com/video/av[0-9]+/
  local anime_pattern=https?://bangumi.bilibili.com/anime/[0-9]+/play#[0-9]+
  if [[ $1 =~ $anime_pattern ]]; then
    echo 'Get episode data'
    local episode_id=${1#*#}
    local episode_data=$(request http://bangumi.bilibili.com/web_api/episode/$episode_id.json)
    local danmaku_id=$(jq -r .result.currentEpisode.danmaku <<< $episode_data)
    av_id=$(jq -r .result.currentEpisode.avId <<< $episode_data)
  elif [[ $1 =~ $video_pattern  ]]; then
    av_id=$(expr "$1" : '.*av\(.*\)/')
  else
    echo The url $1 is invalid.
    echo A valid url is like $video_pattern or
    echo $anime_pattern
    exit 1
  fi

  echo 'Get video data'
  local video_data=$(request "http://api.bilibili.com/view?appkey=8e9fc618fbd41e28&id=$av_id")
  local cid=$(jq .cid <<< $video_data)
  local title=$(jq -r .title <<< $video_data)
  local params="_appver=424000&_device=android&_down=0&_hwid=$RANDOM&_p=1&_tid=0&appkey=452d3958f048c02a&cid=$cid&otype=json&platform=android"
  local sign=$(echo -n ${params}f7c926f549b9becf1c27644958676a21 | md5)

  echo 'Get playlist'
  local play_url=$(request "https://interface.bilibili.com/playurl?$params&sign=${sign:0:32}")
  local length=$(jq ".durl | length" <<< $play_url)
  local playlist
  for (( i = 0; i < length; i++ )) do
    playlist+="$(jq -r .durl[${i}].url <<< $play_url) "
  done

  echo 'Get comments'
  request http://comment.bilibili.com/$cid.xml --compressed > $COMMENTS_FILE
  danmaku2ass -s 1280x720 -dm 20 -o $ASS_FILE $COMMENTS_FILE
  mpv --force-media-title "$title" -sub-file $ASS_FILE --merge-files $playlist
}

if [ -z $1 ]; then
  cat << EOF
Usage：bilibili URL
EOF
else
  main $1
fi
