FROM ghcr.io/archlinux/archlinux@sha256:18cebbf28effab23240fc9edc10697f1e3cc3dca1b6070c35ffebe55709739a5

COPY run.sh /run.sh

RUN \
  # * Fix script permissions
  chmod 755 /run.sh && \
  # * Install needed packages
  pacman -Syyu --noconfirm --needed \
      archlinux-keyring \
      base-devel \
      cmake \
      sudo \
      python \
      binutils \
      fakeroot \
      git \
      rsync && \
  # * makepkg cannot (and should not) be run as root
  useradd -m builder && \
  # * Allow builder to run as root (to install dependencies)
  echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder && \
  # * cleanup
  rm -Rf /var/cache/pacman/pkg/ && \
  rm -rf ~/.cache/*

# * Continue execution as builder
USER builder
WORKDIR /home/builder

RUN \
  # * Auto-fetch GPG keys (for checking signatures)
  mkdir .gnupg && \
  touch .gnupg/gpg.conf && \
  echo "keyserver-options auto-key-retrieve" > .gnupg/gpg.conf && \
  find ~/.gnupg -type f -exec chmod 600 {} \; && \
  find ~/.gnupg -type d -exec chmod 700 {} \; && \
  # * Install yay for AUR deps
  git clone https://aur.archlinux.org/yay.git && \
  cd yay && \
  makepkg -sri --clean --noconfirm --needed && \
  cd .. && rm -Rf yay

# Build the package
WORKDIR /pkg
ENTRYPOINT ["/bin/bash"]
CMD ["/run.sh"]
