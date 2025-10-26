# 🔌 Guia Rápido: Conectar Supabase

## ⚡ Instruções Rápidas

### 1️⃣ Execute o SQL no Supabase
1. Abra o arquivo `supabase-setup.sql` (está na raiz do projeto)
2. Copie TODO o conteúdo
3. Acesse seu projeto no Supabase → **SQL Editor** → **New Query**
4. Cole o SQL e clique em **Run**

### 2️⃣ Pegue suas Credenciais
No Supabase Dashboard → **Settings → API**:
- **Project URL**: `https://seu-projeto.supabase.co`
- **anon public** key: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

### 3️⃣ Configure na Aplicação
1. Acesse `/configuracoes` na aplicação
2. Cole a URL e a chave
3. Clique em **Testar Conexão**
4. Clique em **Salvar Configurações**

✅ **Pronto!** Seus dados agora são salvos no Supabase.

---

## 📋 Tabelas Criadas

O SQL cria 3 tabelas automaticamente:

| Tabela | Descrição |
|--------|-----------|
| `forms` | Formulários criados |
| `form_submissions` | Respostas dos usuários |
| `form_templates` | Templates de design |

---

## 🐛 Problemas Comuns

### ❌ "relation does not exist"
**Causa:** Tabelas não foram criadas  
**Solução:** Execute o arquivo `supabase-setup.sql` no SQL Editor

### ❌ "Invalid JWT" ou "API key not found"
**Causa:** Chave incorreta  
**Solução:** Use a chave **anon public**, não a service_role

### ❌ "Failed to fetch"
**Causa:** URL incorreta  
**Solução:** Verifique se a URL começa com `https://`

### ❌ "Conexão OK, mas tabelas não encontradas"
**Causa:** SQL não foi executado completamente  
**Solução:** Execute todo o conteúdo de `supabase-setup.sql`

---

## 🔄 Voltar para PostgreSQL Local

Se quiser usar o banco de dados local do Replit novamente:
1. Vá em `/configuracoes`
2. Clique em **Limpar**
3. A aplicação voltará a usar o PostgreSQL local

---

## 📖 Documentação Completa

Veja `replit.md` para instruções detalhadas passo a passo.

---

## ✅ Verificar se Funcionou

1. Crie um formulário na aplicação
2. No Supabase → **Table Editor** → **forms**
3. Veja o formulário aparecer na tabela! 🎉
