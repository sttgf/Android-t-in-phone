#!/data/data/com.termux/files/usr/bin/bash

# 当前脚本版本
SCRIPT_VERSION="2.0"

# 检查依赖
if ! command -v dialog &> /dev/null; then
    echo "✨ 安装dialog中..."
    pkg install dialog -y >/dev/null 2>&1 || { echo "❌ 安装失败！手动执行: pkg install dialog"; exit 1; }
fi

# 检查curl依赖
if ! command -v curl &> /dev/null; then
    echo "✨ 安装curl中..."
    pkg install curl -y >/dev/null 2>&1 || { echo "❌ curl安装失败！手动执行: pkg install curl"; exit 1; }
fi

# 颜文字数组
declare -A KAOMOJI=(
    ["happy"]="ヽ(•‿•)ノ"
    ["angry"]="(╯°□°）╯︵ ┻━┻"
    ["think"]='(。-`ω´-)'
    ["cool"]="(⌐■_■)"
    ["shock"]="(⊙_☉)"
    ["run"]="ε=ε=ε=┏(゜゜ロ゜゜;)┛"
    ["done"]="✅"
    ["fail"]="❌"
    ["download"]="📥"
    ["model"]="🧠"
    ["fire"]="🔥"
    ["update"]="🔄"
    ["mirror"]="🪞"
)

# 获取已安装模型
get_models() {
    ollama list | awk 'NR>1 {print $1}'
}

# 显示欢迎标题
show_welcome() {
    clear
    echo -e "\033[1;36m
    ___       __    _______    ________
   /   | ____/ /   / ____/ |  / / ____/
  / /极 |/ __ 速 /   / __/  | | / / __/   
 / 下 载 / /_/ /   / /___  | |/ / /___   
/_/ 体 验__,_/   /_____/  |___/_____/   
\033[0m"
    echo -e "       ${KAOMOJI[model]} \033[1;33mOllama 终端管理器 v$SCRIPT_VERSION ${KAOMOJI[fire]}\033[0m"
    sleep 1
}

# 检查更新
check_updates() {
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
    fi
}

# 更新脚本
update_script() {
    # 下载更新脚本
    dialog --infobox "${KAOMOJI[download]} 下载更新中..." 5 40
    
    # 创建临时更新脚本路径
    update_script_path="/sdcard/deep_update_$$.sh"
    
    # 定义多个下载源（主源+镜像）
    sources=(
        "https://raw.githubusercontent.com/sttgf/Android-t-in-phone/main/deep.sh"
        "https://ghproxy.com/https://raw.githubusercontent.com/sttgf/Android-t-in-phone/main/deep.sh"
        "https://cdn.jsdelivr.net/gh/sttgf/Android-t-in-phone/deep.sh"
        "https://raw.fastgit.org/sttgf/Android-t-in-phone/main/deep.sh"
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
    
    # 执行更新
    dialog --infobox "${KAOMOJI[update]} 正在应用更新..." 5 40
    sleep 1
    
    # 执行新脚本
    exec "$update_script_path"
}

# 主菜单
main_menu() {
    while true; do
        choice=$(dialog --title " ${KAOMOJI[model]} Ollama 管理器" \
            --menu "选择操作 ${KAOMOJI[think]}" 16 50 6 \
            1 "${KAOMOJI[model]} 运行模型" \
            2 "${KAOMOJI[download]} 安装模型" \
            3 "🌐 开启Web服务" \
            4 "🗑️ 卸载模型" \
            0 "🚪 退出" \
            3>&1 1>&2 2>&3)
        
        [ $? -ne 0 ] && exit 0
        
        case $choice in
            1) run_model ;;
            2) install_model ;;
            3) start_web_service ;;
            4) uninstall_model ;;
            0) exit_msg ;;
        esac
    done
}

# 运行模型
run_model() {
    models=($(get_models))
    [ ${#models[@]} -eq 0 ] && {
        dialog --msgbox "${KAOMOJI[fail]} 没有安装模型！请先安装" 6 40
        return
    }
    
    options=()
    for i in "${!models[@]}"; do
        options+=("极速模型 $((i+1))" "${models[$i]} ${KAOMOJI[model]}")
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
    [ -极速安装 -z "$model_name" ] && return
    
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
    [ ${#models[@]} -eq 0 ] && {
        dialog --msgbox "${KAOMOJI[fail]} 没有可卸载的模型！" 6 40
        return
    }
    
    options=()
    for i in "${!models[@]}"; do
        options+=("$((i+1))" "${models[$i]} ${KAOMOJI[model]}")
    done
    options+=("C" "📛 取消操作")

    choice=$(dialog --menu "🗑️ 选择要卸载的模型" 15 50 10 "${options[@]}" 3>&1 1>&2 2>&3)
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
    echo "感谢使用 Ollama 管理器 ${KAOMOJI[happy]}"
    echo "再见! ${KAOMOJI[run]}"
    echo -e "\033[0m"
    exit 0
}

# 启动欢迎界面
show_welcome

# 检查更新
check_updates

# 进入主菜单
main_menu
