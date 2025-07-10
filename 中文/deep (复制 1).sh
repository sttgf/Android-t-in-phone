#!/data/data/com.termux/files/usr/bin/bash

# 当前脚本版本
SCRIPT_VERSION="1.1"


# 配置文件路径
CONFIG_FILE="$HOME/.ollama_manager.cfg"

# 初始化配置
init_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        cat > "$CONFIG_FILE" <<EOF
AUTO_UPDATE=0
EOF
    fi
    source "$CONFIG_FILE"
}

# 保存配置
save_config() {
    cat > "$CONFIG_FILE" <<EOF
AUTO_UPDATE=$AUTO_UPDATE
EOF
}

# 颜文字数组
declare -A KAOMOJI=(
    ["happy"]="ヽ(•‿•)ノ"
    ["angry"]="(╯°□°）╯︵ ┻━┻"
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
    ["about"]="ℹℹ️"
)

# 获取已安装模型
get_models() {
    if command -v ollama &> /dev/null; then
        ollama list | awk 'NR>1 {print $1}'
    else
        echo ""
    fi
}

# 显示欢迎标题
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
    echo -e "       ${KAOMOJI[model]} \033[1;33mDSINSH 终端管理器 v$SCRIPT_VERSION ${KAOMOJI[fire]}\033[0m"
    sleep 1
}

# 检查更新
check_updates() {
    # 显示提示信息
    dialog --infobox "检查更新中，可能较慢..." 5 40
    
    # 检查网络连接
    if ! ping -c 1 github.com >/dev/null 2>&1; then
        dialog --msgbox "${KAOMOJI[fail]} 无法连接到互联网！跳过更新检查" 6 50
        return
    fi
    
    # 获取远程版本信息
    remote_version=$(curl -s "https://raw.githubusercontent.com/sttgf/Android-t-in-phone/main/visions.txt")
    
    if [ -z "$remote_version" ]; then
        dialog --msgbox "${KAOMOJI[fail]} 无法获取远程版本信息！" 6 50
        return
    fi
    
    if [ "$remote_version" != "$SCRIPT_VERSION" ]; then
        dialog --yesno "${KAOMOJI[update]} 发现新版本: $remote_version (当前: $SCRIPT_VERSION)\n是否立即更新？" 10 50
        
        if [ $? -eq 0 ]; then
            # 用户选择更新
            update_script
        fi
    else
        dialog --msgbox "${KAOMOJI[done]} 当前已是最新版本！" 6 40
    fi
}

# 更新脚本
update_script() {
    # 获取当前脚本目录
    CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # 创建临时更新脚本路径
    update_script_path="$CURRENT_DIR/deep_update_$$.sh"
    final_script_path="$CURRENT_DIR/deep.sh"
    st_script_path="$CURRENT_DIR/st.sh"
    
    # 定义多个下载源
    sources=(
        "https://raw.githubusercontent.com/sttgf/Android-t-in-phone/main/deep.sh"
        "https://ghproxy.com/https://raw.githubusercontent.com/sttgf/Android-t-in-phone/main/deep.sh"
        "https://cdn.jsdelivr.net/gh/sttgf/Android-t-in-phone/deep.sh"
        "https://raw.fastgit.org/sttgf/Android-t-in-phone/main/deep.sh"
        "https://gcore.jsdelivr.net/gh/sttgf/Android-t-in-phone/deep.sh"
        "https://cdn.staticaly.com/gh/sttgf/Android-t-in-phone/main/deep.sh"
        "https://raw.gitmirror.com/sttgf/Android-t-in-phone/main/deep.sh"
    )
    
    success=0
    
    for source in "${sources[@]}"; do
        dialog --infobox "${KAOMOJI[mirror]} 尝试源: ${source:0:40}..." 5 60
        if curl -s -o "$update_script_path" "$source"; then
            success=1
            break
        fi
        sleep 1
    done
    
    if [ $success -eq 0 ]; then
        dialog --msgbox "${KAOMOJI[fail]} 所有下载源均失败！\n\n手动更新方案:\n1. 浏览器访问: https://github.com/sttgf/Android-t-in-phone\n2. 下载 deep.sh\n3. 替换当前脚本" 12 60
        return
    fi
    
    # 设置执行权限
    chmod +x "$update_script_path"
    
    # 重命名更新文件
    mv "$update_script_path" "$final_script_path"
    
    # 创建启动脚本
    echo "#!/bin/bash" > "$st_script_path"
    echo "bash \"$final_script_path\"" >> "$st_script_path"
    chmod +x "$st_script_path"
    
    # 执行新脚本
    dialog --infobox "${KAOMOJI[update]} 更新完成！启动新版本..." 5 50
    sleep 2
    exec "$st_script_path"
}

# 精美关于页面
about_animation() {
    clear
    
    # 显示动态标题
    echo -e "\033[1;36m"
    echo "    "
    echo "    "
    echo "    DS in sh"
    echo "    "
    echo "    "
    sleep 0.5
    
    # 作者信息
    clear
    echo -e "\033[1;36m"
    echo "    "
    echo "    "
    echo "    DS in sh"
    echo "    "
    echo "    作者:LHRstudios"
    echo "    "
    sleep 0.5
    
    # 版本信息
    clear
    echo -e "\033[1;36m"
    echo "    "
    echo "    "
    echo "    DS in sh"
    echo "    "
    echo "    作者:LHRstudios"
    echo "    版本: v$SCRIPT_VERSION"
    echo "    "
    echo "    "
    sleep 0.5
    
    # 致谢信息
    clear
    echo -e "\033[1;36m"
    echo "    "
    echo "    "
    echo "    DS in sh"
    echo "    "
    echo "    作者:LHRstudios"
    echo "    版本: v$SCRIPT_VERSION"
    echo "    "
    echo "    感谢您的使用!"
    echo "    ${KAOMOJI[happy]}"
    echo "    " 
    echo "    "
    
    # 等待用户按键
    echo -e "\033[0m\n\033[1;32m      [按任意键返回]\033[0m"
    read -n1 -s
}

# 设置菜单
settings_menu() {
    while true; do
        choice=$(dialog --title " ${KAOMOJI[settings]} 设置" \
            --menu "选择操作 ${KAOMOJI[think]}" 12 50 4 \
            1 "自动检查更新: $([ $AUTO_UPDATE -eq 1 ] && echo "✅" || echo "❌")" \
            2 "${KAOMOJI[about]} 关于" \
            0 "返回" \
            3>&1 1>&2 2>&3)
        
        [ $? -ne 0 ] && return
        
        case $choice in
            1) 
                AUTO_UPDATE=$((1 - AUTO_UPDATE))
                save_config
                dialog --msgbox "自动检查更新已 ${KAOMOJI[done]} $([ $AUTO_UPDATE -eq 1 ] && echo "开启" || echo "关闭")" 6 40
                ;;
            2) about_animation ;;
            0) return ;;
        esac
    done
}

# 主菜单
main_menu() {
    while true; do
        choice=$(dialog --title " ${KAOMOJI[model]} DS in sh" \
            --menu "选择操作 ${KAOMOJI[think]}" 17 50 7 \
            1 "${KAOMOJI[model]} 运行模型" \
            2 "${KAOMOJI[download]} 安装模型" \
            3 "🌐 开启Web服务" \
            4 "🗑 卸载模型" \
            5 "${KAOMOJI[update]} 检查更新" \
            6 "${KAOMOJI[settings]} 设置" \
            0 "🚪 退出" \
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

# 运行模型
run_model() {
    models=($(get_models))
    if [ ${#models[@]} -eq 0 ]; then
        dialog --msgbox "${KAOMOJI[fail]} 没有安装模型！请先安装 也有可能是没开web服务" 6 40
        return
    fi
    
    options=()
    for i in "${!models[@]}"; do
        options+=("$((i+1))" "${models[$i]} ${KAOMOJI[model]}")
    done
    
    choice=$(dialog --menu "选择模型 ${KAOMOJI[think]}" 15 40 10 "${options[@]}" 3>&1 1>&2 2>&3)
    [ -z "$choice" ] && return
    
    model_name="${models[$((choice-1))]}"
    
    clear
    echo -e "\033[1;36m=== ${KAOMOJI[model]} 运行模型: $model_name ===\033[0m"
    echo -e "💡 输入 /exit 退出对话 ${KAOMOJI[run]}"
    
    ollama run "$model_name"
    
    read -p "🚪 按回车返回主菜单..."
}

# 安装模型
install_model() {
    model_name=$(dialog --inputbox "${KAOMOJI[download]} 输入模型名称 (如: llama3)" 10 40 3>&1 1>&2 2>&3)
    [ -z "$model_name" ] && return
    
    # 创建日志文件
    log_file="/tmp/ollama_install_$$.log"
    
    # 进度框显示安装过程
    (
        echo "XXX"
        echo "0"
        echo "${KAOMOJI[download]} 开始下载 $model_name..."
        echo "XXX"
        
        # 安装过程
        if ollama pull "$model_name" 2>&1 | while IFS= read -r line; do
            if [[ $line =~ ([0-9]+)% ]]; then
                percent=${BASH_REMATCH[1]}
                echo "XXX"
                echo "$percent"
                echo "${KAOMOJI[download]} 下载进度: $percent%"
                echo "XXX"
            else
                echo "$line" >> "$log_file"
            fi
        done; then
            echo "XXX"
            echo "100"
            echo "${KAOMOJI[done]} 安装成功！"
            echo "XXX"
            sleep 1
        else
            echo "XXX"
            echo "0"
            echo "${KAOMOJI[fail]} 安装失败！"
            echo "XXX"
            sleep 2
            exit 1
        fi
    ) | dialog --title " ${KAOMOJI[download]} 模型安装" --gauge "🔄🔄 正在下载 $model_name..." 10 70
    
    # 检查安装结果
    if grep -q "success" "$log_file" || ollama list | grep -q "$model_name"; then
        dialog --msgbox "${KAOMOJI[done]} $model_name 安装成功！" 7 40
    else
        # 错误处理
        if grep -q "manifest unknown" "$log_file"; then
            error_msg="模型不存在或名称错误"
        elif grep -q "no space left" "$log_file"; then
            error_msg="存储空间不足"
        else
            error_msg="未知错误"
        fi
        
        dialog --msgbox "${KAOMOJI[fail]} 安装失败！原因: $error_msg" 8 50
    fi
    
    rm "$log_file"
}

# 卸载模型
uninstall_model() {
    models=($(get_models))
    if [ ${#models[@]} -eq 0 ]; then
        dialog --msgbox "${KAOMOJI[fail]} 没有可卸载的模型！" 6 40
        return
    fi
    
    options=()
    for i in "${!models[@]}"; do
        options+=("$((i+1))" "${models[$i]} ${KAOMOJI[model]}")
    done
    options+=("C" "📛 取消操作")

    choice=$(dialog --menu "🗑 选择要卸载的模型" 15 50 10 "${options[@]}" 3>&1 1>&2 2>&3)
    [[ "$choice" == "C" || -z "$choice" ]] && return

    model_name="${models[$((choice-1))]}"
    
    dialog --yesno "⚠️ 确定要永久卸载 ${model_name} 吗？" 7 50
    [ $? -ne 0 ] && return
    
    # 执行卸载
    result=$(ollama rm "$model_name" 2>&1)
    if [ $? -eq 0 ]; then
        dialog --msgbox "${KAOMOJI[done]} 成功卸载: $model_name" 7 40
    else
        dialog --msgbox "${KAOMOJI[fail]} 卸载失败:\n$result" 8 50
    fi
}

# 开启网页服务
start_web_service() {
    dialog --msgbox "🌐 Ollama服务已启动\n访问: http://localhost:11434\n${KAOMOJI[happy]}" 8 50
    {
        echo "启动服务..."
        ollama serve
    } > /dev/null 2>&1 &
}

# 退出消息
exit_msg() {
    clear
    echo -e "\033[1;36m"
    echo "感谢使用  DSinsh ${KAOMOJI[happy]}"
    echo "再见! ${KAOMOJI[run]}"
    echo -e "\033[0m"
    exit 0
}

# 初始化配置
init_config

# 检查并安装Ollama
check_and_install_ollama

# 启动欢迎界面
show_welcome

# 自动检查更新（如果启用）
if [ $AUTO_UPDATE -eq 1 ]; then
    check_updates
fi

# 进入主菜单
main_menu
