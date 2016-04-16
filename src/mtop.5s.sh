#!/usr/bin/env bash

# <bitbar.title>CPU Usage Graph</bitbar.title>
# <bitbar.version>v1.1</bitbar.version>
# <bitbar.author>Ganesh V</bitbar.author>
# <bitbar.author.github>ganeshv</bitbar.author.github>
# <bitbar.desc>CPU usage bar graph</bitbar.desc>
# <bitbar.image>https://raw.github.com/ganeshv/mtop/master/screenshots/mtop2.png</bitbar.image>
# <bitbar.about>https://github.com/ganeshv/mtop</bitbar.about>

# CPU utilization bar graph is rendered onto a 25x16 BMP file created from
# scratch with no external dependencies. The dropdown contains current usage,
# load average and the top 5 CPU-hogs as reported by `top`.
#
# Tested on Mountain Lion through El Capitan. Works with Dark Mode (though
# you have to restart Bitbar if you change mode).
#
# Mountain Lion does not interpret the BITMAPV5HEADER variant of the BMP
# format, which has alpha channel support. We fall back to a basic version
# (BITMAPINFOHEADER).
#
# Bash builtins are used as much as possible to reduce performance impact.

. ../bitbash/bmplib.sh

HISTORY_FILE=$HOME/.bitbar.mtop
[ ! -r "$HISTORY_FILE" ] && touch "$HISTORY_FILE"
[ X"$(find "$HISTORY_FILE" -mtime -2m)" != X"$HISTORY_FILE" ] && echo -n >"$HISTORY_FILE" # Discard history if older than 2 minutes

OLDIFS=$IFS

osver=$(sw_vers -productVersion)

# Colors in BGRA format
fgcol=(00 00 00 ff)
bgcol=(00 00 00 00)
bmp_ver=5
icontype=templateImage

if [[ $osver == 10.8.* ]]; then
    bmp_ver=1
    bgcol="d0 d0 d0 7f"
    icontype=image
fi

border_height=3

get_cpu_stats() {
    local IFS=$'\n'
    topdata=($(top -F -R -l2 -o cpu -n 5 -s 2 -stats pid,command,cpu))
    nlines=${#topdata[@]}
    histdata=($(tail -$((width - 1)) "$HISTORY_FILE"))

    IFS=$OLDIFS
    for ((i = nlines / 2; i < nlines; i++)); do
        line=(${topdata[$i]})
        word=${line[0]}
        if [ "$word" = Load ]; then
            loadstr=${topdata[$i]}
        elif [ "$word" = CPU ]; then
            cpustr=${line[*]}
            histdata+=("${line[2]/'%'/} ${line[4]/'%'/} ${line[6]/'%'/}")
        elif [ "$word" = PID ]; then
            top5=("${topdata[@]:$i}")
        fi
    done

    IFS=$'\n'
    echo "${histdata[*]}" >"$HISTORY_FILE"
}
if [ "$1" = 'activity_monitor' ]; then
    osascript << END
    tell application "Activity Monitor"
        reopen
        activate
    end tell
END
    exit 0
elif [ "$1" = 'perf' ]; then
    PERF=1
fi

render_graph() {
    heights=()
    for ((i = 0; i < ${#histdata[@]}; i++)); do
        comps=(${histdata[$i]})
        _idle=${comps[2]:-100}
        printf -v _idle "%.0f" "$_idle"
        heights[$i]=$(((100 - _idle) * (height - border_height) / 100))
    done 

    startx=$((width - ${#heights[@]}))
    starty=2
    for ((i = 0; i < ${#heights[@]}; i++)); do
        _h=${heights[$i]}
        [ $_h -gt 0 ] && line $((startx + i)) $starty $((startx + i)) $((starty + _h - 1))
    done
}

[ -z "$PERF" ] && get_cpu_stats

curcol=(${bgcol[@]})
init_bmp $bmp_ver 25 16
curcol=(${fgcol[@]})

fill 0 0 $width 2                                       # bottom border
line 0 $((height - 1)) $((width - 1)) $((height - 1))   # top border

render_graph

echo -n "| $icontype="
output_bmp | base64
echo "---"
echo "$cpustr | refresh=true"
echo "$loadstr | refresh=true"
echo "---"
top5=("${top5[@]/%/| font=Menlo}")
IFS=$'\n'
echo "${top5[*]}"
IFS=$OLDIFS
echo "---"
echo "Open Activity Monitor | bash=$0 param1=activity_monitor terminal=false"
