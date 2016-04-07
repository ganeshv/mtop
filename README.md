# mtop

`mtop` is a [BitBar](https://getbitbar.com/) plugin to display a graph of CPU
usage in the Mac OS X menu bar. Clicking the graph opens a dropdown containing
the current CPU usage (user, sys, idle), load average and the top 5 CPU hogs
as reported by `top`.

![mtop example](https://raw.github.com/ganeshv/mtop/master/screenshots/mtop1.png)

![mtop with dropdown](https://raw.github.com/ganeshv/mtop/master/screenshots/mtop2.png)

This `bash` script gets data from `top` and renders the usage graph to a BMP
file created from scratch, with no external image processing utilities or
dependencies.

## Usage

Install [BitBar](https://getbitbar.com/) and copy `mtop.5s.sh` from this
repo into the plugins directory you chose when you first ran BitBar.

That's it. You should see the `mtop` graph in your menu bar.

Should work on Mountain Lion through El Capitan.
