#!/bin/bash

# ConfSync - 交互式主界面模块
# 支持上下键选择和回车确认的交互式菜单

# 颜色定义 - 使用不同前缀避免冲突
readonly I_RED='\033[0;31m'
readonly I_GREEN='\033[0;32m'
readonly I_YELLOW='\033[1;33m'
readonly I_BLUE='\033[0;34m'
readonly I_CYAN='\033[0;36m'
readonly I_WHITE='\033[1;37m'
readonly I_BOLD='\033[1m'
readonly I_REVERSE='\033[7m'
readonly I_NC='\033[0m'

# 特殊字符
readonly CHECKMARK='✓'
readonly CROSS='✗'
readonly ARROW_RIGHT='→'
readonly ARROW_DOWN='↓'
readonly ARROW_UP='↑'

# 光标控制
cursor_up() { echo -e "\033[$1A"; }
cursor_down() { echo -e "\033[$1B"; }
cursor_forward() { echo -e "\033[$1C"; }
cursor_backward() { echo -e "\033[$1D"; }
clear_line() { echo -e "\033[K"; }
clear_screen() { echo -e "\033[2J\033[H"; }
save_cursor() { echo -e "\033[s"; }
restore_cursor() { echo -e "\033[u"; }

# 读取单字符输入（支持方向键）
read_key() {
    local key
    local char1 char2 char3

    # 使用read -n1读取第一个字符
    read -n1 -s char1

    # 检查是否是ESC序列（方向键等）
    if [[ "$char1" == $'\x1b' ]]; then
        read -n2 -s -t 0.1 char2 char3
        if [[ -n "$char2" && -n "$char3" ]]; then
            case "$char2$char3" in
                "[A") echo "UP" ;;      # 上箭头
                "[B") echo "DOWN" ;;    # 下箭头
                "[C") echo "RIGHT" ;;   # 右箭头
                "[D") echo "LEFT" ;;    # 左箭头
                *) echo "UNKNOWN" ;;
            esac
        else
            echo "ESC"
        fi
    else
        case "$char1" in
            $'\x0a'|$'\x0d') echo "ENTER" ;;   # 回车
            $'\x7f') echo "BACKSPACE" ;;       # 退格
            $'\x09') echo "TAB" ;;             # Tab
            "q"|"Q") echo "QUIT" ;;            # Q键
            "s"|"S") echo "SYNC" ;;            # S键
            "p"|"P") echo "PULL" ;;            # P键
            "l"|"L") echo "LIST" ;;            # L键
            "h"|"H"|"?") echo "HELP" ;;        # H键
            "a"|"A") echo "ADD" ;;             # A键
            "r"|"R") echo "REMOVE" ;;          # R键
            "b"|"B") echo "BACKUP" ;;          # B键
            "i"|"I") echo "INFO" ;;            # I键
            " ") echo "SPACE" ;;               # 空格
            *) echo "$char1" ;;
        esac
    fi
}

# 显示高亮菜单项
highlight_item() {
    local text="$1"
    local max_width="$2"
    local current_line="$3"

    # 清除当前行并显示高亮项
    cursor_up "$current_line"
    cursor_backward 1000
    clear_line

    # 反色显示当前选中项
    echo -e "${I_REVERSE}${I_BOLD} ${text}${I_NC}"

    # 恢复光标到原位置
    cursor_down "$current_line"
}

# 显示普通菜单项
normal_item() {
    local text="$1"
    local max_width="$2"
    local current_line="$3"

    cursor_up "$current_line"
    cursor_backward 1000
    clear_line

    # 普通显示
    echo -e " ${text}"

    cursor_down "$current_line"
}

# 显示带图标的菜单项
icon_item() {
    local icon="$1"
    local text="$2"
    local max_width="$3"
    local current_line="$4"
    local is_selected="$5"

    cursor_up "$current_line"
    cursor_backward 1000
    clear_line

    if [[ "$is_selected" == "true" ]]; then
        echo -e "${I_REVERSE}${I_BOLD} ${icon} ${text}${I_NC}"
    else
        echo -e " ${icon} ${text}"
    fi

    cursor_down "$current_line"
}

# 交互式菜单选择
interactive_menu() {
    # 获取数组名称
    local array_name="$1"
    local title="$2"
    local footer="$3"
    local allow_quit="${4:-true}"

    # 使用eval获取数组内容（兼容macOS bash）
    eval "local -a menu_items=(\"\${${array_name}[@]}\")"
    local selected=0
    local item_count=${#menu_items[@]}
    local key_input
    local running=true

    while $running; do
        # 清屏并显示标题
        clear_screen
        echo -e "${I_CYAN}${I_BOLD}=== $title ===${I_NC}"
        echo

        # 显示菜单项
        for ((i=0; i<item_count; i++)); do
            local item="${menu_items[$i]}"
            if [[ $i -eq $selected ]]; then
                echo -e "${I_REVERSE}${I_BOLD} ${ARROW_RIGHT} ${item}${I_NC}"
            else
                echo -e "  ${item}"
            fi
        done

        echo
        if [[ -n "$footer" ]]; then
            echo -e "${I_WHITE}${footer}${I_NC}"
        fi

        echo
        # 提示信息
        local quit_hint=""
        if [[ "$allow_quit" == "true" ]]; then
            quit_hint="，${I_YELLOW}Q${I_NC} 退出"
        fi
        echo -e "${I_BLUE}提示:${I_NC} 使用 ${I_YELLOW}↑↓${I_NC} 选择，${I_YELLOW}Enter${I_NC} 确认${quit_hint}"

        # 读取用户输入
        key_input=$(read_key)

        case "$key_input" in
            "UP")
                ((selected--))
                if [[ $selected -lt 0 ]]; then
                    selected=$((item_count - 1))
                fi
                ;;
            "DOWN")
                ((selected++))
                if [[ $selected -ge $item_count ]]; then
                    selected=0
                fi
                ;;
            "ENTER")
                echo -e "\n${I_GREEN}选择了: ${menu_items[$selected]}${I_NC}"
                echo $selected
                return 0
                ;;
            "QUIT")
                if [[ "$allow_quit" == "true" ]]; then
                    echo -e "\n${I_YELLOW}退出菜单${I_NC}"
                    echo -1
                    return 1
                fi
                ;;
            "q"|"Q")
                if [[ "$allow_quit" == "true" ]]; then
                    echo -e "\n${I_YELLOW}退出菜单${I_NC}"
                    echo -1
                    return 1
                fi
                ;;
        esac
    done
}

# 快捷键菜单
quick_action_menu() {
    local key_input
    local running=true

    while $running; do
        clear_screen
        echo -e "${I_CYAN}${I_BOLD}=== ConfSync 快捷操作 ===${I_NC}"
        echo
        echo -e "${I_WHITE}可用快捷键:${I_NC}"
        echo
        echo -e "  ${I_YELLOW}A${I_NC} - 添加新配置"
        echo -e "  ${I_YELLOW}L${I_NC} - 列出配置"
        echo -e "  ${I_YELLOW}R${I_NC} - 选择并还原配置"
        echo -e "  ${I_YELLOW}S${I_NC} - 同步到远程"
        echo -e "  ${I_YELLOW}P${I_NC} - 从远程拉取"
        echo -e "  ${I_YELLOW}B${I_NC} - 备份配置"
        echo -e "  ${I_YELLOW}I${I_NC} - 查看状态"
        echo -e "  ${I_YELLOW}H${I_NC} - 帮助"
        echo -e "  ${I_YELLOW}Q${I_NC} - 退出"
        echo
        echo -e "${I_BLUE}请按相应键进行操作...${I_NC}"

        key_input=$(read_key)

        case "$key_input" in
            "ADD") echo "add"; return 0 ;;
            "LIST") echo "list"; return 0 ;;
            "REMOVE") echo "restore"; return 0 ;;
            "SYNC") echo "sync"; return 0 ;;
            "PULL") echo "pull"; return 0 ;;
            "BACKUP") echo "backup"; return 0 ;;
            "INFO") echo "status"; return 0 ;;
            "HELP") echo "help"; return 0 ;;
            "QUIT") echo "quit"; return 1 ;;
        esac
    done
}

# 配置选择菜单
config_selection_menu() {
    local configs_array=("$@")
    local selected=0
    local config_count=${#configs_array[@]}
    local key_input
    local page_size=10
    local page_start=0

    if [[ $config_count -eq 0 ]]; then
        echo -e "${I_YELLOW}没有可选择的配置${I_NC}"
        return 1
    fi

    while true; do
        clear_screen
        echo -e "${I_CYAN}${I_BOLD}=== 选择配置文件 ===${I_NC}"
        echo

        # 分页显示
        local page_end=$((page_start + page_size))
        if [[ $page_end -gt $config_count ]]; then
            page_end=$config_count
        fi

        # 显示页面信息
        echo -e "${I_WHITE}配置列表 (显示 $((page_start + 1))-$page_end / $config_count):${I_NC}"
        echo

        # 显示当前页的配置
        for ((i=page_start; i<page_end; i++)); do
            local config_info="${configs_array[$i]}"
            local name=$(echo "$config_info" | cut -d'|' -f1)
            local category=$(echo "$config_info" | cut -d'|' -f2)
            local directory=$(echo "$config_info" | cut -d'|' -f3)
            local description=$(echo "$config_info" | cut -d'|' -f4)

            # 选择图标
            local icon="📄"
            case "$category" in
                "shell") icon="🐚" ;;
                "editor") icon="📝" ;;
                "system") icon="⚙️" ;;
                "app") icon="📱" ;;
                "network") icon="🌐" ;;
            esac

            if [[ $i -eq $selected ]]; then
                echo -e "${I_REVERSE}${I_BOLD} ${ARROW_RIGHT} ${icon} ${name} (${category})${I_NC}"
                echo -e "${I_REVERSE}${I_BOLD}    📁 ${directory}${I_NC}"
                if [[ "$description" != "无描述" && -n "$description" ]]; then
                    echo -e "${I_REVERSE}${I_BOLD}    💬 ${description}${I_NC}"
                fi
            else
                echo -e "  ${icon} ${name} (${category})"
                echo -e "    📁 ${directory}"
            fi
            echo
        done

        # 显示操作提示
        echo -e "${I_BLUE}操作提示:${I_NC}"
        echo -e "  ${I_YELLOW}↑↓${I_NC} 选择  ${I_YELLOW}Enter${I_NC} 确认  ${I_YELLOW}←→${I_NC} 翻页  ${I_YELLOW}Q${I_NC} 退出"

        # 如果有多页，显示翻页信息
        if [[ $config_count -gt $page_size ]]; then
            local current_page=$((page_start / page_size + 1))
            local total_pages=$(((config_count + page_size - 1) / page_size))
            echo -e "  页码: ${current_page}/${total_pages}"
        fi

        key_input=$(read_key)

        case "$key_input" in
            "UP")
                ((selected--))
                if [[ $selected -lt $page_start ]]; then
                    if [[ $selected -ge 0 ]]; then
                        page_start=$selected
                    else
                        selected=$((config_count - 1))
                        page_start=$(((config_count - 1) / page_size * page_size))
                    fi
                fi
                ;;
            "DOWN")
                ((selected++))
                if [[ $selected -ge $page_end ]]; then
                    if [[ $selected -lt $config_count ]]; then
                        page_end=$selected
                        page_start=$(((page_end - 1) / page_size * page_size))
                        page_end=$((page_start + page_size))
                        if [[ $page_end -gt $config_count ]]; then
                            page_end=$config_count
                        fi
                    else
                        selected=0
                        page_start=0
                        page_end=$((page_start + page_size))
                    fi
                fi
                ;;
            "LEFT")
                if [[ $page_start -gt 0 ]]; then
                    page_start=$((page_start - page_size))
                    selected=$page_start
                    page_end=$((page_start + page_size))
                    if [[ $page_end -gt $config_count ]]; then
                        page_end=$config_count
                    fi
                fi
                ;;
            "RIGHT")
                if [[ $page_end -lt $config_count ]]; then
                    page_start=$page_end
                    selected=$page_start
                    page_end=$((page_start + page_size))
                    if [[ $page_end -gt $config_count ]]; then
                        page_end=$config_count
                    fi
                fi
                ;;
            "ENTER")
                echo
                echo "${configs_array[$selected]}"
                return 0
                ;;
            "QUIT"|"q"|"Q")
                echo
                return 1
                ;;
        esac
    done
}

# 确认对话框
confirm_dialog() {
    local message="$1"
    local default="${2:-n}"
    local key_input

    clear_screen
    echo -e "${I_YELLOW}${I_BOLD}确认${I_NC}"
    echo
    echo -e "$message"
    echo
    echo -e "${I_BLUE}Y${I_NC} 是  ${I_BLUE}N${I_NC} 否"

    while true; do
        key_input=$(read_key)
        case "$key_input" in
            "y"|"Y"|"ENTER") return 0 ;;
            "n"|"N"|"q"|"Q"|"ESC") return 1 ;;
        esac
    done
}

# 输入对话框
input_dialog() {
    local prompt="$1"
    local default_value="$2"
    local allow_empty="${3:-false}"
    local input=""
    local key_input

    clear_screen
    echo -e "${I_CYAN}${I_BOLD}输入${I_NC}"
    echo
    echo -e "$prompt"
    echo
    if [[ -n "$default_value" ]]; then
        echo -e "默认值: ${I_WHITE}$default_value${I_NC}"
    fi
    echo -n "> "

    while true; do
        key_input=$(read_key)

        case "$key_input" in
            "ENTER")
                if [[ -z "$input" && -n "$default_value" ]]; then
                    echo "$default_value"
                    return 0
                elif [[ -n "$input" || "$allow_empty" == "true" ]]; then
                    echo "$input"
                    return 0
                fi
                ;;
            "BACKSPACE")
                if [[ -n "$input" ]]; then
                    input="${input%?}"
                    echo -ne "\b \b"
                fi
                ;;
            "QUIT"|"q"|"Q"|"ESC")
                return 1
                ;;
            "UNKNOWN")
                # 忽略未知键
                ;;
            *)
                if [[ ${#key_input} -eq 1 && "$key_input" =~ [a-zA-Z0-9_\-./] ]]; then
                    input+="$key_input"
                    echo -n "$key_input"
                fi
                ;;
        esac
    done
}

# 进度显示
show_progress() {
    local current="$1"
    local total="$2"
    local message="$3"
    local width=50

    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))

    printf "\r${I_BLUE}$message${I_NC}: ["
    printf "%*s" $filled | tr ' ' '█'
    printf "%*s" $empty | tr ' ' '░'
    printf "] %d%% (%d/%d)" $percent $current $total
}

# 状态通知
notify() {
    local type="$1"
    local message="$2"
    local duration="${3:-3}"

    case "$type" in
        "success") echo -e "\n${I_GREEN}${CHECKMARK} ${message}${I_NC}" ;;
        "error") echo -e "\n${I_RED}${CROSS} ${message}${I_NC}" ;;
        "warning") echo -e "\n${I_YELLOW}⚠ ${message}${I_NC}" ;;
        "info") echo -e "\n${I_BLUE}ℹ ${message}${I_NC}" ;;
    esac

    if [[ $duration -gt 0 ]]; then
        sleep "$duration"
    fi
}