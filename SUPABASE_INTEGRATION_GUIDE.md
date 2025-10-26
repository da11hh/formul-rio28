# 🚀 Guia Completo de Integração Supabase
## ExecutiveAI Pro - Documentação de Persistência de Dados

**Data:** 22 de Outubro de 2025  
**Autor:** Equipe de Desenvolvimento  
**Status:** ✅ Funcionando e Testado

---

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Arquitetura do Sistema](#arquitetura-do-sistema)
3. [Tabelas Integradas](#tabelas-integradas)
4. [Como Funciona a Integração](#como-funciona-a-integração)
5. [Mapeamento de Campos](#mapeamento-de-campos)
6. [Endpoints e Fluxos](#endpoints-e-fluxos)
7. [Problema Anterior e Solução](#problema-anterior-e-solução)
8. [Exemplos Práticos](#exemplos-práticos)
9. [Troubleshooting](#troubleshooting)

---

## 🎯 Visão Geral

O ExecutiveAI Pro utiliza uma **arquitetura dual-write** para persistência de dados:

- **PostgreSQL Local (Replit):** Banco de dados local para desenvolvimento e fallback
- **Supabase:** Banco de dados cloud principal para produção e sincronização

### Tabelas Integradas com Supabase

| Tabela | Descrição | Endpoint Principal |
|--------|-----------|-------------------|
| `financial_files` | Arquivos/Anexos financeiros | `/api/files` |
| `workspace_pages` | Páginas do workspace Notion-style | `/api/workspace/load` |
| `workspace_boards` | Quadros Kanban | `/api/workspace/load` |
| `workspace_databases` | Bancos de dados do workspace | `/api/workspace/load` |
| `dashboard_completo_v5_base` | Dados do dashboard executivo | `/api/dashboard/dashboard-data` |

---

## 🏗️ Arquitetura do Sistema

### Diagrama de Fluxo

```
┌─────────────┐
│   Frontend  │
│   (React)   │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────┐
│   Backend Express (Node.js)         │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  Credenciais do Cliente     │   │
│  │  (Supabase URL + Key)       │   │
│  └─────────────────────────────┘   │
│                │                    │
│                ▼                    │
│  ┌─────────────────────────────┐   │
│  │  Cliente Dinâmico Supabase  │   │
│  │  getDynamicSupabaseClient() │   │
│  └─────────────────────────────┘   │
│                │                    │
└────────────────┼────────────────────┘
                 │
        ┌────────┴────────┐
        │                 │
        ▼                 ▼
┌──────────────┐   ┌──────────────┐
│  Supabase    │   │ PostgreSQL   │
│  (Cloud)     │   │ (Local)      │
│  PRIORIDADE  │   │  FALLBACK    │
└──────────────┘   └──────────────┘
```

### Princípios Fundamentais

1. **Prioridade ao Supabase:** Sempre tenta buscar dados do Supabase primeiro
2. **Fallback Inteligente:** Se Supabase não estiver configurado, usa PostgreSQL local
3. **Dual-Write:** Salva em ambos os bancos (quando aplicável)
4. **Conversão de Campos:** snake_case (Supabase) ↔ camelCase (Frontend)

---

## 📊 Tabelas Integradas

### 1. `financial_files` - Anexos Financeiros

**Endpoint:** `GET /api/files`

```typescript
// Estrutura no Supabase (snake_case)
{
  id: string,
  user_id: string,
  file_name: string,
  file_url: string,
  category: string,
  amount: number,
  description: string,
  storage_type: 'supabase',
  status: 'active',
  created_at: timestamp,
  updated_at: timestamp
}

// Mapeado para Frontend (camelCase)
{
  id: string,
  userId: string,
  fileName: string,
  fileUrl: string,
  category: string,
  amount: number,
  description: string,
  storageType: 'supabase',
  status: 'active',
  createdAt: timestamp,
  updatedAt: timestamp
}
```

**Exemplo de Resposta:**
```json
[
  {
    "id": "fin_1760323905992_rhnnwa2wl",
    "userId": "default_user",
    "fileName": null,
    "fileUrl": "https://supabase.co/storage/v1/...",
    "category": "moradia",
    "amount": 665.77,
    "description": "Despesas condominiais",
    "storageType": "supabase",
    "status": "active",
    "createdAt": "2025-10-13T02:51:34.231+00:00",
    "updatedAt": "2025-10-13T02:51:46.289+00:00"
  }
]
```

---

### 2. `workspace_pages` - Páginas do Workspace

**Endpoint:** `GET /api/workspace/load`

```typescript
// Estrutura no Supabase (snake_case)
{
  id: string,
  tenant_id: string,
  client_id: string,
  title: string,
  icon: string,
  cover: string,
  blocks: JSONB,  // Array de blocos
  databases: JSONB,  // Array de databases
  parent_id: string,
  created_at: timestamp,
  updated_at: timestamp,
  font_style: string,
  small_text: boolean,
  full_width: boolean,
  locked: boolean,
  favorited: boolean
}
```

**Campos JSONB:**
- `blocks`: Array de objetos de conteúdo da página
- `databases`: Array de IDs de databases vinculados

**Conversão automática:**
```typescript
// Supabase retorna:
blocks: '["array", "json", "stringified"]'

// Backend converte para:
blocks: ["array", "json", "parsed"]
```

---

### 3. `workspace_boards` - Quadros Kanban

**Endpoint:** `GET /api/workspace/load`

```typescript
// Estrutura no Supabase (snake_case)
{
  id: string,
  tenant_id: string,
  client_id: string,
  title: string,
  icon: string,
  cover: string,
  lists: JSONB,     // Colunas do Kanban
  cards: JSONB,     // Cartões
  labels: JSONB,    // Etiquetas
  members: JSONB,   // Membros
  settings: JSONB,  // Configurações
  created_at: timestamp,
  updated_at: timestamp,
  favorited: boolean
}
```

**Campos JSONB:**
- `lists`: Array de colunas com seus cartões
- `cards`: Array de todos os cartões
- `labels`: Array de etiquetas configuradas
- `members`: Array de membros do board
- `settings`: Objeto de configurações gerais

---

### 4. `workspace_databases` - Databases do Workspace

**Endpoint:** `GET /api/workspace/load`

```typescript
// Estrutura no Supabase (snake_case)
{
  id: string,
  tenant_id: string,
  client_id: string,
  title: string,
  icon: string,
  cover: string,
  view_type: string,  // 'table', 'board', 'calendar', etc
  columns: JSONB,     // Definição das colunas
  rows: JSONB,        // Dados das linhas
  views: JSONB,       // Visualizações salvas
  created_at: timestamp,
  updated_at: timestamp
}
```

**Mapeamento Especial:**
```typescript
// Supabase usa view_type
// Frontend usa view
// Backend converte automaticamente:
if (camelDb.viewType && !camelDb.view) {
  camelDb.view = camelDb.viewType;
}
```

---

### 5. `dashboard_completo_v5_base` - Dashboard Executivo

**Endpoint:** `GET /api/dashboard/dashboard-data`

```typescript
// Estrutura no Supabase (snake_case)
{
  idx: number,
  tenant_id: string,
  telefone: string,
  nome_completo: string,
  email_principal: string,
  status_atendimento: 'active' | 'pause' | 'completed',
  setor_atual: string,
  ativo: boolean,
  tipo_reuniao_atual: 'online' | 'presencial',
  primeiro_contato: timestamp,
  ultimo_contato: timestamp,
  total_registros: number,
  registros_dados_cliente: number,
  total_mensagens_chat: number,
  total_transcricoes: number,
  fontes_dados: number,
  tem_dados_cliente: boolean,
  tem_historico_chat: boolean,
  tem_transcricoes: boolean,
  ultima_atividade: timestamp,
  id_reuniao_atual: string,
  ultima_transcricao: timestamp,
  mensagens_cliente: text,
  mensagens_agente: text
}
```

---

## 🔄 Como Funciona a Integração

### Fluxo de Leitura (GET)

```typescript
// 1. Frontend faz request
GET /api/workspace/load

// 2. Backend verifica credenciais
const supabase = getDynamicSupabaseClient(clientId);

// 3a. Se Supabase configurado:
if (supabase) {
  // Busca do Supabase
  const { data, error } = await supabase
    .from('workspace_pages')
    .select('*');
  
  // Converte snake_case → camelCase
  const camelData = convertKeysToCamelCase(data);
  
  // Parse campos JSONB
  if (typeof camelData.blocks === 'string') {
    camelData.blocks = JSON.parse(camelData.blocks);
  }
  
  return { success: true, data: camelData, source: 'supabase' };
}

// 3b. Se Supabase NÃO configurado:
else {
  // Fallback para PostgreSQL local
  const localData = await db.select().from(workspacePages);
  return { success: true, data: localData, source: 'local_db' };
}
```

### Fluxo de Escrita (POST/PUT)

```typescript
// 1. Frontend envia dados (camelCase)
POST /api/workspace/save
{
  pages: [{
    id: "abc123",
    title: "Minha Página",
    blocks: [{ type: "text", content: "Hello" }]
  }]
}

// 2. Backend converte camelCase → snake_case
const snakeCasePages = pages.map(page => {
  const converted = convertKeysToSnakeCase({
    ...page,
    tenantId,
    clientId,
    createdAt: page.createdAt || Date.now(),
    updatedAt: Date.now()
  });
  
  // 3. Stringify campos JSONB
  if (converted.blocks) {
    converted.blocks = JSON.stringify(converted.blocks);
  }
  
  return converted;
});

// 4. Salva no Supabase com UPSERT
const { error } = await supabase
  .from('workspace_pages')
  .upsert(snakeCasePages, { onConflict: 'id' });

// 5. Retorna sucesso
return { success: true, message: 'Workspace salvo' };
```

### Sistema de Deletions

```typescript
// 1. Busca IDs existentes no Supabase
const { data: existingPages } = await supabase
  .from('workspace_pages')
  .select('id');

const existingIds = existingPages.map(p => p.id);

// 2. Identifica IDs que não foram recebidos
const receivedIds = new Set(pages.map(p => p.id));
const idsToDelete = existingIds.filter(id => !receivedIds.has(id));

// 3. Deleta IDs ausentes
if (idsToDelete.length > 0) {
  await supabase
    .from('workspace_pages')
    .delete()
    .in('id', idsToDelete);
}
```

---

## 🗺️ Mapeamento de Campos

### Função de Conversão Snake Case

```typescript
function toSnakeCase(str: string): string {
  return str.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`);
}

function convertKeysToSnakeCase(obj: any): any {
  if (obj === null || obj === undefined) return obj;
  
  if (Array.isArray(obj)) {
    return obj.map(item => convertKeysToSnakeCase(item));
  }
  
  if (typeof obj === 'object' && obj.constructor === Object) {
    const converted: any = {};
    for (const key in obj) {
      if (obj.hasOwnProperty(key)) {
        const snakeKey = toSnakeCase(key);
        converted[snakeKey] = convertKeysToSnakeCase(obj[key]);
      }
    }
    return converted;
  }
  
  return obj;
}
```

### Função de Conversão Camel Case

```typescript
function toCamelCase(str: string): string {
  return str.replace(/_([a-z])/g, (_, letter) => letter.toUpperCase());
}

function convertKeysToCamelCase(obj: any): any {
  if (obj === null || obj === undefined) return obj;
  
  if (Array.isArray(obj)) {
    return obj.map(item => convertKeysToCamelCase(item));
  }
  
  if (typeof obj === 'object' && obj.constructor === Object) {
    const converted: any = {};
    for (const key in obj) {
      if (obj.hasOwnProperty(key)) {
        const camelKey = toCamelCase(key);
        converted[camelKey] = convertKeysToCamelCase(obj[key]);
      }
    }
    return converted;
  }
  
  return obj;
}
```

### Exemplos de Conversão

| camelCase (Frontend) | snake_case (Supabase) |
|---------------------|----------------------|
| `userId` | `user_id` |
| `fileName` | `file_name` |
| `createdAt` | `created_at` |
| `updatedAt` | `updated_at` |
| `tenantId` | `tenant_id` |
| `clientId` | `client_id` |
| `statusAtendimento` | `status_atendimento` |
| `nomeCompleto` | `nome_completo` |

---

## 🔌 Endpoints e Fluxos

### 1. Anexos Financeiros

#### GET `/api/files` - Listar arquivos

**Request:**
```bash
GET /api/files
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "fin_123",
      "userId": "user_1",
      "fileName": "boleto.pdf",
      "fileUrl": "https://supabase.co/storage/...",
      "category": "moradia",
      "amount": 1500.00,
      "description": "Aluguel",
      "storageType": "supabase",
      "status": "active",
      "createdAt": "2025-10-13T02:51:34.231+00:00",
      "updatedAt": "2025-10-13T02:51:46.289+00:00"
    }
  ],
  "source": "supabase",
  "count": 7
}
```

**Código Implementação:**
```typescript
// server/routes/billing.ts
app.get("/api/files", async (req, res) => {
  try {
    const clientId = req.user?.clientId || '1';
    const supabase = getDynamicSupabaseClient(clientId);
    
    if (!supabase) {
      // Fallback para PostgreSQL local
      const localFiles = await db.select().from(financialFiles);
      return res.json({ 
        success: true, 
        data: localFiles, 
        source: 'local_db' 
      });
    }
    
    console.log('✅ Cliente Supabase (re)criado com sucesso');
    console.log('🔍 Buscando arquivos do Supabase...');
    
    const { data, error } = await supabase
      .from('financial_files')
      .select('*')
      .order('created_at', { ascending: false });
    
    if (error) throw error;
    
    console.log(`📁 ${data?.length || 0} arquivo(s) encontrado(s) no Supabase`);
    
    // Converter snake_case para camelCase
    const formattedData = (data || []).map(file => ({
      id: file.id,
      userId: file.user_id,
      fileName: file.file_name,
      fileUrl: file.file_url,
      category: file.category,
      amount: parseFloat(file.amount || 0),
      description: file.description,
      storageType: file.storage_type || 'supabase',
      status: file.status || 'active',
      createdAt: file.created_at,
      updatedAt: file.updated_at
    }));
    
    return res.json({ 
      success: true, 
      data: formattedData, 
      source: 'supabase',
      count: formattedData.length 
    });
  } catch (error) {
    console.error('Erro ao buscar arquivos:', error);
    return res.status(500).json({ 
      success: false, 
      error: 'Erro ao buscar arquivos' 
    });
  }
});
```

---

### 2. Workspace (Pages, Boards, Databases)

#### GET `/api/workspace/load` - Carregar workspace completo

**Request:**
```bash
GET /api/workspace/load
```

**Response:**
```json
{
  "success": true,
  "data": {
    "pages": [
      {
        "id": "page_123",
        "title": "Minha Página",
        "icon": "📄",
        "blocks": [
          { "id": "block_1", "type": "text", "content": "Hello" }
        ],
        "databases": [],
        "createdAt": 1760537894953,
        "updatedAt": 1760537896392
      }
    ],
    "boards": [
      {
        "id": "board_123",
        "title": "Projeto X",
        "lists": [
          {
            "id": "list_1",
            "title": "A Fazer",
            "cards": [...]
          }
        ],
        "labels": [...],
        "members": [...]
      }
    ],
    "databases": []
  },
  "source": "supabase",
  "loaded": {
    "pages": 1,
    "boards": 1,
    "databases": 0
  }
}
```

**Código Implementação:**
```typescript
// server/routes/workspace.ts
workspaceRoutes.get('/load', authenticateToken, async (req, res) => {
  try {
    const { clientId, tenantId } = req.user;
    const supabase = getDynamicSupabaseClient(clientId);
    
    if (!supabase) {
      return res.json({ 
        success: true,
        data: { pages: [], boards: [], databases: [] },
        source: 'empty'
      });
    }

    // Carregar pages
    const { data: pages, error: pagesError } = await supabase
      .from('workspace_pages')
      .select('*');

    // Carregar boards
    const { data: boards, error: boardsError } = await supabase
      .from('workspace_boards')
      .select('*');

    // Carregar databases
    const { data: databases, error: dbsError } = await supabase
      .from('workspace_databases')
      .select('*');

    // Parse JSON fields and convert to camelCase
    const parsedPages = (pages || []).map((page: any) => {
      const camelPage = convertKeysToCamelCase(page);
      
      // Parse JSONB fields
      if (typeof camelPage.blocks === 'string') {
        camelPage.blocks = JSON.parse(camelPage.blocks);
      }
      if (typeof camelPage.databases === 'string') {
        camelPage.databases = JSON.parse(camelPage.databases);
      }
      
      return camelPage;
    });

    const parsedBoards = (boards || []).map((board: any) => {
      const camelBoard = convertKeysToCamelCase(board);
      
      // Parse JSONB fields
      if (typeof camelBoard.lists === 'string') {
        camelBoard.lists = JSON.parse(camelBoard.lists);
      }
      if (typeof camelBoard.cards === 'string') {
        camelBoard.cards = JSON.parse(camelBoard.cards);
      }
      if (typeof camelBoard.labels === 'string') {
        camelBoard.labels = JSON.parse(camelBoard.labels);
      }
      if (typeof camelBoard.members === 'string') {
        camelBoard.members = JSON.parse(camelBoard.members);
      }
      if (typeof camelBoard.settings === 'string') {
        camelBoard.settings = JSON.parse(camelBoard.settings);
      }
      
      return camelBoard;
    });

    const parsedDatabases = (databases || []).map((db: any) => {
      const camelDb = convertKeysToCamelCase(db);
      
      // Parse JSONB fields
      if (typeof camelDb.columns === 'string') {
        camelDb.columns = JSON.parse(camelDb.columns);
      }
      if (typeof camelDb.rows === 'string') {
        camelDb.rows = JSON.parse(camelDb.rows);
      }
      if (typeof camelDb.views === 'string') {
        camelDb.views = JSON.parse(camelDb.views);
      }
      
      // Map viewType back to view for compatibility
      if (camelDb.viewType && !camelDb.view) {
        camelDb.view = camelDb.viewType;
      }
      
      return camelDb;
    });

    res.json({ 
      success: true,
      data: {
        pages: parsedPages,
        boards: parsedBoards,
        databases: parsedDatabases
      },
      source: 'supabase',
      loaded: {
        pages: parsedPages.length,
        boards: parsedBoards.length,
        databases: parsedDatabases.length
      }
    });
  } catch (error: any) {
    console.error('Erro ao carregar workspace:', error);
    res.status(500).json({ 
      success: false, 
      error: 'Erro ao carregar workspace do Supabase',
      details: error.message
    });
  }
});
```

#### POST `/api/workspace/save` - Salvar workspace

**Request:**
```json
POST /api/workspace/save
{
  "pages": [
    {
      "id": "page_123",
      "title": "Nova Página",
      "icon": "📄",
      "blocks": [
        { "id": "b1", "type": "text", "content": "Hello" }
      ]
    }
  ],
  "boards": [...],
  "databases": [...]
}
```

**Response:**
```json
{
  "success": true,
  "message": "Workspace salvo com sucesso",
  "saved": {
    "pages": 1,
    "boards": 0,
    "databases": 0
  }
}
```

**Código Implementação:**
```typescript
workspaceRoutes.post('/save', authenticateToken, async (req, res) => {
  try {
    const { pages, boards, databases } = req.body;
    const { clientId, tenantId } = req.user;

    const supabase = getDynamicSupabaseClient(clientId);
    if (!supabase) {
      return res.status(400).json({ 
        success: false, 
        error: 'Supabase não configurado' 
      });
    }

    const now = Date.now();

    // Salvar pages com deletion handling
    if (pages !== undefined) {
      const receivedPageIds = new Set(pages.map(p => p.id));
      
      // Buscar IDs existentes
      const { data: existingPages } = await supabase
        .from('workspace_pages')
        .select('id');

      // Deletar páginas removidas
      const existingIds = existingPages.map(p => p.id);
      const toDelete = existingIds.filter(id => !receivedPageIds.has(id));
      
      if (toDelete.length > 0) {
        await supabase
          .from('workspace_pages')
          .delete()
          .in('id', toDelete);
      }

      // Salvar/atualizar páginas
      if (pages && pages.length > 0) {
        const pagesData = pages.map(page => {
          const snakePage = convertKeysToSnakeCase({
            ...page,
            tenantId,
            clientId,
            createdAt: page.createdAt || now,
            updatedAt: now
          });
          
          // Stringify JSONB fields
          if (snakePage.blocks) {
            snakePage.blocks = JSON.stringify(snakePage.blocks);
          }
          if (snakePage.databases) {
            snakePage.databases = JSON.stringify(snakePage.databases);
          }
          
          return snakePage;
        });

        const { error } = await supabase
          .from('workspace_pages')
          .upsert(pagesData, { onConflict: 'id' });

        if (error) throw error;
      }
    }

    // Repetir processo para boards e databases...

    res.json({ 
      success: true, 
      message: 'Workspace salvo com sucesso',
      saved: {
        pages: pages?.length || 0,
        boards: boards?.length || 0,
        databases: databases?.length || 0
      }
    });
  } catch (error: any) {
    console.error('Erro ao salvar workspace:', error);
    res.status(500).json({ 
      success: false, 
      error: 'Erro ao salvar workspace',
      details: error.message
    });
  }
});
```

---

### 3. Dashboard Executivo

#### GET `/api/dashboard/dashboard-data` - Buscar dados do dashboard

**Request:**
```bash
GET /api/dashboard/dashboard-data
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "telefone": "553172380072@s.whatsapp.net",
      "nomeCompleto": "Ellen Viana",
      "emailPrincipal": "ellen@email.com",
      "statusAtendimento": "active",
      "setorAtual": "vendas",
      "ativo": true,
      "tipoReuniaoAtual": "online",
      "primeiroContato": "2025-09-11T23:48:58.869Z",
      "ultimoContato": "2025-09-13T12:01:01.959Z",
      "totalRegistros": 19,
      "totalMensagensChat": 14,
      "totalTranscricoes": 3
    }
  ],
  "source": "dynamic_supabase",
  "message": "Dados carregados do Supabase"
}
```

**Código Implementação:**
```typescript
// server/routes/dashboard.ts
router.get('/dashboard-data', async (req, res) => {
  try {
    const clientId = req.user?.clientId || '1';
    const tenantId = clientTenantMapping[clientId];
    
    // Testa conexão com Supabase
    const connectionTest = await testDynamicSupabaseConnection(clientId);
    
    if (!connectionTest) {
      // Fallback para dados mockados
      const mockData = mockDashboardData.filter(item => 
        item.tenant_id === tenantId
      );
      return res.json({
        success: true,
        data: mockData,
        source: 'mock_data',
        warning: 'Supabase não configurado'
      });
    }
    
    // Busca dados do Supabase
    const supabaseData = await getDashboardDataFromSupabase(clientId, tenantId);
    
    if (supabaseData === null) {
      // Fallback em caso de erro
      const mockData = mockDashboardData.filter(item => 
        item.tenant_id === tenantId
      );
      return res.json({
        success: true,
        data: mockData,
        source: 'mock_data_fallback'
      });
    }
    
    res.json({
      success: true,
      data: supabaseData,
      source: 'dynamic_supabase'
    });
  } catch (error) {
    console.error('Error fetching dashboard data:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch dashboard data'
    });
  }
});
```

---

## ❌ Problema Anterior e Solução

### O Que Estava Dando Errado

#### 1. Prefixos Duplicados nas Rotas do Workspace

**Problema:**
```typescript
// No server/routes.ts
app.use("/api/workspace", workspaceRoutes);

// No workspace.ts (ERRADO)
workspaceRoutes.get('/workspace/load', ...)  // ❌ Duplicou o prefixo
```

**Resultado:**
- Caminho final: `/api/workspace/workspace/load` ❌
- Endpoint retornava 404 ✗

**Solução:**
```typescript
// No workspace.ts (CORRETO)
workspaceRoutes.get('/load', ...)  // ✅ Sem duplicação
```

**Resultado:**
- Caminho final: `/api/workspace/load` ✅
- Endpoint funciona perfeitamente ✓

#### 2. Endpoints Só Liam do PostgreSQL Local

**Problema:**
```typescript
// Código antigo (ERRADO)
app.get("/api/files", async (req, res) => {
  // Sempre buscava do PostgreSQL local
  const files = await db.select().from(financialFiles);
  res.json(files);
});
```

**Consequência:**
- Arquivos salvos no Supabase não apareciam
- Dados duplicados entre bases
- Usuário via apenas dados locais

**Solução:**
```typescript
// Código novo (CORRETO)
app.get("/api/files", async (req, res) => {
  const supabase = getDynamicSupabaseClient(clientId);
  
  // Prioriza Supabase
  if (supabase) {
    const { data } = await supabase
      .from('financial_files')
      .select('*');
    return res.json({ data, source: 'supabase' });
  }
  
  // Fallback para local
  const files = await db.select().from(financialFiles);
  res.json({ data: files, source: 'local_db' });
});
```

**Resultado:**
- Supabase tem prioridade ✓
- Fallback inteligente ✓
- Todos os 7 arquivos aparecem ✓

#### 3. Campos Não Eram Mapeados

**Problema:**
```typescript
// Supabase retorna:
{
  user_id: "123",
  file_name: "doc.pdf",
  created_at: "2025-10-13..."
}

// Frontend esperava:
{
  userId: "123",
  fileName: "doc.pdf",
  createdAt: "2025-10-13..."
}
```

**Consequência:**
- Dados não apareciam corretamente no frontend
- Campos vinham como `undefined`

**Solução:**
```typescript
// Adicionar conversão de campos
const formattedData = data.map(item => ({
  userId: item.user_id,
  fileName: item.file_name,
  fileUrl: item.file_url,
  createdAt: item.created_at,
  updatedAt: item.updated_at,
  // ... outros campos
}));
```

**Resultado:**
- Frontend recebe dados no formato esperado ✓
- Compatibilidade total ✓

#### 4. Campos JSONB Não Eram Parseados

**Problema:**
```typescript
// Supabase retorna JSONB como string:
{
  blocks: '["array", "de", "blocos"]'
}

// Frontend tentava usar como array:
blocks.map(...)  // ❌ ERRO: blocks.map is not a function
```

**Solução:**
```typescript
// Parse campos JSONB antes de enviar
if (typeof camelPage.blocks === 'string') {
  camelPage.blocks = JSON.parse(camelPage.blocks);
}
if (typeof camelBoard.lists === 'string') {
  camelBoard.lists = JSON.parse(camelBoard.lists);
}
```

**Resultado:**
- Frontend recebe arrays e objetos prontos para uso ✓
- Sem erros de tipo ✓

---

## 📝 Exemplos Práticos

### Exemplo 1: Salvar uma Nova Página

```typescript
// Frontend envia
const savePage = async () => {
  const response = await fetch('/api/workspace/save', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      pages: [{
        id: 'new_page_123',
        title: 'Reunião de Planejamento',
        icon: '📋',
        blocks: [
          {
            id: 'block_1',
            type: 'heading',
            content: 'Reunião de Planejamento Q4 2025'
          },
          {
            id: 'block_2',
            type: 'text',
            content: 'Objetivos e metas para o próximo trimestre'
          }
        ],
        databases: [],
        parentId: null
      }],
      boards: [],
      databases: []
    })
  });
  
  const result = await response.json();
  console.log(result);
  // { success: true, message: 'Workspace salvo com sucesso', saved: { pages: 1, boards: 0, databases: 0 } }
};
```

### Exemplo 2: Buscar Arquivos Financeiros

```typescript
// Frontend busca arquivos
const loadFiles = async () => {
  const response = await fetch('/api/files');
  const result = await response.json();
  
  console.log(`${result.count} arquivos carregados do ${result.source}`);
  console.log(result.data);
  
  // Exemplo de arquivo retornado:
  // {
  //   id: "fin_1760323905992_rhnnwa2wl",
  //   userId: "default_user",
  //   fileName: "boleto.pdf",
  //   fileUrl: "https://supabase.co/storage/...",
  //   category: "moradia",
  //   amount: 665.77,
  //   description: "Despesas condominiais",
  //   storageType: "supabase",
  //   status: "active",
  //   createdAt: "2025-10-13T02:51:34.231+00:00",
  //   updatedAt: "2025-10-13T02:51:46.289+00:00"
  // }
};
```

### Exemplo 3: Atualizar Status de Cliente no Dashboard

```typescript
// Frontend atualiza status
const updateClientStatus = async (telefone, newStatus) => {
  const response = await fetch(`/api/dashboard/client/${telefone}/status`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      status: newStatus  // 'active', 'pause', ou 'completed'
    })
  });
  
  const result = await response.json();
  console.log(result);
  // { success: true, data: { ...cliente atualizado... } }
};
```

### Exemplo 4: Criar um Quadro Kanban

```typescript
// Frontend cria novo board
const createBoard = async () => {
  const response = await fetch('/api/workspace/save', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      pages: [],
      boards: [{
        id: 'board_' + Date.now(),
        title: 'Sprint Q4 2025',
        icon: '🚀',
        lists: [
          {
            id: 'list_todo',
            title: 'To Do',
            cards: []
          },
          {
            id: 'list_doing',
            title: 'Doing',
            cards: []
          },
          {
            id: 'list_done',
            title: 'Done',
            cards: []
          }
        ],
        labels: [
          { id: 'l1', name: 'Bug', color: 'red' },
          { id: 'l2', name: 'Feature', color: 'blue' },
          { id: 'l3', name: 'Enhancement', color: 'green' }
        ],
        members: [],
        settings: {
          allowComments: true,
          allowAttachments: true
        }
      }],
      databases: []
    })
  });
  
  const result = await response.json();
  console.log(result);
};
```

---

## 🔧 Troubleshooting

### Problema: Endpoints retornam 404

**Sintoma:**
```json
{
  "success": false,
  "error": "Endpoint não encontrado",
  "path": "/api/workspace/load",
  "method": "GET"
}
```

**Causas Possíveis:**
1. Prefixo duplicado nas rotas
2. Rotas não foram registradas no `server/routes.ts`
3. Servidor não foi reiniciado após mudanças

**Solução:**
```typescript
// 1. Verificar se não há duplicação de prefixo
// ERRADO:
workspaceRoutes.get('/workspace/load', ...)  // ❌

// CORRETO:
workspaceRoutes.get('/load', ...)  // ✅

// 2. Verificar registro em server/routes.ts
app.use("/api/workspace", workspaceRoutes);  // ✅

// 3. Reiniciar servidor
npm run dev
```

---

### Problema: Dados não aparecem do Supabase

**Sintoma:**
```json
{
  "success": true,
  "data": [],
  "source": "mock_data"
}
```

**Causas Possíveis:**
1. Credenciais do Supabase não configuradas
2. Tabela não existe no Supabase
3. Dados não estão sincronizados

**Solução:**
```typescript
// 1. Verificar credenciais
GET /api/config/supabase/credentials

// 2. Testar conexão
GET /api/workspace/test

// Resposta esperada:
{
  "success": true,
  "tests": {
    "pages": { "success": true, "count": 1 },
    "boards": { "success": true, "count": 1 },
    "databases": { "success": true, "count": 0 }
  }
}

// 3. Se retornar erro PGRST205:
// Executar no Supabase SQL Editor:
NOTIFY pgrst, 'reload schema';
```

---

### Problema: Campos vêm como undefined

**Sintoma:**
```javascript
console.log(file.fileName);  // undefined
console.log(file.file_name); // "documento.pdf"
```

**Causa:**
- Conversão snake_case → camelCase não está sendo feita

**Solução:**
```typescript
// Adicionar mapeamento de campos:
const formattedData = data.map(item => ({
  id: item.id,
  userId: item.user_id,
  fileName: item.file_name,
  fileUrl: item.file_url,
  createdAt: item.created_at,
  updatedAt: item.updated_at
}));
```

---

### Problema: Campos JSONB causam erros

**Sintoma:**
```javascript
TypeError: blocks.map is not a function
// blocks = '["array","de","strings"]'
```

**Causa:**
- Supabase retorna JSONB como string
- Frontend tenta usar como objeto/array

**Solução:**
```typescript
// Parse campos JSONB antes de enviar
if (typeof camelPage.blocks === 'string') {
  camelPage.blocks = JSON.parse(camelPage.blocks);
}
```

---

### Problema: Deletions não funcionam

**Sintoma:**
- Páginas deletadas no frontend continuam aparecendo após reload

**Causa:**
- Sistema de deletion não implementado

**Solução:**
```typescript
// Implementar deletion handling:
const receivedIds = new Set(pages.map(p => p.id));

const { data: existing } = await supabase
  .from('workspace_pages')
  .select('id');

const toDelete = existing
  .map(p => p.id)
  .filter(id => !receivedIds.has(id));

if (toDelete.length > 0) {
  await supabase
    .from('workspace_pages')
    .delete()
    .in('id', toDelete);
}
```

---

## ✅ Checklist de Implementação

Use este checklist para implementar Supabase em outro projeto:

### 1. Configuração Inicial
- [ ] Criar projeto no Supabase
- [ ] Copiar URL e Anon Key
- [ ] Criar tabelas necessárias
- [ ] Configurar RLS (Row Level Security) se necessário

### 2. Backend Setup
- [ ] Instalar `@supabase/supabase-js`
- [ ] Criar `lib/dynamicSupabase.ts` com cliente dinâmico
- [ ] Criar funções de conversão snake_case ↔ camelCase
- [ ] Implementar sistema de credenciais

### 3. Endpoints de Leitura
- [ ] Verificar se Supabase está configurado
- [ ] Buscar dados do Supabase primeiro
- [ ] Converter snake_case → camelCase
- [ ] Parse campos JSONB
- [ ] Implementar fallback para DB local
- [ ] Adicionar logs de debug

### 4. Endpoints de Escrita
- [ ] Converter camelCase → snake_case
- [ ] Stringify campos JSONB
- [ ] Usar UPSERT com `onConflict`
- [ ] Implementar deletion handling
- [ ] Adicionar tratamento de erros

### 5. Testes
- [ ] Testar GET sem Supabase (deve usar fallback)
- [ ] Configurar credenciais Supabase
- [ ] Testar GET com Supabase (deve retornar dados)
- [ ] Testar POST/PUT (deve salvar no Supabase)
- [ ] Testar DELETE (deve remover do Supabase)
- [ ] Verificar conversão de campos
- [ ] Verificar parse de JSONB

### 6. Debugging
- [ ] Adicionar console.logs estratégicos
- [ ] Verificar Network tab no DevTools
- [ ] Verificar logs do servidor
- [ ] Testar endpoint `/test` se disponível

---

## 📊 Resumo de Status

| Componente | Status | Endpoint | Fonte de Dados |
|-----------|--------|----------|----------------|
| Anexos Financeiros | ✅ Funcionando | `/api/files` | Supabase |
| Workspace Pages | ✅ Funcionando | `/api/workspace/load` | Supabase |
| Workspace Boards | ✅ Funcionando | `/api/workspace/load` | Supabase |
| Workspace Databases | ✅ Funcionando | `/api/workspace/load` | Supabase |
| Dashboard Completo | ✅ Funcionando | `/api/dashboard/dashboard-data` | Supabase |

**Última atualização:** 22 de Outubro de 2025  
**Testado em:** ExecutiveAI Pro v1.0

---

## 🎓 Conclusão

Este documento fornece um guia completo de como o ExecutiveAI Pro integra com Supabase. Use-o como referência para:

1. **Entender a arquitetura** de dual-write e priorização
2. **Implementar novas tabelas** seguindo o mesmo padrão
3. **Debugar problemas** usando o troubleshooting guide
4. **Migrar outro projeto** usando o checklist

A chave para o sucesso é sempre:
- ✅ Priorizar Supabase quando disponível
- ✅ Converter campos corretamente (snake_case ↔ camelCase)
- ✅ Parse campos JSONB antes de enviar ao frontend
- ✅ Implementar fallback inteligente
- ✅ Testar exaustivamente cada endpoint

---

**Dúvidas?** Verifique os logs do servidor e use os endpoints de teste (`/api/workspace/test`) para diagnosticar problemas.
