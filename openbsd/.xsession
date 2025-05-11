export LANG=en_US.UTF-8
export ENV=$HOME/.kshrc
xrdb -merge $HOME/.Xresources &
xsetroot -solid black &
xidle &
xclock -d -twentyfour &
xset b off
setxkbmap -option caps:ctrl_escape &
xterm -bg black -fg white +sb &

exec cwm
