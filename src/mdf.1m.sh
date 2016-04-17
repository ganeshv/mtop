#!/usr/bin/env bash

# <bitbar.title>Disk Usage</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Ganesh V</bitbar.author>
# <bitbar.author.github>ganeshv</bitbar.author.github>
# <bitbar.desc>Disk usage statistics</bitbar.desc>
# <bitbar.image>https://raw.github.com/ganeshv/mtop/master/screenshots/mdf2.jpg</bitbar.image>
# <bitbar.about>https://github.com/ganeshv/mtop</bitbar.about>

# Bash builtins are used as much as possible to reduce performance impact.

. ../bitbash/bmplib.sh
. common.sh

OLDIFS=$IFS

disk=()
used=()
free=()
capacity=()
root_capacity=0

get_disk_stats() {
    local IFS=$'\n'
    local i dfdata dudata diskname

    dfdata=($(df -H))

    IFS=$OLDIFS
    for ((i = 0; i < ${#dfdata[@]}; i++)); do
        line=(${dfdata[$i]})
        if [ "${line[8]}" = "/" ]; then
            root_capacity="${line[4]/\%}"            
        fi
        if [[ "${line[0]}" == /dev/* ]]; then
            dudata=($(diskutil info "${line[0]}" | grep "Volume Name"))
            diskname="${dudata[*]:2}"
            disk+=("${diskname:-Untitled}")
            used+=("${line[2]}")
            free+=("${line[3]}")
            capacity+=("${line[4]/\%}")
        fi
    done
}

if [ "$1" = 'disk_utility' ]; then
    osascript << END
    tell application "Disk Utility"
        reopen
        activate
    end tell
END
    exit 0
elif [ "$1" = 'perf' ]; then
    PERF=1
fi

[ -z "$PERF" ] && get_disk_stats

vbar 10 16 "$root_capacity"

echo -n "| $icontype="
output_bmp | base64
echo "---"
for ((i = 0; i < ${#capacity[@]}; i++)); do
    echo "Disk   ${disk[$i]} | size=12 refresh=true font=Menlo"
    echo "Used   ${used[$i]}| size=12 refresh=true font=Menlo"
    echo "Free   ${free[$i]}| size=12 refresh=true font=Menlo"
    hbar 128 10 "${capacity[$i]}"
    echo -n "| refresh=true $icontype="
    output_bmp | base64
    echo "---"
done
echo "Open Disk Utility | bash=$0 param1=disk_utility terminal=false"
