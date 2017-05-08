#!/usr/bin/env bash
#
# (c) 2017 Qiu Xiang <i@7c00.cc> under MIT licence
#

ASS_FILE=/tmp/comments.ass
COMMENTS_FILE=/tmp/comments.xml

shopt -s expand_aliases
alias danmaku2ass="python3 danmaku2ass.py"
alias request="curl -s -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.36 Safari/537.36'"

main() {
  local episode_id=${1#*#}
  local episode_data=$(request http://bangumi.bilibili.com/web_api/episode/$episode_id.json)
  local danmaku_id=$(jq -r .result.currentEpisode.danmaku <<< $episode_data)
  local av_id=$(jq -r .result.currentEpisode.avId <<< $episode_data)
  local bangumi_data=$(request "http://api.bilibili.com/view?appkey=8e9fc618fbd41e28&id=$av_id")
  local cid=$(jq .cid <<< $bangumi_data)
  local title=$(jq -r .title <<< $bangumi_data)
  local random=$(md5sum <<< $RANDOM)
  local hw_id=${random:0:16}
  local app_key=452d3958f048c02a
  local app_sec=f7c926f549b9becf1c27644958676a21
  local params="_appver=424000&_device=android&_down=0&_hwid=$hw_id&_p=1&_tid=0&appkey=452d3958f048c02a&cid=$cid&otype=json&platform=android"
  local sign=$(echo -n $params$app_sec | md5sum)
  local play_url=$(request "https://interface.bilibili.com/playurl?$params&sign=${sign:0:32}")
  local length=$(jq ".durl | length" <<< $play_url)
  local playlist
  for (( i = 0; i < length; i++ )) do
    playlist+="$(jq -r .durl[${i}].url <<< $play_url) "
  done
  request http://comment.bilibili.com/$danmaku_id.xml --compressed > $COMMENTS_FILE
  danmaku2ass -s 1280x720 -dm 20 -o $ASS_FILE $COMMENTS_FILE
  mpv --force-media-title "$title" -sub-file $ASS_FILE --merge-files $playlist
}

main $@
