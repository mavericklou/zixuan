#!/bin/bash

PRODUCT_ID=$1

curl -s http://global.lotte.com/goods/viewGoodsDetail.lotte?goods_no=$PRODUCT_ID > $PRODUCT_ID.html

price=`cat $PRODUCT_ID.html | pup 'div#price_div span:not([class]) text{}'`
weight=`cat $PRODUCT_ID.html | pup 'div[class="prd-buy"] table[class="line-type table_delivery"] td:contains("g") text{}'`
option=`cat $PRODUCT_ID.html | pup 'div[class="opt_sel"] text{}'`

echo $price > $PRODUCT_ID.curr
echo $weight >> $PRODUCT_ID.curr
echo $option >> $PRODUCT_ID.curr

if [ ! -f $PRODUCT_ID.prev ]; then
  cp $PRODUCT_ID.curr $PRODUCT_ID.prev
fi

if [ `md5 -q $PRODUCT_ID.prev` != `md5 -q $PRODUCT_ID.curr` ]; then
  echo "changed"
  cp $PRODUCT_ID.curr $PRODUCT_ID.prev
  curl -s --form-string "token=adtpBkJFPSucfK2zfRo3cco2vgk9tB" --form-string "user=uiqs7S7VrF4onLHSeKwH2qKv1B4HcE" --form-string "message=`cat $PRODUCT_ID.curr`" https://api.pushover.net/1/messages.json
else
  echo "not changed"
fi
