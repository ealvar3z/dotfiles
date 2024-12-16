export LANG="en_US.UTF-8"

xrdb -merge $HOME/.Xresources

# remap the caps lock key to be another ctrl key
setxkbmap -option ctrlswapcaps

# set extra dirs in fontpath, if any
if [ -d /usr/local/share/fonts ]; then
  for i in /usr/local/share/fonts/*; do
    xset fp+ $i
  done
  xset fp rehash
fi

xidle -timeout 600 &

# disable system beep
xset b off

# background
xsetroot -solid black

# programs to startup
xterm &

exec fvwm

