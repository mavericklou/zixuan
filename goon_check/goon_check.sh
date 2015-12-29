#!/bin/bash

source /root/.profile

echo ""
echo ""
date

PRODUCT_ID=$1
if [ ! "$PRODUCT_ID" ]; then
  echo "product id not valid"
  exit
fi

WORK_DIR=/root/code/zixuan/goon_check
HTML_FILE=$WORK_DIR/$PRODUCT_ID.html
PREV=$WORK_DIR/$PRODUCT_ID.prev
CURR=$WORK_DIR/$PRODUCT_ID.curr
MESSAGE_FILE=$WORK_DIR/$PRODUCT_ID.massage

CORPID=`cat $WORK_DIR/corpid`
CORPSECRET=`cat $WORK_DIR/corpsecret`

# update delivery fee table
curl -s -X POST -d cntry_sct_cd=CN -d frgn_dlv_co_sct_cd=01 http://global.lotte.com/cart/searchDeliverInfoListAjax.lotte | /usr/bin/jq . > $WORK_DIR/lotte_china_ems.fee

curl -s http://global.lotte.com/goods/viewGoodsDetail.lotte?goods_no=$PRODUCT_ID > $HTML_FILE

cat $HTML_FILE | /root/work/bin/pup 'div#price_div span:not([class]) text{}' > $CURR
cat $HTML_FILE | /root/work/bin/pup 'div[class="prd-buy"] table[class="line-type table_delivery"] td:contains("g") text{}' >> $CURR
cat $HTML_FILE | /root/work/bin/pup 'div[class="opt_sel"] text{}' | sed -e 's/^[ \t]*//' | sed '/^$/d' >> $CURR

if [ ! -f $PREV ]; then
  cp $CURR $PREV
fi

date +"%Y-%m-%d %H:%M:%S" > $MESSAGE_FILE
cat $CURR >> $MESSAGE_FILE

function send_message()
{
  ACCESS_TOKEN=`curl -s --form-string "corpid=$CORPID" --form-string "corpsecret=$CORPSECRET" https://qyapi.weixin.qq.com/cgi-bin/gettoken | cut -c18-103`
  curl -X POST -d '{"touser":"@all","agentid":1,"msgtype":"text","text":{"content":"'"`cat $MESSAGE_FILE`"'"}}' 'https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token='"$ACCESS_TOKEN"
  cp $CURR $PREV
  curl -s --form-string "token=adtpBkJFPSucfK2zfRo3cco2vgk9tB" --form-string "user=uiqs7S7VrF4onLHSeKwH2qKv1B4HcE" --form-string "message=`cat $MESSAGE_FILE`" https://api.pushover.net/1/messages.json
}


if [ `md5sum $PREV | cut -f1 -d' '` != `md5sum $CURR | cut -f1 -d' '` ]; then
  echo "changed"
  cat $CURR
  send_message
else
  echo "not changed"
fi
