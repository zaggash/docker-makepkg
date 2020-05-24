#!/usr/bin/env bash
set -e

# * Make a copy so we never alter the original
cp -R /pkg /tmp/pkg
cd /tmp/pkg

# * makepkg -s cannot install AUR deps !
# * Install (official repo + AUR) dependencies using yay.
yay -Sy --noconfirm \
    $(pacman --deptest $(source ./PKGBUILD && echo ${depends[@]} ${makedepends[@]}))

# * If env $CHECKSUM_SRC, add the checksum
if [[ "$CHECKSUM_SRC" == true  ]]
then
  makepkg -g >> ./PKGBUILD
fi

# * Run the build
makepkg -f

# * If $EXPORT_PKG, set permissions like the PKGBUILD file and export the package
if [[ "$EXPORT_PKG" == true ]]
then
    sudo chown $(stat -c '%u:%g' /pkg/PKGBUILD) ./*.pkg.tar.xz
    sudo mv ./*.pkg.tar.xz /pkg
fi
