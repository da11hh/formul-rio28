# 📋💬 Plataforma Dual: Formulários Premium + WhatsApp Dashboard

## 🎯 Visão Geral do Projeto

Sistema completo dual-platform que combina:
1. **Plataforma de Formulários Premium** - Sistema avançado de criação de formulários com qualificação de leads e scoring
2. **Dashboard WhatsApp** - Gerenciador de conversas WhatsApp integrado com Evolution API

**Status:** ✅ 100% Funcional | Integrado | Pronto para Produção  
**Última Atualização:** 24 de outubro de 2025  
**Versão:** 2.0.0

---

## 📊 Funcionalidades Principais

### 🎨 Plataforma de Formulários
- ✅ **Editor Drag-and-Drop** - Criação visual de formulários
- ✅ **Sistema de Pontuação** - Qualificação automática de leads
- ✅ **Templates Prontos** - 4 templates profissionais pré-configurados
- ✅ **Design Customizado** - Editor visual completo (cores, fontes, espaçamento)
- ✅ **Páginas de Finalização** - Personalizadas por formulário
- ✅ **Dashboard Analytics** - Estatísticas de submissões
- ✅ **Links Públicos** - Compartilhamento fácil de formulários
- ✅ **Dual Database** - Suporta PostgreSQL local + Supabase opcional

### 💬 Dashboard WhatsApp
- ✅ **Gestão de Conversas** - Interface tipo WhatsApp Web
- ✅ **Envio de Mensagens** - Texto, imagens, áudios, vídeos
- ✅ **Gravação de Áudio** - Envio de notas de voz
- ✅ **Upload de Mídia** - Drag-and-drop para imagens e arquivos
- ✅ **Modo Demonstração** - Dados de exemplo para testes
- ✅ **Configuração Evolution API** - Interface para credenciais
- ✅ **Status em Tempo Real** - Indicador de conexão
- ✅ **Armazenamento PostgreSQL** - Configurações persistidas

---

## 🛠️ Stack Tecnológica

### Frontend
- **Framework:** React 18.3.1 + TypeScript 5.8.3
- **Build Tool:** Vite 5.4.19
- **Roteamento:** Wouter 3.7.1 (routing client-side)
- **UI Library:** shadcn/ui (Radix UI + Tailwind CSS)
- **Estilização:** Tailwind CSS 3.4.17 + Custom Design System
- **Estado:** React Query (TanStack) 5.83.0
- **Formulários:** React Hook Form 7.61.1 + Zod 3.25.76
- **Drag-and-Drop:** @dnd-kit 6.3.1
- **Gráficos:** Recharts 2.15.4

### Backend
- **Runtime:** Node.js 20.19.3
- **Framework:** Express 5.1.0
- **Linguagem:** TypeScript (tsx 4.20.6)
- **Database:** PostgreSQL (Neon) + Drizzle ORM 0.44.6
- **Upload:** Multer 2.0.2
- **WebSocket:** ws 8.18.3

### Database
- **Primary:** PostgreSQL via Replit (desenvolvimento)
- **Optional:** Supabase (produção, opcional)
- **ORM:** Drizzle ORM + Drizzle Kit 0.31.5
- **Driver:** @neondatabase/serverless 1.0.2

---

## 📁 Estrutura do Projeto

```
.
├── client/                          # Frontend React
│   ├── src/
│   │   ├── components/             # Componentes compartilhados
│   │   │   ├── design/            # Editores de design
│   │   │   └── ui/                # shadcn/ui components (54 componentes)
│   │   ├── contexts/              # React Contexts
│   │   ├── hooks/                 # Custom Hooks
│   │   ├── integrations/          # Integrações externas (Supabase)
│   │   ├── lib/                   # Utilitários e helpers
│   │   ├── pages/                 # Páginas da Plataforma de Formulários
│   │   ├── types/                 # TypeScript types
│   │   ├── whatsapp-platform/     # Plataforma WhatsApp COMPLETA
│   │   │   ├── components/       # 11 componentes WhatsApp
│   │   │   ├── hooks/            # Hooks específicos
│   │   │   ├── lib/              # API client + Evolution API
│   │   │   ├── pages/            # Index + Settings
│   │   │   └── App.tsx           # App WhatsApp isolado
│   │   ├── App.tsx                # App principal (router)
│   │   └── main.tsx               # Entry point
│   └── public/                     # Assets estáticos
│
├── server/                          # Backend Express
│   ├── utils/                      # Utilitários backend
│   ├── index.ts                    # Servidor principal
│   ├── routes.ts                   # Todas as rotas API (Forms + WhatsApp)
│   ├── storage.ts                  # Database layer (Forms + WhatsApp)
│   ├── db.ts                       # PostgreSQL connection
│   └── vite.ts                     # Vite middleware
│
├── shared/                          # Código compartilhado
│   └── schema.ts                   # Drizzle schema (6 tabelas)
│
├── server_whatsapp/                 # [LEGACY] Código WhatsApp antigo
├── client_whatsapp/                 # [LEGACY] Frontend WhatsApp antigo
├── shared_whatsapp/                 # [LEGACY] Schema WhatsApp antigo
│
├── package.json                     # Dependências (79 packages)
├── vite.config.ts                  # Configuração Vite
├── drizzle.config.ts               # Configuração Drizzle
├── tsconfig.json                   # TypeScript config
└── tailwind.config.ts              # Tailwind config
```

---

## 🗄️ Schema do Banco de Dados

### Tabelas (6 total)

#### 1. `forms`
Armazena formulários criados
```typescript
{
  id: uuid (PK)
  title: text
  description: text
  questions: jsonb                    // Array de perguntas
  passingScore: integer               // Pontuação mínima
  scoreTiers: jsonb                   // Níveis de qualificação
  designConfig: jsonb                 // Cores, fontes, etc
  completionPageId: uuid (FK)         // Página de finalização
  createdAt: timestamp
  updatedAt: timestamp
}
```

#### 2. `form_submissions`
Respostas dos usuários
```typescript
{
  id: uuid (PK)
  formId: uuid (FK) CASCADE
  answers: jsonb                      // Respostas do usuário
  totalScore: integer
  passed: boolean
  contactName: text
  contactEmail: text
  contactPhone: text
  createdAt: timestamp
}
```

#### 3. `completion_pages`
Páginas de finalização customizadas
```typescript
{
  id: uuid (PK)
  name: text
  title: text
  subtitle: text
  successMessage: text
  failureMessage: text
  showScore: boolean
  showTierBadge: boolean
  logo: text
  logoAlign: text
  successIconColor: text
  failureIconColor: text
  successIconImage: text
  failureIconImage: text
  successIconType: text
  failureIconType: text
  ctaText: text
  ctaUrl: text
  customContent: text
  designConfig: jsonb
  createdAt: timestamp
  updatedAt: timestamp
}
```

#### 4. `form_templates`
Templates de design prontos
```typescript
{
  id: uuid (PK)
  name: text
  description: text
  thumbnailUrl: text
  designConfig: jsonb
  questions: jsonb
  isDefault: boolean
  createdAt: timestamp
  updatedAt: timestamp
}
```

#### 5. `app_settings`
Configurações globais (Supabase)
```typescript
{
  id: uuid (PK)
  supabaseUrl: text
  supabaseAnonKey: text
  createdAt: timestamp
  updatedAt: timestamp
}
```

#### 6. `configurations_whatsapp`
Credenciais da Evolution API
```typescript
{
  id: serial (PK)
  userIdWhatsapp: text (default: "default")
  apiUrlWhatsapp: text
  apiKeyWhatsapp: text
  instanceWhatsapp: text
  updatedAtWhatsapp: timestamp
}
```

**Relacionamentos:**
- `forms.completionPageId` → `completion_pages.id` (1:1, SET NULL)
- `form_submissions.formId` → `forms.id` (N:1, CASCADE)

**Índices:**
- Criado automaticamente para todas as chaves estrangeiras
- Índices em `created_at` para ordenação eficiente

---

## 🚀 Instalação e Configuração

### Pré-requisitos
- Node.js 20.x ou superior
- PostgreSQL 14+ (ou Replit Database)
- npm ou yarn

### Passo 1: Clonar e Instalar

```bash
# Clone o repositório
git clone <YOUR_REPO_URL>
cd <PROJECT_NAME>

# Instalar dependências (IMPORTANTE: usar --legacy-peer-deps)
npm install --legacy-peer-deps
```

**⚠️ Por que `--legacy-peer-deps`?**  
Há conflitos entre `date-fns` v4 e `react-day-picker` que requerem esta flag.

### Passo 2: Configurar Banco de Dados

#### Opção A: PostgreSQL Local/Replit (Padrão)

```bash
# 1. Configure DATABASE_URL no .env (ou use variável do Replit)
DATABASE_URL=postgresql://user:password@host:5432/database

# 2. Sincronizar schema
npm run db:push
```

#### Opção B: Supabase (Opcional)

1. Crie projeto no [Supabase](https://supabase.com)
2. Execute SQL em `supabase-setup.sql` no SQL Editor
3. Configure credenciais na aplicação (`/configuracoes`)

### Passo 3: Iniciar Servidor

```bash
# Desenvolvimento (porta 5000)
npm run dev

# Produção
npm run build
npm start
```

### Passo 4: Acessar Plataforma

- **Formulários:** http://localhost:5000/
- **WhatsApp:** http://localhost:5000/whatsapp

---

## 🔌 Configuração WhatsApp (Evolution API)

### Pré-requisitos
1. Servidor Evolution API rodando
2. Instância WhatsApp criada e conectada

### Passo a Passo

1. Acesse `/whatsapp/settings`
2. Preencha os campos:
   - **URL da API:** `https://seu-servidor-evolution.com`
   - **API Key:** Sua chave de autenticação
   - **Nome da Instância:** Nome da instância criada
3. Clique em **"Testar Conexão"**
4. Se conectado ✅, clique em **"Salvar Configurações"**
5. Volte ao dashboard (`/whatsapp`)

### Modo Demonstração

Se a API não estiver configurada, a plataforma mostra conversas de exemplo automaticamente.

---

## 📡 Rotas da API

### Plataforma de Formulários

| Método | Rota | Descrição |
|--------|------|-----------|
| `GET` | `/api/forms` | Lista todos os formulários |
| `GET` | `/api/forms/:id` | Busca formulário por ID |
| `POST` | `/api/forms` | Cria novo formulário |
| `PATCH` | `/api/forms/:id` | Atualiza formulário |
| `DELETE` | `/api/forms/:id` | Deleta formulário |
| `GET` | `/api/submissions` | Lista submissões (query: formId) |
| `GET` | `/api/submissions/:id` | Busca submissão por ID |
| `POST` | `/api/submissions` | Cria nova submissão |
| `GET` | `/api/templates` | Lista templates |
| `GET` | `/api/templates/:id` | Busca template por ID |
| `POST` | `/api/templates` | Cria template |
| `PATCH` | `/api/templates/:id` | Atualiza template |
| `DELETE` | `/api/templates/:id` | Deleta template |
| `GET` | `/api/completion-pages` | Lista páginas de finalização |
| `GET` | `/api/completion-pages/:id` | Busca página por ID |
| `POST` | `/api/completion-pages` | Cria página |
| `PATCH` | `/api/completion-pages/:id` | Atualiza página |
| `DELETE` | `/api/completion-pages/:id` | Deleta página |
| `GET` | `/api/settings` | Busca configurações |
| `POST` | `/api/settings` | Salva configurações |
| `POST` | `/api/upload/logo` | Upload de logo (multipart) |

### Dashboard WhatsApp

| Método | Rota | Descrição |
|--------|------|-----------|
| `GET` | `/api/whatsapp/config` | Busca configuração |
| `POST` | `/api/whatsapp/config` | Salva configuração |
| `POST` | `/api/whatsapp/config/test` | Testa conexão |
| `POST` | `/api/whatsapp/fetch-chats` | Lista conversas |
| `POST` | `/api/whatsapp/fetch-messages` | Lista mensagens |
| `POST` | `/api/whatsapp/send-text` | Envia mensagem texto |
| `POST` | `/api/whatsapp/send-image` | Envia imagem |
| `POST` | `/api/whatsapp/send-audio` | Envia áudio |
| `POST` | `/api/whatsapp/send-video` | Envia vídeo |
| `POST` | `/api/whatsapp/send-document` | Envia documento |
| `GET` | `/api/whatsapp/connection-state` | Verifica estado conexão |

**Headers Especiais:**
- `x-supabase-url`: URL do Supabase (se configurado)
- `x-supabase-key`: Chave anon do Supabase (se configurado)

---

## 🎨 Design System

### Paleta de Cores

```css
/* Cores Principais */
--primary: hsl(221, 83%, 53%)        /* Azul vibrante */
--secondary: hsl(210, 40%, 96%)      /* Cinza claro */
--accent: hsl(142, 71%, 45%)         /* Verde sucesso */
--destructive: hsl(0, 84%, 60%)      /* Vermelho erro */

/* Premium Colors */
--purple-deep: #2D1B4E               /* Roxo profundo */
--gold: #F5C842                       /* Dourado */

/* Whatsapp */
--whatsapp-green: #25D366            /* Verde WhatsApp */
--whatsapp-teal: #128C7E             /* Azul-verde WhatsApp */
```

### Componentes UI (shadcn/ui)

**54 componentes disponíveis:**
accordion, alert-dialog, alert, aspect-ratio, avatar, badge, breadcrumb, button, calendar, card, carousel, chart, checkbox, collapsible, command, context-menu, dialog, drawer, dropdown-menu, form, hover-card, input-otp, input, label, menubar, navigation-menu, pagination, popover, progress, radio-group, resizable, scroll-area, select, separator, sheet, sidebar, skeleton, slider, sonner, switch, table, tabs, textarea, toast, toaster, toggle-group, toggle, tooltip, use-toast

### Animações

```css
/* Definidas em index.css */
@keyframes fadeIn         /* Opacidade 0 → 1 */
@keyframes slideUp        /* Desliza de baixo */
@keyframes scaleIn        /* Escala 0.95 → 1 */
@keyframes glow           /* Efeito glow pulsante */
```

---

## 🌐 Deploy (Replit)

### Configuração Atual

```json
{
  "deployment_target": "autoscale",
  "build": ["npm", "run", "build"],
  "run": ["npm", "start"]
}
```

### Workflow

```yaml
name: Server
command: npm run dev
wait_for_port: 5000
output_type: webview
```

### Variáveis de Ambiente Necessárias

```bash
# Obrigatório
DATABASE_URL=postgresql://...
NODE_ENV=production              # Para modo produção

# Opcional (Supabase)
# Configurado via interface em /configuracoes
```

### Passos para Deploy

1. Configure DATABASE_URL
2. Execute `npm run build`
3. Inicie com `npm start`
4. Aplicação estará em `https://seu-repl.repl.co`

---

## 🔧 Scripts Disponíveis

```json
{
  "dev": "tsx server/index.ts",              // Desenvolvimento
  "start": "NODE_ENV=production tsx server/index.ts",  // Produção
  "build": "vite build",                     // Build frontend
  "build:dev": "vite build --mode development",
  "lint": "eslint .",                        // Linting
  "preview": "vite preview",                 // Preview build
  "db:push": "drizzle-kit push"             // Sync database
}
```

---

## 🐛 Troubleshooting

### Erro: "Bus error (core dumped)"
**Causa:** Plugin SWC incompatível com Replit  
**Solução:** Usar `@vitejs/plugin-react` ao invés de `-swc`

### Erro: "Blocked request" / "Host not allowed"
**Causa:** Vite bloqueando domínios dinâmicos do Replit  
**Solução:** `allowedHosts: true` em `vite.config.ts` (JÁ CONFIGURADO)

### Erro: "ENOENT: no such file or directory" (upload)
**Causa:** Pasta uploads não existe  
**Solução:** Criada automaticamente em `server/routes.ts` (JÁ RESOLVIDO)

### Erro: "relation does not exist"
**Causa:** Schema não sincronizado  
**Solução:** `npm run db:push`

### WhatsApp mostra dados de exemplo
**Causa:** Evolution API não configurada  
**Solução:** Configure em `/whatsapp/settings`

---

## 📚 Documentação Adicional

- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - Arquitetura detalhada
- **[DATABASE.md](./DATABASE.md)** - Schema completo do banco
- **[API.md](./API.md)** - Documentação de todas as rotas
- **[FRONTEND.md](./FRONTEND.md)** - Estrutura do frontend
- **[DEPLOYMENT.md](./DEPLOYMENT.md)** - Guia de deployment
- **[MIGRATION.md](./MIGRATION.md)** - Migração para outra plataforma

---

## 📄 Licença

Este projeto foi desenvolvido para uso interno.

---

## 👥 Suporte

Para dúvidas ou problemas:
1. Consulte a documentação completa
2. Verifique os logs do servidor
3. Revise as configurações do banco de dados

---

**Desenvolvido com ❤️ usando React + TypeScript + Express + PostgreSQL**
