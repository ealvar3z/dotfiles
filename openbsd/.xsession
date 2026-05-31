export LANG=en_US.UTF-8

xrdb -merge "$HOME/.Xresources"
xsetroot -solid grey80
xset b off
xidle &
xclock -d -twentyfour &
xterm &

exec fvwm
