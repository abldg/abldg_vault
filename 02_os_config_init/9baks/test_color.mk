# 定义颜色控制码变量
# tput setaf 用于设置前景色，tput sgr0 重置所有属性
RED := $(shell tput setaf 1)
GREEN := $(shell tput setaf 2)
YELLOW := $(shell tput setaf 3)
BLUE := $(shell tput setaf 4)
MAGENTA := $(shell tput setaf 5)
CYAN := $(shell tput setaf 6)
WHITE := $(shell tput setaf 7)
RESET := $(shell tput sgr0)

# 加粗文本
BOLD := $(shell tput bold)

# 示例目标
all: info success warning error

# 信息提示（蓝色）
info:
	@echo "$(BLUE)Info: 这是一条信息提示$(RESET)"
	@echo "$(BOLD)$(CYAN)Notice: 这是一条加粗的通知$(RESET)"

# 成功信息（绿色）
success:
	@echo "$(GREEN)Success: 操作执行成功$(RESET)"

# 警告信息（黄色）
warning:
	@echo "$(YELLOW)Warning: 这是一条警告信息$(RESET)"

# 错误信息（红色）
error:
	@echo "$(RED)Error: 发生错误，请检查$(RESET)"
	@echo "$(BOLD)$(RED)Fatal: 这是一条加粗的致命错误信息$(RESET)"

# 清理目标
clean:
	@echo "$(MAGENTA)Cleaning up temporary files...$(RESET)"
	# 这里添加实际的清理命令
	@echo "$(GREEN)Clean completed$(RESET)"
