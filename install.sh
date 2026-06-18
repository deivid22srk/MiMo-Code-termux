#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

echo "=== Instalando dependências para MiMo-Code no Termux ==="
# 1. Atualizar pacotes e instalar glibc-repo
pkg update -y
pkg install -y glibc-repo

# 2. Atualizar novamente para carregar o novo repositório e instalar as bibliotecas de compatibilidade
pkg update -y
pkg install -y glibc openssl-glibc ncurses-glibc glibc-runner tar curl

# 3. Definir diretórios de instalação
INSTALL_DIR="$HOME/.mimocode/bin"
mkdir -p "$INSTALL_DIR"

echo "=== Baixando o MiMo-Code ==="
# 4. Baixar a versão mais recente do MiMo-Code para Linux ARM64
APP="mimocode"
target="linux-arm64"
filename="${APP}-${target}.tar.gz"
url="https://github.com/XiaomiMiMo/MiMo-Code/releases/latest/download/${filename}"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

echo "Baixando de $url..."
curl -L -o "$tmp_dir/$filename" "$url"

echo "Extraindo..."
tar -xzf "$tmp_dir/$filename" -C "$tmp_dir"

# Mover o binário original para mimo.real
mv "$tmp_dir/mimo" "$INSTALL_DIR/mimo.real"
chmod 755 "$INSTALL_DIR/mimo.real"

echo "=== Criando Wrapper de compatibilidade do Termux ==="
# Criar o script de atalho que executa o mimo real através de grun
cat << 'EOF' > "$INSTALL_DIR/mimo"
#!/data/data/com.termux/files/usr/bin/bash
exec grun "/data/data/com.termux/files/home/.mimocode/bin/mimo.real" "$@"
EOF
chmod 755 "$INSTALL_DIR/mimo"

# 5. Adicionar ao PATH no .bashrc ou .zshrc
config_file="$HOME/.bashrc"
command_to_add="export PATH=\$HOME/.mimocode/bin:\$PATH"

if [ -f "$HOME/.zshrc" ]; then
    config_file="$HOME/.zshrc"
fi

if grep -q "mimocode" "$config_file" 2>/dev/null; then
    echo "O caminho do mimocode já existe no arquivo $config_file"
else
    echo -e "\n# mimocode" >> "$config_file"
    echo "$command_to_add" >> "$config_file"
    echo "Caminho adicionado ao PATH no arquivo $config_file"
fi

echo "=== Instalação do MiMo-Code concluída com sucesso! ==="
echo "Reinicie seu terminal ou execute: source $config_file"
echo "Depois inicie executando o comando: mimo"
