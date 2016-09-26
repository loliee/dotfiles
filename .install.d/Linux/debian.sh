#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

export DEBIAN_FRONTEND=noninteractive

GUEST_OS=${GUEST_OS:-0}
DEBIAN_USER=${DEBIAN_USER:='mloliee'}
version_files_dir='/usr/local/src/.versions'

#apt-get update
#apt-get install -y curl apt-transport-https
#
## Create directory with prog versions
#mkdir -p "${version_files_dir}"
#
## Add all apt repos
#curl -sL https://deb.nodesource.com/setup_6.x | bash -
#apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 \
#            --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
#if [[ ! -f /etc/apt/sources.list.d/docker.list ]]; then
#  echo "deb https://apt.dockerproject.org/repo debian-jessie main" >> /etc/apt/sources.list.d/docker.list
#fi
#if [[ ! -f /etc/apt/sources.list.d/google-chrome.list ]]; then
#  echo 'deb http://dl.google.com/linux/chrome/deb/ stable main' > /etc/apt/sources.list.d/google-chrome.list
#  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A040830F7FAC5991
#fi
#
## Install JAVA
#if [[ ! -f /etc/apt/sources.list.d/webupd8team-java.list ]]; then
#  echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | \
#    tee /etc/apt/sources.list.d/webupd8team-java.list
#  echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | \
#    tee -a /etc/apt/sources.list.d/webupd8team-java.list
#  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
#fi
#
## Accept ORACLE license
#echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
#echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
#
## Purge
#apt-get purge -f -y vim vim-runtime gvim || true
#apt-get purge -f -y tmux || true
#apt-get purge -f -y stow || true
#apt-get purge -f -y openjdk-7-jre gcj-4.7-base gcj-4.7-jre openjdk-6-jre-headless &>/dev/null || true
#
## Prepare for docker
#apt-get purge -f "lxc-docker*" &>/dev/null || true
#apt-get purge -f "docker.io*" &>/dev/null || true
#apt-cache policy docker-engine
#
## Install all packages
#apt-get update && apt-get upgrade -y
#apt-get install -y -f
#apt-get install -y \
#  ack-grep \
#  bridge-utils \
#  ca-certificates \
#  checkinstall \
#  cmake \
#  dkms \
#  docker-engine \
#  dnsmasq \
#  dnsutils \
#  evtest \
#  ecryptfs-utils \
#  enigmail \
#  g++ \
#  gimp \
#  git-core \
#  google-chrome-stable \
#  golang \
#  graphviz \
#  htop \
#  icedove \
#  iceweasel \
#  imagemagick \
#  ipcalc \
#  iptables-persistent \
#  jq \
#  jpegoptim \
#  qtbase5-dev \
#  linux-headers-amd64 \
#  liblua5.2-dev\
#  libevent-dev \
#  libreoffice \
#  libncurses5-dev \
#  libqt5x11extras5-dev \
#  libqt5svg5-dev \
#  libmuparser-dev \
#  keepass2 \
#  keyboard-configuration \
#  lftp \
#  locales \
#  lua5.2 \
#  ncdu \
#  nmap \
#  nodejs \
#  ntfs-3g \
#  ntp \
#  openssh-server \
#  optipng \
#  oracle-java8-installer \
#  pandoc \
#  python-dev \
#  python-virtualenv \
#  pwgen \
#  rsync \
#  shellcheck \
#  sudo \
#  terminator \
#  tig \
#  tcpdump \
#  transmission \
#  unzip \
#  vlc \
#  virt-manager \
#  wireshark \
#  xfce4 \
#  xfce4-cpugraph-plugin \
#  xfce4-netload-plugin \
#  xfce4-systemload-plugin \
#  zsh
#
## fail in docker
#apt-get intall -y virtualbox &>/dev/null || true
#
## Start xorg at boot
##echo /etc/X11/Xwrapper.config
## allowed_users=anybody
#
## Keyboard Layout
#localectl set-x11-keymap layout macbook79 mac
#
## Services
#systemctl enable docker
#systemctl restart docker
#sudo usermod -aG docker "${DEBIAN_USER}"
#
# Reconfigure locale
#dpkg-reconfigure locales || true

# Setup default user
echo "--> setup user: ${DEBIAN_USER}"
grep "${DEBIAN_USER}" /etc/passwd || \
  "${DEBIAN_USER}" -d "/home/${DEBIAN_USER}"
grep "${DEBIAN_USER}" /etc/sudoers \
  || echo "${DEBIAN_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
# Ensure zsh is default shell
usermod "${DEBIAN_USER}" -s /bin/zsh

# Install recent vim version
vim_version='8.0.0005'
grep -q "^${vim_version}" "${version_files_dir}/.vim" &>/dev/null || {
  echo "--> install vim v${vim_version}..."
  if [[ ! -f "/tmp/vim-${vim_version}.tar.gz" ]]; then
    curl -o "/tmp/vim-${vim_version}.tar.gz" \
      -L "https://github.com/vim/vim/archive/v${vim_version}.tar.gz"
  fi
  pushd "/tmp/" &>/dev/null
    tar xvfz "/tmp/vim-${vim_version}.tar.gz"
    rm -rf /usr/local/src/vim &>/dev/null
    mv "vim-${vim_version}" /usr/local/src/vim
    pushd "/usr/local/src/vim" &>/dev/null
      ./configure \
        --enable-multibyte \
        --prefix=/usr/local \
        --with-features=huge \
        --enable-pythoninterp \
        --enable-python3interp \
        --enable-luainterp \
        --enable-rubyinterp
      make install
      echo "${vim_version}" > "${version_files_dir}/.vim"
    popd &>/dev/null
  popd &>/dev/null
}

# Install docker-compose
docker_version="$(uname -s)-$(uname -m)"
docker_compose_version="1.8.0"
grep -q "^${docker_compose_version}" "${version_files_dir}/.docker_compose" &>/dev/null || {
  echo "--> install docker-compose v${docker_compose_version}..."
    curl -L "https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-${docker_version}" \
  > /usr/local/bin/docker-compose
  chmod 755 /usr/local/bin/docker-compose
  echo "${docker_compose_version}" > "${version_files_dir}/.docker_compose"
}

# Install vagrant
vagrant_version='1.8.5'
grep -q "^${vagrant_version}" "${version_files_dir}/.vagrant" &>/dev/null || {
  echo "--> install vagrant v${vagrant_version}..."
  if [[ ! -f "/tmp/vagrant-${vagrant_version}.deb" ]]; then
    curl -o "/tmp/vagrant-${vagrant_version}.deb" \
    "https://releases.hashicorp.com/vagrant/${vagrant_version}/vagrant_${vagrant_version}_x86_64.deb"
  fi
  dpkg -i "/tmp/vagrant-${vagrant_version}.deb"
  echo "${vagrant_version}" > "${version_files_dir}/.vagrant"
}

# Install fzf
if [[ ! -d /usr/local/src/fzf ]]; then
  echo "--> install fzf ..."
  git clone --depth 1 https://github.com/junegunn/fzf.git /usr/local/src/fzf
  /usr/local/src/fzf/install --no-completion --key-bindings --no-update-rc
  ln -sf /usr/local/src/fzf/bin/fzf /usr/local/bin/fzf
  ln -sf /usr/local/src/fzf/bin/fzf-tmux /usr/local/bin/fzf-tmux
fi

# Install fasd
if [[ ! -d /usr/local/src/fasd ]]; then
  echo "--> install fasd ..."
  git clone https://github.com/clvv/fasd.git /usr/local/src/fasd
  pushd "/usr/local/src/fasd" &>/dev/null
    make install
  popd &>/dev/null
fi

# Install stow
stow_version='2.2.2'
grep -q "^${stow_version}" "${version_files_dir}/.stow" &>/dev/null || {
  echo "--> install stow v${stow_version}..."
  if [[ ! -f "/tmp/stow-${stow_version}.tar.gz" ]]; then
    curl -L -o "/tmp/stow-${stow_version}.tar.gz" \
      "http://ftp.gnu.org/gnu/stow/stow-${stow_version}.tar.gz"
  fi
  pushd "/tmp/" &>/dev/null
    tar xvfz "/tmp/stow-${stow_version}.tar.gz"
    rm -rf /usr/local/src/stow &>/dev/null
    mv "stow-${stow_version}" /usr/local/src/stow
    pushd "/usr/local/src/stow" &>/dev/null
      ./configure
      make install
      echo "${stow_version}" > "${version_files_dir}/.stow"
    popd &>/dev/null
  popd &>/dev/null
}

# Install tmux
tmux_version='2.2'
grep -q "^${tmux_version}" "${version_files_dir}/.tmux" &>/dev/null || {
  echo "--> install tmux v${tmux_version}..."
  if [[ ! -f "/tmp/tmux-${tmux_version}.tar.gz" ]]; then
    curl -L -o "/tmp/tmux-${tmux_version}.tar.gz" \
      "https://github.com/tmux/tmux/releases/download/${tmux_version}/tmux-${tmux_version}.tar.gz"
  fi
  pushd "/tmp/" &>/dev/null
    tar xvfz "tmux-${tmux_version}.tar.gz"
    rm -rf /usr/local/src/tmux &>/dev/null || true
    mv "tmux-${tmux_version}" /usr/local/src/tmux
    pushd "/usr/local/src/tmux" &>/dev/null
      ./configure && make
      make install
      echo "${tmux_version}" > "${version_files_dir}/.tmux"
    popd &>/dev/null
  popd &>/dev/null
}

# Install bats
bats_version='0.4.0'
grep -q "^${bats_version}" "${version_files_dir}/.bats" &>/dev/null || {
  echo "--> install bats v${bats_version}..."
  if [[ ! -d /tmp/bats ]]; then
    git clone https://github.com/sstephenson/bats.git /tmp/bats
  fi
  pushd "/tmp/bats" &>/dev/null
      git co "v${bats_version}"
      ./install.sh /usr/local
      echo "${bats_version}" > "${version_files_dir}/.bats"
  popd &>/dev/null
}

# Install Hack font
hack_version='2.020'
if [[ ! -f "/tmp/hack-${hack_version}-ttf.zip" ]]; then
  echo "--> install hack font v${hack_version}..."
  curl -o "/tmp/hack-${hack_version}-ttf.zip" \
    -L "https://github.com/chrissimpkins/Hack/releases/download/v${hack_version}/Hack-v${hack_version/./_}-ttf.zip"
  unzip -d /usr/share/fonts/ "/tmp/hack-${hack_version}-ttf.zip"
fi

# Install sshrc
curl -o /usr/local/bin/sshrc -L \
  https://raw.githubusercontent.com/Russell91/sshrc/master/sshrc
chmod +x /usr/local/bin/sshrc

# Install vagrant
# XFCE setup
if [[ ! -d "/home/${DEBIAN_USER}/.local/share/themes/axe rounded" ]]; then
  echo "--> install xfce axe theme..."
  curl -L https://dl.opendesktop.org/api/files/download/id/1460767141/73291-axe.tar.gz -o /tmp/xfce-axe.tar.gz
  mkdir -p "/home/${DEBIAN_USER}/.local/share/themes"
  pushd "/tmp" &>/dev/null
    tar xvfz xfce-axe.tar.gz
    mv axe\ rounded "/home/${DEBIAN_USER}/.local/share/themes/"
    chown -R "${DEBIAN_USER}:${DEBIAN_USER}" "/home/${DEBIAN_USER}/.local"
  popd &>/dev/null
fi

lacapitaine_icon_theme_version=0.3.0
if [[ ! -d "/home/${DEBIAN_USER}/.icons/la-capitaine-icon-theme-${lacapitaine_icon_theme_version}" ]]; then
  echo "--> install icons theme lacapitaine v${lacapitaine_icon_theme_version}..."
  curl -L "https://dl.opendesktop.org/api/files/download/id/1472166359/la-capitaine-icon-theme-${lacapitaine_icon_theme_version}.tar.gz" \
    -o "/tmp/lacapitaine-icon-theme-${lacapitaine_icon_theme_version}.tar.gz"
  mkdir -p "/home/${DEBIAN_USER}/.icons"
  pushd "/tmp" &>/dev/null
    tar xvfz "lacapitaine-icon-theme-${lacapitaine_icon_theme_version}.tar.gz"
    mv "la-capitaine-icon-theme-${lacapitaine_icon_theme_version}" "/home/${DEBIAN_USER}/.icons/la-capitaine-icon-theme-${lacapitaine_icon_theme_version}"
    chown -R "${DEBIAN_USER}:${DEBIAN_USER}" "/home/${DEBIAN_USER}/.icons"
  popd &>/dev/null
fi

# Python
echo "--> install pip..."
hash pip &>/dev/null || {
  curl -o /tmp/get-pip.py -L "https://bootstrap.pypa.io/get-pip.py"
  python /tmp/get-pip.py
}

# Install install_ruby
install_ruby_version='0.6.0'
grep -q "^${install_ruby_version}" "${version_files_dir}/.install-ruby" &>/dev/null || {
  echo "--> install install-ruby v${install_ruby_version}..."
  if [[ ! -f "/tmp/install-ruby-${install_ruby_version}.tar.gz" ]]; then
    curl -L -o "/tmp/install-ruby-${install_ruby_version}.tar.gz" \
      "https://github.com/postmodern/ruby-install/archive/v${install_ruby_version}.tar.gz"
    curl -L -o "/tmp/install-ruby-${install_ruby_version}.tar.gz.asc" \
      "https://raw.github.com/postmodern/ruby-install/master/pkg/ruby-install-${install_ruby_version}.tar.gz.asc"
    gpg --verify "/tmp/ruby-install-${install_ruby_version}.tar.gz.asc" "/tmp/ruby-install-${install_ruby_version}.tar.gz"
  fi
  pushd "/tmp/" &>/dev/null
    tar xvfz "/tmp/install-ruby-${install_ruby_version}.tar.gz"
    rm -rf /usr/local/src/install-ruby &>/dev/null
    mv "ruby-install-${install_ruby_version}" /usr/local/src/install-ruby
    pushd "/usr/local/src/install-ruby" &>/dev/null
      make install
      mkdir -p ~/.rubies
      RUBIES=(
        2.3.0
      )
      for ruby in "${RUBIES[@]}"; do
        ruby-install --no-reinstall --rubies-dir "/home/${DEBIAN_USER}/.rubies" \
        ruby "$ruby"
      done
      echo "${RUBIES[@]:(-1)}" > "/home/${DEBIAN_USER}/.ruby-version"
      echo "${install_ruby_version}" > "${version_files_dir}/.install-ruby"
    popd &>/dev/null
  popd &>/dev/null
}

# Install chruby
chruby_version='0.3.9'
grep -q "^${chruby_version}" "${version_files_dir}/.chruby" &>/dev/null || {
  echo "--> install chruby v${chruby_version}..."
  if [[ ! -f "/tmp/chruby-${chruby_version}.tar.gz" ]]; then
    curl -L -o "/tmp/chruby-${chruby_version}.tar.gz" \
      "https://github.com/postmodern/chruby/archive/v${chruby_version}.tar.gz"
  fi
  pushd "/tmp/" &>/dev/null
    tar xvfz "/tmp/chruby-${chruby_version}.tar.gz"
    rm -rf /usr/local/src/chruby &>/dev/null
    mv "chruby-${chruby_version}" /usr/local/src/chruby
    pushd "/usr/local/src/chruby" &>/dev/null
      make install
      source   . /usr/local/share/chruby/chruby.sh
      chruby "$(cat ~/.ruby-version)"
      echo "${chruby_version}" > "${version_files_dir}/.chruby"
    popd &>/dev/null
  popd &>/dev/null
}

GEMS=(
  bundler
  rake
  serverspec
  travis
)

for gem in "${GEMS[@]}"; do
  gem list -i "${gem}" &>/dev/null || gem install "${gem}"
done

# Install albert
if [[ ! -d /usr/local/src/albert ]]; then
git clone https://github.com/ManuelSchneid3r/albert.git \
  /usr/local/src/albert
  pushd "/usr/local/src/albert" &>/dev/null
    cmake . -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
    make
    make install
  popd &>/dev/null
fi

# Firewall
# Set default chain policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Accept on localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

iptables -A INPUT -i docker0 -j ACCEPT
iptables -A OUTPUT -o docker0 -j ACCEPT

# Allow established sessions to receive traffic
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow SSH
iptables -I INPUT -p tcp --dport 22 -j ACCEPT
iptables-save > /etc/iptables/rules.v4

# Save iptables
iptables-save
