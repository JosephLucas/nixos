#!/usr/bin/env bash
# connect Bose QC35 headset via bluetooth
# https://askubuntu.com/a/773391

card_profile="$(pacmd list-cards | grep bluez_card -B1 | grep index | awk '{print $2}')" 
card_mac="$(pacmd list-cards | grep "device.description = \"Bose QC35 II\"" -A1 | grep "device.string" | awk '{print $3}')"
# remove leading and trailing quotes
card_mac="${card_mac%\"}"
card_mac="${card_mac#\"}"

pacmd set-card-profile "${card_profile}" off
sleep 2
echo -e "disconnect ${card_mac}\n quit" |bluetoothctl
sleep 5
echo -e "connect ${card_mac}\n quit"|bluetoothctl 
sleep 5
# "grab once more the profile index, because the index changes every time the device is disconnected and reconnected"
card_profile="$(pacmd list-cards | grep bluez_card -B1 | grep index | awk '{print $2}')"
# set the audio profile to a2dp
pacmd set-card-profile "${card_profile}" a2dp_sink