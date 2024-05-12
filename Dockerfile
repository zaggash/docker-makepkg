FROM ghcr.io/archlinux/archlinux@sha256:62c752ee01a473f979b1335689eda938cffaf8a756fb1b402af31dfed130e40b

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
  git clone https://aur.archlinux.org/yay-bin.git && \
  cd yay-bin && \
  makepkg -sri --clean --noconfirm --needed && \
  cd .. && rm -Rf yay-bin

# Build the package
WORKDIR /pkg
ENTRYPOINT ["/bin/bash"]
CMD ["/run.sh"]
