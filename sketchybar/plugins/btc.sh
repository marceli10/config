#!/bin/bash

sketchybar --set $NAME \
  label="Loading..." \
  icon.color=0xff5edaff

BTC_PRICE=$(curl -s 'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd' | jq -r '.bitcoin.usd')

sketchybar --set $NAME label=" $BTC_PRICE\$"

