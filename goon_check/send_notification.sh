#!/bin/bash

WORK_DIR=/root/code/zixuan/goon_check
CORPID=`cat $WORK_DIR/corpid`
CORPSECRET=`cat $WORK_DIR/corpsecret`
MESSAGE_FILE=$1
CONTENT=`cat $MESSAGE_FILE`

PAID_USER="mavlou|qianjun1986"
FREE_USER="mavlou|xiaobaozi|zhangyi3049|zhihuiguoguo6|zhujey2010"

ACCESS_TOKEN=`curl -s --form-string "corpid=$CORPID" --form-string "corpsecret=$CORPSECRET" https://qyapi.weixin.qq.com/cgi-bin/gettoken | cut -c18-103`
curl -X POST -d '{"touser":"'"$PAID_USER"'","agentid":1,"msgtype":"text","text":{"content":"'"$CONTENT"'"}}' 'https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token='"$ACCESS_TOKEN"
curl -s --form-string "token=adtpBkJFPSucfK2zfRo3cco2vgk9tB" --form-string "user=uiqs7S7VrF4onLHSeKwH2qKv1B4HcE" --form-string "message=$CONTENT" https://api.pushover.net/1/messages.json
sleep 30m && curl -X POST -d '{"touser":"'"$FREE_USER"'","agentid":1,"msgtype":"text","text":{"content":"DELAYED 30 MINUTES!!!'"$CONTENT"'"}}' 'https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token='"$ACCESS_TOKEN" &
