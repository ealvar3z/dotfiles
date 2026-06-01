export LANG=en_US.UTF-8

xrdb -merge "$HOME/.Xresources"
xset b off
xidle &
xterm &

exec fvwm -f "$HOME/.fvwm/config"
