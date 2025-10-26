# 🚀 Guia Completo de Deployment

## 📋 Visão Geral

Este documento fornece instruções detalhadas para fazer deploy da aplicação em diferentes plataformas e ambientes.

---

## ✅ Pré-requisitos para Deploy

### Obrigatórios
- [ ] Node.js 20.x instalado
- [ ] PostgreSQL 14+ provisionado
- [ ] DATABASE_URL configurada
- [ ] Código testado localmente (`npm run dev` funciona)
- [ ] Build funciona sem erros (`npm run build`)

### Recomendados
- [ ] Domínio customizado (opcional)
- [ ] SSL/TLS (automático na maioria das plataformas)
- [ ] Logs e monitoring configurados

---

## 🛠️ Configuração de Build

### Scripts NPM

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

### Build Command (Plataformas)

```bash
npm install --legacy-peer-deps && npm run build
```

**⚠️ Importante:** Sempre usar `--legacy-peer-deps` devido a conflitos de `date-fns`.

### Start Command

```bash
npm start
```

**Porta:** Escuta em `process.env.PORT` ou 5000 por padrão.

---

## 🌐 Replit (Atual)

### Configuração Atual

**Workflow:**
```yaml
name: Server
command: npm run dev
wait_for_port: 5000
output_type: webview
```

**Deploy Config:**
```json
{
  "deployment_target": "autoscale",
  "build": ["npm", "run", "build"],
  "run": ["npm", "start"]
}
```

### Variáveis de Ambiente

```bash
# Automático
DATABASE_URL=postgresql://...
REPLIT_DOMAINS=user.repl.co

# Manual (se necessário)
NODE_ENV=production
```

### Processo de Deploy

1. Código é commitado automaticamente
2. Clique em "Publish" no Replit
3. Escolha "Autoscale"
4. Aplicação é deployada automaticamente
5. URL: `https://user.repl.co`

---

## 🔷 Heroku

### Setup Inicial

```bash
# Instalar Heroku CLI
npm install -g heroku

# Login
heroku login

# Criar app
heroku create my-app-name

# Adicionar PostgreSQL
heroku addons:create heroku-postgresql:mini
```

### Procfile

Criar arquivo `Procfile` na raiz:

```
web: npm start
```

### Config Vars

```bash
heroku config:set NODE_ENV=production
```

### Deploy

```bash
# Commit changes
git add .
git commit -m "Deploy to Heroku"

# Push to Heroku
git push heroku main

# Sync database
heroku run npm run db:push

# View logs
heroku logs --tail
```

### Custo Estimado
- **Dynos:** $7/mês (Eco)
- **PostgreSQL:** $5/mês (Mini)
- **Total:** ~$12/mês

---

## 🟢 Vercel

### Limitações

⚠️ **Vercel é serverless - limitações importantes:**
- WebSocket NÃO suportado
- Filesystem efêmero (uploads precisam de S3)
- PostgreSQL precisa de connection pooling (usar Neon/Supabase)

### vercel.json

```json
{
  "version": 2,
  "builds": [
    {
      "src": "server/index.ts",
      "use": "@vercel/node"
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
  ],
  "env": {
    "DATABASE_URL": "@database-url"
  }
}
```

### Deploy

```bash
# Instalar Vercel CLI
npm i -g vercel

# Deploy
vercel

# Configurar variáveis
vercel env add DATABASE_URL production

# Deploy para produção
vercel --prod
```

### Database (Neon ou Supabase)

```bash
# Neon (recomendado)
DATABASE_URL=postgresql://user:pass@ep-...neon.tech/db?sslmode=require

# Supabase (alternativa)
DATABASE_URL=postgresql://postgres:...@db....supabase.co:5432/postgres
```

### Custo
- **Vercel:** $0 (hobby) ou $20/mês (pro)
- **Neon:** $0 (free tier) ou $19/mês (scale)

---

## 🚂 Railway

### Setup

```bash
# Instalar Railway CLI
npm i -g @railway/cli

# Login
railway login

# Inicializar projeto
railway init

# Adicionar PostgreSQL
railway add
# Selecione "PostgreSQL"

# Linkar variáveis
railway variables
```

### Deploy

```bash
# Deploy
railway up

# Sync database
railway run npm run db:push

# Ver logs
railway logs
```

### railway.json (opcional)

```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "nixpacks",
    "buildCommand": "npm install --legacy-peer-deps && npm run build"
  },
  "deploy": {
    "startCommand": "npm start",
    "restartPolicyType": "always"
  }
}
```

### Custo
- **Railway:** $5/mês (starter) + uso
- PostgreSQL incluído

---

## 🌊 DigitalOcean App Platform

### Via Dashboard

1. Conecte repositório GitHub
2. App Platform detecta Node.js automaticamente
3. Configure:
   - **Build:** `npm install --legacy-peer-deps && npm run build`
   - **Run:** `npm start`
4. Adicione PostgreSQL Managed Database
5. Configure environment variables
6. Deploy

### Via CLI (doctl)

```bash
# Instalar CLI
brew install doctl  # macOS
# ou
snap install doctl  # Linux

# Auth
doctl auth init

# Criar app
doctl apps create --spec app.yaml
```

**app.yaml:**
```yaml
name: my-app
services:
- name: web
  github:
    repo: user/repo
    branch: main
  build_command: npm install --legacy-peer-deps && npm run build
  run_command: npm start
  environment_slug: node-js
  instance_size_slug: basic-xxs
  instance_count: 1
  http_port: 5000
  
databases:
- engine: PG
  name: db
  production: true
  version: "14"
```

### Custo
- **App:** $5/mês (Basic)
- **Database:** $15/mês (Basic)
- **Total:** ~$20/mês

---

## ☁️ AWS (EC2 + RDS)

### Provisionar RDS

1. AWS Console → RDS → Create Database
2. PostgreSQL 14
3. Escolha template (Free tier ou Production)
4. Configure security group (permitir 5432)
5. Anote endpoint e credenciais

### Provisionar EC2

1. AWS Console → EC2 → Launch Instance
2. Ubuntu 22.04 LTS
3. t2.micro (Free tier) ou maior
4. Configure security group:
   - SSH (22) - Seu IP
   - HTTP (80) - 0.0.0.0/0
   - HTTPS (443) - 0.0.0.0/0
5. Launch

### Setup no Servidor

```bash
# SSH
ssh -i key.pem ubuntu@ec2-ip

# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Instalar Git
sudo apt install git -y

# Clonar repositório
git clone https://github.com/user/repo.git
cd repo

# Configurar .env
echo "DATABASE_URL=postgresql://..." > .env
echo "NODE_ENV=production" >> .env

# Instalar dependências
npm install --legacy-peer-deps

# Build
npm run build

# Sync database
npm run db:push

# Instalar PM2 (process manager)
sudo npm install -g pm2

# Iniciar app
pm2 start npm --name "my-app" -- start

# Auto-start on reboot
pm2 startup
pm2 save

# Ver logs
pm2 logs
```

### Configurar Nginx (Reverse Proxy)

```bash
sudo apt install nginx -y

sudo nano /etc/nginx/sites-available/myapp
```

**Conteúdo:**
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

```bash
# Ativar site
sudo ln -s /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### Configurar SSL com Certbot

```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d yourdomain.com
```

### Custo Estimado
- **EC2 t2.micro:** $0 (Free tier) ou $8/mês
- **RDS db.t3.micro:** $0 (Free tier) ou $15/mês
- **Total:** $0-23/mês

---

## 🐳 Docker

### Dockerfile

```dockerfile
FROM node:20-alpine

WORKDIR /app

# Copiar package files
COPY package*.json ./

# Instalar dependências
RUN npm install --legacy-peer-deps

# Copiar código
COPY . .

# Build frontend
RUN npm run build

# Expor porta
EXPOSE 5000

# Start comando
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
    restart: always

  db:
    image: postgres:14-alpine
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=myapp
    volumes:
      - pgdata:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    restart: always

volumes:
  pgdata:
```

### Build e Deploy

```bash
# Build
docker-compose build

# Up
docker-compose up -d

# Sync database
docker-compose exec app npm run db:push

# Logs
docker-compose logs -f

# Stop
docker-compose down
```

---

## 📊 Monitoring e Logs

### PM2 (VPS)

```bash
# Monitorar
pm2 monit

# Logs em tempo real
pm2 logs --lines 100

# Reload sem downtime
pm2 reload my-app

# Ver status
pm2 status
```

### Heroku

```bash
# Logs em tempo real
heroku logs --tail

# Métricas
heroku metrics

# Restart
heroku restart
```

### Railway

```bash
# Logs
railway logs

# Shell
railway run bash
```

---

## 🔐 Variáveis de Ambiente

### Lista Completa

```bash
# Obrigatórias
DATABASE_URL=postgresql://user:pass@host:5432/db
NODE_ENV=production

# Opcionais
PORT=5000                        # Porta (automático na maioria)
```

### Supabase (Opcional)

Configurado via interface em `/configuracoes`, NÃO via env vars.

---

## ✅ Checklist Pós-Deploy

### Funcionalidade
- [ ] Homepage (`/`) carrega
- [ ] Dashboard (`/admin`) acessível
- [ ] Criar formulário funciona
- [ ] Salvar formulário persiste no banco
- [ ] Link público funciona (`/form/:id`)
- [ ] Submissão salva no banco
- [ ] WhatsApp dashboard (`/whatsapp`) carrega
- [ ] Settings WhatsApp (`/whatsapp/settings`) salva config

### Performance
- [ ] Página carrega em <3s
- [ ] API responde em <500ms
- [ ] Imagens otimizadas
- [ ] CSS/JS minificados

### Segurança
- [ ] HTTPS habilitado
- [ ] Headers de segurança configurados
- [ ] Database URL não exposta
- [ ] Logs não expõem dados sensíveis

### Monitoring
- [ ] Logs configurados
- [ ] Alertas de erro (opcional)
- [ ] Uptime monitoring (opcional)

---

## 🐛 Troubleshooting Comum

### Build Falha

**Erro:** `Cannot find module`  
**Solução:** `npm install --legacy-peer-deps`

**Erro:** `Bus error`  
**Solução:** Verificar `vite.config.ts` usa `@vitejs/plugin-react` (não `-swc`)

### Aplicação Não Inicia

**Erro:** `ECONNREFUSED`  
**Solução:** Verificar DATABASE_URL

**Erro:** `Port already in use`  
**Solução:** Mudar PORT ou matar processo

### Database Errors

**Erro:** `relation does not exist`  
**Solução:** `npm run db:push`

**Erro:** `password authentication failed`  
**Solução:** Verificar credenciais DATABASE_URL

### 502 Bad Gateway (Nginx)

**Causa:** App não está rodando  
**Solução:** `pm2 restart my-app`

---

## 📚 Referências

- [Replit Deployments](https://docs.replit.com/hosting/deployments)
- [Heroku Node.js](https://devcenter.heroku.com/articles/deploying-nodejs)
- [Vercel Guide](https://vercel.com/docs)
- [Railway Docs](https://docs.railway.app/)
- [DigitalOcean Apps](https://docs.digitalocean.com/products/app-platform/)
- [Docker Compose](https://docs.docker.com/compose/)

---

**Guia de Deployment | Última atualização: 24 de outubro de 2025**
