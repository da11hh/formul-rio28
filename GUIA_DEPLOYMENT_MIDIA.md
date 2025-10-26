# 🚀 Guia Completo de Deploy e Testes - Evolution API com Mídia

## 📋 Índice
1. [Estrutura de Arquivos](#estrutura-de-arquivos)
2. [Deploy das Edge Functions](#deploy-das-edge-functions)
3. [Configuração do Frontend](#configuração-do-frontend)
4. [Testes por Tipo de Mídia](#testes-por-tipo-de-mídia)
5. [Troubleshooting](#troubleshooting)

---

## 📁 Estrutura de Arquivos

```
seu-projeto/
├── supabase/
│   └── functions/
│       ├── evolution-send-message/
│       │   └── index.ts          # ✅ CRIADO (texto)
│       ├── evolution-send-audio/
│       │   └── index.ts          # ✅ CRIADO (áudio)
│       ├── evolution-send-media/
│       │   └── index.ts          # ✅ CRIADO (imagem/vídeo/doc)
│       ├── evolution-fetch-chats/
│       │   └── index.ts          # (já existente)
│       └── evolution-fetch-messages/
│           └── index.ts          # (já existente)
├── src/
│   ├── components/
│   │   ├── ChatArea.tsx          # ✅ ATUALIZADO
│   │   ├── MessageBubble.tsx     # ✅ ATUALIZADO
│   │   ├── AudioRecorder.tsx     # ✅ CRIADO
│   │   ├── AudioPlayer.tsx       # ✅ CRIADO
│   │   └── MediaSender.tsx       # ✅ CRIADO
│   └── lib/
│       └── evolutionMessageProcessor.ts  # ✅ CRIADO
```

---

## 🚀 Deploy das Edge Functions

### Passo 1: Criar os arquivos das Edge Functions

```bash
# 1. Criar diretório para áudio
mkdir -p supabase/functions/evolution-send-audio
touch supabase/functions/evolution-send-audio/index.ts

# 2. Criar diretório para mídia
mkdir -p supabase/functions/evolution-send-media
touch supabase/functions/evolution-send-media/index.ts

# 3. Atualizar função de texto (se necessário)
# Arquivo já existe: supabase/functions/evolution-send-message/index.ts
```

### Passo 2: Copiar o código

**IMPORTANTE**: Copie o código dos artefatos que criei:
- `evolution-send-audio/index.ts` → Do artefato "Evolution API - Edge Function para Áudio"
- `evolution-send-media/index.ts` → Do artefato "Evolution API - Edge Function para Mídia"
- `evolution-send-message/index.ts` → Do artefato "Evolution API - Versão Universal (V1 + V2)"

### Passo 3: Deploy

```bash
# Deploy todas as funções de uma vez
supabase functions deploy evolution-send-audio
supabase functions deploy evolution-send-media
supabase functions deploy evolution-send-message

# Ou deploy todas
supabase functions deploy
```

### Passo 4: Verificar logs

```bash
# Ver logs em tempo real
supabase functions logs evolution-send-audio --tail
supabase functions logs evolution-send-media --tail
supabase functions logs evolution-send-message --tail
```

---

## ⚙️ Configuração do Frontend

### Passo 1: Instalar componentes necessários

```bash
# Se não tiver os componentes shadcn/ui instalados
npx shadcn-ui@latest add button
npx shadcn-ui@latest add textarea
npx shadcn-ui@latest add toast
```

### Passo 2: Criar os componentes

1. **AudioRecorder.tsx**: Copie do artefato "Componente de Gravação de Áudio"
2. **AudioPlayer.tsx**: Copie do artefato "Componente Player de Áudio"
3. **MediaSender.tsx**: Copie do artefato "Componente para Enviar Imagens e Vídeos"

### Passo 3: Atualizar componentes existentes

1. **ChatArea.tsx**: Substitua pelo código do artefato "ChatArea Completo com Suporte a Mídia"
2. **MessageBubble.tsx**: Substitua pelo código do artefato "MessageBubble com Suporte a Todos os Tipos de Mídia"

### Passo 4: Criar helper

```bash
mkdir -p src/lib
touch src/lib/evolutionMessageProcessor.ts
```

Copie o código do artefato "Processador de Mensagens Evolution API"

---

## 🧪 Testes por Tipo de Mídia

### ✅ Teste 1: Mensagem de Texto

**Objetivo**: Confirmar que mensagens de texto funcionam

```bash
# Teste via curl
curl -X POST \
  "https://SEU_PROJETO.supabase.co/functions/v1/evolution-send-message" \
  -H "Authorization: Bearer SEU_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "apiUrl": "http://103.199.187.145:8080/",
    "apiKey": "10414D921BD3-4EC3-A745-AC2EBB189044",
    "instance": "nexus intelligence",
    "number": "553192267220",
    "text": "Teste de mensagem de texto"
  }'
```

**Resultado esperado**:
```json
{
  "success": true,
  "data": {
    "key": {
      "id": "...",
      "remoteJid": "553192267220@s.whatsapp.net"
    }
  }
}
```

---

### 🎵 Teste 2: Áudio

**Objetivo**: Gravar e enviar áudio de voz

**Passos no Frontend**:
1. Abra um chat
2. Clique no botão de microfone 🎤
3. Permita acesso ao microfone (se solicitado)
4. Grave por alguns segundos
5. Clique em parar ⏹️
6. Clique em enviar ✅

**Verificar logs**:
```bash
supabase functions logs evolution-send-audio --tail
```

**Logs esperados**:
```
🎵 Recebendo requisição de áudio
📦 Enviando payload
📡 Resposta da Evolution API: status: 200
✅ Áudio enviado com sucesso
```

**Teste via curl** (com áudio base64):
```bash
# Primeiro, converta um áudio para base64
base64 -i audio.webm -o audio.txt

# Depois teste
curl -X POST \
  "https://SEU_PROJETO.supabase.co/functions/v1/evolution-send-audio" \
  -H "Authorization: Bearer SEU_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "apiUrl": "http://103.199.187.145:8080/",
    "apiKey": "10414D921BD3-4EC3-A745-AC2EBB189044",
    "instance": "nexus intelligence",
    "number": "553192267220",
    "audioBase64": "CONTEUDO_DO_AUDIO_BASE64_AQUI"
  }'
```

---

### 📸 Teste 3: Imagem

**Objetivo**: Enviar imagem com legenda

**Passos no Frontend**:
1. Abra um chat
2. Clique no botão de imagem 🖼️
3. Selecione uma imagem (JPG, PNG, GIF, WEBP)
4. Adicione uma legenda (opcional)
5. Clique em "Enviar"

**Verificar logs**:
```bash
supabase functions logs evolution-send-media --tail
```

**Logs esperados**:
```
📸 Recebendo requisição de mídia: mediatype: image
🎯 Detalhes da requisição
📦 Enviando payload
📡 Resposta da Evolution API: status: 200
✅ Mídia enviada com sucesso
```

**Teste via curl**:
```bash
# Converter imagem para data URL
base64 -i imagem.jpg | awk '{print "data:image/jpeg;base64,"$0}' > imagem_data.txt

curl -X POST \
  "https://SEU_PROJETO.supabase.co/functions/v1/evolution-send-media" \
  -H "Authorization: Bearer SEU_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "apiUrl": "http://103.199.187.145:8080/",
    "apiKey": "10414D921BD3-4EC3-A745-AC2EBB189044",
    "instance": "nexus intelligence",
    "number": "553192267220",
    "mediatype": "image",
    "mimetype": "image/jpeg",
    "caption": "Teste de imagem",
    "media": "data:image/jpeg;base64,/9j/4AAQ..."
  }'
```

---

### 🎥 Teste 4: Vídeo

**Objetivo**: Enviar vídeo

**Passos no Frontend**:
1. Abra um chat
2. Clique no botão de vídeo 🎬
3. Selecione um vídeo (MP4, AVI, MOV - máx 16MB)
4. Adicione uma legenda (opcional)
5. Clique em "Enviar"

**Validações automáticas**:
- ✅ Tamanho máximo: 16MB
- ✅ Formato suportado
- ✅ Conversão para data URL

---

### 📄 Teste 5: Documento

**Objetivo**: Enviar documento PDF

**Passos no Frontend**:
1. Abra um chat
2. Clique no botão de documento 📎
3. Selecione um documento (PDF, DOCX, XLSX, TXT, ZIP)
4. Adicione uma descrição (opcional)
5. Clique em "Enviar"

---

## 🔍 Troubleshooting

### Problema 1: "Connection Closed"

**Causa**: Instância do WhatsApp desconectada

**Solução**:
```bash
# Verificar status da instância
curl -X GET \
  "http://103.199.187.145:8080/instance/connectionState/nexus%20intelligence" \
  -H "apikey: 10414D921BD3-4EC3-A745-AC2EBB189044"
```

**Se desconectada**:
1. Acesse o dashboard Evolution: `http://103.199.187.145:8080/manager`
2. Escaneie o QR code novamente
3. Aguarde status "open"

---

### Problema 2: Áudio não grava

**Causa**: Permissão de microfone negada

**Solução**:
1. Chrome: Clique no cadeado na barra de endereço → Configurações do site → Microfone → Permitir
2. Firefox: Clique no ícone de permissões → Microfone → Permitir
3. Edge: Similar ao Chrome

---

### Problema 3: Imagem muito grande

**Erro**: `Arquivo muito grande`

**Solução**:
- Redimensione a imagem antes de enviar
- Comprima usando ferramentas online
- Limite: 16MB

---

### Problema 4: Formato não suportado

**Erro**: `Tipo de mídia inválido`

**Formatos aceitos**:
- **Imagens**: JPEG, PNG, GIF, WEBP
- **Vídeos**: MP4, 3GP, AVI, MOV
- **Áudio**: WebM (Opus codec)
- **Documentos**: PDF, DOC, DOCX, XLS, XLSX, TXT, ZIP

---

### Problema 5: Edge Function não responde

**Verificar logs**:
```bash
# Logs detalhados
supabase functions logs evolution-send-audio --tail --verbose
supabase functions logs evolution-send-media --tail --verbose
```

**Verificar deploy**:
```bash
# Listar funções deployadas
supabase functions list

# Re-deploy se necessário
supabase functions deploy evolution-send-audio --debug
```

---

## ✅ Checklist Final

Antes de considerar completo, verifique:

- [ ] **Texto**: Envia e recebe mensagens de texto
- [ ] **Áudio**: Grava, envia e reproduz áudio
- [ ] **Imagem**: Envia, recebe e visualiza imagens
- [ ] **Vídeo**: Envia, recebe e reproduz vídeos
- [ ] **Documento**: Envia, recebe e baixa documentos
- [ ] **Logs**: Todos os logs estão limpos, sem erros
- [ ] **UI**: Interface responsiva e funcional
- [ ] **Performance**: Sem travamentos ao enviar mídia
- [ ] **Erros**: Tratamento adequado de erros

---

## 📞 Próximos Passos

1. **Implementar polling**: Para receber mensagens em tempo real
2. **Adicionar indicadores**: "Digitando...", "Gravando...", etc
3. **Cache de mídia**: Salvar mídia localmente para performance
4. **Notificações**: Alertas de novas mensagens
5. **Busca**: Pesquisar mensagens e contatos

---

## 🎯 Comandos Rápidos

```bash
# Deploy tudo
supabase functions deploy

# Ver logs em tempo real
supabase functions logs --tail

# Testar Edge Function localmente
supabase functions serve evolution-send-audio

# Restart local dev
supabase stop
supabase start
```

---

**Boa sorte com os testes! 🚀**