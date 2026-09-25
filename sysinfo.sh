#!/usr/bin/env bash
# Emits one line: CPU=<int> MEM=<int> TEMP=<int> BAT=<n|AC> VOL=<int>
S1=$(head -n1 /proc/stat); sleep 0.4; S2=$(head -n1 /proc/stat)
CPU=$(printf '%s\n%s\n' "$S1" "$S2" | awk 'NR==1{i1=$2+$3+$4+$5+$6+$7+$8;t1=$5} NR==2{i2=$2+$3+$4+$5+$6+$7+$8;t2=$5} END{if(i2>i1) printf "%d",(1-(t2-t1)/(i2-i1))*100; else printf "0"}')
MEM=$(free | awk '/Mem:/ {printf "%d", $3/$2*100}')
TEMP=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | sort -rn | head -n1 | awk '{printf "%d", $1/1000}')
[ -z "$TEMP" ] && TEMP=0
BAT=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1)
[ -z "$BAT" ] && BAT="AC"
VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{printf "%d", $2*100}')
[ -z "$VOL" ] && VOL=0
BRI=$(brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d %)
[ -z "$BRI" ] && BRI=0
US=$(cut -d. -f1 /proc/uptime 2>/dev/null)
[ -z "$US" ] && US=0
UPTIME=$(awk -v s="$US" 'BEGIN{d=int(s/86400);h=int(s%86400/3600);m=int(s%3600/60); if(d>0)printf "%dd-%dh",d,h; else if(h>0)printf "%dh-%dm",h,m; else printf "%dm",m}')
LOAD=$(awk '{print $1","$2","$3}' /proc/loadavg 2>/dev/null)
[ -z "$LOAD" ] && LOAD="0,0,0"
DISK=$(df / --output=pcent 2>/dev/null | tail -n1 | tr -d ' %')
[ -z "$DISK" ] && DISK=0
echo "CPU=$CPU MEM=$MEM TEMP=$TEMP BAT=$BAT VOL=$VOL BRI=$BRI UPTIME=$UPTIME LOAD=$LOAD DISK=$DISK"
