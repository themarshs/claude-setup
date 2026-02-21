---
name: skill-judge
description: "Evaluate and forge Agent Skills into production-ready components. Two modes: (1) Whole-Skill evaluation — score a Skill against 8 dimensions (120 points), grade A-F. (2) Element Dissection — decompose Skills into atomic elements, score individually, detect combinations, compare against existing system, and forge精华 into precise locations. Use when reviewing, auditing, improving, or absorbing community Skills/Agents/Rules. Triggers: skill evaluation, skill review, skill audit, code review of skills, absorb community asset, forge skill elements."
---

# Skill Judge — 评价 + 锻造

> 不只是验房师，是精装修公司：搜 → 拆 → 评 → 组 → 锻 → 装 → 验收 → 交钥匙

## Core Formula

> **Good Skill = Expert-only Knowledge − What Claude Already Knows**

Knowledge types in any Skill:

| Type | Definition | Treatment |
|------|------------|-----------|
| **[E] Expert** | Claude genuinely doesn't know | Must keep — this is value |
| **[A] Activation** | Claude knows but may not think of | Keep if brief |
| **[R] Redundant** | Claude definitely knows | Delete — token waste |

## Mode Selection

```
输入是什么？
    │
    ├─ 一个完整的 Skill/Agent 需要整体评分？
    │   └─ → Mode 1: Whole-Skill Evaluation
    │     MANDATORY load: references/whole-skill-evaluation.md
    │     Do NOT load: references/element-dissection.md
    │
    ├─ 多个候选需要拆解、比较、融合？
    │   └─ → Mode 2: Element Dissection
    │     MANDATORY load: references/element-dissection.md
    │     Do NOT load: references/whole-skill-evaluation.md
    │
    └─ 不确定？→ 看信号词
        "评一下" "打个分" "怎么样" → Mode 1
        "最好的" "吸收" "融合" "精华" "锻造" → Mode 2
```

## Mode 1: Whole-Skill Evaluation (验房)

**输入**: 一个 Skill/Agent 的完整内容
**输出**: 评分报告 + 改进建议

**MANDATORY**: Load `references/whole-skill-evaluation.md` for the 8-dimension scoring framework.

Quick summary of dimensions (120 points total):

| Dimension | Max | Core Question |
|-----------|-----|---------------|
| D1: Knowledge Delta | 20 | Does it add knowledge Claude doesn't have? |
| D2: Mindset + Procedures | 15 | Does it transfer thinking patterns? |
| D3: Anti-Pattern Quality | 15 | Does it have expert-grade NEVER lists? |
| D4: Spec Compliance | 15 | Is the description comprehensive (WHAT+WHEN+KEYWORDS)? |
| D5: Progressive Disclosure | 15 | Is content properly layered? |
| D6: Freedom Calibration | 15 | Does specificity match task fragility? |
| D7: Pattern Recognition | 10 | Does it follow established patterns? |
| D8: Practical Usability | 15 | Can an Agent immediately use it? |

Grade: A(90+) / B(80-89) / C(70-79) / D(60-69) / F(<60)

## Mode 2: Element Dissection (精装修)

**输入**: 一个或多个 Skill/Agent 的完整内容 + 现有体系上下文
**输出**: 锻造完成的文件（交钥匙）

**MANDATORY**: Load `references/element-dissection.md` for the 7-step forging protocol.

Quick summary of the pipeline:

```
Step 1: DISSECT — 拆为原子元素
Step 2: SCORE — 逐个评分（25-100）
Step 3: COMBINE — 检测元素间的协同效应
Step 4: COMPARE — 对比现有体系（有/没有/更好/互补）
Step 5: FORGE — 精华锻造方案（补什么/改什么/扔什么）
Step 6: INSTALL — 写入文件
Step 7: VERIFY — 回归验证
```

Key insight: **整体 77 分的 Skill 内部可能有 95 分的元素和 25 分的冗余。元素解剖让精华不被冗余拖下水。**

## NEVER

- NEVER 整体拒绝就走人——低分 Skill 里可能有高分元素
- NEVER 整体接受就搬入——高分 Skill 里可能有冗余
- NEVER 只看单元素分数——组合可能产生涌现价值
- NEVER 不对比现有体系就融合——现有可能已经更好
- NEVER 给高分因为"看起来专业"——格式不等于知识密度
- NEVER 忽略 description 字段——它决定 Skill 是否被激活

## Meta-Question

评价任何 Skill 时，始终回到这个根本问题：

> **"如果我是这个领域的 10 年专家，看到这个 Skill，我会说'是的，这些知识是我踩了无数坑才学会的'吗？"**

Yes → genuine value. No → garbage compression.
