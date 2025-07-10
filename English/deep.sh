#!/data/data/com.termux/files/usr/bin/bash

# Current script version
SCRIPT_VERSION="1.1"

# Check dependencies
if ! command -v dialog &> /dev/null; then
    echo "✨ Installing dialog..."
    pkg install dialog -y >/dev/null 2>&1 || { echo "❌❌ Installation failed! Manual command: pkg install dialog"; exit 1; }
fi

# Check curl dependency
if ! command -v curl &> /dev/null; then
    echo "✨ Installing curl..."
    pkg install curl -y >/dev/null 2>&1 || { echo "❌❌ curl installation failed! Manual command: pkg install curl"; exit 1; }
fi

# Check and install Ollama
check_and_install_ollama() {
    if ! command -v ollama &> /dev/null; then
        # Show installation prompt
        dialog --infobox "Ollama not detected, installing now..." 5 50
        
        # Create temporary log file
        log_file="/tmp/ollama_install_$$.log"
        
        # Try multiple installation sources
        sources=(
            "https://ollama.ai/install.sh"
            "https://ghproxy.com/https://ollama.ai/install.sh"
            "https://cdn.jsdelivr.net/gh/ollama/ollama.ai/install.sh"
            "https://raw.fastgit.org/ollama/ollama.ai/main/install.sh"
        )
        
        success=0
        
        for source in "${sources[@]}"; do
            if curl -s "$source" | sh > "$log_file" 2>&1; then
                success=1
                break
            fi
            sleep 1
        done
        
        if [ $success -eq 1 ]; then
            dialog --msgbox "✅ Ollama installed successfully!\n\nPlease restart terminal or run: source ~/.bashrc" 8 50
        else
            dialog --msgbox "❌❌ Ollama installation failed!\n\nError log:\n$(tail -n 10 "$log_file")\n\nTry manual installation: curl https://ollama.ai/install.sh | sh" 15 60
            rm "$log_file"
            exit 1
        fi
        
        rm "$log_file"
    fi
}

# Configuration file path
CONFIG_FILE="$HOME/.ollama_manager.cfg"

# Initialize configuration
init_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        cat > "$CONFIG_FILE" <<EOF
AUTO_UPDATE=0
EOF
    fi
    source "$CONFIG_FILE"
}

# Save configuration
save_config() {
    cat > "$CONFIG_FILE" <<EOF
AUTO_UPDATE=$AUTO_UPDATE
EOF
}

# Emoji array
declare -A KAOMOJI=(
    ["happy"]="ヽ(•‿•)ノ"
    ["angry"]="(╯°□°╯╯︵ ┻━┻"
    ["think"]='(。-`ω´-)'
    ["cool"]="(⌐■_■)"
    ["shock"]="(⊙_☉)"
    ["run"]="ε=ε=ε=┏(゜ロ゜;)┛"
    ["done"]="✅"
    ["fail"]="❌"
    ["download"]="📥"
    ["model"]="🧠"
    ["fire"]="🔥"
    ["update"]="🔄"
    ["mirror"]="🪞"
    ["settings"]="⚙️"
    ["about"]="ℹ️"
)

# Get installed models
get_models() {
    if command -v ollama &> /dev/null; then
        ollama list | awk 'NR>1 {print $1}'
    else
        echo ""
    fi
}

# Show welcome title
show_welcome() {
    clear
    echo -e "\033[1;36m


|____    _____  .           _____  |     |
|    |  |          |\   |  |       |     |
|    |   -----  |  | \  |   ------ |_____|
|    |       |  |  |  \ |         ||     |
|~~~~    -----  |  |   \|   －－－  |     |
 D        S     I    N         S      H

         DeepSeek IN SHell

           Starting up...

      powered by ollama Linuxshell
\033[0m"
    echo -e "       ${KAOMOJI[model]} \033[1;33mDSINSH Terminal Manager v$SCRIPT_VERSION ${KAOMOJI[fire]}\033[0m"
    sleep 1
}

# Check for updates
check_updates() {
    # Show progress info
    dialog --infobox "Checking for updates, may take a while..." 5 40
    
    # Check internet connection
    if ! ping -c 1 github.com >/dev/null 2>&1; then
        dialog --msgbox "${KAOMOJI[fail]} No internet connection! Skipping update check" 6 50
        return
    fi
    
    # Get remote version info
    remote_version=$(curl -s "https://raw.githubusercontent.com/sttgf/Android-t-in-phone/main/visions.txt")
    
    if [ -z "$remote_version" ]; then
        dialog --msgbox "${KAOMOJI[fail]} Failed to get remote version info!" 6 50
        return
    fi
    
    if [ "$remote_version" != "$SCRIPT_VERSION" ]; then
        dialog --yesno "${KAOMOJI[update]} New version found: $remote_version (Current: $SCRIPT_VERSION)\nUpdate now?" 10 50
        
        if [ $? -eq 0 ]; then
            # User chose to update
            update_script
        fi
    else
        dialog --msgbox "${KAOMOJI[done]} You have the latest version!" 6 40
    fi
}

# Update script
update_script() {
    # Get current script directory
    CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Create temporary update script path
    update_script_path="$CURRENT_DIR/deep_update_$$.sh"
    final_script_path="$CURRENT_DIR/deep.sh"
    st_script_path="$CURRENT_DIR/st.sh"
    
    # Define multiple download sources
    sources=(
        "https://raw.githubusercontent.com/sttgf/Android-t-in-phone/main/English/deep.sh"
        "https://ghproxy.com/https://raw.githubusercontent.com/sttgf/Android-t-in-phone/main/English/deep.sh"
        "https://cdn.jsdelivr.net/gh/sttgf/Android-t-in-phone/English/deep.sh"
        "https://raw.fastgit.org/sttgf/Android-t-in-phone/main/English/deep.sh"
        "https://gcore.jsdelivr.net/gh/sttgf/Android-t-in-phone/English/deep.sh"
        "https://cdn.staticaly.com/gh/sttgf/Android-t-in-phone/main/English/deep.sh"
        "https://raw.gitmirror.com/sttgf/Android-t-in-phone/main/English/deep.sh"
    )
    
    success=0
    
    for source in "${sources[@]}"; do
        dialog --infobox "${KAOMOJI[mirror]} Trying source: ${source:0:40}..." 5 60
        if curl -s -o "$update_script_path" "$source"; then
            success=1
            break
        fi
        sleep 1
    done
    
    if [ $success -eq 0 ]; then
        dialog --msgbox "${KAOMOJI[fail]} All download sources failed!\n\nManual update:\n1. Visit: https://github.com/sttgf/Android-t-in-phone/English/. Download deep.sh. Replace current script" 12 60
        return
    fi
    
    # Set execute permission
    chmod +x "$update_script_path"
    
    # Rename update file
    mv "$update_script_path" "$final_script_path"
    
    # Create launch script
    echo "#!/bin/bash" > "$st_script_path"
    echo "bash \"$final_script_path\"" >> "$st_script_path"
    chmod +x "$st_script_path"
    
    # Execute new script
    dialog --infobox "${KAOMOJI[update]} Update complete! Launching new version..." 5 50
    sleep 2
    exec "$st_script_path"
}

# About animation
about_animation() {
    clear
    
    # Show animated title
    echo -e "\033[1;36m"
    echo "    "
    echo "    "
    echo "    DS in sh"
    echo "    "
    echo "    "
    sleep 0.5
    
    # Author info
    clear
    echo -e "\033[1;36m"
    echo "    "
    echo "    "
    echo "    DS in sh"
    echo "    "
    echo "    Author: LHRstudios"
    echo "    "
    sleep 0.5
    
    # Version info
    clear
    echo -e "\033[1;36m"
    echo "    "
    echo "    "
    echo "    DS in sh"
    echo "    "
    echo "    Author: LHRstudios"
    echo "    Version: v$SCRIPT_VERSION"
    echo "    "
    echo "    "
    sleep 0.5
    
    # Thank you message
    clear
    echo -e "\033[1;36m"
    echo "    "
    echo "    "
    echo "    DS in sh"
    echo "    "
    echo "    Author: LHRstudios"
    echo "    Version: v$SCRIPT_VERSION"
    echo "    "
    echo "    Thank you for using!"
    echo "    ${KAOMOJI[happy]}"
    echo "    " 
    echo "    "
    
    # Wait for keypress
    echo -e "\033[0m\n\033[1;32m      [Press any key to return]\033[0m"
    read -n1 -s
}

# Settings menu
settings_menu() {
    while true; do
        choice=$(dialog --title " ${KAOMOJI[settings]} Settings" \
            --menu "Select action ${KAOMOJI[think]}" 12 50 4 \
            1 "Auto-check updates: $([ $AUTO_UPDATE -eq 1 ] && echo "✅" || echo "❌❌")" \
            2 "${KAOMOJI[about]} About" \
            0 "Back" \
            3>&1 1>&2 2>&3)
        
        [ $? -ne 0 ] && return
        
        case $choice in
            1) 
                AUTO_UPDATE=$((1 - AUTO_UPDATE))
                save_config
                dialog --msgbox "Auto-update check ${KAOMOJI[done]} $([ $AUTO_UPDATE -eq 1 ] && echo "enabled" || echo "disabled")" 6 40
                ;;
            2) about_animation ;;
            0) return ;;
        esac
    done
}

# Main menu
main_menu() {
    while true; do
        choice=$(dialog --title " ${KAOMOJI[model]} DS in sh" \
            --menu "Select action ${KAOMOJI[think]}" 17 50 7 \
            1 "${KAOMOJI[model]} Run model" \
            2 "${KAOMOJI[download]} Install model" \
            3 "🌐 Start web service" \
            4 "🗑 Uninstall model" \
            5 "${KAOMOJI[update]} Check updates" \
            6 "${KAOMOJI[settings]} Settings" \
            0 "🚪 Exit" \
            3>&1 1>&2 2>&3)
        
        [ $? -ne 0 ] && exit 0
        
        case $choice in
            1) run_model ;;
            2) install_model ;;
            3) start_web_service ;;
            4) uninstall_model ;;
            5) check_updates ;;
            6) settings_menu ;;
            0) exit_msg ;;
        esac
    done
}

# Run model
run_model() {
    models=($(get_models))
    if [ ${#models[@]} -eq 0 ]; then
        dialog --msgbox "${KAOMOJI[fail]} No models installed! Install one first or check web service status" 7 50
        return
    fi
    
    options=()
    for i in "${!models[@]}"; do
        options+=("$((i+1))" "${models[$i]} ${KAOMOJI[model]}")
    done
    
    choice=$(dialog --menu "Select model ${KAOMOJI[think]}" 15 40 10 "${options[@]}" 3>&1 1>&2 2>&3)
    [ -z "$choice" ] && return
    
    model_name="${models[$((choice-1))]}"
    
    clear
    echo -e "\033[1;36m=== ${KAOMOJI[model]} Running model: $model_name ===\033[0m"
    echo -e "💡 Type /exit to quit ${KAOMOJI[run]}"
    
    ollama run "$model_name"
    
    read -p "🚪 Press Enter to return to menu..."
}

# Install model
install_model() {
    model_name=$(dialog --inputbox "${KAOMOJI[download]} Enter model name (e.g.: llama3)" 10 40 3>&1 1>&2 2>&3)
    [ -z "$model_name" ] && return
    
    # Create log file
    log_file="/tmp/ollama_install_$$.log"
    
    # Show progress gauge
    (
        echo "XXX"
        echo "0"
        echo "${KAOMOJI[download]} Starting download of $model_name..."
        echo "XXX"
        
        # Installation process
        if ollama pull "$model_name" 2>&1 | while IFS= read -r line; do
            if [[ $line =~ ([0-9]+)% ]]; then
                percent=${BASH_REMATCH[1]}
                echo "XXX"
                echo "$percent"
                echo "${KAOMOJI[download]} Download progress: $percent%"
                echo "XXX"
            else
                echo "$line" >> "$log_file"
            fi
        done; then
            echo "XXX"
            echo "100"
            echo "${KAOMOJI[done]} Installation successful!"
            echo "XXX"
            sleep 1
        else
            echo "XXX"
            echo "0"
            echo "${KAOMOJI[fail]} Installation failed!"
            echo "XXX"
            sleep 2
            exit 1
        fi
    ) | dialog --title " ${KAOMOJI[download]} Model Installation" --gauge "🔄🔄🔄🔄 Downloading $model_name..." 10 70
    
    # Check installation result
    if grep -q "success" "$log_file" || ollama list | grep -q "$model_name"; then
        dialog --msgbox "${KAOMOJI[done]} $model_name installed successfully!" 7 40
    else
        # Error handling
        if grep -q "manifest unknown" "$log_file"; then
            error_msg="Model doesn't exist or wrong name"
        elif grep -q "no space left" "$log_file"; then
            error_msg="Insufficient storage space"
        else
            error_msg="Unknown error"
        fi
        
        dialog --msgbox "${KAOMOJI[fail]} Installation failed! Reason: $error_msg" 8 50
    fi
    
    rm "$log_file"
}

# Uninstall model
uninstall_model() {
    models=($(get_models))
    if [ ${#models[@]} -eq 0 ]; then
        dialog --msgbox "${KAOMOJI[fail]} No models to uninstall!" 6 40
        return
    fi
    
    options=()
    for i in "${!models[@]}"; do
        options+=("$((i+1))" "${models[$i]} ${KAOMOJI[model]}")
    done
    options+=("C" "📛 Cancel")

    choice=$(dialog --menu "🗑 Select model to uninstall" 15 50 10 "${options[@]}" 3>&1 1>&2 2>&3)
    [[ "$choice" == "C" || -z "$choice" ]] && return

    model_name="${models[$((choice-1))]}"
    
    dialog --yesno "⚠️ Permanently uninstall ${model_name}?" 7 50
    [ $? -ne 0 ] && return
    
    # Perform uninstallation
    result=$(ollama rm "$model_name" 2>&1)
    if [ $? -eq 0 ]; then
        dialog --msgbox "${KAOMOJI[done]} Uninstalled: $model_name" 7 40
    else
        dialog --msgbox "${KAOMOJI[fail]} Uninstall failed:\n$result" 8 50
    fi
}

# Start web service (FIXED VERSION)
start_web_service() {
    # Check if service is already running
    if curl -s http://localhost:11434 >/dev/null; then
        dialog --msgbox "🌐 Ollama service is already running!\nAccess at: http://localhost:11434\n${KAOMOJI[happy]}" 9 50
        return
    fi
    
    # Start the service in the background
    {
        ollama serve
    } >/dev/null 2>&1 &
    
    # Give it a moment to start
    sleep 2
    
    # Check if service started successfully
    if curl -s http://localhost:11434 >/dev/null; then
        dialog --msgbox "🌐 Ollama service started!\nAccess at: http://localhost:11434\n${KAOMOJI[happy]}" 9 50
    else
        dialog --msgbox "❌ Failed to start Ollama web service!\nPossible reasons:\n1. Port 11434 is blocked\n2. Ollama not installed properly\n3. Insufficient permissions" 10 50
    fi
}

# Exit message
exit_msg() {
    clear
    echo -e "\033[1;36m"
    echo "Thank you for using DSinsh ${KAOMOJI[happy]}"
    echo "Goodbye! ${KAOMOJI[run]}"
    echo -e "\033[0m"
    exit 0
}

# Initialize configuration
init_config

# Check and install Ollama
check_and_install_ollama

# Show welcome screen
show_welcome

# Auto check updates (if enabled)
if [ $AUTO_UPDATE -eq 1 ]; then
    check_updates
fi

# Enter main menu
main_menu
