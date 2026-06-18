# MiMo-Code-termux

Instalador automático do **MiMo-Code** para o **Termux** no Android (arquitetura `aarch64`).

O MiMo-Code é um assistente de programação IA terminal-native desenvolvido pela Xiaomi. Como o binário oficial é compilado para Linux com `glibc`, este script automatiza a instalação das dependências do `glibc-repo` no Termux e configura um wrapper usando `grun` para fazê-lo funcionar nativamente de forma automática.

## Como Instalar

Abra o Termux e execute o seguinte comando para instalar tudo automaticamente a partir do zero:

```bash
curl -fsSL https://raw.githubusercontent.com/deivid22srk/MiMo-Code-termux/main/install.sh | bash
```

## O que o script faz?

1. Ativa o repositório de compatibilidade `glibc-repo` no Termux.
2. Instala as dependências necessárias de compatibilidade (`glibc`, `openssl-glibc`, `ncurses-glibc`, `grun`, `tar`, `curl`).
3. Baixa a versão mais recente do binário do MiMo-Code para Linux ARM64.
4. Renomeia o binário original para `mimo.real` e cria um script wrapper `mimo` que o executa utilizando `grun`.
5. Adiciona o diretório do wrapper ao seu `$PATH` no arquivo `.bashrc` ou `.zshrc` automaticamente.
