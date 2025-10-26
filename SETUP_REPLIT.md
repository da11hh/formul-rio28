# 🚀 Guia Completo: Deploy no Replit

Este guia detalha **passo a passo** como fazer o deploy deste projeto WhatsApp Dashboard no Replit.

## 📋 Pré-requisitos

Antes de começar, tenha em mãos:

- [ ] Conta no [Replit](https://replit.com)
- [ ] Evolution API rodando (servidor próprio ou cloud)
- [ ] Credenciais da Evolution API:
  - URL da API
  - API Key (AUTHENTICATION_API_KEY)
  - Nome da instância

## 🎯 Método 1: Import via GitHub (Recomendado)

### Passo 1: Conectar ao GitHub (no Lovable)

1. No Lovable, clique no botão **"GitHub"** no topo direito
2. Clique em **"Connect to GitHub"**
3. Autorize o Lovable a acessar sua conta GitHub
4. Clique em **"Create Repository"**
5. Dê um nome ao repositório (ex: `whatsapp-dashboard`)
6. Aguarde a criação do repositório

### Passo 2: Import no Replit

1. Acesse [Replit.com](https://replit.com)
2. Clique no botão **"+ Create Repl"**
3. Na aba superior, escolha **"Import from GitHub"**
4. Cole a URL do seu repositório GitHub
   - Exemplo: `https://github.com/seu-usuario/whatsapp-dashboard`
5. Clique em **"Import from GitHub"**
6. Aguarde o Replit clonar o repositório

### Passo 3: Configurar o Repl

1. O Replit detectará automaticamente que é um projeto Node.js/Vite
2. Clique em **"Shell"** (no lado esquerdo)
3. Execute os comandos:

```bash
# Instalar dependências
npm install

# Aguarde a instalação completar
```

### Passo 4: Configurar Porta (se necessário)

O projeto já está configurado para porta `8080`. Verifique se o `.replit` foi criado:

```toml
# .replit
run = "npm run dev"

[deployment]
run = ["sh", "-c", "npm run dev"]
```

### Passo 5: Iniciar o Projeto

1. Clique no botão **"Run"** (topo da página)
2. Aguarde o Vite iniciar
3. O Replit abrirá automaticamente uma janela de preview
4. Ou acesse via URL fornecida (ex: `https://whatsapp-dashboard.seu-usuario.repl.co`)

### Passo 6: Configurar Credenciais

1. Na aplicação aberta, clique no **ícone de engrenagem** (Settings)
2. Preencha os campos:
   - **URL da API**: `http://seu-servidor:8080`
   - **API Key**: Sua chave AUTHENTICATION_API_KEY
   - **Nome da Instância**: Nome da sua instância
3. Clique em **"Testar Conexão"**
4. Se tudo estiver OK, clique em **"Salvar Configurações"**

## 🎯 Método 2: Upload Manual

### Passo 1: Exportar do Lovable

1. No Lovable, vá em **Project** → **Settings**
2. Role até **"Export"**
3. Clique em **"Download ZIP"**
4. Extraia o arquivo ZIP no seu computador

### Passo 2: Criar Repl

1. Acesse [Replit.com](https://replit.com)
2. Clique em **"+ Create Repl"**
3. Escolha o template **"Node.js"**
4. Dê um nome ao projeto (ex: `whatsapp-dashboard`)
5. Clique em **"Create Repl"**

### Passo 3: Upload dos Arquivos

Existem duas formas de fazer upload:

**Opção A: Via Interface (para poucos arquivos)**

1. Clique em **"Upload folder"** na barra lateral de arquivos
2. Selecione a pasta extraída do ZIP
3. Aguarde o upload completar

**Opção B: Via Shell (recomendado)**

1. Clique em **"Shell"** (no lado esquerdo)
2. Execute:

```bash
# Fazer upload via Git (se tiver o repo no GitHub)
git clone https://github.com/seu-usuario/whatsapp-dashboard.git
cd whatsapp-dashboard

# Ou fazer upload manual e depois:
npm install
```

### Passo 4: Continuar do Passo 3 do Método 1

Siga os mesmos passos de configuração de porta, iniciar projeto e configurar credenciais.

## ⚙️ Configurações Avançadas

### Variables de Ambiente (Opcional)

Se quiser armazenar configurações como variáveis de ambiente:

1. Clique em **"Tools"** (cadeado) no lado esquerdo
2. Clique em **"Secrets"**
3. Adicione as variáveis:
   - `VITE_EVOLUTION_API_URL`
   - `VITE_EVOLUTION_API_KEY`
   - `VITE_EVOLUTION_INSTANCE`

4. Modifique `src/lib/config.ts` para ler do ambiente:

```typescript
// Adicionar fallback para variáveis de ambiente
const defaultConfig = {
  apiUrl: import.meta.env.VITE_EVOLUTION_API_URL || '',
  apiKey: import.meta.env.VITE_EVOLUTION_API_KEY || '',
  instance: import.meta.env.VITE_EVOLUTION_INSTANCE || '',
};
```

### Manter o Repl Sempre Online

Replit pode desligar Repls inativos no plano gratuito. Para manter online:

**Opção 1: Always On (Replit Paid)**
- Upgrade para Replit Hacker ou Pro
- Ative **"Always On"** nas configurações do Repl

**Opção 2: Ping Externo**
- Use serviços como [UptimeRobot](https://uptimerobot.com)
- Configure ping a cada 5 minutos para sua URL do Repl
- Exemplo: `https://whatsapp-dashboard.seu-usuario.repl.co`

### Domínio Customizado

Para usar um domínio próprio:

1. Clique em **"Domains"** (no lado esquerdo)
2. Siga as instruções para conectar seu domínio
3. Configure os registros DNS conforme indicado
4. Aguarde propagação (pode levar até 48h)

## 🔧 Troubleshooting

### Erro: "Cannot find module"

```bash
# Limpar cache e reinstalar
rm -rf node_modules package-lock.json
npm install
```

### Erro: "Port already in use"

```bash
# Matar processo na porta 8080
kill -9 $(lsof -t -i:8080)

# Ou mudar a porta no vite.config.ts
# Altere port: 8080 para port: 3000
```

### Erro: "Mixed Content" (HTTP/HTTPS)

Se sua Evolution API usa HTTP e o Replit usa HTTPS:

1. **Solução ideal**: Configure sua Evolution API para usar HTTPS
2. **Alternativa**: Use as Edge Functions do Lovable Cloud como proxy
   - Mantenha a conexão com Lovable Cloud ativa
   - As requisições passarão pelo proxy Supabase

### Edge Functions não funcionam

Se você não estiver usando Lovable Cloud:

**Opção 1: Manter Lovable Cloud**
- Mantenha o projeto conectado ao Lovable Cloud
- As Edge Functions continuarão funcionando

**Opção 2: Remover Edge Functions**
- Modifique `src/lib/evolutionApi.ts` para fazer chamadas diretas
- Remova imports do Supabase
- Exemplo:

```typescript
// Antes (com Edge Function)
const { data, error } = await supabase.functions.invoke('evolution-proxy', {...})

// Depois (chamada direta)
const response = await fetch(`${config.apiUrl}/message/sendText/${config.instance}`, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'apikey': config.apiKey,
  },
  body: JSON.stringify(body),
})
const data = await response.json()
```

### Projeto não inicia

```bash
# Ver logs de erro
npm run dev

# Se houver erro de TypeScript
npm run build

# Ver mais detalhes
DEBUG=* npm run dev
```

## 📊 Monitoramento

### Verificar Logs

1. Clique em **"Console"** (no lado esquerdo)
2. Veja os logs em tempo real do Vite
3. Erros aparecerão em vermelho

### Verificar Network

1. Abra DevTools do navegador (F12)
2. Vá na aba **"Network"**
3. Veja todas as requisições para Evolution API
4. Verifique status codes (200 = OK, 401 = Auth erro, etc)

### Verificar Console

1. No DevTools, vá na aba **"Console"**
2. Veja logs do cliente JavaScript
3. Procure por erros em vermelho

## 🎓 Dicas Importantes

### Performance

- Use o modo **"Always On"** para produção
- Configure CDN para assets estáticos
- Use cache para conversas frequentes

### Segurança

- **NUNCA** exponha sua API Key no código
- Use variáveis de ambiente (Secrets)
- Configure CORS corretamente na Evolution API
- Use HTTPS sempre que possível

### Desenvolvimento

- Use **"Dev Mode"** no Lovable para editar código
- Faça push para GitHub para sincronizar com Replit
- Use branches para features novas
- Teste localmente antes de fazer deploy

## 🚀 Próximos Passos

Depois do deploy:

1. ✅ Configure suas credenciais
2. ✅ Teste o envio de mensagens
3. ✅ Configure domínio customizado (opcional)
4. ✅ Configure "Always On" (opcional)
5. ✅ Configure backup automático
6. ✅ Configure monitoramento
7. ✅ Compartilhe com sua equipe!

## 📞 Precisa de Ajuda?

- 📖 Leia o [README.md](./README.md) completo
- 💬 Pergunte na comunidade Replit
- 🐛 Abra uma issue no GitHub
- 📧 Entre em contato com suporte

---

**Boa sorte com seu deploy! 🎉**

Se tudo funcionou, você agora tem um dashboard profissional do WhatsApp rodando no Replit! 🚀
