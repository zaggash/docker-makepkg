FROM archlinux

COPY run.sh /run.sh

# * makepkg cannot (and should not) be run as root
# * Install needed packages
RUN \
  useradd -m builder && \
  pacman -Syyu --noconfirm --needed \
      archlinux-keyring \
      base-devel \
      git && \
  # cleanup
  rm -Rf /var/cache/pacman/pkg/ && \
  rm -rf ~/.cache/*

# * Allow builder to run as root (to install dependencies)
RUN echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder

# * Continue execution as builder
USER builder
WORKDIR /home/builder

# * Auto-fetch GPG keys (for checking signatures)
# * Install yay for AUR deps
RUN \
  mkdir .gnupg && \
  touch .gnupg/gpg.conf && \
  echo "keyserver-options auto-key-retrieve" > .gnupg/gpg.conf && \
  find ~/.gnupg -type f -exec chmod 600 {} \; && \
  find ~/.gnupg -type d -exec chmod 700 {} \; && \

  git clone https://aur.archlinux.org/yay-bin.git && \
  cd yay-bin && \
  makepkg -sri --clean --noconfirm --needed && \
  cd .. && rm -Rf yay-bin

# Build the package
WORKDIR /pkg
CMD /bin/sh /run.sh
