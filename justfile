#!/usr/bin/env just --justfile

alias up := update

default:
  @just --choose

update: update-brew update-sdkman update-rust update-node update-npm update-pip update-gem update-cdk update-amplify update-zinit update-spacevim update-xcode

update-brew:
    brew update
    brew upgrade

update-sdkman:
    #!/usr/bin/env zsh
    source "$SDKMAN_DIR/bin/sdkman-init.sh"
    echo "$(tput bold)sdk update$(tput sgr0)"
    sdk update
    echo "$(tput bold)sdk upgrade$(tput sgr0)"
    sdk upgrade

update-rust:
    rustup update

update-node:
    #!/usr/bin/env zsh
    source "$NVM_DIR/nvm.sh"
    set -eo pipefail

    local -r local_node_version=$(nvm version)
    local -r local_major_node_version=$(echo $local_node_version | ggrep -oP "v\K([0-9]+)")
    local -r local_node_lts=$(nvm ls --no-colors | ggrep -oP "^lts/\K([a-z]+)(?=\ ->\ v$local_major_node_version\..*$)")
    echo "$(tput bold)⬇️  Fetching the latest Node.js $local_node_lts version…$(tput sgr0)"
    local -r remote_node_version=$(nvm version-remote lts/$local_node_lts)
    if [ "$local_node_version" != "$remote_node_version" ]; then
        echo "$(tput setaf 4)❗️ A new version of Node.js $local_node_lts was found!$(tput sgr0)"
        #echo "🔄 Updating Node.js $local_node_lts ($local_node_version -> $remote_node_version)…"
        #nvm install "lts/$local_node_lts" --reinstall-packages-from="$local_node_version"  # --latest-npm is not working
        #nvm uninstall "$local_node_version"
        #nvm use "lts/$local_node_lts"
        #nvm alias default "lts/$local_node_lts"
        #nvm cache clear
    fi
    echo "$(tput setaf 2)✅ Node.js $local_node_lts is up-to-date ($(nvm version))$(tput sgr0)"

update-npm:
    #!/usr/bin/env zsh
    source "$NVM_DIR/nvm.sh"
    set -euo pipefail

    echo "$(tput bold)nvm install-latest-npm$(tput sgr0)"
    nvm install-latest-npm
    echo "$(tput bold)npm -g update$(tput sgr0)"
    npm -g update

update-pip:
    pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install -U

update-gem:
    gem update --system

update-cdk:
    npm install -g aws-cdk

update-amplify:
    amplify upgrade

update-zinit:
    #!/usr/bin/env zsh
    source "$ZINIT_HOME/zinit/zinit.git/zinit.zsh"
    set -eo pipefail

    echo "$(tput bold)zinit self-update$(tput sgr0)"
    zinit self-update
    echo "$(tput bold)zinit update --parallel$(tput sgr0)"
    zinit update --parallel

update-spacevim:
    git -C ~/.SpaceVim/ pull

update-tealdeer:
    tldr --update

update-xcode:
    #!/usr/bin/env zsh
    set -eo pipefail

    local -r local_xcode_version=$(xcodes list | grep 'Selected' | sd '\s\(.+$' '')
    echo "$(tput bold)⬇️  Fetching the latest Xcode version…$(tput sgr0)"
    local -r remote_xcode_version=$(xcodes list | tail -1 | sd '\s\(.+$' '')
    if [ "$local_xcode_version" != "$remote_xcode_version" ]; then
        echo "$(tput setaf 4)❗️ A new version of Xcode was found! ($local_xcode_version -> $remote_xcode_version)$(tput sgr0)"
    else
        echo "$(tput setaf 2)✅ Xcode is up-to-date ($local_xcode_version)$(tput sgr0)"
    fi

update-macos:
    softwareupdate --install --all --force


show-installed-packages:
    brew deps --installed --tree

show-path:
    echo $PATH | tr ':' '\n'


encrypt:
    @echo "$(tput bold)🔏 Paste the message to encrypt (Return Ctrl+D when done):$(tput sgr0)"
    gpg -esar alexandre@gressier.dev

decrypt:
    @echo "$(tput bold)🔓 Paste the message to decrypt (Return Ctrl+D when done):$(tput sgr0)"
    gpg -d


brew-clean:
    brew autoremove
    brew cleanup


boostrap-npm:
    npm install -g npm-check-updates aws-cdk @aws-amplify/cli

bootstrap-pip:
    pip install awscli aws-sam-cli

boostrap-gem:
    gem install bundler rake cocoapods fastlane
