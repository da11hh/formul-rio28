# 🚨 Guia de Troubleshooting - Replit

Este documento explica os problemas mais comuns no Replit e como evitá-los **permanentemente**.

## 📋 Índice

1. [Erro: "Blocked request. This host is not allowed"](#erro-blocked-request)
2. [Problema: Servidor reiniciando constantemente](#problema-servidor-reiniciando)
3. [Checklist de Configuração Obrigatória](#checklist-obrigatório)

---

## 🔴 Erro: "Blocked request. This host is not allowed"

### Sintoma
```
Blocked request. This host ("d295229e-be29-4800-b38c-17bd06fce62f-00-152d48r4s0qae.worf.replit.dev") is not allowed.
To allow this host, add "..." to `server.allowedHosts` in vite.config.js.
```

### Por que acontece?
O Replit usa URLs dinâmicas de proxy (como `*.replit.dev`) que mudam constantemente. O Vite, por segurança, bloqueia requisições de hosts desconhecidos.

### ✅ Solução PERMANENTE

**Arquivo: `vite.config.ts`**

```typescript
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react-swc";
import path from "path";

export default defineConfig(({ mode }) => ({
  root: "client",
  server: {
    host: "0.0.0.0",           // OBRIGATÓRIO: Aceita conexões externas
    port: 5000,                // Porta padrão do Replit
    allowedHosts: true,        // ⚠️ CRÍTICO: Permite TODOS os hosts (essencial para Replit)
    hmr: {
      protocol: 'wss',         // WebSocket seguro para HMR
      clientPort: 443,         // Porta HTTPS do proxy Replit
    },
  },
  plugins: [
    react(),
    mode === "development" && componentTagger(),
  ].filter(Boolean),
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "client/src"),
      "@shared": path.resolve(__dirname, "shared"),
      "@assets": path.resolve(__dirname, "attached_assets"),
    },
  },
  build: {
    outDir: "../dist/public",
    emptyOutDir: true,
  },
}));
```

### 🔑 Configuração Crítica

```typescript
server: {
  allowedHosts: true,  // ← NUNCA REMOVA ISSO!
}
```

**Por que `allowedHosts: true` é essencial:**
- ✅ Permite que o Replit acesse a aplicação através das URLs de proxy dinâmicas
- ✅ Sem isso, você sempre verá "Blocked request"
- ✅ É seguro no ambiente Replit porque o proxy já fornece segurança

### ⚠️ IMPORTANTE
**NUNCA remova ou altere `allowedHosts: true` do vite.config.ts**. Se remover, a aplicação ficará inacessível no Replit.

---

## 🔄 Problema: Servidor reiniciando constantemente

### Sintomas
- O servidor reinicia a cada poucos segundos
- Logs mostram: `"Server running..."` repetidamente
- Console do navegador: `"[vite] server connection lost. Polling for restart..."`
- A aplicação fica lenta ou travada

### Por que acontece?

Existem DOIS problemas diferentes que causam sintomas parecidos:

**Problema 1: TSX Watch reiniciando**
- O `tsx watch` detecta mudanças em arquivos do frontend ou arquivos temporários do Vite
- Isso faz o servidor Express reiniciar desnecessariamente

**Problema 2: HMR WebSocket não conecta**
- O Hot Module Reload (HMR) do Vite tenta conectar via WebSocket
- No Replit, essa conexão pode falhar
- Você vê "[vite] connection lost. Polling for restart..." mas **o servidor NÃO está reiniciando**
- É só uma mensagem enganosa do HMR tentando reconectar

### ✅ Solução PERMANENTE

**Arquivo: `package.json`**

```json
{
  "scripts": {
    "dev": "tsx watch --clear-screen=false --ignore 'vite.config.ts.timestamp-*' --ignore '*.timestamp-*.mjs' --ignore 'client/**/*' --ignore 'dist/**/*' server/index.ts",
    "build": "vite build",
    "preview": "vite preview"
  }
}
```

### 🔑 Explicação dos Ignores

```bash
tsx watch \
  --clear-screen=false \                      # Não limpa o terminal
  --ignore 'vite.config.ts.timestamp-*' \    # Ignora arquivos temporários do Vite config
  --ignore '*.timestamp-*.mjs' \             # Ignora TODOS arquivos timestamp do Vite
  --ignore 'client/**/*' \                   # Ignora mudanças no frontend (Vite cuida)
  --ignore 'dist/**/*' \                     # Ignora pasta de build
  server/index.ts                            # Monitora apenas o backend
```

### Por que isso funciona?

1. **`--ignore 'client/**/*'`**: O frontend usa Hot Module Reload (HMR) do Vite, não precisa reiniciar o servidor Express
2. **`--ignore '*.timestamp-*.mjs'`**: Vite cria esses arquivos temporários, ignorá-los evita reinícios
3. **`--ignore 'dist/**/*'`**: Pasta de build não deve causar reinícios

### 📊 Comparação

| Configuração | Comportamento |
|-------------|--------------|
| ❌ **Sem ignores** | Reinicia a cada 2-5 segundos (PROBLEMA) |
| ✅ **Com ignores** | Reinicia apenas quando o código backend muda |

---

## 🎯 Checklist Obrigatório de Configuração

Use este checklist para verificar se sua aplicação está configurada corretamente:

### ✅ vite.config.ts

- [ ] `server.host` está definido como `"0.0.0.0"`
- [ ] `server.port` está definido como `5000`
- [ ] `server.allowedHosts` está definido como `true` ⚠️ **CRÍTICO**
- [ ] `server.hmr.protocol` está definido como `'wss'`
- [ ] `server.hmr.clientPort` está definido como `443`

### ✅ package.json

- [ ] Script `dev` tem `--ignore 'client/**/*'`
- [ ] Script `dev` tem `--ignore '*.timestamp-*.mjs'`
- [ ] Script `dev` tem `--ignore 'vite.config.ts.timestamp-*'`
- [ ] Script `dev` tem `--ignore 'dist/**/*'`

### ✅ Workflow Replit

- [ ] Workflow configurado com nome "Server"
- [ ] Comando: `npm run dev`
- [ ] Porta: `5000`
- [ ] Output type: `webview`

### ✅ Deployment

- [ ] Deployment target: `vm` (sempre rodando)
- [ ] Run command: `npm run dev`

---

## 🔧 Como Verificar se Está Funcionando

### 1. Teste do Vite (Blocked Request)

**Antes da correção:**
```
❌ Erro: "Blocked request. This host is not allowed"
❌ Página em branco ou não carrega
```

**Depois da correção:**
```
✅ Aplicação carrega normalmente
✅ Dashboard WhatsApp visível
✅ Sem erros de host bloqueado
```

### 2. Teste de Reinícios

**Antes da correção:**
```bash
# Terminal mostra reinícios constantes:
✅ Server running on http://0.0.0.0:5000
✅ Server running on http://0.0.0.0:5000  # ← Reiniciou sem razão
✅ Server running on http://0.0.0.0:5000  # ← Reiniciou de novo
```

**Depois da correção:**
```bash
# Terminal mostra apenas um start:
✅ Server running on http://0.0.0.0:5000
# ... sem reinícios desnecessários
```

**Teste manual:**
1. Edite um arquivo do frontend (`client/src/pages/Index.tsx`)
2. Salve o arquivo
3. Verifique o terminal
4. ✅ **Servidor NÃO deve reiniciar** (Vite HMR cuida disso)

---

## 📝 Resumo Executivo

### Problema 1: Vite Blocked Request
- **Causa**: URLs dinâmicas do Replit não são permitidas por padrão
- **Solução**: `allowedHosts: true` no vite.config.ts
- **Status**: ✅ **NUNCA REMOVER**

### Problema 2: Reinícios Constantes
- **Causa**: TSX watch detecta mudanças no frontend e arquivos temporários
- **Solução**: Adicionar `--ignore` patterns no script `dev`
- **Status**: ✅ **Configurado permanentemente**

---

## 🚀 Comandos de Emergência

Se algo der errado, use estes comandos:

```bash
# 1. Reinstalar dependências
npm install

# 2. Verificar se o servidor está rodando
ps aux | grep tsx

# 3. Matar todos os processos Node.js (use com cuidado)
pkill -f tsx

# 4. Reiniciar o workflow
# (Use o botão Restart no Replit)

# 5. Verificar logs do servidor
cat /tmp/logs/Server_*.log
```

---

## 📞 Suporte

Se você ainda está enfrentando problemas:

1. ✅ Verifique o checklist acima
2. ✅ Leia os logs do servidor: `/tmp/logs/Server_*.log`
3. ✅ Verifique o console do navegador (F12)
4. ✅ Confirme que `allowedHosts: true` está no vite.config.ts
5. ✅ Confirme que os `--ignore` patterns estão no package.json

---

## 🔒 Configuração Final Completa

### vite.config.ts (COMPLETO)
```typescript
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react-swc";
import path from "path";
import { componentTagger } from "lovable-tagger";

export default defineConfig(({ mode }) => ({
  root: "client",
  server: {
    host: "0.0.0.0",
    port: 5000,
    allowedHosts: true,  // ⚠️ CRÍTICO PARA REPLIT
    hmr: {
      protocol: 'wss',
      clientPort: 443,
    },
  },
  plugins: [
    react(),
    mode === "development" && componentTagger(),
  ].filter(Boolean),
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "client/src"),
      "@shared": path.resolve(__dirname, "shared"),
      "@assets": path.resolve(__dirname, "attached_assets"),
    },
  },
  build: {
    outDir: "../dist/public",
    emptyOutDir: true,
  },
}));
```

### package.json (Script dev)
```json
{
  "scripts": {
    "dev": "tsx watch --clear-screen=false --ignore 'vite.config.ts.timestamp-*' --ignore '*.timestamp-*.mjs' --ignore 'client/**/*' --ignore 'dist/**/*' server/index.ts"
  }
}
```

---

**Última atualização:** 22/10/2025  
**Versão:** 1.0  
**Status:** ✅ Configuração testada e funcionando
