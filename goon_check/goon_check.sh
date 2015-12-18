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

curl -s http://global.lotte.com/goods/viewGoodsDetail.lotte?goods_no=$PRODUCT_ID > $HTML_FILE

cat $HTML_FILE | /root/work/bin/pup 'div#price_div span:not([class]) text{}' > $CURR
cat $HTML_FILE | /root/work/bin/pup 'div[class="prd-buy"] table[class="line-type table_delivery"] td:contains("g") text{}' >> $CURR
cat $HTML_FILE | /root/work/bin/pup 'div[class="opt_sel"] text{}' >> $CURR

if [ ! -f $PREV ]; then
  cp $CURR $PREV
fi

if [ `md5sum $PREV | cut -f1 -d' '` != `md5sum $CURR | cut -f1 -d' '` ]; then
  echo "changed"
  cp $CURR $PREV
  cat $PREV
  curl -s --form-string "token=adtpBkJFPSucfK2zfRo3cco2vgk9tB" --form-string "user=uiqs7S7VrF4onLHSeKwH2qKv1B4HcE" --form-string "message=`cat $PREV`" https://api.pushover.net/1/messages.json
else
  echo "not changed"
fi
