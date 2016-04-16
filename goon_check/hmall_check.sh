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
MESSAGE_FILE=$WORK_DIR/$PRODUCT_ID.message


curl -s -X POST -d slitmCd=$PRODUCT_ID http://global.hyundaihmall.com/GL/pda/getStockCount.do > $HTML_FILE

cat $HTML_FILE | /root/work/bin/pup 'td[class=center]' text{} | sed '/^ *$/d' | sed 's/^ *//' | sed 's/ *$//' | head -4 | tail -1 > $CURR

if [ ! -f $PREV ]; then
  cp $CURR $PREV
fi

date +"%Y-%m-%d %H:%M:%S" > $MESSAGE_FILE
cat $CURR >> $MESSAGE_FILE

if [[ `head -1 $PREV` == "of stock" && `head -1 $CURR` != "of stock" ]]; then
#if [[ `head -1 $PREV` == "Out of stock" && `head -1 $CURR` != "Out of stock" ]]; then
  echo "stock refill"
  cat $CURR
  $WORK_DIR/send_notification.sh $MESSAGE_FILE
  cp $CURR $PREV
else
  echo "out of stock"
fi
