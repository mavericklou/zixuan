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


##### functions for weight and delivery fee #####
##curl -s -X POST -d cntry_sct_cd=CN -d frgn_dlv_co_sct_cd=01 http://global.lotte.com/cart/searchDeliverInfoListAjax.lotte | /usr/bin/jq . > $WORK_DIR/lotte_china_ems_fee.curr
##
##function get_weight_floor()
##{
##  weight=$((((( $1 - 1) / 500) + 1) * 500))
##}
##
##get_weight_floor 16500
##echo $weight
##
##function get_delivery_fee_for()
##{
##  cat lotte_china_ems_fee.curr | /usr/bin/jq '.[] | select(.STD_WGT_VAL == '"$1"') | .DLEX'
##}
##
##delivery_fee=`get_delivery_fee_for 15000`




curl -s http://global.lotte.com/goods/viewGoodsDetail.lotte?goods_no=$PRODUCT_ID > $HTML_FILE

cat $HTML_FILE | /root/work/bin/pup 'div#price_div span:not([class]) text{}' > $CURR
cat $HTML_FILE | /root/work/bin/pup 'div[class="prd-buy"] table[class="line-type table_delivery"] td:contains("g") text{}' >> $CURR
cat $HTML_FILE | /root/work/bin/pup 'div[class="opt_sel"] text{}' | sed -e 's/^[ \t]*//' | sed '/^$/d' >> $CURR

if [ ! -f $PREV ]; then
  cp $CURR $PREV
fi

date +"%Y-%m-%d %H:%M:%S" > $MESSAGE_FILE
cat $CURR >> $MESSAGE_FILE

if [ `md5sum $PREV | cut -f1 -d' '` != `md5sum $CURR | cut -f1 -d' '` ]; then
  echo "changed"
  cat $CURR
  $WORK_DIR/send_notification.sh $MESSAGE_FILE
  if [ `cat $CURR | grep -c "XL"` -ne 0 ] ; then
    echo "Hey, XL is in stock!" > $MESSAGE_FILE
    $WORK_DIR/send_notification.sh $MESSAGE_FILE
    $WORK_DIR/send_notification.sh $MESSAGE_FILE
    $WORK_DIR/send_notification.sh $MESSAGE_FILE
    $WORK_DIR/send_notification.sh $MESSAGE_FILE
  fi
  cp $CURR $PREV
else
  echo "not changed"
  if [ `cat $CURR | grep -c "XL"` -ne 0 ] ; then
    cat $CURR
    $WORK_DIR/send_notification.sh $MESSAGE_FILE
  fi
fi




## notification for delivery fee table changes
if [ ! -f $WORK_DIR/lotte_china_ems_fee.prev ]; then
  cp $WORK_DIR/lotte_china_ems_fee.curr $WORK_DIR/lotte_china_ems_fee.prev
fi

if [ `md5sum $WORK_DIR/lotte_china_ems_fee.prev  | cut -f1 -d' '` != `md5sum $WORK_DIR/lotte_china_ems_fee.curr | cut -f1 -d' '` ]; then
  date +"%Y-%m-%d %H:%M:%S" > $MESSAGE_FILE
  echo "delivery fee changed" >> $MESSAGE_FILE
  echo "previous for 10kg `get_delivery_fee_for 10000`krw" >> $MESSAGE_FILE
  echo "now      for 10kg `get_delivery_fee_for 10000`krw" >> $MESSAGE_FILE
  echo "previous for 15kg `get_delivery_fee_for 15000`krw" >> $MESSAGE_FILE
  echo "now      for 15kg `get_delivery_fee_for 15000`krw" >> $MESSAGE_FILE
  echo "previous for 20kg `get_delivery_fee_for 20000`krw" >> $MESSAGE_FILE
  echo "now      for 20kg `get_delivery_fee_for 20000`krw" >> $MESSAGE_FILE
  $WORK_DIR/send_notification.sh $MESSAGE_FILE
  cp $WORK_DIR/lotte_china_ems_fee.curr $WORK_DIR/lotte_china_ems_fee.prev
fi
