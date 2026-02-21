---
name: fuzzing-automation
description:
  what: "AFL++ 模糊测试自动化工作流，支持二进制安全漏洞发现与崩溃分析"
  when: "对二进制程序进行安全模糊测试，发现潜在漏洞时使用"
  keywords: [fuzzing, AFL++, binary, security, crash-analysis, exploit]
---

# Fuzzing Automation Skill

> 基于 gadievron/raptor (1.1k stars) AFL++ 集成最佳实践

## 核心概念

### 1. AFL++ 模糊测试工作流

AFL++ 是基于 AFL 的下一代模糊测试工具，提供更快的模糊测试速度和更高效的覆盖率引导。

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   种子语料库    │───▶│   AFL++ Fuzzer   │───▶│   崩溃输出      │
│  (Seed Corpus)  │    │  (并行实例)      │    │ (Crashes Dir)   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                                        │
                                                        ▼
                                               ┌─────────────────┐
                                               │  崩溃分析管道   │
                                               │ (Crash分析+分类)│
                                               └─────────────────┘
```

### 2. 关键参数配置

| 参数 | 说明 | 推荐值 |
|------|------|--------|
| `--parallel` | 并行 AFL 实例数 | CPU 核心数 |
| `--timeout` | 单次执行超时(ms) | 1000 |
| `--duration` | 模糊测试时长(秒) | 3600+ |
| `--dict` | 字典文件路径 | 结构化输入必选 |
| `--input-mode` | 输入模式 | stdin/file |

### 3. 崩溃收集与分类

#### 信号优先级（按可利用性排序）

```python
SIGNAL_PRIORITY = {
    "11": 1,  # SIGSEGV - 内存访问违例（最高优先级）
    "06": 2,  # SIGABRT - 断言失败/堆损坏
    "04": 3,  # SIGILL - 非法指令
    "08": 4,  # SIGFPE - 浮点异常
}
```

#### 崩溃去重策略

1. **输入哈希去重**：SHA256(input_file) 去除重复输入
2. **栈哈希去重**：stack_hash 去除相同崩溃位置的重复崩溃
3. **优先级排序**：按信号类型排序，优先分析高可利用性崩溃

### 4. 语料库管理最佳实践

#### 种子选择原则

- **多样性**：覆盖不同输入格式和代码路径
- **最小化**：删除冗余种子，只保留能触发新边的种子
- **格式感知**：使用字典文件引导结构化输入

#### 语料库目录结构

```
corpus/
├── seeds/           # 初始种子
│   ├── json/
│   ├── xml/
│   └── binary/
└── minimized/       # 最小化后的种子
```

### 5. 模糊测试策略选择

#### 策略矩阵

| 场景 | 策略 | 参数 |
|------|------|------|
| 已知结构化输入 | Havoc + Dictionary | `-x dict.txt` |
| 二进制协议解析 | QEMU 模式 | `-Q` |
| 并行加速 | 多实例 | `-M main -S secondary` |
| 长时间测试 | 持久模式 | `-P` |

## 实践公式

### 崩溃可利用性评分

```
Exploitability = f(signal_type, has_sanitizer, crash_location)
```

- 有 ASAN/UBSAN：更容易定位根因
- 在危险函数(crash in strcpy/memcpy)：高可利用性
- 堆溢出 vs 栈溢出：堆溢出更难利用

### 模糊测试效率公式

```
Coverage = f(corpus_quality, parallel_jobs, duration)
```

- 语料库质量 >> 并行数
- 长时间运行收益递减（每6小时评估一次）

## 命令参考

### 基础模糊测试

```bash
# 基本用法
python3 raptor_fuzzing.py --binary /path/to/binary --duration 3600

# 带种子语料库
python3 raptor_fuzzing.py --binary ./target --corpus ./seeds --duration 1800

# 并行模糊测试
python3 raptor_fuzzing.py --binary ./target --parallel 4 --duration 3600
```

### 高级配置

```bash
# 结构化输入（JSON）
python3 raptor_fuzzing.py --binary ./parser --dict json.dict --input-mode file

# 带覆盖率分析
python3 raptor_fuzzing.py --binary ./target --use-showmap --duration 3600

# 检查 sanitizer
python3 raptor_fuzzing.py --binary ./target --check-sanitizers
```

### 自主模式（带 LLM 分析）

```bash
# 自主模式 + 目标导向
python3 raptor_fuzzing.py --binary ./target --autonomous --goal "find heap overflow"
```

## NEVER 清单

### 安全红线

- **NEVER** 在生产环境直接运行模糊测试
- **NEVER** 模糊测试未隔离的网络服务
- **NEVER** 提交生成的崩溃文件到版本控制
- **NEVER** 在共享机器上运行长时间模糊测试（资源竞争）

### 技术红线

- **NEVER** 模糊测试未编译的源代码（必须先编译+仪器化）
- **NEVER** 使用非仪器化二进制进行覆盖率引导模糊测试（使用 `-Q` QEMU 模式）
- **NEVER** 忽略 sanitizer 警告（ASAN/UBSAN 是崩溃根因的金矿）
- **NEVER** 不设置超时就运行模糊测试（资源耗尽）

### 操作红线

- **NEVER** 直接分析外部提供的崩溃文件（先在沙箱环境验证）
- **NEVER** 生成利用代码后不验证可执行性
- **NEVER** 忽略 macOS 的共享内存限制问题（需要配置 `shm`）
- **NEVER** 不检查二进制是否仪器化就运行模糊测试

## 输出结构

### 模糊测试报告

```json
{
  "binary": "/path/to/binary",
  "duration": 3600,
  "total_crashes": 42,
  "analysed": 10,
  "exploitable": 3,
  "exploits_generated": 2,
  "coverage": {
    "edges": 12345,
    "uncovered_edges": 6789
  }
}
```

### 崩溃分析结果

```
CRASH_001:
  - Signal: SIGSEGV (11)
  - Location: memcpy() in libparser.so
  - Type: heap-buffer-overflow
  - Exploitability: HIGH
  - Suggested Fix: 添加边界检查
```

## 故障排查

### 常见问题

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| 无崩溃 | 种子质量差 | 使用多样化种子或生成新种子 |
| 共享内存错误 | macOS 限制 | 配置 `AFL_MAP_SIZE=65536` |
| QEMU 模式慢 | 无仪器化 | 重新编译为仪器化版本 |
| 覆盖率不增长 | 二进制无 GCOV | 使用 `AFL_USE_LTO=1` 编译 |

### 诊断命令

```bash
# 检查仪器化
strings target | grep -i afl

# 检查 sanitizer
readelf -d target | grep -i sanitizer

# 查看覆盖率
afl-showmap -o /dev/null -i corpus -- ./target @@
```

---

**来源**: gadievron/raptor packages/fuzzing/ 模块 + raptor_fuzzing.py 主流程
