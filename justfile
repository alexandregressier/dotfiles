#!/usr/bin/env just --justfile

alias up := update

default:
  @just --choose

update: update-macos update-brew update-sdkman update-node update-npm update-gems update-pip update-tealdeer

update-macos:
    softwareupdate --install --all --force

update-brew:
    brew update
    brew upgrade

update-sdkman:
    #!/usr/bin/env zsh
    safe_source "$SDKMAN_DIR/bin/sdkman-init.sh"
    echo "$(tput bold)sdk update$(tput sgr0)"
    sdk update
    echo "$(tput bold)sdk upgrade$(tput sgr0)"
    sdk upgrade

update-node:
    #!/usr/bin/env zsh
    safe_source "$NVM_DIR/nvm.sh"
    set -eo pipefail

    local -r local_node_version=$(nvm version)
    local -r local_node_lts=$(nvm ls --no-colors | ggrep -oP "^lts/\K([a-z]+)(?=\ ->\ $local_node_version.*$)")
    echo "$(tput bold)⬇️  Fetching the latest Node.js $local_node_lts version…$(tput sgr0)"
    local -r remote_node_version=$(nvm version-remote lts/$local_node_lts)
    if [ "$local_node_version" != "$remote_node_version" ]; then
        echo "$(tput setaf 4)❗️ A new version of Node.js $local_node_lts was found!$(tput sgr0)"
        echo "🔄 Updating Node.js $local_node_lts ($local_node_version -> $remote_node_version)…"
        nvm install "lts/$local_node_lts" --reinstall-packages-from="$previous_node_version" # --latest-npm is not working
        nvm uninstall "$previous_node_version"
        nvm cache clear
    fi
    echo "$(tput setaf 2)✅ Node.js $local_node_lts is up-to-date ($local_node_version)$(tput sgr0)"

update-npm:
    #!/usr/bin/env zsh
    safe_source "$NVM_DIR/nvm.sh"
    set -euo pipefail

    echo "$(tput bold)nvm install-latest-npm$(tput sgr0)"
    nvm install-latest-npm
    echo "$(tput bold)npm -g update$(tput sgr0)"
    npm -g update

update-gems:
    gem update --system

update-pip:
    pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install -U

update-tealdeer:
    tldr --update


show-path:
    echo $PATH | tr ':' '\n'


encrypt:
    @echo "$(tput bold)🔏 Paste the message to encrypt (Return Ctrl+D when done):$(tput sgr0)"
    gpg -esar alexandre@gressier.dev

decrypt:
    @echo "$(tput bold)🔓 Paste the message to decrypt (Return Ctrl+D when done):$(tput sgr0)"
    gpg -d