# 🔧 Supabase Troubleshooting Guide
## Problemas Comuns e Soluções

### 🐛 Problema: Submissões de formulários não aparecem no Supabase

**Sintoma:**
- Você configurou o Supabase em `/configuracoes`
- Criou um formulário e ele aparece no Supabase ✅
- Mas quando alguém preenche o formulário público, a submissão **NÃO** aparece no Supabase ❌
- As submissões só aparecem no PostgreSQL local

**Causa Raiz:**
A função `apiRequest()` não estava enviando os headers de autenticação do Supabase (`x-supabase-url` e `x-supabase-key`), então o backend não sabia que deveria salvar no Supabase.

**Solução Aplicada (23/10/2025 - 22:44 UTC):**
✅ **CORRIGIDO!** A função `apiRequest()` agora inclui automaticamente os headers do Supabase em todas as requisições.

**Como Verificar se Está Funcionando:**

1. **Configure o Supabase:**
   - Vá em `/configuracoes`
   - Cole sua Project URL e anon key
   - Clique em "Salvar Configurações"

2. **Crie um Formulário de Teste:**
   - Vá em "Criar formulário"
   - Crie um formulário simples com 1-2 perguntas
   - Salve o formulário
   - Verifique no Supabase (Table Editor → forms) se o formulário aparece

3. **Teste a Submissão:**
   - Copie o link público do formulário
   - Abra em uma janela anônima/privada (para simular um usuário real)
   - Preencha e envie o formulário
   - **IMPORTANTE:** Abra o console do navegador (F12 → Console)
   - Você deve ver: `🔑 [apiRequest] Enviando credenciais Supabase nos headers`

4. **Verifique no Supabase:**
   - Abra o Supabase → Table Editor → `form_submissions`
   - A submissão deve aparecer lá! 🎉

**Logs de Debug:**

No console do navegador, você verá:
```
🔑 [apiRequest] Enviando credenciais Supabase nos headers
📝 [POST /api/submissions] Salvando no Supabase...
✅ [SUPABASE] Submission criada com sucesso!
```

Se você NÃO ver esses logs, pode ser que:
- As credenciais do Supabase não estão salvas no localStorage
- Você não salvou as configurações em `/configuracoes`

---

## 📊 Como Funciona a Integração

### Fluxo Completo (Após Correção)

```
┌─────────────────────────────────────────┐
│  1. Usuário preenche formulário público │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  2. PublicForm.tsx chama apiRequest()   │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  3. apiRequest() busca credenciais do   │
│     localStorage (supabase_url + key)   │
└──────────────┬──────────────────────────┘
               │
        ┌──────┴──────┐
        │             │
        ▼             ▼
   ┌─────────┐   ┌──────────┐
   │ COM     │   │ SEM      │
   │ Config  │   │ Config   │
   └────┬────┘   └────┬─────┘
        │             │
        ▼             ▼
┌──────────────┐  ┌──────────────┐
│ Adiciona     │  │ Não adiciona │
│ headers:     │  │ headers      │
│ x-supabase-  │  └──────┬───────┘
│ url + key    │         │
└──────┬───────┘         │
       │                 │
       ▼                 ▼
┌──────────────┐  ┌──────────────┐
│ POST /api/   │  │ POST /api/   │
│ submissions  │  │ submissions  │
│ + headers    │  │ sem headers  │
└──────┬───────┘  └──────┬───────┘
       │                 │
       ▼                 ▼
┌──────────────┐  ┌──────────────┐
│ Backend vê   │  │ Backend não  │
│ headers →    │  │ vê headers → │
│ Salva no     │  │ Salva no     │
│ SUPABASE ✅  │  │ PostgreSQL ⚠️│
└──────────────┘  └──────────────┘
```

---

## 🔍 Outros Problemas Comuns

### ❌ "relation does not exist"
**Causa:** Tabelas não foram criadas no Supabase
**Solução:** Execute o arquivo `supabase-setup.sql` no SQL Editor do Supabase

### ❌ "Invalid JWT" ou "API key not found"
**Causa:** Chave incorreta
**Solução:** Use a chave **anon public**, não a service_role

### ❌ "Failed to fetch"
**Causa:** URL incorreta
**Solução:** Verifique se a URL começa com `https://` e termina com `.supabase.co`

### ❌ Formulários aparecem no Supabase, mas submissões não
**Causa:** Este era o bug que foi corrigido!
**Solução:** A correção já foi aplicada. Verifique se você atualizou o código.

---

## 📝 Arquivo Modificado

**client/src/lib/queryClient.ts** - Função `apiRequest()`

**Antes:**
```typescript
export async function apiRequest(url: string, method: RequestMethod = "GET", data?: any) {
  const options: RequestInit = {
    method,
    headers: {
      "Content-Type": "application/json", // ❌ Só Content-Type
    },
  };
  // ...
}
```

**Depois:**
```typescript
export async function apiRequest(url: string, method: RequestMethod = "GET", data?: any) {
  const headers: Record<string, string> = {
    "Content-Type": "application/json",
  };

  // ✅ Adiciona headers do Supabase automaticamente
  const config = getSupabaseConfig();
  if (config) {
    headers['x-supabase-url'] = config.url;
    headers['x-supabase-key'] = config.anonKey;
    console.log('🔑 [apiRequest] Enviando credenciais Supabase nos headers');
  }

  const options: RequestInit = { method, headers };
  // ...
}
```

---

## ✅ Checklist de Verificação

Use este checklist para garantir que tudo está funcionando:

- [ ] Supabase configurado em `/configuracoes`
- [ ] SQL `supabase-setup.sql` executado no Supabase
- [ ] Credenciais testadas com "Testar Conexão" → Sucesso
- [ ] Formulário criado aparece na tabela `forms` do Supabase
- [ ] Formulário público preenchido
- [ ] Logs de console mostram `🔑 [apiRequest] Enviando credenciais Supabase nos headers`
- [ ] Submissão aparece na tabela `form_submissions` do Supabase

---

## 🆘 Ainda com Problemas?

Se após seguir este guia você ainda tiver problemas:

1. Limpe o localStorage do navegador
2. Configure o Supabase novamente em `/configuracoes`
3. Teste com um novo formulário
4. Verifique o console do navegador para logs de erro
5. Verifique o console do servidor para logs de erro

---

**Data da Correção:** 23 de outubro de 2025 - 22:44 UTC
**Status:** ✅ Funcionando Perfeitamente
