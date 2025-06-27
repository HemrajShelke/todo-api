#!/bin/bash

installAgent() {
    # Global variables for Agent installation
    version="latest"
    os_name=""
    arch_name=""
    install_dir="$HOME/.keploy-agent/bin"
    binary_name="keploy-agent"
    shell_profile=""
    tmp_dir=""
    asset_filename=""
    download_url=""

    # Functions copied from keploy-agent.sh
    check_dependencies() {
        if ! command -v curl &> /dev/null; then
            echo "Error: 'curl' is required but not installed." >&2
            echo "Please install curl using your package manager (e.g., 'sudo apt install curl' on Ubuntu, 'brew install curl' on macOS)." >&2
            return 1
        fi

        if ! command -v unzip &> /dev/null; then
            echo "Error: 'unzip' is required but not installed." >&2
            echo "Please install unzip using your package manager (e.g., 'sudo apt install unzip' on Ubuntu, 'brew install unzip' on macOS)." >&2
            return 1
        fi
    }

    parse_arguments() {
        while [ "$#" -gt 0 ]; do
            case "$1" in
                -v)
                    if [[ "$2" =~ ^v[0-9]+\.[0-9]+\.[0-9]+-agent.* ]]; then
                        version="$2"
                        shift 2
                    else
                        echo "Error: Invalid version format." >&2
                        echo "Please use a semantic version format prefixed with 'v', like '-v v1.2.3-agent'." >&2
                        return 1
                    fi
                    ;;
                *)
                    echo "Warning: Ignoring unknown argument: $1" >&2
                    shift 1
                    ;;
            esac
        done
    }

    detect_os_arch() {
        case "$(uname -m)" in
            x86_64)
                arch_name="amd64"
                ;;
            aarch64|arm64)
                arch_name="arm64"
                ;;
            *)
                echo "Error: Unsupported architecture: $(uname -m)" >&2
                return 1
                ;;
        esac

        case "$(uname -s)" in
            Linux)
                os_name="linux"
                ;;
            Darwin)
                os_name="darwin_all"
                arch_name=""
                ;;
            *)
                echo "Error: Unsupported operating system: $(uname -s)" >&2
                return 1
                ;;
        esac
    }

    construct_download_url() {
        asset_filename="${binary_name}-${os_name}"
        if [ -n "$arch_name" ]; then
            asset_filename="${asset_filename}_${arch_name}"
        fi
        asset_filename="${asset_filename}.zip"

        if [ "$version" == "latest" ]; then
            download_url="https://keploy-enterprise.s3.us-west-2.amazonaws.com/releases/latest/${asset_filename}"
        else
            download_url="https://keploy-enterprise.s3.us-west-2.amazonaws.com/releases/${version}/${asset_filename}"
        fi
    }

    download_and_extract() {
        local zip_file="${tmp_dir}/${asset_filename}"
        curl --silent --show-error --location --output "$zip_file" "$download_url"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to download the Keploy Agent." >&2
            echo "Please check the version number and your network connection." >&2
            return 1
        fi

        unzip -o "$zip_file" -d "$tmp_dir" > /dev/null
        if [ $? -ne 0 ]; then
            echo "Error: Failed to unzip the archive." >&2
            return 1
        fi

        local binary_path="${tmp_dir}/${binary_name}"
        if [ ! -f "$binary_path" ]; then
            echo "Error: Binary not found in the archive." >&2
            return 1
        fi

        echo "$binary_path"
    }

    install_binary() {
        local binary_path="$1"
        local install_path="${install_dir}/${binary_name}"

        echo "Installing Keploy Agent to: $install_dir"
        mkdir -p "$install_dir"
        if [ ! -d "$install_dir" ]; then
            echo "Error: Failed to create installation directory: $install_dir" >&2
            return 1
        fi

        mv "$binary_path" "$install_path"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to move the binary to the installation directory." >&2
            return 1
        fi

        chmod +x "$install_path"
    }

    update_shell_profile() {
        local path_export_cmd="export PATH=\"${install_dir}:\$PATH\""
        local current_shell
        current_shell=$(basename "$SHELL")

        if [[ "$current_shell" = "zsh" || "$current_shell" = "-zsh" ]]; then
            shell_profile="$HOME/.zshrc"
        elif [[ "$current_shell" = "bash" || "$current_shell" = "-bash" ]]; then
            if [ -f "$HOME/.bash_profile" ]; then
                shell_profile="$HOME/.bash_profile"
            else
                shell_profile="$HOME/.bashrc"
            fi
        else
            shell_profile="$HOME/.profile"
        fi

        echo "Updating your shell profile: $shell_profile"

        if ! grep -q "# --- Keploy Agent ---" "$shell_profile"; then
            [ -n "$(tail -c 1 "$shell_profile")" ] && echo >> "$shell_profile"
            echo "" >> "$shell_profile"
            echo "# --- Keploy Agent ---" >> "$shell_profile"
            echo "$path_export_cmd" >> "$shell_profile"
        fi
    }

    print_instructions() {
        echo ""
        echo "✅ Keploy Agent installed successfully!"
        echo ""
        echo "To get started, please restart your terminal or run the following command:"
        echo "   source \"$shell_profile\""
        echo ""
        echo "You can then verify the installation by running:"
        echo "   keploy-agent --help"
        echo ""
    }

    tmp_dir=$(mktemp -d)
    trap "rm -rf \"${tmp_dir}\"" EXIT

    check_dependencies || return 1
    parse_arguments "$@" || return 1
    detect_os_arch || return 1
    construct_download_url
    if [ "$version" == "latest" ]; then
        echo "Installing the latest version of Keploy Agent..."
    else
        echo "Installing Keploy Agent version: $version..."
    fi
    echo "Downloading from: ${download_url}"

    local binary_path
    binary_path=$(download_and_extract)
    if [ $? -ne 0 ]; then
        return 1
    fi

    install_binary "$binary_path" || return 1
    update_shell_profile || return 1
    print_instructions
}

installKeploy() {
    version="latest"
    IS_CI=false
    NO_ROOT=false
    PLATFORM="$(basename "$SHELL")"
    for arg in "$@"; do
        case $arg in
        -isCI)
            IS_CI=true
            shift
            ;;
        -v)
            shift
            if [[ "$1" =~ ^v[0-9]+.* ]]; then
                version="${1:1}"
                shift
            else
                echo "Invalid version format. Please use '-v v<semver>'."
                return 1
            fi
            ;;
        -noRoot)
            NO_ROOT=true
            shift
            ;;
        *) ;;
        esac
    done

    if [ "$version" != "latest" ]; then
        echo "Installing Keploy version: $version......"
    fi

    install_keploy_arm() {
        if [ "$version" != "latest" ]; then
            download_url="https://keploy-enterprise.s3.us-west-2.amazonaws.com/releases/$version/enterprise_linux_arm64"
        else
            download_url="https://keploy-enterprise.s3.us-west-2.amazonaws.com/releases/latest/enterprise_linux_arm64"
        fi
        curl --silent --location "$download_url" -o /tmp/keploy

        if [ "$NO_ROOT" = true ]; then
            chmod a+x /tmp/keploy && mkdir -p "$HOME/.keploy/bin" && mv /tmp/keploy "$HOME/.keploy/bin"
        else
            sudo chmod a+x /tmp/keploy && sudo mkdir -p /usr/local/bin && sudo mv /tmp/keploy /usr/local/bin
        fi

        set_alias 'sudo -E env PATH="$PATH" keploy'

        check_docker_status_for_linux
        dockerStatus=$?
        if [ "$dockerStatus" -eq 0 ]; then
            return
        fi
        add_network
    }

    install_keploy_amd() {
        if [ $version != "latest" ]; then
            download_url="https://keploy-enterprise.s3.us-west-2.amazonaws.com/releases/$version/enterprise_linux_amd64"
        else
            download_url="https://keploy-enterprise.s3.us-west-2.amazonaws.com/releases/latest/enterprise_linux_amd64"
        fi
        curl --silent --location "$download_url" -o /tmp/keploy

        if [ "$NO_ROOT" = true ]; then
            chmod a+x /tmp/keploy && mkdir -p "$HOME/.keploy/bin" && mv /tmp/keploy "$HOME/.keploy/bin"
        else
            sudo chmod a+x /tmp/keploy && sudo mkdir -p /usr/local/bin && sudo mv /tmp/keploy /usr/local/bin
        fi

        set_alias 'sudo -E env PATH="$PATH" keploy'

        check_docker_status_for_linux
        dockerStatus=$?
        if [ "$dockerStatus" -eq 0 ]; then
            return
        fi
        add_network
    }

    append_to_rc() {
        last_byte=$(tail -c 1 $2)
        if [[ "$last_byte" != "" ]]; then
            echo -e "\n$1" >>$2
        else
            echo "$1" >>$2
        fi
        source $2
    }

    update_path() {
        PATH_CMD="export PATH=\"\$HOME/.keploy/bin:\$PATH\""
        rc_file="$1"
        if [ -f "$rc_file" ]; then
            if ! grep -q "$PATH_CMD" "$rc_file"; then
                append_to_rc "$PATH_CMD" "$rc_file"
            fi
        else
            export PATH="$PATH_CMD"
        fi
    }

    # Get the alias to set and set it
    set_alias() {
        current_shell="$PLATFORM"
        if [ "$NO_ROOT" = "true" ]; then
            # Just update the PATH in .zshrc or .bashrc, no alias needed
            if [[ "$current_shell" = "zsh" || "$current_shell" = "-zsh" ]]; then
                update_path "$HOME/.zshrc"
            elif [[ "$current_shell" = "bash" || "$current_shell" = "-bash" ]]; then
                update_path "$HOME/.bashrc"
            else
                update_path "$HOME/.profile"
            fi
        else
            # Check if the command is for docker or not
            if [[ "$1" == *"docker"* ]]; then
                # Check if the user is a member of the docker group
                check_sudo
                sudoCheck=$?
                if [ "$sudoCheck" -eq 0 ] && [ $OS_NAME = "Linux" ]; then
                    # Add sudo to the alias.
                    ALIAS_CMD="alias keploy='sudo $1'"
                else
                    ALIAS_CMD="alias keploy='$1'"
                fi
            else
                ALIAS_CMD="alias keploy='$1'"
            fi
            current_shell="$(basename "$SHELL")"
            if [[ "$current_shell" = "zsh" || "$current_shell" = "-zsh" ]]; then
                if [ -f ~/.zshrc ]; then
                    if grep -q "alias keploy=" ~/.zshrc; then
                        if [ "$OS_NAME" = "Darwin" ]; then
                            sed -i '' '/alias keploy/d' ~/.zshrc
                        else
                            sed -i '/alias keploy/d' ~/.zshrc
                        fi
                    fi
                    append_to_rc "$ALIAS_CMD" ~/.zshrc
                else
                    alias keploy="$1"
                fi
            elif [[ "$current_shell" = "bash" || "$current_shell" = "-bash" ]]; then
                if [ -f ~/.bashrc ]; then
                    if grep -q "alias keploy=" ~/.bashrc; then
                        if [ "$OS_NAME" = "Darwin" ]; then
                            sed -i '' '/alias keploy/d' ~/.bashrc
                        else
                            sed -i '/alias keploy/d' ~/.bashrc
                        fi
                    fi
                    append_to_rc "$ALIAS_CMD" ~/.bashrc
                else
                    alias keploy="$1"
                fi
            else
                alias keploy="$1"
            fi
        fi
    }

    check_sudo() {
        if groups | grep -q '\bdocker\b'; then
            return 1
        else
            return 0
        fi
    }

    check_docker_status_for_linux() {
        check_sudo
        sudoCheck=$?
        network_alias=""
        if [ "$sudoCheck" -eq 0 ]; then
            # Add sudo to docker
            network_alias="sudo"
        fi
        if ! $network_alias which docker &>/dev/null; then
            echo -n "Docker not found on device, please install docker and reinstall keploy if you have applications running on docker"
            return 0
        fi
        if ! $network_alias docker info &>/dev/null; then
            echo "Please start Docker and reinstall keploy if you have applications running on docker"
            return 0
        fi
        return 1
    }

    check_docker_status_for_Darwin() {
        check_sudo
        sudoCheck=$?
        network_alias=""
        if [ "$sudoCheck" -eq 0 ]; then
            # Add sudo to docker
            network_alias="sudo"
        fi
        if ! $network_alias which docker &>/dev/null; then
            echo -n "Docker not found on device, please install docker to use Keploy"
            return 0
        fi
        # Check if docker is running
        if ! $network_alias docker info &>/dev/null; then
            echo "Keploy only supports intercepting and replaying docker containers on macOS, and requires Docker to be installed and running. Please start Docker and try again."
            return 0
        fi
        return 1
    }

    add_network() {
        if ! $network_alias docker network ls | grep -q 'keploy-network'; then
            $network_alias docker network create keploy-network
        fi
    }

    delete_keploy_alias() {
        current_shell="$PLATFORM"
        shell_rc_file=""
        if [[ "$current_shell" = "zsh" || "$current_shell" = "-zsh" ]]; then
            shell_rc_file="$HOME/.zshrc"
        elif [[ "$current_shell" = "bash" || "$current_shell" = "-bash" ]]; then
            shell_rc_file="$HOME/.bashrc"
        else
            echo "Unsupported shell: $current_shell"
            return
        fi
        if [ -f "$shell_rc_file" ]; then
            if grep -q "alias keploy=" "$shell_rc_file"; then
                if [[ "$(uname)" = "Darwin" ]]; then
                    sed -i '' '/alias keploy/d' "$shell_rc_file"
                else
                    sed -i '/alias keploy/d' "$shell_rc_file"
                fi
            fi
        fi
        if alias keploy &>/dev/null; then
            unalias keploy
        fi
    }

    install_keploy_darwin_all() {
        delete_keploy_alias
        if [ $version != "latest" ]; then
            download_url="https://keploy-enterprise.s3.us-west-2.amazonaws.com/releases/$version/enterprise_darwin_all"
        else
            download_url="https://keploy-enterprise.s3.us-west-2.amazonaws.com/releases/latest/enterprise_darwin_all"
        fi
        rm -rf /tmp/keploy
        mkdir -p /tmp/keploy
        curl --silent --location $download_url -o /tmp/keploy/keploy

        if [ "$NO_ROOT" = "true" ]; then
            target_dir="$HOME/.keploy/bin"
            source_dir="/tmp/keploy/keploy"
            mkdir -p "$target_dir"
            if [ $? -ne 0 ]; then
                echo "Error: Failed to create directory $target_dir"
                exit 1
            fi

            if [ -f "$source_dir" ]; then
                mv "$source_dir" "$target_dir/keploy"
                if [ $? -ne 0 ]; then
                    echo "Error: Failed to move the keploy binary from $source_dir to $target_dir"
                    exit 1
                fi
            else
                echo "Error: $source_dir does not exist."
                exit 1
            fi

            chmod +x "$target_dir/keploy"
            if [ $? -ne 0 ]; then
                echo "Error: Failed to make the keploy binary executable"
                exit 1
            fi
        else
            source_dir="/tmp/keploy/keploy"
            sudo mkdir -p /usr/local/bin && sudo mv "$source_dir" /usr/local/bin/keploy
            sudo chmod +x /usr/local/bin/keploy
            if [ $? -ne 0 ]; then
                echo "Error: Failed to make the keploy binary executable"
                exit 1
            fi

            check_docker_status_for_Darwin
            dockerStatus=$?
            if [ "$dockerStatus" -eq 0 ]; then
                return
            fi

            add_network
        fi

        set_alias 'sudo -E env PATH="$PATH" keploy'

    }

    install_docker() {
        if [ "$OS_NAME" = "Darwin" ]; then
            check_docker_status_for_Darwin
            dockerStatus=$?
            if [ "$dockerStatus" -eq 0 ]; then
                return
            fi
            add_network
            if ! docker volume inspect debugfs &>/dev/null; then
                docker volume create --driver local --opt type=debugfs --opt device=debugfs debugfs
            fi
            set_alias 'docker run --pull always --name keploy-v2 -p 16789:16789 --privileged --pid=host -it -v $(pwd):$(pwd) -w $(pwd) -v /sys/fs/cgroup:/sys/fs/cgroup -v debugfs:/sys/kernel/debug:rw -v /sys/fs/bpf:/sys/fs/bpf -v /var/run/docker.sock:/var/run/docker.sock -v '"$HOME"'/.keploy:/root/.keploy --rm docker.io/keploy/enterprise'
        else
            set_alias 'docker run --pull always --name keploy-v2 -p 16789:16789 --privileged --pid=host -it -v $(pwd):$(pwd) -w $(pwd) -v /sys/fs/cgroup:/sys/fs/cgroup -v /sys/kernel/debug:/sys/kernel/debug -v /sys/fs/bpf:/sys/fs/bpf -v /var/run/docker.sock:/var/run/docker.sock -v '"$HOME"'/.keploy:/root/.keploy --rm docker.io/keploy/enterprise'
        fi
    }

    ARCH=$(uname -m)

    if [ "$IS_CI" = false ]; then
        OS_NAME="$(uname -s)"
        if [ "$OS_NAME" = "Darwin" ]; then
            install_keploy_darwin_all
            return
        elif [ "$OS_NAME" = "Linux" ]; then
            if [ "$NO_ROOT" = false ]; then
                if ! mountpoint -q /sys/kernel/debug; then
                    sudo mount -t debugfs debugfs /sys/kernel/debug
                fi
            fi
            if [ "$ARCH" = "x86_64" ]; then
                install_keploy_amd
            elif [ "$ARCH" = "aarch64" ]; then
                install_keploy_arm
            else
                echo "Unsupported architecture: $ARCH"
                return
            fi
        elif [[ "$OS_NAME" == MINGW32_NT* ]] || [[ "$OS_NAME" == MINGW64_NT* ]]; then
            echo "\e]8;; https://pureinfotech.com/install-windows-subsystem-linux-2-windows-10\aWindows not supported please run on WSL2\e]8;;\a"
        else
            echo "Unknown OS, install Linux to run Keploy"
        fi
    else
        if [ "$ARCH" = "x86_64" ]; then
            install_keploy_amd
        elif [ "$ARCH" = "aarch64" ]; then
            install_keploy_arm
        else
            echo "Unsupported architecture: $ARCH"
            return
        fi
    fi
}

remove_scripts() {
    rm -rf keploy-enterprise.sh
    rm -rf install.sh
}

if [[ "$1" == "--agent" ]]; then
    installAgent "$@"
    if command -v keploy-agent &>/dev/null; then
        keploy-agent --help
        remove_scripts
    fi
else
    installKeploy "$@"
    if command -v keploy &>/dev/null; then
        keploy example
        remove_scripts
    fi
fi
