# 📡 Documentação Completa da API

## 🎯 Visão Geral

**Base URL:** `http://localhost:5000` (desenvolvimento) ou seu domínio em produção  
**Formato:** REST API com JSON  
**Total de Endpoints:** 23 rotas  
**Autenticação:** Nenhuma (adicionar JWT/auth se necessário)

---

## 📋 Categorias de Endpoints

1. **Forms** (12 endpoints) - CRUD de formulários
2. **Submissions** (4 endpoints) - Gestão de respostas
3. **Templates** (5 endpoints) - Templates prontos
4. **Completion Pages** (5 endpoints) - Páginas de finalização
5. **Settings** (2 endpoints) - Configurações gerais
6. **Upload** (1 endpoint) - Upload de arquivos
7. **WhatsApp** (11 endpoints) - Integração Evolution API

---

## 🔷 FORMS - Formulários

### `GET /api/forms`
**Descrição:** Lista todos os formulários

**Headers opcionais:**
```
x-supabase-url: https://seu-projeto.supabase.co
x-supabase-key: eyJ...
```

**Response:** `200 OK`
```json
[
  {
    "id": "uuid",
    "title": "Formulário de Qualificação",
    "description": "Avalie leads",
    "questions": [...],
    "passingScore": 50,
    "scoreTiers": [...],
    "designConfig": {...},
    "completionPageId": "uuid",
    "createdAt": "2025-10-24T10:00:00Z",
    "updatedAt": "2025-10-24T10:00:00Z"
  }
]
```

---

### `GET /api/forms/:id`
**Descrição:** Busca formulário por ID

**Params:**
- `id` (string, UUID) - ID do formulário

**Response:** `200 OK` | `404 Not Found`

---

### `POST /api/forms`
**Descrição:** Cria novo formulário

**Body:**
```json
{
  "title": "Meu Formulário",
  "description": "Descrição opcional",
  "questions": [
    {
      "id": "q1",
      "type": "multiple-choice",
      "question": "Qual o tamanho da sua empresa?",
      "options": [
        { "text": "1-10", "points": 5 },
        { "text": "11-50", "points": 10 }
      ],
      "required": true
    }
  ],
  "passingScore": 50,
  "scoreTiers": [
    { "name": "Bronze", "minScore": 0, "maxScore": 49 }
  ],
  "designConfig": {...},
  "completionPageId": null
}
```

**Response:** `201 Created`

---

### `PATCH /api/forms/:id`
**Descrição:** Atualiza formulário

**Body:** (campos parciais)
```json
{
  "title": "Título Atualizado",
  "passingScore": 60
}
```

**Response:** `200 OK`

---

### `DELETE /api/forms/:id`
**Descrição:** Deleta formulário (CASCADE deleta submissions)

**Response:** `204 No Content`

---

## 📝 SUBMISSIONS - Respostas

### `GET /api/submissions`
**Descrição:** Lista submissões (opcionalmente filtra por form)

**Query Params:**
- `formId` (opcional) - Filtra por formulário

**Exemplo:**
```
GET /api/submissions?formId=550e8400-e29b-41d4-a716-446655440000
```

**Response:** `200 OK`
```json
[
  {
    "id": "uuid",
    "formId": "uuid",
    "answers": {
      "q1": { "value": "11-50", "points": 10 }
    },
    "totalScore": 55,
    "passed": true,
    "contactName": "João Silva",
    "contactEmail": "joao@empresa.com",
    "contactPhone": "+5511999999999",
    "createdAt": "2025-10-24T15:00:00Z"
  }
]
```

---

### `GET /api/submissions/:id`
**Descrição:** Busca submissão por ID

**Response:** `200 OK` | `404 Not Found`

---

### `POST /api/submissions`
**Descrição:** Cria nova submissão (usado no formulário público)

**Body:**
```json
{
  "formId": "uuid",
  "answers": {
    "q1": { "value": "opção escolhida", "points": 10 }
  },
  "totalScore": 55,
  "passed": true,
  "contactName": "João Silva",
  "contactEmail": "joao@empresa.com",
  "contactPhone": "+5511999999999"
}
```

**Response:** `201 Created`

---

## 🎨 TEMPLATES - Templates de Formulários

### `GET /api/templates`
**Descrição:** Lista todos os templates

**Response:** `200 OK`
```json
[
  {
    "id": "uuid",
    "name": "Template Moderno Azul",
    "description": "Design profissional com tons de azul",
    "thumbnailUrl": null,
    "designConfig": {...},
    "questions": [...],
    "isDefault": true,
    "createdAt": "...",
    "updatedAt": "..."
  }
]
```

---

### `GET /api/templates/:id`
**Descrição:** Busca template por ID

---

### `POST /api/templates`
**Descrição:** Cria novo template

---

### `PATCH /api/templates/:id`
**Descrição:** Atualiza template

---

### `DELETE /api/templates/:id`
**Descrição:** Deleta template

---

## 🏁 COMPLETION PAGES - Páginas de Finalização

### `GET /api/completion-pages`
**Descrição:** Lista todas as páginas de finalização

**Response:** `200 OK`
```json
[
  {
    "id": "uuid",
    "name": "Página Padrão",
    "title": "Obrigado!",
    "subtitle": "Sua resposta foi enviada",
    "successMessage": "Parabéns! Você está qualificado.",
    "failureMessage": "Obrigado pela participação.",
    "showScore": true,
    "showTierBadge": true,
    "logo": "/uploads/logos/logo-12345.png",
    "logoAlign": "center",
    "successIconColor": "hsl(142, 71%, 45%)",
    "failureIconColor": "hsl(0, 84%, 60%)",
    "ctaText": "Agendar Reunião",
    "ctaUrl": "https://cal.com/...",
    "customContent": "<p>Conteúdo adicional</p>",
    "designConfig": {...}
  }
]
```

---

### `GET /api/completion-pages/:id`
**Descrição:** Busca página por ID

---

### `POST /api/completion-pages`
**Descrição:** Cria nova página

**Body:**
```json
{
  "name": "Nome Interno",
  "title": "Obrigado!",
  "successMessage": "Você está qualificado!",
  "failureMessage": "Obrigado!",
  "showScore": true,
  "showTierBadge": true,
  "ctaText": "Agendar",
  "ctaUrl": "https://...",
  "designConfig": {...}
}
```

---

### `PATCH /api/completion-pages/:id`
**Descrição:** Atualiza página

---

### `DELETE /api/completion-pages/:id`
**Descrição:** Deleta página

---

## ⚙️ SETTINGS - Configurações

### `GET /api/settings`
**Descrição:** Busca configurações globais (Supabase)

**Response:** `200 OK`
```json
{
  "supabaseUrl": "https://projeto.supabase.co",
  "supabaseAnonKey": "eyJ..."
}
```

---

### `POST /api/settings`
**Descrição:** Salva configurações Supabase

**Body:**
```json
{
  "supabaseUrl": "https://projeto.supabase.co",
  "supabaseAnonKey": "eyJ..."
}
```

**Response:** `200 OK`

---

## 📤 UPLOAD - Upload de Arquivos

### `POST /api/upload/logo`
**Descrição:** Upload de logo (max 5MB, apenas imagens)

**Headers:**
```
Content-Type: multipart/form-data
```

**Body:** (FormData)
```
logo: <file>
```

**Response:** `200 OK`
```json
{
  "url": "/uploads/logos/logo-1729777200000-123456789.png"
}
```

**Erros:**
- `400` - Arquivo não enviado
- `500` - Erro no upload

---

## 💬 WHATSAPP - Evolution API

### `POST /api/config`
**Descrição:** Salva configuração WhatsApp

**Body:**
```json
{
  "userIdWhatsapp": "default",
  "apiUrlWhatsapp": "https://evolution.seuservidor.com",
  "apiKeyWhatsapp": "sua-api-key",
  "instanceWhatsapp": "nome_instancia"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "config": {...}
}
```

---

### `GET /api/config/:userId`
**Descrição:** Busca configuração por userId

**Params:**
- `userId` (string) - ID do usuário (default: "default")

**Response:** `200 OK` | `404 Not Found`

---

### `POST /api/evolution/proxy`
**Descrição:** Proxy genérico para Evolution API

**Body:**
```json
{
  "userId": "default",
  "method": "GET",
  "endpoint": "/instance/connectionState/instancia",
  "body": {}
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "status": 200,
  "data": {
    "instance": {
      "state": "open"
    }
  }
}
```

---

### `POST /api/evolution/chats`
**Descrição:** Busca lista de conversas

**Body:**
```json
{
  "userId": "default"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "chats": [
    {
      "id": "5511999999999@s.whatsapp.net",
      "name": "João Silva",
      "lastMessage": "Olá!",
      "timestamp": 1729777200,
      "unreadCount": 2
    }
  ]
}
```

---

### `POST /api/evolution/contacts`
**Descrição:** Busca lista de contatos

**Body:**
```json
{
  "userId": "default"
}
```

**Response:** Similar a `/chats`

---

### `POST /api/evolution/messages`
**Descrição:** Busca mensagens de uma conversa

**Body:**
```json
{
  "userId": "default",
  "chatId": "5511999999999@s.whatsapp.net"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "messages": [
    {
      "key": {
        "id": "msg-id",
        "remoteJid": "5511999999999@s.whatsapp.net",
        "fromMe": false
      },
      "message": {
        "conversation": "Olá, tudo bem?"
      },
      "messageTimestamp": 1729777200
    }
  ]
}
```

---

### `POST /api/evolution/send-message`
**Descrição:** Envia mensagem de texto

**Body:**
```json
{
  "userId": "default",
  "number": "5511999999999",
  "text": "Olá! Como posso ajudar?"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "key": {
      "id": "msg-id",
      "remoteJid": "5511999999999@s.whatsapp.net",
      "fromMe": true
    },
    "status": "PENDING"
  }
}
```

**Erros:**
- `400` - Parâmetros faltando
- `500` - WhatsApp desconectado

---

### `POST /api/evolution/send-media`
**Descrição:** Envia mídia (imagem, vídeo, documento)

**Body:**
```json
{
  "userId": "default",
  "number": "5511999999999",
  "mediatype": "image",
  "mimetype": "image/jpeg",
  "media": "data:image/jpeg;base64,/9j/4AAQSkZJRg...",
  "caption": "Legenda opcional",
  "fileName": "documento.pdf"
}
```

**Params:**
- `mediatype`: `"image"` | `"video"` | `"document"`
- `media`: Base64 string ou URL

**Response:** Similar a `/send-message`

---

## ❌ Códigos de Erro

| Código | Descrição |
|--------|-----------|
| `200` | OK |
| `201` | Created |
| `204` | No Content (delete) |
| `400` | Bad Request (validação falhou) |
| `404` | Not Found |
| `500` | Internal Server Error |

---

## 🔐 Headers Especiais

### Supabase Integration

Se configurado em `/configuracoes`, as rotas de Forms aceitam:

```http
x-supabase-url: https://seu-projeto.supabase.co
x-supabase-key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

Quando presentes, dados são salvos no Supabase ao invés do PostgreSQL local.

---

## 📚 Exemplos de Uso

### JavaScript/Fetch

```javascript
// Criar formulário
const response = await fetch('/api/forms', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    title: 'Meu Formulário',
    questions: [...],
    passingScore: 50,
  }),
});

const form = await response.json();
console.log('Form criado:', form.id);
```

### React Query (usado no projeto)

```typescript
import { useMutation } from '@tanstack/react-query';

const createFormMutation = useMutation({
  mutationFn: async (formData) => {
    const res = await fetch('/api/forms', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(formData),
    });
    return res.json();
  },
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['forms'] });
  },
});

// Uso
createFormMutation.mutate({ title: 'Novo Form', ... });
```

### cURL

```bash
# Listar formulários
curl http://localhost:5000/api/forms

# Criar formulário
curl -X POST http://localhost:5000/api/forms \
  -H "Content-Type: application/json" \
  -d '{"title":"Teste","questions":[],"passingScore":0}'

# Enviar mensagem WhatsApp
curl -X POST http://localhost:5000/api/evolution/send-message \
  -H "Content-Type: application/json" \
  -d '{"userId":"default","number":"5511999999999","text":"Olá!"}'
```

---

## 🧪 Testing

### Postman Collection (exemplo)

```json
{
  "info": {
    "name": "Formulários + WhatsApp API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/"
  },
  "item": [
    {
      "name": "Forms",
      "item": [
        {
          "name": "List Forms",
          "request": {
            "method": "GET",
            "url": "{{base_url}}/api/forms"
          }
        }
      ]
    }
  ],
  "variable": [
    {
      "key": "base_url",
      "value": "http://localhost:5000"
    }
  ]
}
```

---

**Documentação da API | Última atualização: 24 de outubro de 2025**
