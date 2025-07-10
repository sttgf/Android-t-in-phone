#!/data/data/com.termux/files/usr/bin/bash

# 当前脚本版本
SCRIPT_VERSION="1.1"

# 检查依赖
if ! command -v dialog &> /dev/null; then
    echo "✨ dialogをインストール中..."
    pkg install dialog -y >/dev/null 2>&1 || { echo "❌ インストール失敗！手動実行: pkg install dialog"; exit 1; }
fi

# 检查curl依赖
if ! command -v curl &> /dev/null; then
    echo "✨ curlをインストール中..."
    pkg install curl -y >/dev/null 2>&1 || { echo "❌ curlインストール失敗！手動実行: pkg install curl"; exit 1; }
fi

# 检查并安装Ollama
check_and_install_ollama() {
    if ! command -v ollama &> /dev/null; then
        # 显示安装提示
        dialog --infobox "Ollamaがインストールされていません。インストール中..." 5 50
        
        # 创建临时日志文件
        log_file="/tmp/ollama_install_$$.log"
        
        # 尝试多个安装源
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
            dialog --msgbox "✅ Ollamaインストール成功！\n\n端末を再起動するか、次を実行: source ~/.bashrc" 8 50
        else
            dialog --msgbox "❌ Ollamaインストール失敗！\n\nエラーログ:\n$(tail -n 10 "$log_file")\n\n手動でインストールを試してください: curl https://ollama.ai/install.sh | sh" 15 60
            rm "$log_file"
            exit 1
        fi
        
        rm "$log_file"
    fi
}

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
    ["angry"]="(╯°□°）╯︵ ┻━┻┻"
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
    ["about"]="ℹ "
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

           起動中...

      powered by ollama Linuxshell
\033[0m"
    echo -e "       ${KAOMOJI[model]} \033[1;33mDSINSH ターミナルマネージャ v$SCRIPT_VERSION ${KAOMOJI[fire]}\033[0m"
    sleep 1
}

# 检查更新
check_updates() {
    # 显示提示信息
    dialog --infobox "更新を確認中、時間がかかる場合があります..." 5 40
    
    # 检查网络连接
    if ! ping -c 1 github.com >/dev/null 2>&1; then
        dialog --msgbox "${KAOMOJI[fail]} インターネットに接続できません！更新確認をスキップ" 6 50
        return
    fi
    
    # 获取远程版本信息
    remote_version=$(curl -s "https://raw.githubusercontent.com/sttgf/Android-t-in-phone/main/visions.txt")
    
    if [ -z "$remote_version" ]; then
        dialog --msgbox "${KAOMOJI[fail]} リモートバージョン情報を取得できません！" 6 50
        return
    fi
    
    if [ "$remote_version" != "$SCRIPT_VERSION" ]; then
        dialog --yesno "${KAOMOJI[update]} 新しいバージョンが見つかりました: $remote_version (現在: $SCRIPT_VERSION)\n今すぐ更新しますか？" 10 50
        
        if [ $? -eq 0 ]; then
            # 用户选择更新
            update_script
        fi
    else
        dialog --msgbox "${KAOMOJI[done]} 最新バージョンです！" 6 40
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
        "https://raw.githubusercontent.com/sttgf/Android-t-in-phone/main/日本語/deep.sh"
        "https://ghproxy.com/https://raw.githubusercontent.com/sttgf/Android-t-in-phone/main/日本語/deep.sh"
        "https://cdn.jsdelivr.net/gh/sttgf/Android-t-in-phone/日本語/deep.sh"
        "https://raw.fastgit.org/sttgf/Android-t-in-phone/main/日本語/deep.sh"
        "https://gcore.jsdelivr.net/gh/sttgf/Android-t-in-phone/日本語/deep.sh"
        "https://cdn.staticaly.com/gh/sttgf/Android-t-in-phone/main/日本語/deep.sh"
        "https://raw.gitmirror.com/sttgf/Android-t-in-phone/main/日本語/deep.sh"
    )
    
    success=0
    
    for source in "${sources[@]}"; do
        dialog --infobox "${KAOMOJI[mirror]} ソースを試しています: ${source:0:40}..." 5 60
        if curl -s -o "$update_script_path" "$source"; then
            success=1
            break
        fi
        sleep 1
    done
    
    if [ $success -eq 0 ]; then
        dialog --msgbox "${KAOMOJI[fail]} すべてのダウンロードソースが失敗しました！\n\n手動更新方法:\n1. ブラウザでアクセス: https://github.com/sttgf/Android-t-in-phone/日本語/deep.sh. deep.shをダウンロードし、現在のスクリプトと置き換えてください" 12 60
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
    dialog --infobox "${KAOMOJI[update]} 更新完了！新しいバージョンを起動..." 5 50
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
    echo "    作者: LHRstudios"
    echo "    "
    sleep 0.5
    
    # 版本信息
    clear
    echo -e "\033[1;36m"
    echo "    "
    echo "    "
    echo "    DS in sh"
    echo "    "
    echo "    作者: LHRstudios"
    echo "    バージョン: v$SCRIPT_VERSION"
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
    echo "    作者: LHRstudios"
    echo "    バージョン: v$SCRIPT_VERSION"
    echo "    "
    echo "    ご利用ありがとうございます!"
    echo "    ${KAOMOJI[happy]}"
    echo "    " 
    echo "    "
    
    # 等待用户按键
    echo -e "\033[0m\n\033[1;32m      [任意のキーを押して戻る]\033[0m"
    read -n1 -s
}

# 设置菜单
settings_menu() {
    while true; do
        choice=$(dialog --title " ${KAOMOJI[settings]} 設定" \
            --menu "操作を選択 ${KAOMOJI[think]}" 12 50 4 \
            1 "自動更新チェック: $([ $AUTO_UPDATE -eq 1 ] && echo "✅" || echo "❌")" \
            2 "${KAOMOJI[about]} バージョン情報" \
            0 "戻る" \
            3>&1 1>&2 2>&3)
        
        [ $? -ne 0 ] && return
        
        case $choice in
            1) 
                AUTO_UPDATE=$((1 - AUTO_UPDATE))
                save_config
                dialog --msgbox "自動更新チェックが ${KAOMOJI[done]} $([ $AUTO_UPDATE -eq 1 ] && echo "有効" || echo "無効") になりました" 6 40
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
            --menu "操作を選択 ${KAOMOJI[think]}" 17 50 7 \
            1 "${KAOMOJI[model]} モデルを実行" \
            2 "${KAOMOJI[download]} モデルをインストール" \
            3 "🌐 Webサービスを起動" \
            4 "🗑 モデルをアンインストール" \
            5 "${KAOMOJI[update]} 更新を確認" \
            6 "${KAOMOJI[settings]} 設定" \
            0 "🚪 終了" \
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
        dialog --msgbox "${KAOMOJI[fail]} インストールされたモデルがありません！先にモデルをインストールするか、Webサービスが起動していない可能性があります" 6 40
        return
    fi
    
    options=()
    for i in "${!models[@]}"; do
        options+=("$((i+1))" "${models[$i]} ${KAOMOJI[model]}")
    done
    
    choice=$(dialog --menu "モデルを選択 ${KAOMOJI[think]}" 15 40 10 "${options[@]}" 3>&1 1>&2 2>&3)
    [ -z "$choice" ] && return
    
    model_name="${models[$((choice-1))]}"
    
    clear
    echo -e "\033[1;36m=== ${KAOMOJI[model]} モデル実行中: $model_name ===\033[0m"
    echo -e "💡 終了するには /exit と入力 ${KAOMOJI[run]}"
    
    ollama run "$model_name"
    
    read -p "🚪 戻るにはEnterを押してください..."
}

# 安装模型
install_model() {
    model_name=$(dialog --inputbox "${KAOMOJI[download]} モデル名を入力 (例: llama3)" 10 40 3>&1 1>&2 2>&3)
    [ -z "$model_name" ] && return
    
    # 创建日志文件
    log_file="/tmp/ollama_install_$$.log"
    
    # 进度框显示安装过程
    (
        echo "XXX"
        echo "0"
        echo "${KAOMOJI[download]} $model_name をダウンロード中..."
        echo "XXX"
        
        # 安装过程
        if ollama pull "$model_name" 2>&1 | while IFS= read -r line; do
            if [[ $line =~ ([0-9]+)% ]]; then
                percent=${BASH_REMATCH[1]}
                echo "XXX"
                echo "$percent"
                echo "${KAOMOJI[download]} ダウンロード進捗: $percent%"
                echo "XXX"
            else
                echo "$line" >> "$log_file"
            fi
        done; then
            echo "XXX"
            echo "100"
            echo "${KAOMOJI[done]} インストール成功！"
            echo "XXX"
            sleep 1
        else
            echo "XXX"
            echo "0"
            echo "${KAOMOJI[fail]} インストール失敗！"
            echo "XXX"
            sleep 2
            exit 1
        fi
    ) | dialog --title " ${KAOMOJI[download]} モデルインストール" --gauge "🔄🔄🔄🔄 $model_name をダウンロード中..." 10 70
    
    # 检查安装结果
    if grep -q "success" "$log_file" || ollama list | grep -q "$model_name"; then
        dialog --msgbox "${KAOMOJI[done]} $model_name インストール成功！" 7 40
    else
        # 错误处理
        if grep -q "manifest unknown" "$log_file"; then
            error_msg="モデルが存在しないか名前が間違っています"
        elif grep -q "no space left" "$log_file"; then
            error_msg="ストレージ容量不足"
        else
            error_msg="不明なエラー"
        fi
        
        dialog --msgbox "${KAOMOJI[fail]} インストール失敗！原因: $error_msg" 8 50
    fi
    
    rm "$log_file"
}

# 卸载模型
uninstall_model() {
    models=($(get_models))
    if [ ${#models[@]} -eq 0 ]; then
        dialog --msgbox "${KAOMOJI[fail]} アンインストール可能なモデルがありません！" 6 40
        return
    fi
    
    options=()
    for i in "${!models[@]}"; do
        options+=("$((i+1))" "${models[$i]} ${KAOMOJI[model]}")
    done
    options+=("C" "📛 キャンセル")

    choice=$(dialog --menu "🗑 アンインストールするモデルを選択" 15 50 10 "${options[@]}" 3>&1 1>&2 2>&3)
    [[ "$choice" == "C" || -z "$choice" ]] && return

    model_name="${models[$((choice-1))]}"
    
    dialog --yesno "⚠️ $model_name を完全にアンインストールしますか？" 7 50
    [ $? -ne 0 ] && return
    
    # 执行卸载
    result=$(ollama rm "$model_name" 2>&1)
    if [ $? -eq 0 ]; then
        dialog --msgbox "${KAOMOJI[done]} アンインストール成功: $model_name" 7 40
    else
        dialog --msgbox "${KAOMOJI[fail]} アンインストール失敗:\n$result" 8 50
    fi
}

# 开启网页服务
start_web_service() {
    dialog --msgbox "🌐🌐 Ollamaサービスを起動しました\nアクセス先: http://localhost:11434\n${KAOMOJI[happy]}" 8 50
    {
        echo "サービスを起動中..."
        ollama serve
    } > /dev/null 2>&1 &
}

# 退出消息
exit_msg() {
    clear
    echo -e "\033[1;36m"
    echo "DSinsh をご利用いただきありがとうございます ${KAOMOJI[happy]}"
    echo "さようなら! ${KAOMOJI[run]}"
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
