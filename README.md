#  dotfiles

Peruse at your own leisure

---

## evil-helix install

[Download the package](https://github.com/usagi-flow/evil-helix/releases) and extract it in `/opt`.
Symlink it to `/usr/local/bin`:

```console
VERSION=20250915
ARCH=aarch64
OS=macos
URL="https://github.com/usagi-flow/evil-helix/releases/download"
META="release-${VERSION}/helix-${ARCH}-${OS}.tar.gz"

cd /tmp || exit 1
curl -fL -o helix.tar.gz "${URL}/${META}" || exit 1
sudo mkdir -p /opt/helix
sudo tar -xzf helix.tar.gz -C /opt/helix --strip-components=1 || exit 1
sudo ln -sf /opt/helix/hx /usr/local/bin/hx
```

## Codex skills

Personal Codex skills live under
`prompts/.codex/skills/<skill-name>/` using the canonical Codex skill layout.
The dotfiles repository is the source of truth; `~/.codex/skills` is the
installed Stow view.

Launch Codex once on a fresh machine before stowing so it creates the real
`~/.codex/skills` directory and its managed `.system` skills. This prevents GNU
Stow from folding the whole directory into the dotfiles repository.

Then install the prompts package:

```console
cd ~/dotfiles
stow -t ~ prompts
```

Codex continues to own `~/.codex/skills/.system`. Stow links each personal skill
beside it and also installs the package's `commands/` and `sharable.md` at the
home-directory root.

## License

Redistributed under the terms specified in the [`LICENSE`] file.

[`LICENSE`]: /LICENSE
