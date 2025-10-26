# 🗄️ Documentação Completa do Banco de Dados

## 📊 Visão Geral

**ORM:** Drizzle ORM 0.44.6  
**Driver:** @neondatabase/serverless 1.0.2  
**Database:** PostgreSQL 14+  
**Schema File:** `shared/schema.ts`  
**Total de Tabelas:** 6

---

## 📋 Tabelas Detalhadas

### 1. `forms` - Formulários

**Descrição:** Armazena todos os formulários criados pelos usuários

```typescript
export const forms = pgTable("forms", {
  id: uuid("id").primaryKey().default(sql`gen_random_uuid()`),
  title: text("title").notNull(),
  description: text("description"),
  questions: jsonb("questions").notNull(),
  passingScore: integer("passing_score").notNull().default(0),
  scoreTiers: jsonb("score_tiers"),
  designConfig: jsonb("design_config").default(/* default design */),
  completionPageId: uuid("completion_page_id")
    .references(() => completionPages.id, { onDelete: "set null" }),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
});
```

**Campos:**

| Campo | Tipo | Null | Default | Descrição |
|-------|------|------|---------|-----------|
| `id` | uuid | NO | gen_random_uuid() | Identificador único |
| `title` | text | NO | - | Título do formulário |
| `description` | text | YES | NULL | Descrição opcional |
| `questions` | jsonb | NO | - | Array de perguntas |
| `passing_score` | integer | NO | 0 | Pontuação mínima para passar |
| `score_tiers` | jsonb | YES | NULL | Níveis de qualificação |
| `design_config` | jsonb | NO | default | Configurações visuais |
| `completion_page_id` | uuid | YES | NULL | FK para completion_pages |
| `created_at` | timestamptz | NO | now() | Data de criação |
| `updated_at` | timestamptz | NO | now() | Data da última atualização |

**Índices:**
- `PRIMARY KEY (id)`
- `idx_forms_created_at` ON `created_at DESC`
- `idx_forms_completion_page` ON `completion_page_id`

**Constraints:**
- FK `completion_page_id` → `completion_pages.id` (SET NULL on delete)

**Exemplo de Dados:**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Formulário de Qualificação de Leads",
  "description": "Avalie o potencial de cada lead",
  "questions": [
    {
      "id": "q1",
      "type": "multiple-choice",
      "question": "Qual o tamanho da sua empresa?",
      "options": [
        { "text": "1-10 funcionários", "points": 5 },
        { "text": "11-50 funcionários", "points": 10 },
        { "text": "51+ funcionários", "points": 15 }
      ],
      "required": true
    }
  ],
  "passing_score": 50,
  "score_tiers": [
    { "name": "Bronze", "minScore": 0, "maxScore": 49 },
    { "name": "Prata", "minScore": 50, "maxScore": 74 },
    { "name": "Ouro", "minScore": 75, "maxScore": 100 }
  ],
  "design_config": {
    "colors": {
      "primary": "hsl(221, 83%, 53%)",
      "secondary": "hsl(210, 40%, 96%)",
      "background": "hsl(0, 0%, 100%)",
      "text": "hsl(222, 47%, 11%)"
    },
    "typography": {
      "fontFamily": "Inter",
      "titleSize": "2xl",
      "textSize": "base"
    },
    "spacing": "comfortable"
  },
  "completion_page_id": null,
  "created_at": "2025-10-24T14:30:00Z",
  "updated_at": "2025-10-24T14:30:00Z"
}
```

---

### 2. `form_submissions` - Submissões de Formulários

**Descrição:** Armazena todas as respostas enviadas pelos usuários

```typescript
export const formSubmissions = pgTable("form_submissions", {
  id: uuid("id").primaryKey().default(sql`gen_random_uuid()`),
  formId: uuid("form_id").notNull()
    .references(() => forms.id, { onDelete: "cascade" }),
  answers: jsonb("answers").notNull(),
  totalScore: integer("total_score").notNull(),
  passed: boolean("passed").notNull(),
  contactName: text("contact_name"),
  contactEmail: text("contact_email"),
  contactPhone: text("contact_phone"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
});
```

**Campos:**

| Campo | Tipo | Null | Default | Descrição |
|-------|------|------|---------|-----------|
| `id` | uuid | NO | gen_random_uuid() | Identificador único |
| `form_id` | uuid | NO | - | FK para forms |
| `answers` | jsonb | NO | - | Respostas do usuário |
| `total_score` | integer | NO | - | Pontuação total alcançada |
| `passed` | boolean | NO | - | Se passou no critério mínimo |
| `contact_name` | text | YES | NULL | Nome do respondente |
| `contact_email` | text | YES | NULL | Email do respondente |
| `contact_phone` | text | YES | NULL | Telefone do respondente |
| `created_at` | timestamptz | NO | now() | Data da submissão |

**Índices:**
- `PRIMARY KEY (id)`
- `idx_submissions_form_id` ON `form_id`
- `idx_submissions_created_at` ON `created_at DESC`

**Constraints:**
- FK `form_id` → `forms.id` (CASCADE on delete)

**Exemplo de Dados:**

```json
{
  "id": "660e8400-e29b-41d4-a716-446655440001",
  "form_id": "550e8400-e29b-41d4-a716-446655440000",
  "answers": {
    "q1": { "value": "11-50 funcionários", "points": 10 },
    "q2": { "value": "Sim", "points": 20 },
    "q3": { "value": "R$ 100.000+", "points": 25 }
  },
  "total_score": 55,
  "passed": true,
  "contact_name": "João Silva",
  "contact_email": "joao@empresa.com",
  "contact_phone": "+5511999999999",
  "created_at": "2025-10-24T15:00:00Z"
}
```

---

### 3. `completion_pages` - Páginas de Finalização

**Descrição:** Páginas personalizadas mostradas após envio do formulário

```typescript
export const completionPages = pgTable("completion_pages", {
  id: uuid("id").primaryKey().default(sql`gen_random_uuid()`),
  name: text("name").notNull(),
  title: text("title").notNull().default("Obrigado!"),
  subtitle: text("subtitle"),
  successMessage: text("success_message").notNull()
    .default("Parabéns! Você está qualificado..."),
  failureMessage: text("failure_message").notNull()
    .default("Obrigado pela sua participação..."),
  showScore: boolean("show_score").default(true),
  showTierBadge: boolean("show_tier_badge").default(true),
  logo: text("logo"),
  logoAlign: text("logo_align").default("center"),
  successIconColor: text("success_icon_color").default("hsl(142, 71%, 45%)"),
  failureIconColor: text("failure_icon_color").default("hsl(0, 84%, 60%)"),
  successIconImage: text("success_icon_image"),
  failureIconImage: text("failure_icon_image"),
  successIconType: text("success_icon_type").default("check-circle"),
  failureIconType: text("failure_icon_type").default("x-circle"),
  ctaText: text("cta_text"),
  ctaUrl: text("cta_url"),
  customContent: text("custom_content"),
  designConfig: jsonb("design_config").default(/* default design */),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
});
```

**Campos:** (23 campos total)

| Campo | Tipo | Null | Default | Descrição |
|-------|------|------|---------|-----------|
| `id` | uuid | NO | gen_random_uuid() | Identificador único |
| `name` | text | NO | - | Nome interno |
| `title` | text | NO | "Obrigado!" | Título da página |
| `subtitle` | text | YES | NULL | Subtítulo opcional |
| `success_message` | text | NO | default | Mensagem sucesso |
| `failure_message` | text | NO | default | Mensagem falha |
| `show_score` | boolean | NO | true | Mostrar pontuação? |
| `show_tier_badge` | boolean | NO | true | Mostrar badge nível? |
| `logo` | text | YES | NULL | URL do logo |
| `logo_align` | text | NO | "center" | Alinhamento logo |
| `success_icon_color` | text | NO | HSL verde | Cor ícone sucesso |
| `failure_icon_color` | text | NO | HSL vermelho | Cor ícone falha |
| `success_icon_image` | text | YES | NULL | Imagem ícone sucesso |
| `failure_icon_image` | text | YES | NULL | Imagem ícone falha |
| `success_icon_type` | text | NO | "check-circle" | Tipo ícone sucesso |
| `failure_icon_type` | text | NO | "x-circle" | Tipo ícone falha |
| `cta_text` | text | YES | NULL | Texto botão CTA |
| `cta_url` | text | YES | NULL | URL botão CTA |
| `custom_content` | text | YES | NULL | Conteúdo adicional |
| `design_config` | jsonb | NO | default | Config visual |
| `created_at` | timestamptz | NO | now() | Data criação |
| `updated_at` | timestamptz | NO | now() | Última atualização |

**Índices:**
- `PRIMARY KEY (id)`
- `idx_completion_pages_created_at` ON `created_at DESC`

---

### 4. `form_templates` - Templates de Formulários

**Descrição:** Templates pré-configurados com design e perguntas prontas

```typescript
export const formTemplates = pgTable("form_templates", {
  id: uuid("id").primaryKey().default(sql`gen_random_uuid()`),
  name: text("name").notNull(),
  description: text("description"),
  thumbnailUrl: text("thumbnail_url"),
  designConfig: jsonb("design_config").notNull(),
  questions: jsonb("questions").notNull(),
  isDefault: boolean("is_default").default(false),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
});
```

**Campos:**

| Campo | Tipo | Null | Default | Descrição |
|-------|------|------|---------|-----------|
| `id` | uuid | NO | gen_random_uuid() | Identificador único |
| `name` | text | NO | - | Nome do template |
| `description` | text | YES | NULL | Descrição |
| `thumbnail_url` | text | YES | NULL | URL da thumbnail |
| `design_config` | jsonb | NO | - | Configuração visual |
| `questions` | jsonb | NO | - | Perguntas prontas |
| `is_default` | boolean | NO | false | É template padrão? |
| `created_at` | timestamptz | NO | now() | Data criação |
| `updated_at` | timestamptz | NO | now() | Última atualização |

**Templates Padrão:** (4 inseridos automaticamente)
1. Template Moderno Azul (Inter)
2. Template Roxo Premium (Poppins)
3. Template Verde Natureza (Roboto)
4. Template Laranja Vibrante (Montserrat)

---

### 5. `app_settings` - Configurações Globais

**Descrição:** Configurações da aplicação (credenciais Supabase)

```typescript
export const appSettings = pgTable("app_settings", {
  id: uuid("id").primaryKey().default(sql`gen_random_uuid()`),
  supabaseUrl: text("supabase_url"),
  supabaseAnonKey: text("supabase_anon_key"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
});
```

**Campos:**

| Campo | Tipo | Null | Default | Descrição |
|-------|------|------|---------|-----------|
| `id` | uuid | NO | gen_random_uuid() | Identificador único |
| `supabase_url` | text | YES | NULL | URL do projeto Supabase |
| `supabase_anon_key` | text | YES | NULL | Chave anônima Supabase |
| `created_at` | timestamptz | NO | now() | Data criação |
| `updated_at` | timestamptz | NO | now() | Última atualização |

**Nota:** Apenas 1 registro é mantido (singleton pattern)

---

### 6. `configurations_whatsapp` - Configurações WhatsApp

**Descrição:** Credenciais da Evolution API para WhatsApp

```typescript
export const configurationsWhatsapp = pgTable("configurations_whatsapp", {
  id: serial("id").primaryKey(),
  userIdWhatsapp: text("user_id_whatsapp").notNull().default("default"),
  apiUrlWhatsapp: text("api_url_whatsapp").notNull(),
  apiKeyWhatsapp: text("api_key_whatsapp").notNull(),
  instanceWhatsapp: text("instance_whatsapp").notNull(),
  updatedAtWhatsapp: timestamp("updated_at_whatsapp").defaultNow().notNull(),
});
```

**Campos:**

| Campo | Tipo | Null | Default | Descrição |
|-------|------|------|---------|-----------|
| `id` | serial | NO | auto-increment | Identificador único |
| `user_id_whatsapp` | text | NO | "default" | ID do usuário (multi-tenant) |
| `api_url_whatsapp` | text | NO | - | URL da Evolution API |
| `api_key_whatsapp` | text | NO | - | API Key de autenticação |
| `instance_whatsapp` | text | NO | - | Nome da instância WhatsApp |
| `updated_at_whatsapp` | timestamptz | NO | now() | Última atualização |

**Exemplo de Dados:**

```json
{
  "id": 1,
  "user_id_whatsapp": "default",
  "api_url_whatsapp": "https://evolution.seuservidor.com",
  "api_key_whatsapp": "sua-api-key-aqui",
  "instance_whatsapp": "minha_instancia",
  "updated_at_whatsapp": "2025-10-24T16:00:00Z"
}
```

---

## 🔗 Diagrama de Relacionamentos

```
┌─────────────────────────┐
│   completion_pages      │
│                         │
│  id (PK, UUID)          │
│  name                   │
│  title                  │
│  ...                    │
└────────────▲────────────┘
             │
             │ (1:1 SET NULL)
             │
┌────────────┴────────────┐         ┌─────────────────────────┐
│        forms            │         │   form_submissions      │
│                         │         │                         │
│  id (PK, UUID)          │◄────────┤  id (PK, UUID)          │
│  title                  │ (1:N)   │  form_id (FK, CASCADE)  │
│  description            │         │  answers (JSONB)        │
│  questions (JSONB)      │         │  total_score            │
│  passing_score          │         │  passed                 │
│  score_tiers (JSONB)    │         │  contact_*              │
│  design_config (JSONB)  │         │  created_at             │
│  completion_page_id (FK)│         └─────────────────────────┘
│  created_at             │
│  updated_at             │
└─────────────────────────┘

┌─────────────────────────┐
│    form_templates       │
│                         │
│  id (PK, UUID)          │
│  name                   │
│  design_config (JSONB)  │
│  questions (JSONB)      │
│  is_default             │
│  ...                    │
└─────────────────────────┘

┌─────────────────────────┐
│     app_settings        │
│                         │
│  id (PK, UUID)          │
│  supabase_url           │
│  supabase_anon_key      │
│  ...                    │
└─────────────────────────┘

┌──────────────────────────────┐
│  configurations_whatsapp     │
│                              │
│  id (PK, SERIAL)             │
│  user_id_whatsapp            │
│  api_url_whatsapp            │
│  api_key_whatsapp            │
│  instance_whatsapp           │
│  updated_at_whatsapp         │
└──────────────────────────────┘
```

---

## 🔧 Comandos Drizzle

### Sincronizar Schema

```bash
# Push schema para o banco (cria/atualiza tabelas)
npm run db:push

# Gerar migrations (opcional)
npx drizzle-kit generate

# Aplicar migrations
npx drizzle-kit migrate
```

### Introspect Database

```bash
# Gerar schema a partir do banco existente
npx drizzle-kit introspect
```

### Drizzle Studio (GUI)

```bash
# Abrir interface gráfica
npx drizzle-kit studio
```

---

## 📊 Queries Comuns

### Buscar Formulários com Submissões

```typescript
import { db } from './server/db';
import { forms, formSubmissions } from '@shared/schema';
import { eq } from 'drizzle-orm';

const formsWithSubmissions = await db
  .select({
    form: forms,
    submissions: formSubmissions,
  })
  .from(forms)
  .leftJoin(formSubmissions, eq(forms.id, formSubmissions.formId));
```

### Estatísticas de Formulário

```typescript
import { count, avg } from 'drizzle-orm';

const stats = await db
  .select({
    totalSubmissions: count(),
    avgScore: avg(formSubmissions.totalScore),
  })
  .from(formSubmissions)
  .where(eq(formSubmissions.formId, formId));
```

### Submissões Qualificadas

```typescript
const qualifiedLeads = await db
  .select()
  .from(formSubmissions)
  .where(eq(formSubmissions.passed, true))
  .orderBy(desc(formSubmissions.totalScore));
```

---

## 🔒 Backups

### PostgreSQL Nativo

```bash
# Backup completo
pg_dump -h host -U user -d database > backup.sql

# Restore
psql -h host -U user -d database < backup.sql
```

### Supabase (se configurado)

- Backups automáticos diários (retenção 7 dias no plano gratuito)
- Download via Dashboard → Database → Backups

---

## 🚨 Migrações Importantes

### Se mudar estrutura do JSONB

```typescript
// ANTES
questions: jsonb("questions")

// DEPOIS (com validação)
questions: jsonb("questions").$type<Question[]>()

// Atualizar dados existentes (se necessário)
await db.update(forms)
  .set({
    questions: sql`jsonb_set(questions, '{0,newField}', '"defaultValue"')`
  });
```

---

## 📈 Performance Tips

1. **Use índices para colunas frequentemente filtradas**
```typescript
.where(eq(forms.id, id))  // ✅ Índice PK
.where(like(forms.title, '%test%'))  // ❌ Sem índice, full scan
```

2. **Evite SELECT \* em joins**
```typescript
// ❌ Ruim
.select()

// ✅ Bom
.select({
  id: forms.id,
  title: forms.title,
})
```

3. **Use paginação**
```typescript
.limit(20)
.offset(page * 20)
```

---

**Documentação do Banco de Dados | Última atualização: 24 de outubro de 2025**
