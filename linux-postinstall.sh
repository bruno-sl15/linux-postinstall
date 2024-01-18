URL_GOOGLE_CHROME="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
DIRETORIO_DOWNLOADS="$HOME/Downloads/Programas"
GIT_USER="bruno-sl15"
MEU_EMAIL="bruno.silvaleite15@gmail.com"
NGROK_AUTHTOKEN="1u5n8YGwAC0NLkfVC6jt08dMBjs_38G6BdWpYVNbRdKNRd3UY"

# Cores
VERMELHO='\e[1;91m'
VERDE='\e[1;92m'
SEM_COR='\e[0m'

PAUSE="Pressione Enter para continuar..."

PACOTES_PARA_INSTALAR=(
  libu2f-udev
  htop
  gparted
  git
  qbittorrent
  pipx
  cpu-checker
  qemu
  qemu-kvm
  libvirt-daemon
  libvirt-clients
  bridge-utils
  virt-manager
  libqt5help5
  libqt5opengl5
  libqt5printsupport5
  libqt5x11extras5
  nodejs
  npm
  xsel
)

PACOTES_PARA_REMOVER=(
  thunderbird
  hexchat
  transmission-common
)

create_aliases(){
  echo -e "${VERDE}Criando aliases${SEM_COR}"

  touch $HOME/.bash_aliases

  echo -e "alias atualizar='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && flatpak update && pipx upgrade-all && npm update'\n" >> $HOME/.bash_aliases

  echo -e "alias atualizar.desligar='sudo apt update |& tee ~/update.log && sudo apt upgrade -y |& tee -a ~/update.log && sudo apt autoremove -y |& tee -a ~/update.log && flatpak update -y |& tee -a ~/update.log && pipx upgrade-all |& tee -a ~/update.log && npm update |& tee -a ~/update.log && shutdown -h now'\n" >> $HOME/.bash_aliases

  echo -e "alias chat='shell-genie ask'" >> $HOME/.bash_aliases
  echo -e "alias suggest='gh copilot suggest'" >> $HOME/.bash_aliases
  echo -e "alias explain='gh copilot explain'" >> $HOME/.bash_aliases
}

apt_update(){
  echo -e "${VERDE}Atualizando pacotes apt:${SEM_COR}"

  sudo apt update && sudo apt upgrade -y
}

instalar_debs(){
  echo -e "${VERDE}Instalando pacotes deb:${SEM_COR}"

  mkdir "$DIRETORIO_DOWNLOADS"

  wget -c "$URL_GOOGLE_CHROME" -P "$DIRETORIO_DOWNLOADS"

  echo -e "${VERDE}Baixe o VS Code e o Virtual Box e coloque-os na pasta $DIRETORIO_DOWNLOADS.${SEM_COR}"
  read -p "$PAUSE"

  sudo dpkg -i $DIRETORIO_DOWNLOADS/*.deb
  rm -r $DIRETORIO_DOWNLOADS/
}

instalar_pacotes(){
  echo -e "${VERDE}Instalando pacotes apt:${SEM_COR}"

  for pacote in ${PACOTES_PARA_INSTALAR[@]}; do
    sudo apt install "$pacote" -y
  done
}

remover_pacotes(){
  echo -e "${VERDE}Removendo pacotes apt:${SEM_COR}"

  for pacote in ${PACOTES_PARA_REMOVER[@]}; do
    sudo apt purge "$pacote" -y
  done
  sudo apt autoremove -y
}

instalar_flatpaks(){
  echo -e "${VERDE}Instalando flatpaks:${SEM_COR}"

  flatpak update -y
  flatpak install flathub org.telegram.desktop -y
  flatpak install flathub com.stremio.Stremio -y
}

configurar_git(){
  echo -e "${VERDE}Configurando git:${SEM_COR}"

  git config --global user.name "$GIT_USER"
  git config --global user.email "$MEU_EMAIL"

  # gerar chave ssh
  ssh-keygen -t ed25519 -C "$MEU_EMAIL"
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_ed25519
  cat ~/.ssh/id_ed25519.pub

  echo -e "${VERDE}Copie a chave ssh acima e cole no github.${SEM_COR}"
  read -p "$PAUSE"
}

shell_genie(){
  echo -e "${VERDE}Instalando shell genie:${SEM_COR}"

  pipx ensurepath
  pipx install shell-genie

  touch $HOME/.config/.shell_genie/config.json

  echo "{
    'backend': 'free-genie',
    'os': 'Linux',
    'os_fullname': 'Linux Mint 21.2',
    'shell': 'bash',
    'training-feedback': False
  }" >> $HOME/.config/.shell_genie/config.json

}

pacotes_npm(){
  echo -e "${VERDE}Instalando pacotes npm:${SEM_COR}"

  npm install -g http-server
  npm install -g ngrok
  ngrok config add-authtoken $NGROK_AUTHTOKEN
}

github_cli_copilot(){
  echo -e "${VERDE}Instalando GitHub CLI e GitHub Copilot:${SEM_COR}"

  # Instalação do GitHub CLI
  type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update \
  && sudo apt install gh -y

  # Autenticação no GitHub CLI
  gh auth login

  # Instalação do GitHub Copilot
  gh extension install github/gh-copilot
}

# Execução
create_aliases
apt_update
instalar_pacotes
instalar_debs
remover_pacotes
instalar_flatpaks
configurar_git
shell_genie
pacotes_npm
github_cli_copilot
