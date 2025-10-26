# 🔌 Documentação de Integrações e Dependências

## 📋 Visão Geral

Este documento lista TODAS as integrações, dependências e serviços externos utilizados no projeto.

---

## 📦 Dependências NPM

### Produção (79 packages)

#### Frontend Core
```json
{
  "react": "^18.3.1",
  "react-dom": "^18.3.1",
  "vite": "^5.4.19",
  "wouter": "^3.7.1"
}
```

#### UI & Styling
```json
{
  "tailwindcss": "^3.4.17",
  "tailwindcss-animate": "^1.0.7",
  "tailwind-merge": "^2.6.0",
  "class-variance-authority": "^0.7.1",
  "clsx": "^2.1.1",
  "lucide-react": "^0.462.0",
  "next-themes": "^0.3.0"
}
```

#### Radix UI (shadcn/ui) - 27 packages
```json
{
  "@radix-ui/react-accordion": "^1.2.11",
  "@radix-ui/react-alert-dialog": "^1.1.14",
  "@radix-ui/react-avatar": "^1.1.10",
  "@radix-ui/react-checkbox": "^1.3.2",
  "@radix-ui/react-dialog": "^1.1.14",
  "@radix-ui/react-dropdown-menu": "^2.1.15",
  "@radix-ui/react-label": "^2.1.7",
  "@radix-ui/react-popover": "^1.1.14",
  "@radix-ui/react-select": "^2.2.5",
  "@radix-ui/react-tabs": "^1.1.12",
  "@radix-ui/react-toast": "^1.2.14",
  "@radix-ui/react-tooltip": "^1.2.7"
  // ... 15 mais
}
```

#### State Management
```json
{
  "@tanstack/react-query": "^5.83.0",
  "react-hook-form": "^7.61.1",
  "zod": "^3.25.76",
  "@hookform/resolvers": "^3.10.0"
}
```

#### Drag and Drop
```json
{
  "@dnd-kit/core": "^6.3.1",
  "@dnd-kit/sortable": "^10.0.0",
  "@dnd-kit/utilities": "^3.2.2"
}
```

#### Charts & Visualization
```json
{
  "recharts": "^2.15.4",
  "react-colorful": "^5.6.1",
  "embla-carousel-react": "^8.6.0"
}
```

#### Forms & Validation
```json
{
  "react-day-picker": "^8.10.1",
  "date-fns": "^4.1.0",
  "input-otp": "^1.4.2"
}
```

#### Notifications
```json
{
  "sonner": "^1.7.4"
}
```

#### Backend
```json
{
  "express": "^5.1.0",
  "multer": "^2.0.2",
  "ws": "^8.18.3"
}
```

#### Database
```json
{
  "drizzle-orm": "^0.44.6",
  "drizzle-zod": "^0.8.3",
  "@neondatabase/serverless": "^1.0.2",
  "pg": "^8.16.3"
}
```

#### Supabase (Opcional)
```json
{
  "@supabase/supabase-js": "^2.75.1"
}
```

### DevDependencies (22 packages)

#### TypeScript
```json
{
  "typescript": "^5.8.3",
  "typescript-eslint": "^8.38.0",
  "@types/react": "^18.3.23",
  "@types/react-dom": "^18.3.7",
  "@types/express": "^5.0.3",
  "@types/node": "^22.16.5",
  "@types/multer": "^2.0.0"
}
```

#### Build Tools
```json
{
  "@vitejs/plugin-react": "^5.1.0",
  "@vitejs/plugin-react-swc": "^3.11.0",
  "autoprefixer": "^10.4.21",
  "postcss": "^8.5.6"
}
```

#### Linting
```json
{
  "eslint": "^9.32.0",
  "@eslint/js": "^9.32.0",
  "eslint-plugin-react-hooks": "^5.2.0",
  "eslint-plugin-react-refresh": "^0.4.20",
  "globals": "^15.15.0"
}
```

#### Database Tools
```json
{
  "drizzle-kit": "^0.31.5"
}
```

#### Utilities
```json
{
  "tsx": "^4.20.6",
  "lovable-tagger": "^1.1.11"
}
```

---

## 🗄️ Serviços de Database

### PostgreSQL (Obrigatório)

**Opções:**
1. **Replit Database** (desenvolvimento)
   - Automático
   - Free
   - DATABASE_URL configurado automaticamente

2. **Neon** (produção recomendada)
   - Free tier: 0.5 GB storage, 1 compute
   - Paid: $19/mês (scale plan)
   - URL: `postgresql://user:pass@ep-...neon.tech/db`

3. **Supabase** (produção alternativa)
   - Free tier: 500 MB, 50k requests/mês
   - Pro: $25/mês
   - URL: `postgresql://postgres:...@db....supabase.co:5432/postgres`

4. **AWS RDS**
   - Free tier: db.t3.micro 12 meses
   - Paid: ~$15/mês (t3.micro)

5. **DigitalOcean Managed**
   - Basic: $15/mês
   - Production: $60+/mês

**Driver:** `@neondatabase/serverless` (serverless-ready)

---

## 📤 Storage de Arquivos

### Uploads de Logo

**Atual:** Sistema de arquivos local (`client/public/uploads/logos/`)

**Produção (Recomendado):** AWS S3 ou Cloudinary

#### AWS S3

```bash
npm install @aws-sdk/client-s3
```

**Variáveis:**
```bash
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=secret...
S3_BUCKET=my-bucket
```

**Código:**
```typescript
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";

const s3 = new S3Client({
  region: process.env.AWS_REGION,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID!,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY!,
  },
});
```

#### Cloudinary

```bash
npm install cloudinary
```

**Variáveis:**
```bash
CLOUDINARY_CLOUD_NAME=your-cloud
CLOUDINARY_API_KEY=123456
CLOUDINARY_API_SECRET=secret
```

---

## 💬 Evolution API (WhatsApp)

### Descrição

API self-hosted para integração com WhatsApp Business.

### Configuração

**Via Interface:** `/whatsapp/settings`

**Campos:**
- **URL da API:** `https://evolution.seuservidor.com`
- **API Key:** Chave de autenticação
- **Nome da Instância:** Nome da instância criada

### Documentação

- [Evolution API Docs](https://doc.evolution-api.com/)
- [GitHub](https://github.com/EvolutionAPI/evolution-api)

### Endpoints Utilizados

```
GET  /instance/connectionState/{instance}
POST /chat/findChats/{instance}
POST /chat/findMessages/{instance}
POST /message/sendText/{instance}
POST /message/sendMedia/{instance}
```

### Custo

- **Self-hosted:** Free (VPS necessário)
- **Managed:** Varia por provedor ($10-50/mês)

---

## 🟦 Supabase (Opcional)

### Uso

**Dual-database support:** Usuário pode escolher salvar dados no Supabase ao invés do PostgreSQL local.

### Configuração

**Via Interface:** `/configuracoes`

**Campos:**
- **Supabase URL:** `https://projeto.supabase.co`
- **Anon Key:** `eyJ...`

### Setup

1. Criar projeto no Supabase
2. Executar SQL em `supabase-setup.sql`
3. Configurar na aplicação

### Custo

- **Free:** 500 MB storage, 50k requests/mês
- **Pro:** $25/mês
- **Team:** $599/mês

---

## 🎨 CDN & Assets

### Fontes

**Google Fonts (via Tailwind):**
```css
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');
```

**Fontes usadas:**
- Inter (padrão)
- Poppins (template premium)
- Roboto (template natureza)
- Montserrat (template vibrante)

### Ícones

**Lucide React:** `lucide-react` (bundled)

---

## 🔐 Autenticação (Não Implementada)

### Sugestões para Futuro

#### Clerk

```bash
npm install @clerk/clerk-react
```

#### NextAuth.js

```bash
npm install next-auth
```

#### Supabase Auth

```bash
# Já incluído em @supabase/supabase-js
```

---

## 📧 Email (Não Implementado)

### Sugestões

#### Resend

```bash
npm install resend
```

#### SendGrid

```bash
npm install @sendgrid/mail
```

#### Nodemailer

```bash
npm install nodemailer
```

---

## 📊 Analytics (Não Implementado)

### Sugestões

#### Google Analytics

```html
<!-- index.html -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXX"></script>
```

#### Plausible

```html
<script defer data-domain="yourdomain.com" src="https://plausible.io/js/script.js"></script>
```

---

## 🧪 Testing (Não Implementado)

### Sugestões

#### Vitest + Testing Library

```bash
npm install -D vitest @testing-library/react @testing-library/jest-dom
```

#### Playwright (E2E)

```bash
npm install -D @playwright/test
```

---

## 🔄 CI/CD (Não Implementado)

### Sugestões

#### GitHub Actions

```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm install --legacy-peer-deps
      - run: npm run build
      - run: npm test
```

---

## 📋 Resumo de Custos

### Mínimo (Free Tier)

| Serviço | Custo |
|---------|-------|
| Hosting (Replit Hobby) | $0 |
| Database (Replit) | $0 |
| Evolution API (self-hosted) | $0 |
| **Total** | **$0/mês** |

### Produção (Recomendado)

| Serviço | Custo |
|---------|-------|
| Hosting (Railway) | $5 |
| Database (Railway PostgreSQL) | Incluído |
| Evolution API (VPS) | $5 |
| S3 (storage) | $1 |
| Domain (.com) | $12/ano |
| **Total** | **~$11/mês** |

### Enterprise

| Serviço | Custo |
|---------|-------|
| Hosting (AWS EC2 t3.small) | $15 |
| Database (RDS t3.micro) | $15 |
| Evolution API (VPS) | $10 |
| S3 + CloudFront | $5 |
| Domain + SSL | $12/ano |
| Monitoring (DataDog) | $15 |
| **Total** | **~$60/mês** |

---

## 🔧 Configuração Completa

### .env Example

```bash
# Database
DATABASE_URL=postgresql://user:pass@host:5432/db

# Node
NODE_ENV=production
PORT=5000

# AWS (opcional - para uploads)
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=secret...
S3_BUCKET=my-bucket

# Cloudinary (alternativa para uploads)
CLOUDINARY_CLOUD_NAME=your-cloud
CLOUDINARY_API_KEY=123456
CLOUDINARY_API_SECRET=secret
```

### Supabase & Evolution API

**NÃO usar .env** - configurar via interface:
- Supabase: `/configuracoes`
- Evolution API: `/whatsapp/settings`

---

## ⚠️ Avisos Importantes

### peer Dependencies

**date-fns v4 conflita com react-day-picker.**

**Solução:** Sempre usar `npm install --legacy-peer-deps`

### SWC Plugin

**Erro "Bus error" no Replit.**

**Solução:** Usar `@vitejs/plugin-react` ao invés de `-swc` em `vite.config.ts`

---

**Documentação de Integrações | Última atualização: 24 de outubro de 2025**
