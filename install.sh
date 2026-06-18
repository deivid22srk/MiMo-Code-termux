#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Definindo cores (ANSI escape sequences)
NC='\033[0m'              # No Color / Reset
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'

# Cores de texto Negrito
B_CYAN='\033[1;36m'
B_GREEN='\033[1;32m'
B_YELLOW='\033[1;33m'
B_RED='\033[1;31m'
B_PURPLE='\033[1;35m'

show_banner() {
    clear
    echo -e "${B_CYAN}"
    echo -e "    __  ____ __  ___        ______          __    "
    echo -e "   /  |/  (_)  |/  /___    / ____/___  ____/ /__  "
    echo -e "  / /|_/ / / /|_/ / __ \  / /   / __ \/ __  / _ \ "
    echo -e " / /  / / / /  / / /_/ / / /___/ /_/ / /_/ /  __/ "
    echo -e "/_/  /_/_/_/  /_/\____/  \____/\____/\__,_/\___|  "
    echo -e "             ${ITALIC}Terminal-Native AI Assistant${NC}"
    echo -e "${DIM}======================================================${NC}"
    echo ""
}

info() {
    echo -e " ${B_CYAN}[info]${NC} $1"
}

success() {
    echo -e " ${B_GREEN}[ok]${NC}   $1"
}

warn() {
    echo -e " ${B_YELLOW}[warn]${NC} $1"
}

step() {
    echo -e "\n${BOLD}${B_PURPLE}➔ Step:${NC} ${BOLD}$1${NC}"
}

# Mostrar o cabeçalho inicial
show_banner

# 1. Atualizar pacotes e instalar glibc-repo
step "Instalando dependências para MiMo-Code no Termux"

info "Atualizando repositório base do Termux..."
pkg update -y

info "Instalando repositório de compatibilidade glibc-repo..."
pkg install -y glibc-repo

# 2. Atualizar novamente para carregar o novo repositório e instalar as bibliotecas de compatibilidade
info "Atualizando para carregar o novo repositório..."
pkg update -y

info "Instalando glibc, glibc-runner, openssl, ncurses, tar e curl..."
pkg install -y glibc openssl-glibc ncurses-glibc glibc-runner tar curl

# 3. Definir diretórios de instalação
step "Criando diretório de instalação"
INSTALL_DIR="$HOME/.mimocode/bin"
mkdir -p "$INSTALL_DIR"
success "Diretório criado: ${DIM}$INSTALL_DIR${NC}"

# 4. Baixar a versão mais recente do MiMo-Code para Linux ARM64
step "Baixando a versão mais recente do MiMo-Code"
APP="mimocode"
target="linux-arm64"
filename="${APP}-${target}.tar.gz"
url="https://github.com/XiaomiMiMo/MiMo-Code/releases/latest/download/${filename}"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

info "Baixando pacote de: ${DIM}$url${NC}"
curl -L -o "$tmp_dir/$filename" "$url"

info "Extraindo arquivos do pacote..."
tar -xzf "$tmp_dir/$filename" -C "$tmp_dir"

info "Movendo executável principal..."
mv "$tmp_dir/mimo" "$INSTALL_DIR/mimo.real"
chmod 755 "$INSTALL_DIR/mimo.real"
success "Executável instalado com sucesso!"

# Criar Wrapper de compatibilidade do Termux
step "Configurando Wrapper de compatibilidade"
info "Criando script de atalho com grun..."
cat << 'EOF' > "$INSTALL_DIR/mimo"
#!/data/data/com.termux/files/usr/bin/bash
exec grun "/data/data/com.termux/files/home/.mimocode/bin/mimo.real" "$@"
EOF
chmod 755 "$INSTALL_DIR/mimo"
success "Wrapper de compatibilidade ativado!"

# 5. Adicionar ao PATH no .bashrc ou .zshrc
step "Configurando variável de ambiente PATH"
config_file="$HOME/.bashrc"
command_to_add="export PATH=\$HOME/.mimocode/bin:\$PATH"

if [ -f "$HOME/.zshrc" ]; then
    config_file="$HOME/.zshrc"
fi

if grep -q "mimocode" "$config_file" 2>/dev/null; then
    warn "O caminho do mimocode já existe no arquivo ${DIM}$config_file${NC}"
else
    echo -e "\n# mimocode" >> "$config_file"
    echo "$command_to_add" >> "$config_file"
    success "Caminho adicionado ao PATH no arquivo ${DIM}$config_file${NC}"
fi

echo ""
echo -e "${DIM}======================================================${NC}"
echo -e " ${B_GREEN}🎉 Instalação do MiMo-Code concluída com sucesso! 🎉${NC}"
echo -e "   Para começar a usar, siga as etapas abaixo:"
echo ""
echo -e "   1. Reinicie seu terminal ou execute:"
echo -e "      ${BOLD}source $config_file${NC}"
echo ""
echo -e "   2. Inicie o assistente de IA com o comando:"
echo -e "      ${B_CYAN}mimo${NC}"
echo -e "${DIM}======================================================${NC}"
