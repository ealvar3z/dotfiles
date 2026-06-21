. ~/.bashrc

if [[ -x $HOME/bin/audio-init ]]; then
	"$HOME/bin/audio-init" >/dev/null 2>&1 || true
fi
