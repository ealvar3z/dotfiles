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

## License

Redistributed under the terms specified in the [`LICENSE`] file.

[`LICENSE`]: /LICENSE

