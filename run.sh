#!/usr/bin/env bash
set -e

# * Set Makepkg.conf settings
numberofcores=$(nproc)
if [ $numberofcores -gt 1 ]
then
        echo "$numberofcores cores available."
        echo "Changing the makeflags for $numberofcores cores."
        sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j'$numberofcores'"/g' /etc/makepkg.conf;
        echo "Changing the compression settings for $numberofcores cores."
        sudo sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T 0 -z -)/g' /etc/makepkg.conf
else
        echo "No change."
fi

# * Make a copy so we never alter the original
echo "* Copy PKGBUILD ..."
cp -R /pkg /tmp/pkg
cd /tmp/pkg

# * makepkg -s cannot install AUR deps !
# * Install (official repo + AUR) dependencies using yay if needed.
echo "* Installing  dependencies..."
yay -Syyu --noconfirm
yay -Sy --noconfirm \
    $(pacman --deptest $(source ./PKGBUILD && echo ${depends[@]} ${checkdepends[@]} ${makedepends[@]}))

# * If env $CHECKSUM_SRC, add the checksum
if [[ "$CHECKSUM_SRC" == true  ]]
then
  echo "* Add Checksum to PKGBUILD ..."
  makepkg -g >> ./PKGBUILD
fi

# * Run the build
echo "* Run the Build ..."
if [[ -n "PGPKEY" ]]
then
  echo "* importing the PGP key ..."
  echo "$PGPKEY" | base64 -d | gpg --import -
  makepkg -f --sign
else
  makepkg -f
fi

# * If $EXPORT_PKG, set permissions like the PKGBUILD file and export the package
if [[ "$EXPORT_PKG" == true ]]
then
    echo "* Copy back the builded package ..."
    sudo chown $(stat -c '%u:%g' /pkg/PKGBUILD) ./*.pkg.tar.*
    sudo mv ./*.pkg.tar.* /pkg
fi
