#!/bin/bash

# v1.0.0

# 脚本保存路径
SCRIPT_PATH="/home/Dawn.sh"
DAWN_DIR="/home/Dawn"

# 检查是否以 root 用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以 root 用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到 root 用户，然后再次运行此脚本。"
    exit 1
fi

# 安装和配置函数
function install_and_configure() {
    # 检查 Python 3.11 是否已安装
    function check_python_installed() {
        if command -v python3.11 &>/dev/null; then
            echo "Python 3.11 已安装。"
        else
            echo "未安装 Python 3.11，正在安装..."
            install_python
        fi
    }

    # 安装 Python 3.11
    function install_python() {
        sudo apt update
        sudo apt install -y software-properties-common
        sudo add-apt-repository ppa:deadsnakes/ppa -y
        sudo apt install -y python3.11 python3.11-venv python3.11-dev python3-pip
        sudo apt install libopencv-dev python3-opencv
        # 添加 pip 升级命令
        python3.11 -m pip install --upgrade pip  # 升级 pip
        echo "Python 3.11 和 pip 安装完成。"
    }

    # 检查 Python 版本
    check_python_installed

    # 更新包列表并安装 git 和 tmux
    echo "正在更新软件包列表和安装 git 和 tmux..."
    sudo apt update
    sudo apt install -y git tmux python3.11-venv libgl1-mesa-glx libglib2.0-0 libsm6 libxext6 libxrender-dev

    # 检查 Dawn 目录是否存在，如果存在则删除	
    if [ -d "$DAWN_DIR" ]; then	
        echo "检测到 Dawn 目录已存在，正在删除..."	
        rm -rf "$DAWN_DIR"	
        echo "Dawn 目录已删除。"	
    fi

     # 检查并终止已存在的 Dawn tmux 会话
    if tmux has-session -t dawn 2>/dev/null; then
        echo "检测到正在运行的 dawn 会话，正在终止..."
        tmux kill-session -t dawn
        echo "已终止现有的 dawn 会话。"
    fi
    
    # 克隆 GitHub 仓库
    echo "正在从 GitHub 克隆仓库..."
    git clone https://github.com/Jaammerr/The-Dawn-Bot.git "$DAWN_DIR"

    # 检查克隆操作是否成功
    if [ ! -d "$DAWN_DIR" ]; then
        echo "克隆失败，请检查网络连接或仓库地址。"
        exit 1
    fi

    # 进入仓库目录
    cd "$DAWN_DIR" || { echo "无法进入 Dawn 目录"; exit 1; }

    # 创建虚拟环境
    python3.11 -m venv venv  # 创建虚拟环境
    source venv/bin/activate  # 激活虚拟环境

    # 配置邮件和Token
    echo "请分别输入您的邮箱、密码和2captcha API密钥"
    read -p "请输入邮箱: " email
    read -p "请输入密码: " password
    read -p "请输入2captcha API密钥: " captcha_key

    # # 验证输入不为空
    # while [[ -z "$email" || -z "$password" || -z "$captcha_key" ]]; do
    #     echo "错误：邮箱、密码和2captcha API密钥都不能为空！"
    #     read -p "请输入邮箱: " email
    #     read -p "请输入密码: " password
    #     read -p "请输入2captcha API密钥: " captcha_key
    # done

    # # 更新settings.yaml文件中的two_captcha_api_key
    # settings_file="$DAWN_DIR/config/settings.yaml"
    # if [ -f "$settings_file" ]; then
    #     # 使用sed替换two_captcha_api_key的值
    #     sed -i "s/two_captcha_api_key: .*/two_captcha_api_key: \"$captcha_key\"/" "$settings_file"
    # else
    #     echo "错误：未找到settings.yaml文件"
    #     exit 1
    # fi

    # # 组合成需要的格式并写入farm.txt
    # email_token="${email}:${password}"
    # farm_file="$DAWN_DIR/config/data/farm.txt"
    # echo "$email_token" > "$farm_file"
    # echo "账户信息已写入 $farm_file"

    # # 配置代理信息
    # read -p "请输入您的代理信息，格式为 (http://user:pass@ip:port): " proxy_info
    # proxies_file="$DAWN_DIR/config/data/proxies.txt"

    # # 将代理信息写入文件
    # echo "$proxy_info" > "$proxies_file"
    # echo "代理信息已添加到 $proxies_file."

    echo "安装、克隆、虚拟环境设置和配置已完成！"
    echo "正在运行脚本 python3 run.py..."
    
    echo "正在使用 tmux 启动 main.py..."
    tmux new-session -d -s dawn  # 创建新的 tmux 会话，名称为 dawn
    tmux send-keys -t dawn "cd Dawn" C-m  # 切换到 Dawn 目录
    tmux send-keys -t dawn "source \"venv/bin/activate\"" C-m  # 激活虚拟环境
    tmux send-keys -t dawn "python3.11 -m pip install -r requirements.txt" C-m  # 安装依赖
    tmux send-keys -t dawn "python3.11 run.py" C-m  # 启动 main.py
    echo "使用 'tmux attach -t dawn' 命令来查看日志。"
    echo "要退出 tmux 会话，请按 Ctrl+B 然后按 D。"
    echo "请配置proxies.txt login_accounts.txt farm_accounts.txt Settings.yaml后再开启挖矿"

    # 提示用户按任意键返回主菜单
    read -n 1 -s -r -p "按任意键返回主菜单..."
}

# 主菜单函数
function main_menu() {
    while true; do
        clear
        echo "免费开源，请勿相信收费"
        echo "================================================================"
        echo "退出脚本，请按键盘 ctrl + C 退出即可"
        echo "请选择要执行的操作:"
        echo "1. 安装部署 Dawn"
        echo "2. 退出"

        read -p "请输入您的选择 (1,2): " choice
        case $choice in
            1)
                install_and_configure  # 调用安装和配置函数
                ;;
            2)
                echo "退出脚本..."
                exit 0
                ;;
            *)
                echo "无效的选择，请重试."
                read -n 1 -s -r -p "按任意键继续..."
                ;;
        esac
    done
}

# 进入主菜单
main_menu