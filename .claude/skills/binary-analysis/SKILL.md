---
name: binary-analysis
description:
  what: "二进制崩溃分析与调试工作流，提供从崩溃样本到可利用性评估的完整管道"
  when: "模糊测试发现崩溃、需要分析崩溃根因、评估漏洞可利用性时使用"
  keywords: [binary-analysis, crash-analysis, debugger, gdb, exploitability, reverse-engineering, memory-corruption]
---

# Binary Analysis Skill

> 来源：gadievron/raptor (1.1k stars) binary_analysis 包
> 核心公式：Good Skill = Expert-only Knowledge - What Claude Already Knows

## 激活条件

- 模糊测试发现崩溃需要分析时
- 需要判断崩溃可利用性时
- 进行二进制逆向工程和安全审计时
- 漏洞挖掘中的崩溃根因分析场景

## 核心架构

### 崩溃分析工作流

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐    ┌──────────────┐
│  崩溃样本   │───▶│  调试器分析  │───▶│  反汇编分析 │───▶│  可利用性评估 │
│ (Crash Input)│    │ (GDB/LLDB)   │    │ (objdump)   │    │ (LLM Analysis)│
└─────────────┘    └──────────────┘    └─────────────┘    └──────────────┘
```

### 工具链

| 工具 | 用途 | 必选 |
|------|------|------|
| GDB/LLDB | 调试器，获取栈trace和寄存器 | 是 |
| nm | 符号表分析 | 是 |
| addr2line | 地址到源码映射 | 是 |
| objdump | 反汇编 | 是 |
| readelf | ELF 文件分析 | 是 |

## 核心数据结构

### CrashContext 崩溃上下文

```python
@dataclass
class CrashContext:
    crash_id: str              # 崩溃唯一标识
    binary_path: Path          # 二进制路径
    input_file: Path           # 触发崩溃的输入文件
    signal: str                # 信号类型 (SIGSEGV, SIGABRT, etc.)

    # 调试器提取
    stack_trace: str = ""      # 栈跟踪信息
    registers: Dict[str, str]  # 寄存器状态
    crash_instruction: str    # 导致崩溃的指令
    crash_address: str         # 崩溃地址
    stack_hash: str = ""       # 栈哈希（去重）

    # 反汇编分析
    disassembly: str = ""      # 反汇编代码
    function_name: str         # 函数名
    source_location: str      # 源码位置 (file:line)

    # 二进制信息
    binary_info: Dict[str, str]  # 安全缓解措施

    # 分析结果
    exploitability: str        # 可利用性评估
    crash_type: str            # 崩溃类型
    cvss_estimate: float      # CVSS 评分
```

### 崩溃类型分类

| 类型 | 说明 | 可利用性 |
|------|------|----------|
| heap_overflow | 堆溢出 | 高 |
| stack_overflow | 栈溢出 | 高 |
| use_after_free | UAF | 高 |
| double_free | 双重释放 | 中 |
| null_deref | 空指针解引用 | 低 |
| out_of_bounds | 越界访问 | 高 |
| format_string | 格式化字符串 | 高 |

## 执行流程

### Step 1: 工具可用性检查

```python
def _check_tool_availability(self) -> Dict[str, bool]:
    """检查必需的二进制分析工具是否可用"""
    tools = {
        'nm': self._check_tool('nm'),
        'addr2line': self._check_tool('addr2line'),
        'objdump': self._check_tool('objdump'),
        'gdb': self._check_tool('gdb') or self._check_tool('lldb'),
    }
    return tools
```

**关键约束**：必须验证所有工具可用后再继续，否则分析不完整。

### Step 2: 调试器检测与选择

```python
def _detect_debugger(self):
    """根据平台选择调试器"""
    system = platform.system()
    if system == "Darwin":
        return "lldb"  # macOS 使用 LLDB
    else:
        return "gdb"   # Linux 使用 GDB
```

### Step 3: 符号表加载

```python
def _load_symbol_table(self):
    """加载符号表用于地址到函数名的映射"""
    result = subprocess.run(
        ['nm', '-C', str(self.binary)],
        capture_output=True,
        text=True
    )
    # 解析 nm 输出构建符号缓存
```

### Step 4: GDB 崩溃分析

```python
def get_backtrace(self, input_file: Path) -> str:
    """获取崩溃时的完整栈跟踪"""
    commands = [
        "set pagination off",
        "set confirm off",
        f"run < {input_file}",
        "backtrace full",
        "quit",
    ]
    return self.run_commands(commands)

def get_registers(self, input_file: Path) -> str:
    """获取崩溃时的寄存器状态"""
    commands = [
        "set pagination off",
        "set confirm off",
        f"run < {input_file}",
        "info registers",
        "quit",
    ]
    return self.run_commands(commands)

def examine_memory(self, input_file: Path, address: str, num_bytes: int = 64) -> str:
    """检查指定地址的内存内容"""
    commands = [
        "set pagination off",
        "set confirm off",
        f"run < {input_file}",
        f"x/{num_bytes}xb {address}",
        "quit",
    ]
    return self.run_commands(commands)
```

### Step 5: 反汇编分析

```python
def _get_disassembly(self, address: str) -> str:
    """获取崩溃地址的反汇编代码"""
    result = subprocess.run(
        ['objdump', '-d', '-j', '.text', str(self.binary)],
        capture_output=True,
        text=True
    )
    # 从 objdump 输出中提取崩溃地址附近的指令
```

### Step 6: 源码位置映射

```python
def _get_source_location(self, address: str) -> str:
    """使用 addr2line 将地址映射到源码位置"""
    result = subprocess.run(
        ['addr2line', '-e', str(self.binary), '-f', address],
        capture_output=True,
        text=True
    )
    # 格式: function_name\nfile:line
```

### Step 7: 内存布局分析

```python
def _analyze_memory_regions(self) -> Dict[str, str]:
    """分析崩溃发生时的内存区域类型"""
    # 读取 /proc/self/maps (Linux) 或使用调试器
    # 返回: heap, stack, mmap, rwdata, unknown
```

### Step 8: 安全缓解措施检测

```python
def _get_memory_layout_info(self) -> Dict[str, str]:
    """检测二进制安全缓解措施"""
    checks = {
        'ASLR': self._check_aslr(),
        'Stack Canary': self._check_stack_canary(),
        'NX': self._check_nx_bit(),
        'Full RELRO': self._check_relro(),
    }
    return checks
```

### Step 9: ASan 二进制检测与特殊分析

```python
def _detect_asan_binary(self) -> bool:
    """检测是否为 AddressSanitizer 编译的二进制"""
    result = subprocess.run(
        ['nm', str(self.binary)],
        capture_output=True,
        text=True
    )
    return '__asan_init' in result.stdout

def _run_asan_analysis(self, crash_input: Path) -> Dict:
    """对 ASan 二进制进行增强分析"""
    # ASan 提供更精确的内存错误信息
```

## 可利用性评估框架

### 评估矩阵

| 崩溃位置 | 有缓解 | 信号 | 可利用性 |
|----------|--------|------|----------|
| 堆 (heap) | 无 | SIGSEGV | EXPLOITABLE |
| 栈 (stack) | 有 canary | SIGSEGV | UNLIKELY |
| .text | N/A | SIGSEGV | LIKELY |
| NULL | N/A | SIGSEGV | NOT_EXPLOITABLE |

### CVSS 估算

```python
def _estimate_cvss(self, crash_type: str, exploitability: str) -> float:
    """基于崩溃类型和可利用性估算 CVSS 评分"""
    base_scores = {
        'heap_overflow': 9.8,
        'stack_overflow': 9.8,
        'use_after_free': 8.8,
        'null_deref': 4.3,
    }
    # 根据缓解措施调整
```

## 崩溃去重策略

### 栈哈希去重

```python
def _compute_stack_hash(self, stack_trace: str) -> str:
    """计算栈跟踪的哈希用于去重"""
    # 规范化栈跟踪（去除地址偏移等）
    normalized = re.sub(r'0x[0-9a-f]+', 'ADDR', stack_trace)
    return hashlib.sha256(normalized.encode()).hexdigest()[:16]
```

### 优先级排序

```python
SIGNAL_PRIORITY = {
    "11": 1,  # SIGSEGV - 内存访问违例
    "06": 2,  # SIGABRT - 断言失败/堆损坏
    "04": 3,  # SIGILL - 非法指令
    "08": 4,  # SIGFPE - 浮点异常
}
```

## 环境崩溃检测

```python
def _detect_environmental_crash(self, output: str) -> bool:
    """过滤调试器本身产生的崩溃（如 GDB 内部错误）"""
    env_errors = [
        "During symbol reading",
        "No symbol table",
        "Dwarf Error",
    ]
    return any(err in output for err in env_errors)
```

## NEVER 清单

- **NEVER** 直接运行未验证的崩溃输入而不检查其来源
- **NEVER** 跳过工具可用性检查就执行分析
- **NEVER** 忽略 ASan 二进制的特殊分析需求
- **NEVER** 仅依赖单一调试器输出做可利用性判断
- **NEVER** 跳过内存区域分析就确定崩溃位置
- **NEVER** 忽略环境崩溃（调试器自身错误）的过滤
- **NEVER** 不检查安全缓解措施就评估可利用性
- **NEVER** 对崩溃输入不做去重就批量分析

## 使用示例

```python
# 初始化崩溃分析器
from packages.binary_analysis.crash_analyser import CrashAnalyser

analyser = CrashAnalyser(binary_path='/path/to/target_binary')

# 分析崩溃
result = analyser.analyse_crash(
    crash_input=Path('/path/to/crash_input'),
    crash_id='crash_001'
)

# 输出结果
print(f"Crash Type: {result.crash_type}")
print(f"Exploitability: {result.exploitability}")
print(f"CVSS: {result.cvss_estimate}")
print(f"Location: {result.source_location}")
```

## 与现有工具的关系

| 工具 | 关系 | 说明 |
|------|------|------|
| fuzzing-automation | 互补 | fuzzing-automation 负责模糊测试，binary-analysis 负责崩溃分析 |
| security-research | 互补 | security-research 进行渗透测试，binary-analysis 提供底层崩溃分析能力 |
| exploit-feasibility | 互补 | exploit-feasibility 分析缓解措施，binary-analysis 分析崩溃本身 |
| hunt | 无关 | 通用搜索工具 |
| rag / context7 | 正交 | 文档检索增强 |
