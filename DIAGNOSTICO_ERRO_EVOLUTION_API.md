# Diagnóstico Completo - Erro ao Enviar Mensagens via Evolution API

## 📋 CONTEXTO DO PROJETO

Estamos desenvolvendo uma aplicação de chat integrada com a Evolution API (WhatsApp) usando:
- **Frontend**: React + TypeScript
- **Backend**: Supabase Edge Functions (Deno)
- **Automação**: n8n workflows
- **API Externa**: Evolution API v2 (WhatsApp)

## 🔴 PROBLEMA ATUAL

**Erro**: Bad Request ao tentar enviar mensagens via Evolution API
**Status**: Mensagens não são enviadas, aplicação retorna erro 400/500
**Impacto**: Sistema de chat completamente inoperante

## 📊 LOGS DE ERRO DETALHADOS

### Console Logs (Cliente)
```
2025-10-21T01:00:44Z info: Sending message to: 553192267220

2025-10-21T01:00:46Z error: Failed to send message: {
  "success": false,
  "error": "WhatsApp não está conectado. Por favor, conecte sua instância primeiro.",
  "details": "{\"status\":500,\"error\":\"Internal Server Error\",\"response\":{\"message\":\"Connection Closed\"}}"
}
```

### Edge Function Logs (evolution-send-message)
```json
{
  "event_message": "Sending message via Evolution API",
  "apiUrl": "http://103.199.187.145:8080/",
  "instance": "nexus intelligence",
  "number": "553192267220",
  "textLength": 3,
  "hasApiKey": true
}

{
  "event_message": "Making request to: http://103.199.187.145:8080/message/sendText/nexus%20intelligence"
}

{
  "event_message": "Request body",
  "body": {
    "number": "553192267220@s.whatsapp.net",
    "text": "ola",
    "options": {
      "delay": 1200,
      "presence": "composing",
      "linkPreview": false
    }
  }
}

{
  "event_message": "Evolution API response",
  "status": 500,
  "ok": false,
  "body": "{\"status\":500,\"error\":\"Internal Server Error\",\"response\":{\"message\":\"Connection Closed\"}}"
}

{
  "event_message": "Failed to send message",
  "error": "{\"status\":500,\"error\":\"Internal Server Error\",\"response\":{\"message\":\"Connection Closed\"}}"
}
```

### Network Request
```
POST https://tdasfipgmiynjtvaeoua.supabase.co/functions/v1/evolution-send-message
Status: 200

Request Body:
{
  "apiUrl": "http://103.199.187.145:8080/",
  "apiKey": "10414D921BD3-4EC3-A745-AC2EBB189044",
  "instance": "nexus intelligence",
  "number": "553192267220",
  "text": "ola"
}

Response Body:
{
  "success": false,
  "error": "WhatsApp não está conectado. Por favor, conecte sua instância primeiro.",
  "details": "{\"status\":500,\"error\":\"Internal Server Error\",\"response\":{\"message\":\"Connection Closed\"}}"
}
```

## 🔧 CÓDIGO ATUAL

### Edge Function: `supabase/functions/evolution-send-message/index.ts`

```typescript
const requestBody = {
  number: formattedNumber,
  text: text,
  options: {
    delay: 1200,
    presence: 'composing',
    linkPreview: false,
  },
};

const response = await fetch(url, {
  method: 'POST',
  headers: {
    'apikey': apiKey,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify(requestBody),
});
```

### Endpoint Construído
```
http://103.199.187.145:8080/message/sendText/nexus%20intelligence
```

## 🔍 ANÁLISE DO FLUXO N8N

### Workflow "Secretária Amanda"
O workflow n8n possui os seguintes componentes relevantes:

1. **Webhook EVO1**: Recebe mensagens do Evolution API
2. **Switch7**: Identifica tipo de mensagem (text, audio, image)
3. **Amanda (Agent)**: Processa com IA
4. **Split de Mensagem**: Divide respostas longas
5. **Loop Over Items3**: Itera sobre mensagens divididas
6. **Enviar texto**: Envia via Evolution API usando credenciais

### Nó "Enviar texto" (Evolution API)
```json
{
  "parameters": {
    "resource": "messages-api",
    "instanceName": "={{ $('Webhook EVO1').first().json.body.instance }}",
    "remoteJid": "={{ $('Dados1').first().json.Telefone }}",
    "messageText": "=*{{ $('Switch2').item.json['Nome do agente'] }}*\n{{ $json.output }}",
    "options_message": {
      "delay": 4200,
      "linkPreview": false
    }
  },
  "type": "n8n-nodes-evolution-api.evolutionApi",
  "credentials": {
    "evolutionApi": {
      "id": "31MiHLkXOH3jhX5O",
      "name": "Evolution account 2"
    }
  }
}
```

## 📚 DOCUMENTAÇÃO EVOLUTION API

### Endpoint Correto para Envio de Texto
```
POST /message/sendText/{instance}
```

### Headers Necessários
```
apikey: {sua-api-key}
Content-Type: application/json
```

### Body Esperado (Possíveis Formatos)

**Formato 1 (Simples)**:
```json
{
  "number": "5531999999999",
  "text": "Mensagem aqui"
}
```

**Formato 2 (Com Options)**:
```json
{
  "number": "5531999999999",
  "textMessage": {
    "text": "Mensagem aqui"
  },
  "options": {
    "delay": 1200,
    "presence": "composing",
    "linkPreview": false
  }
}
```

**Formato 3 (Completo)**:
```json
{
  "number": "5531999999999@s.whatsapp.net",
  "text": "Mensagem aqui",
  "options": {
    "delay": 1200,
    "presence": "composing"
  }
}
```

## 🔄 TENTATIVAS DE CORREÇÃO ANTERIORES

### Tentativa 1
- Alterado de `text: text` para `textMessage: { text: text }`
- **Resultado**: Bad Request

### Tentativa 2
- Revertido para `text: text` mantendo options
- **Resultado**: Connection Closed / Bad Request

### Tentativa 3 (Atual)
- Formato atual com `text` no root e `options` separado
- **Resultado**: Ainda apresenta erro

## ⚠️ POSSÍVEIS CAUSAS DO ERRO

### 1. Formato do Payload Incorreto
- A Evolution API pode estar esperando estrutura diferente
- Versão da API pode ter mudado
- Documentação pode estar desatualizada

### 2. Problema com a Instância
- Mensagem: "Connection Closed" sugere que a instância do WhatsApp não está conectada
- A instância "nexus intelligence" pode estar desconectada do WhatsApp

### 3. Formato do Número
- Número sendo enviado: `553192267220@s.whatsapp.net`
- Pode precisar ser apenas: `553192267220`
- Ou formato internacional: `+5531992267220`

### 4. Endpoint Incorreto
- Usando: `/message/sendText/nexus%20intelligence`
- Nome da instância tem espaço, sendo URL encoded
- Pode precisar ser diferente

### 5. Headers Incompletos
- Pode faltar algum header específico
- API key pode estar inválida ou expirada

## 🎯 DADOS DE CONFIGURAÇÃO

```javascript
apiUrl: "http://103.199.187.145:8080/"
apiKey: "10414D921BD3-4EC3-A745-AC2EBB189044"
instance: "nexus intelligence"
```

## 📝 ESTRUTURA DE ARQUIVOS RELEVANTES

```
supabase/functions/
├── evolution-send-message/
│   └── index.ts (Edge Function principal)
├── evolution-fetch-chats/
│   └── index.ts
├── evolution-fetch-messages/
│   └── index.ts
└── evolution-proxy/
    └── index.ts

src/
├── lib/
│   ├── evolutionApi.ts (Cliente API)
│   ├── config.ts (Gerenciador de configuração)
│   └── storage.ts
├── components/
│   ├── ChatArea.tsx (UI do chat)
│   └── MessageBubble.tsx
└── pages/
    ├── Index.tsx (Página principal)
    └── Settings.tsx (Configurações)
```

## 🔍 CÓDIGO COMPLETO DA EDGE FUNCTION

```typescript
serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const { apiUrl, apiKey, instance, number, text } = await req.json();

    if (!apiUrl || !apiKey || !instance || !number || !text) {
      return new Response(
        JSON.stringify({ error: 'Missing required parameters' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const baseUrl = apiUrl.replace(/\/$/, '');
    const encodedInstance = encodeURIComponent(instance);
    
    let formattedNumber = number;
    if (!formattedNumber.includes('@')) {
      formattedNumber = `${number}@s.whatsapp.net`;
    }
    
    const url = `${baseUrl}/message/sendText/${encodedInstance}`;
    
    const requestBody = {
      number: formattedNumber,
      text: text,
      options: {
        delay: 1200,
        presence: 'composing',
        linkPreview: false,
      },
    };

    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'apikey': apiKey,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(requestBody),
    });

    const responseText = await response.text();

    if (!response.ok) {
      let errorMessage = `API returned status ${response.status}`;
      try {
        const errorData = JSON.parse(responseText);
        if (errorData?.response?.message === 'Connection Closed') {
          errorMessage = 'WhatsApp não está conectado. Por favor, conecte sua instância primeiro.';
        } else if (errorData?.error) {
          errorMessage = errorData.error;
        }
      } catch {}
      
      return new Response(
        JSON.stringify({
          success: false,
          error: errorMessage,
          details: responseText,
        }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    let messageData;
    try {
      messageData = JSON.parse(responseText);
    } catch {
      messageData = { raw: responseText };
    }

    return new Response(
      JSON.stringify({ success: true, data: messageData }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
      }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});
```

## 🎯 O QUE PRECISA SER FEITO

1. **Verificar Status da Instância Evolution**
   - Confirmar se "nexus intelligence" está conectada
   - Verificar se QR code foi escaneado
   - Validar se instância está ativa

2. **Testar Diferentes Formatos de Payload**
   - Testar sem `@s.whatsapp.net`
   - Testar com formato internacional
   - Testar diferentes estruturas de JSON

3. **Validar Endpoint e Headers**
   - Confirmar endpoint correto na documentação oficial
   - Verificar se todos headers necessários estão presentes
   - Testar com ferramenta como Postman/Insomnia

4. **Atualizar Código Conforme Documentação**
   - Ajustar payload para formato correto
   - Implementar tratamento de erros adequado
   - Adicionar validações necessárias

## 🔗 INFORMAÇÕES ADICIONAIS

- **Versão Evolution API**: Presumivelmente v2.x
- **URL Base**: http://103.199.187.145:8080/
- **Instância**: nexus intelligence
- **Tipo de Implementação**: Supabase Edge Functions (Deno runtime)

## ❓ PERGUNTAS PARA RESOLVER

1. Qual é o formato EXATO que a Evolution API v2 espera?
2. A instância "nexus intelligence" está realmente conectada ao WhatsApp?
3. Existe alguma limitação de taxa (rate limit)?
4. O número precisa estar em algum formato específico?
5. Existem permissões ou configurações extras necessárias?

---

**Data do Diagnóstico**: 2025-10-21  
**Status**: 🔴 Crítico - Sistema de envio não funcional  
**Prioridade**: 🔥 Alta - Bloqueador para produção