#!/usr/bin/env bash
# Fast fetch for OSD (no sleeps): VOL=<int> MUTED=<0|1> BRI=<int>
OUT=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
VOL=$(printf '%s' "$OUT" | awk '{printf "%d", $2*100}')
[ -z "$VOL" ] && VOL=0
MUTED=0
printf '%s' "$OUT" | grep -q "MUTED" && MUTED=1
BRI=$(brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d %)
[ -z "$BRI" ] && BRI=0
echo "VOL=$VOL MUTED=$MUTED BRI=$BRI"
