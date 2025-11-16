#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* 用户数据结构体 */
struct Context
{
  int retry_count;
  char *output_path;
};

/* 状态枚举定义处理阶段 */
typedef enum
{
  STATE_READ_FILE, // 读取文件阶段
  STATE_PROCESS1,  // 初步处理阶段
  STATE_PROCESS2,  // 深度处理阶段
  STATE_FINAL,     // 最终处理阶段
  STATE_DONE       // 完成状态
} State;

/* 状态机结构体，维护处理状态和上下文 */
typedef struct
{
  State current_state; // 当前状态
  struct Context *ctx; // 用户上下文
  char *current_data;  // 当前处理的数据
} StateMachine;

///~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void read_file(const char *filename, void (*process)(char *, void *), void *user_data);
void process_data1(char *data, void *user_data);
void process_data2(char *data, void *user_data);
void final_process(char *result, void *user_data);
///~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
StateMachine *state_machine_init(struct Context *ctx);
void state_machine_cleanup(StateMachine *sm);
///~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/* 初始化状态机 */
StateMachine *state_machine_init(struct Context *ctx)
{
  StateMachine *sm = (StateMachine *)malloc(sizeof(StateMachine));
  if (!sm)
    return NULL;
  sm->current_state = STATE_READ_FILE;
  sm->ctx = ctx;
  sm->current_data = NULL;
  return sm;
}

/* 清理状态机资源 */
void state_machine_cleanup(StateMachine *sm)
{
  if (sm)
  {
    free(sm->current_data); // 释放当前数据内存
    free(sm);               // 释放状态机本身
  }
}

/* 状态处理函数：读取文件 */
static void handle_read_file(StateMachine *sm)
{
  // 模拟文件读取（实际可替换为真实文件读取逻辑）
  const char *mock_data = "Hello,Callback!";
  printf("Read complete\n");

  // 复制数据到状态机上下文
  sm->current_data = strdup(mock_data);
  if (!sm->current_data)
  {
    fprintf(stderr, "Memory allocation failed in read phase\n");
    sm->current_state = STATE_DONE; // 分配失败则终止
    return;
  }

  sm->current_state = STATE_PROCESS1; // 转移到初步处理阶段
}

/* 状态处理函数：初步处理数据 */
static void handle_process1(StateMachine *sm)
{
  if (!sm->current_data)
  {
    fprintf(stderr, "No data to process in process1\n");
    sm->current_state = STATE_DONE;
    return;
  }

  // 模拟初步处理（添加标记）
  char *processed = (char *)malloc(50);
  if (!processed)
  {
    fprintf(stderr, "Memory allocation failed in process1\n");
    sm->current_state = STATE_DONE;
    return;
  }
  snprintf(processed, 50, "[1]%s", sm->current_data);
  printf("Process1 done: %s\n", processed);

  free(sm->current_data);             // 释放旧数据
  sm->current_data = processed;       // 更新为新数据
  sm->current_state = STATE_PROCESS2; // 转移到深度处理阶段
}

/* 状态处理函数：深度处理数据 */
static void handle_process2(StateMachine *sm)
{
  if (!sm->current_data)
  {
    fprintf(stderr, "No data to process in process2\n");
    sm->current_state = STATE_DONE;
    return;
  }

  // 模拟深度处理（二次标记）
  char *final = (char *)malloc(50);
  if (!final)
  {
    fprintf(stderr, "Memory allocation failed in process2\n");
    sm->current_state = STATE_DONE;
    return;
  }
  snprintf(final, 50, "[2]%s", sm->current_data);
  printf("Process2 done: %s\n", final);

  free(sm->current_data);          // 释放旧数据
  sm->current_data = final;        // 更新为新数据
  sm->current_state = STATE_FINAL; // 转移到最终处理阶段
}

/* 状态处理函数：最终处理结果 */
static void handle_final(StateMachine *sm)
{
  if (!sm->current_data)
  {
    fprintf(stderr, "No data to finalize\n");
    sm->current_state = STATE_DONE;
    return;
  }

  // 调用最终处理函数（使用用户上下文）
  final_process(sm->current_data, sm->ctx);

  free(sm->current_data); // 释放最终数据
  sm->current_data = NULL;
  sm->current_state = STATE_DONE; // 标记为完成
}

/* 驱动状态机运行 */
void state_machine_run(StateMachine *sm)
{
  while (sm->current_state != STATE_DONE)
  {
    switch (sm->current_state)
    {
    case STATE_READ_FILE:
      handle_read_file(sm);
      break;
    case STATE_PROCESS1:
      handle_process1(sm);
      break;
    case STATE_PROCESS2:
      handle_process2(sm);
      break;
    case STATE_FINAL:
      handle_final(sm);
      break;
    default:
      fprintf(stderr, "Invalid state!\n");
      sm->current_state = STATE_DONE;
      break;
    }
  }
}

/* 模拟文件读取（原逻辑保留） */
void read_file(const char *filename, void (*process)(char *, void *), void *user_data)
{
  // 此处实际应替换为文件读取逻辑，示例使用模拟数据
  char *mock_data = "Hello,Callback!";
  printf("Read complete\n");
  process(mock_data, user_data);
}

/* 原处理函数（调整为独立功能） */
void process_data1(char *data, void *user_data)
{
  char *processed = (char *)malloc(50);
  snprintf(processed, 50, "[1]%s", data);
  printf("Process1 done: %s\n", processed);
  free(processed); // 示例中直接释放（实际需根据需求调整）
}

void process_data2(char *data, void *user_data)
{
  char *final = (char *)malloc(50);
  snprintf(final, 50, "[2]%s", data);
  printf("Process2 done: %s\n", final);
  free(final);
}

/* 最终处理结果（原逻辑保留） */
void final_process(char *result, void *user_data)
{
  struct Context *ctx = (struct Context *)user_data;
  printf("Final output (%d retries): %s -> %s\n",
         ctx->retry_count, result, ctx->output_path);
}

///~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
int main()
{
  struct Context ctx = {3, "/path/to/output.txt"};

  // 使用状态机替代回调嵌套
  StateMachine *sm = state_machine_init(&ctx);
  if (!sm)
  {
    fprintf(stderr, "Failed to initialize state machine\n");
    return 1;
  }

  state_machine_run(sm); // 运行状态机处理全流程

  state_machine_cleanup(sm); // 清理资源
  return 0;
}
