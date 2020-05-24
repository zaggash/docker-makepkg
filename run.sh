#!/usr/bin/env bash
set -e

# * Make a copy so we never alter the original
echo "* Copy PKGBUILD ..."
cp -R /pkg /tmp/pkg
cd /tmp/pkg

# * makepkg -s cannot install AUR deps !
# * Install (official repo + AUR) dependencies using yay.
echo "* Install yay-bin from AUR ..."
yay -Sy --noconfirm \
    $(pacman --deptest $(source ./PKGBUILD && echo ${depends[@]} ${makedepends[@]}))

# * If env $CHECKSUM_SRC, add the checksum
if [[ "$CHECKSUM_SRC" == true  ]]
then
  echo "* Add Checksum to PKGBUILD ..."
  makepkg -g >> ./PKGBUILD
fi

# * Run the build
echo "* Run the Build ..."
makepkg -f

# * If $EXPORT_PKG, set permissions like the PKGBUILD file and export the package
if [[ "$EXPORT_PKG" == true ]]
then
    echo "* Copy back the builded package ..."
    sudo chown $(stat -c '%u:%g' /pkg/PKGBUILD) ./*.pkg.tar.xz
    sudo mv ./*.pkg.tar.xz /pkg
fi
