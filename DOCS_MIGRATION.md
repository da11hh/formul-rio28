# 🚀 Guia Completo de Migração para Outra Plataforma

## 🎯 Objetivo deste Documento

Este guia fornece instruções **passo a passo** para migrar 100% desta aplicação para qualquer outra plataforma de hospedagem (Heroku, Vercel, AWS, DigitalOcean, VPS próprio, etc).

---

## ✅ Pré-requisitos da Plataforma de Destino

A nova plataforma **DEVE suportar**:

### Obrigatórios
- ✅ Node.js 20.x ou superior
- ✅ PostgreSQL 14+ (ou serviço compatível)
- ✅ Variáveis de ambiente
- ✅ Build step (para compilar frontend)
- ✅ Persistência de uploads (ou storage externo tipo S3)

### Recomendados
- ✅ HTTPS (para WebSocket e segurança)
- ✅ Domínio customizado
- ✅ SSL/TLS automático
- ✅ Logs persistentes

---

## 📦 Checklist de Migração

### Fase 1: Preparação Local

- [ ] Clone o repositório Git
- [ ] Teste localmente (`npm install --legacy-peer-deps`)
- [ ] Verifique que `npm run dev` funciona
- [ ] Execute `npm run build` com sucesso
- [ ] Documente todas as variáveis de ambiente usadas

### Fase 2: Banco de Dados

- [ ] Provisione PostgreSQL na nova plataforma
- [ ] Anote a `DATABASE_URL`
- [ ] Execute `npm run db:push` para criar tabelas
- [ ] (Opcional) Migre dados existentes

### Fase 3: Deploy

- [ ] Configure variáveis de ambiente
- [ ] Configure build command: `npm run build`
- [ ] Configure start command: `npm start`
- [ ] Deploy inicial
- [ ] Teste aplicação em produção

### Fase 4: Configuração Pós-Deploy

- [ ] Configure domínio (se aplicável)
- [ ] Configure SSL/TLS
- [ ] Configure uploads (se necessário usar S3/similar)
- [ ] Configure Evolution API WhatsApp (via `/whatsapp/settings`)
- [ ] Teste funcionalidades críticas

---

## 🗄️ Migração do Banco de Dados

### Opção 1: Nova Database (Recomendado para início)

```bash
# 1. Obtenha DATABASE_URL da nova plataforma
DATABASE_URL=postgresql://user:pass@host:5432/db

# 2. Configure localmente para testar
echo "DATABASE_URL=$DATABASE_URL" > .env

# 3. Sincronize schema
npm run db:push

# 4. Verifique tabelas criadas
# Use Drizzle Studio ou cliente PostgreSQL
npx drizzle-kit studio
```

### Opção 2: Migrar Dados Existentes

```bash
# 1. Backup do banco atual (Replit)
pg_dump $DATABASE_URL_REPLIT > backup.sql

# 2. Restore na nova plataforma
psql $DATABASE_URL_NEW < backup.sql

# 3. Verificar integridade
psql $DATABASE_URL_NEW -c "SELECT COUNT(*) FROM forms;"
```

---

## ⚙️ Configuração de Variáveis de Ambiente

### Variáveis Obrigatórias

```bash
# Database
DATABASE_URL=postgresql://user:password@host:5432/database

# Node
NODE_ENV=production
```

### Variáveis Opcionais

```bash
# Port (geralmente automático na plataforma)
PORT=5000

# Supabase (se usando integração opcional)
# Configurado via interface em /configuracoes
```

### Como Configurar por Plataforma

**Heroku:**
```bash
heroku config:set DATABASE_URL="postgresql://..."
heroku config:set NODE_ENV=production
```

**Vercel:**
```bash
# Via Dashboard > Settings > Environment Variables
# ou vercel.json:
{
  "env": {
    "DATABASE_URL": "@database-url",
    "NODE_ENV": "production"
  }
}
```

**AWS/DigitalOcean/VPS:**
```bash
# .env file ou export no shell
export DATABASE_URL="postgresql://..."
export NODE_ENV=production
```

---

## 🔧 Configuração de Build e Start

### package.json Scripts (JÁ CONFIGURADO)

```json
{
  "scripts": {
    "dev": "tsx server/index.ts",
    "start": "NODE_ENV=production tsx server/index.ts",
    "build": "vite build",
    "db:push": "drizzle-kit push"
  }
}
```

### Comandos de Deploy

**Build Command:**
```bash
npm install --legacy-peer-deps && npm run build
```

**Start Command:**
```bash
npm start
```

**Port:**
```bash
# A aplicação escuta na porta 5000 por padrão
# Mas respeita process.env.PORT se definida
```

---

## 📂 Estrutura de Arquivos para Deploy

### Arquivos Necessários

```
✅ package.json              # Dependências
✅ package-lock.json         # Lock file (importante!)
✅ tsconfig.json             # TypeScript config
✅ vite.config.ts            # Vite config
✅ drizzle.config.ts         # Drizzle config
✅ tailwind.config.ts        # Tailwind config
✅ postcss.config.js         # PostCSS config
✅ client/                   # Frontend source
✅ server/                   # Backend source
✅ shared/                   # Shared types/schema
✅ dist/                     # Build output (gerado)
```

### Arquivos a IGNORAR (.gitignore)

```
node_modules/
dist/
.env
.env.local
*.log
.DS_Store
.replit
replit.nix
vite.config.ts.timestamp-*
```

---

## 🌐 Configurações Específicas por Plataforma

### Heroku

**Buildpack:** Node.js (detectado automaticamente)

**Procfile:**
```
web: npm start
```

**Config:**
```bash
heroku create my-app
heroku addons:create heroku-postgresql:mini
heroku config:set NODE_ENV=production
git push heroku main
heroku run npm run db:push
```

---

### Vercel

**Limitações:** Vercel é serverless, pode ter problemas com:
- PostgreSQL connections (use connection pooling)
- Uploads de arquivo (use S3/Cloudinary)
- WebSocket (não suportado)

**vercel.json:**
```json
{
  "version": 2,
  "builds": [
    {
      "src": "server/index.ts",
      "use": "@vercel/node"
    },
    {
      "src": "package.json",
      "use": "@vercel/static-build",
      "config": {
        "distDir": "dist/public"
      }
    }
  ],
  "routes": [
    {
      "src": "/api/(.*)",
      "dest": "server/index.ts"
    },
    {
      "src": "/(.*)",
      "dest": "dist/public/$1"
    }
  ]
}
```

**Recomendação:** Use Neon ou Supabase para PostgreSQL (com pooling).

---

### Railway

**Muito similar ao Heroku, mais simples:**

```bash
# Instalar Railway CLI
npm i -g @railway/cli

# Login
railway login

# Criar projeto
railway init

# Adicionar PostgreSQL
railway add

# Deploy
railway up

# Configurar variáveis
railway variables set NODE_ENV=production

# Push schema
railway run npm run db:push
```

---

### AWS (EC2 + RDS)

**Passos:**

1. **Provisionar RDS PostgreSQL**
   - Anote endpoint e credenciais
   - Configure security group (permitir 5432)

2. **Provisionar EC2**
   - Ubuntu 22.04 LTS
   - t2.micro ou maior
   - Configure security group (permitir 80, 443, 22)

3. **Setup no servidor:**
```bash
# SSH no EC2
ssh ubuntu@ec2-ip

# Instalar Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Clonar repositório
git clone <YOUR_REPO>
cd <PROJECT>

# Instalar dependências
npm install --legacy-peer-deps

# Configurar .env
echo "DATABASE_URL=postgresql://..." > .env
echo "NODE_ENV=production" >> .env

# Build
npm run build

# Sincronizar banco
npm run db:push

# Instalar PM2 (process manager)
sudo npm install -g pm2

# Iniciar aplicação
pm2 start npm --name "my-app" -- start

# Configurar auto-start
pm2 startup
pm2 save
```

4. **Configurar Nginx (reverse proxy):**
```nginx
server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

5. **Configurar SSL com Certbot:**
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com
```

---

### DigitalOcean (App Platform)

**Similar ao Heroku:**

1. Conecte repositório GitHub
2. Detecta Node.js automaticamente
3. Adicione PostgreSQL Managed Database
4. Configure variáveis de ambiente
5. Deploy

**Vantagens:**
- $5/mês (mais barato que Heroku)
- PostgreSQL incluído
- SSL automático
- Fácil scaling

---

### VPS Genérico (Linode, Vultr, etc)

**Mesmo processo que AWS EC2:**
- Ubuntu 22.04
- Node.js 20
- PostgreSQL 14+
- Nginx
- PM2
- Certbot

---

## 📤 Upload de Arquivos

### Problema

A aplicação salva logos em `client/public/uploads/logos/`. Em ambientes serverless ou com filesystem efêmero, isso não funciona.

### Solução 1: S3 / Cloudinary (Recomendado para produção)

**Instalar SDK:**
```bash
npm install @aws-sdk/client-s3
# ou
npm install cloudinary
```

**Modificar `server/routes.ts`:**
```typescript
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";

const s3 = new S3Client({
  region: process.env.AWS_REGION,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID!,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY!,
  },
});

app.post("/api/upload/logo", upload.single('logo'), async (req, res) => {
  if (!req.file) return res.status(400).json({ error: "No file" });
  
  const fileName = `logos/${Date.now()}-${req.file.originalname}`;
  
  await s3.send(new PutObjectCommand({
    Bucket: process.env.S3_BUCKET!,
    Key: fileName,
    Body: req.file.buffer,
    ContentType: req.file.mimetype,
  }));
  
  const url = `https://${process.env.S3_BUCKET}.s3.amazonaws.com/${fileName}`;
  res.json({ url });
});
```

### Solução 2: Volume Persistente (VPS/EC2)

```bash
# Criar pasta persistente
mkdir -p /var/www/uploads

# Link simbólico
ln -s /var/www/uploads client/public/uploads
```

---

## 🔍 Troubleshooting Pós-Migração

### Erro: "Cannot find module"

**Causa:** Dependências não instaladas  
**Solução:**
```bash
npm install --legacy-peer-deps
```

### Erro: "relation does not exist"

**Causa:** Schema não sincronizado  
**Solução:**
```bash
npm run db:push
```

### Erro: "ECONNREFUSED" ao conectar no banco

**Causa:** DATABASE_URL incorreta ou firewall bloqueando  
**Solução:**
```bash
# Teste conexão
psql $DATABASE_URL -c "SELECT 1;"

# Verifique security groups/firewall
# PostgreSQL porta 5432 deve estar aberta
```

### Erro: 502 Bad Gateway

**Causa:** Aplicação não está rodando  
**Solução:**
```bash
# Verifique logs
pm2 logs

# Reinicie
pm2 restart my-app
```

### Uploads não funcionam

**Causa:** Filesystem efêmero ou permissões  
**Solução:** Use S3/Cloudinary (veja seção acima)

---

## ✅ Checklist Final de Validação

Após deploy, teste:

### Plataforma de Formulários
- [ ] `/` - Página inicial carrega
- [ ] `/admin` - Criar formulário funciona
- [ ] Drag-and-drop de perguntas funciona
- [ ] Templates carregam
- [ ] Salvar formulário persiste no banco
- [ ] `/form/:id` - Link público funciona
- [ ] Submissão salva no banco
- [ ] Página de conclusão aparece corretamente
- [ ] Dashboard mostra estatísticas
- [ ] Upload de logo funciona

### Plataforma WhatsApp
- [ ] `/whatsapp` - Dashboard carrega
- [ ] `/whatsapp/settings` - Configurações carregam
- [ ] Salvar credenciais Evolution API persiste
- [ ] Testar conexão funciona
- [ ] Se conectado, conversas aparecem
- [ ] Envio de texto funciona
- [ ] Envio de imagem funciona
- [ ] Gravação de áudio funciona

---

## 📊 Estimativa de Custos por Plataforma

| Plataforma | Custo Mensal | Banco Incluído | SSL | Scaling |
|------------|-------------|----------------|-----|---------|
| **Heroku** | $7 (Eco) + $5 (DB) | Sim | Sim | Manual |
| **Vercel** | $0-20 | Não (use Neon) | Sim | Auto |
| **Railway** | $5 | Sim | Sim | Auto |
| **DigitalOcean** | $5 (app) + $15 (DB) | Sim | Sim | Manual |
| **AWS EC2+RDS** | ~$25 | Sim | Manual | Manual |
| **VPS** | $5-20 | Self-hosted | Manual | Manual |

**Recomendação para início:** Railway ou DigitalOcean App Platform  
**Recomendação para escala:** AWS ou GCP  
**Recomendação para controle:** VPS com Docker

---

## 🐳 Bonus: Deploy com Docker

### Dockerfile

```dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --legacy-peer-deps

COPY . .
RUN npm run build

EXPOSE 5000

CMD ["npm", "start"]
```

### docker-compose.yml

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "5000:5000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/myapp
      - NODE_ENV=production
    depends_on:
      - db

  db:
    image: postgres:14
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=myapp
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

### Deploy

```bash
docker-compose up -d

# Sincronizar schema
docker-compose exec app npm run db:push
```

---

## 📞 Suporte

Se encontrar problemas durante a migração:

1. Verifique logs da aplicação
2. Verifique logs do banco de dados
3. Revise variáveis de ambiente
4. Consulte documentação da plataforma específica
5. Teste localmente primeiro

---

## 📚 Documentação Relacionada

- [README.md](./README.md) - Visão geral do projeto
- [DOCS_ARCHITECTURE.md](./DOCS_ARCHITECTURE.md) - Arquitetura
- [DOCS_DATABASE.md](./DOCS_DATABASE.md) - Schema do banco
- [DOCS_DEPLOYMENT.md](./DOCS_DEPLOYMENT.md) - Detalhes de deployment

---

**Guia de Migração | Última atualização: 24 de outubro de 2025**

**Boa sorte com a migração! 🚀**
