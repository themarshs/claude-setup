---
name: rag
description: 本地 RAG 集成指南。基于 Orama 全文/向量/混合搜索 + Vectra TextSplitter 语言感知分块，对代码库或文档进行语义检索。适用于需要在本地文件中进行语义搜索、上下文召回、知识库构建时。
---

# RAG — 本地语义检索集成指南

> 将代码/文档切片 → embedding → 存入 Orama → 全文/向量/混合检索。全程零外部服务依赖（embedding 除外）。

## 激活条件

- 需要对代码库或文档集进行语义搜索时
- 构建本地知识库、上下文召回管道时
- 需要增量索引变更文件时

## 技术架构

```
文件系统 → TextSplitter(Vectra 内化) → chunks
chunks → Embedding Provider(外部) → vectors
vectors + chunks → Orama(存储+检索) → JSON 持久化
```

- **Orama** (`@orama/orama` v3.1.18)：零依赖, 3.3MB, 同步 API, 全文+向量+混合搜索
- **TextSplitter**：从 Vectra 提取内化，19 语言感知递归分割 + 贪心合并 + overlap 滑窗

## 依赖

```bash
npm install @orama/orama    # 唯一外部依赖
# TextSplitter 为源码内嵌，无需额外安装
```

## 核心 API

### 1. 创建索引

```typescript
import { create, insert, search, save, load } from '@orama/orama'

const db = await create({
  schema: {
    path: 'string',           // 源文件路径
    chunk: 'string',          // 文本片段（全文索引）
    embedding: 'vector[1536]', // 向量（维度匹配你的 embedding 模型）
    metadata: 'string',       // JSON: { line_start, line_end, last_modified }
  },
})
```

### 2. 文档分块与索引

```typescript
import { TextSplitter } from './text-splitter' // 内化源码

const splitter = new TextSplitter({ chunkSize: 512, chunkOverlap: 64 })

async function indexFile(db, filePath: string, content: string, embedFn: EmbedFn) {
  const chunks = splitter.split(content)
  for (let i = 0; i < chunks.length; i++) {
    const vector = await embedFn(chunks[i].text)
    await insert(db, {
      path: filePath,
      chunk: chunks[i].text,
      embedding: vector,
      metadata: JSON.stringify({ line_start: chunks[i].start, line_end: chunks[i].end }),
    })
  }
}
```

### 3. 三种搜索模式

```typescript
// 全文搜索
const fulltext = await search(db, { term: 'useEffect cleanup', properties: ['chunk'] })

// 向量搜索
const queryVec = await embedFn('how to handle errors in async functions')
const vector = await search(db, { mode: 'vector', vector: { value: queryVec, property: 'embedding' } })

// 混合搜索（全文 + 向量融合）
const hybrid = await search(db, {
  mode: 'hybrid',
  term: 'error handling',
  vector: { value: queryVec, property: 'embedding' },
})
```

### 4. 持久化 save/load

```typescript
import { save, load } from '@orama/orama'

// 保存到 JSON
const snapshot = await save(db)
fs.writeFileSync('index.orama.json', JSON.stringify(snapshot))

// 从 JSON 恢复
const data = JSON.parse(fs.readFileSync('index.orama.json', 'utf-8'))
const restored = await load(db, data) // 需先 create 同 schema 的空 db
```

### 5. 增量更新

```typescript
async function incrementalUpdate(db, changedFiles: Map<string, string>, embedFn: EmbedFn) {
  for (const [path, content] of changedFiles) {
    // 删除旧 chunks：搜索该文件所有条目并逐一 remove
    const old = await search(db, { term: path, properties: ['path'], limit: 1000 })
    for (const hit of old.hits) await remove(db, hit.id)
    // 重新索引
    if (content) await indexFile(db, path, content, embedFn)
  }
}
```

## Embedding 接口定义

Orama 不内置 embedding，需外部注入。接口约定：

```typescript
type EmbedFn = (text: string) => Promise<number[]>

// 示例：OpenAI
const embedFn: EmbedFn = async (text) => {
  const res = await fetch('https://api.openai.com/v1/embeddings', {
    method: 'POST', headers: { Authorization: `Bearer ${KEY}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ model: 'text-embedding-3-small', input: text }),
  })
  return (await res.json()).data[0].embedding // 1536 维
}
```

可替换为任意本地模型（Ollama nomic-embed-text 等），只需匹配 schema 中的 vector 维度。

## TextSplitter 要点（Vectra 内化）

- 递归分割：按段落 → 句子 → 词逐级降级，保持语义完整性
- 贪心合并：小片段向上合并直到逼近 chunkSize
- overlap 滑窗：相邻 chunks 重叠 chunkOverlap 个 token，防止边界信息丢失
- 19 语言感知：内置中/英/日等语言的句子边界规则

## 局限性

- **暴力搜索 O(n)**：Orama 向量搜索为线性扫描，适用于 <10K chunks（约 5MB 文本）
- **无内置 embedding**：需自行提供 embedding 函数，增加外部依赖
- **内存驻留**：索引全量加载到内存，大规模数据需考虑分片
- **JSON 持久化**：序列化/反序列化大索引有 I/O 开销，非增量快照
