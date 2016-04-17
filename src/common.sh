# Common functions and globals for m* plugins
# Assumes bmplib.sh already loaded

osver=$(sw_vers -productVersion)

# Colors in BGRA format
fgcol=(00 00 00 ff)
bgcol=(00 00 00 00)
bmp_ver=5
icontype=templateImage

if [[ $osver == 10.8.* ]]; then
    bmp_ver=1
    bgcol=(d0 d0 d0 7f)
    icontype=image
fi

# Routines to draw simple progress-bar-like buckets for showing
# capacity of disks, batteries etc.

init_bar() {
    pixels=()
    curcol=(${bgcol[@]})
    init_bmp $bmp_ver "$1" "$2"
    curcol=(${fgcol[@]})
    rect 0 0 "$1" "$2"
}

# Horizontal bar
# hbar width height capacity
hbar() {
    local w=$((($1 - 4) * $3 / 100))
    init_bar "$1" "$2"
    fill 2 2 $w $(($2 - 4))
}


# Vertical bar
# vbar width height capacity
vbar() {
    local h=$((($2 - 4) * $3 / 100))
    init_bar "$1" "$2"
    fill 2 2 $(($1 - 4)) $h
}
