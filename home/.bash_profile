. ~/.bashrc

for audio_init in "$HOME/bin/audio-init" "$HOME/dotfiles/bin/audio-init"; do
	if [[ -x $audio_init ]]; then
		"$audio_init" >/dev/null 2>&1 || true
		break
	fi
done
