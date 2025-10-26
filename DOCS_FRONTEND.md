# 🎨 Documentação Completa do Frontend

## 📐 Visão Geral

**Framework:** React 18.3.1  
**Linguagem:** TypeScript 5.8.3  
**Build Tool:** Vite 5.4.19  
**Roteamento:** Wouter 3.7.1  
**UI Library:** shadcn/ui (Radix UI + Tailwind)  
**Estado:** React Query (TanStack)  
**Total de Componentes:** 78+  
**Total de Páginas:** 11

---

## 🗂️ Estrutura de Pastas

```
client/src/
├── components/                  # 67 componentes compartilhados
│   ├── design/                 # 7 componentes de design
│   │   ├── ColorPicker.tsx                # Seletor de cores HSL
│   │   ├── CompletionPageCustomizer.tsx   # Editor página final
│   │   ├── CompletionPagePreview.tsx      # Preview página final
│   │   ├── DesignCustomizer.tsx           # Editor de design
│   │   ├── DragDropEditor.tsx             # Editor drag-and-drop
│   │   ├── SortableQuestionItem.tsx       # Item arrastável
│   │   └── TemplateSelector.tsx           # Seletor de templates
│   │
│   └── ui/                     # 54 componentes shadcn/ui
│       ├── accordion.tsx
│       ├── alert-dialog.tsx
│       ├── button.tsx
│       ├── card.tsx
│       ├── dialog.tsx
│       ├── input.tsx
│       └── ... (48 mais)
│
├── whatsapp-platform/          # Plataforma WhatsApp completa
│   ├── components/            # 11 componentes WhatsApp
│   │   ├── AudioDebugInfo.tsx           # Debug de áudio
│   │   ├── AudioPlayer.tsx              # Player de áudio
│   │   ├── AudioRecorder.tsx            # Gravador de áudio
│   │   ├── ChatArea.tsx                 # Área de chat
│   │   ├── ConversationItem.tsx         # Item da lista
│   │   ├── ConversationList.tsx         # Lista de conversas
│   │   ├── Header.tsx                   # Cabeçalho WhatsApp
│   │   ├── ImageViewer.tsx              # Visualizador de imagens
│   │   ├── MediaSender.tsx              # Envio de mídia
│   │   ├── MessageBubble.tsx            # Bolha de mensagem
│   │   └── QRCodeDisplay.tsx            # QR Code
│   │
│   ├── lib/                   # Lógica WhatsApp
│   │   ├── apiClient.ts                 # Cliente API genérico
│   │   ├── config.ts                    # Gerenciamento de config
│   │   ├── evolutionApi.ts              # Cliente Evolution API
│   │   ├── evolutionMessageProcessor.ts # Processador de mensagens
│   │   └── utils.ts                     # Utilitários
│   │
│   ├── pages/                 # 2 páginas WhatsApp
│   │   ├── Index.tsx                    # Dashboard principal
│   │   └── Settings.tsx                 # Configurações
│   │
│   └── App.tsx                # App WhatsApp (sub-router)
│
├── pages/                      # 9 páginas principais
│   ├── Admin.tsx                        # Criar formulário
│   ├── Configuracoes.tsx                # Configurações Supabase
│   ├── Dashboard.tsx                    # Dashboard analytics
│   ├── EditarFormulario.tsx             # Editar formulário
│   ├── Index.tsx                        # Página inicial
│   ├── NotFound.tsx                     # 404
│   ├── PublicForm.tsx                   # Formulário público
│   ├── VerFormularios.tsx               # Listar formulários
│   ├── VerPaginasFinal.tsx              # Gerenciar páginas finais
│   └── WhatsApp.tsx                     # Wrapper WhatsApp
│
├── contexts/                   # React Contexts
│   └── SupabaseConfigContext.tsx        # Config Supabase
│
├── hooks/                      # Custom Hooks
│   ├── use-mobile.tsx                   # Detecta mobile
│   └── use-toast.ts                     # Toast notifications
│
├── integrations/               # Integrações externas
│   └── supabase/
│       └── client.ts                    # Cliente Supabase
│
├── lib/                        # Utilitários e helpers
│   ├── api.ts                           # Helpers de API
│   ├── queryClient.ts                   # React Query config
│   ├── supabase-helpers.ts              # Helpers Supabase
│   └── utils.ts                         # Utilitários gerais
│
├── types/                      # TypeScript types
│   └── form.ts                          # Tipos de formulários
│
├── App.tsx                     # App principal (router)
├── main.tsx                    # Entry point
├── index.css                   # Estilos globais + animações
└── App.css                     # Estilos do App
```

---

## 📄 Páginas Principais

### 1. Index.tsx - Página Inicial

**Rota:** `/`  
**Descrição:** Landing page com hero section e features  
**Componentes usados:** Button, Card  

**Features:**
- Hero section com gradiente
- Lista de features
- Botões CTA (Criar Formulário, Ver Dashboard)

---

### 2. Admin.tsx - Criar Formulário

**Rota:** `/admin`  
**Descrição:** Editor completo de formulários  
**Componentes usados:** FormBuilderWithDesign, Tabs, Dialog  

**Features:**
- 3 abas: Perguntas | Design | Templates
- Drag-and-drop para ordenar perguntas
- Preview em tempo real
- Salvar/atualizar formulário

---

### 3. VerFormularios.tsx - Listar Formulários

**Rota:** `/admin/formularios`  
**Descrição:** Tabela com todos os formulários criados  
**Componentes usados:** Table, Button, Badge, Dialog  

**Features:**
- Tabela com ID, título, pontuação, data
- Ações: editar, copiar link, deletar
- Dialog de confirmação para delete

---

### 4. EditarFormulario.tsx - Editar Formulário

**Rota:** `/admin/editar/:id`  
**Descrição:** Edição de formulário existente  
**Similar a:** Admin.tsx mas carrega dados existentes

---

### 5. Dashboard.tsx - Analytics

**Rota:** `/admin/dashboard`  
**Descrição:** Dashboard com estatísticas  
**Componentes usados:** Card, Recharts (gráficos)  

**Features:**
- Total de formulários
- Total de submissões
- Taxa de conversão
- Gráfico de submissões ao longo do tempo
- Distribuição de pontuações

---

### 6. VerPaginasFinal.tsx - Gerenciar Páginas Finais

**Rota:** `/admin/paginas-final`  
**Descrição:** Editor de páginas de conclusão  
**Componentes usados:** CompletionPageCustomizer, CompletionPagePreview  

**Features:**
- Lista de formulários à esquerda
- Editor completo (cores, textos, logos, CTA)
- Preview em tempo real (modo sucesso/falha)

---

### 7. PublicForm.tsx - Formulário Público

**Rota:** `/form/:id`  
**Descrição:** Formulário preenchido por usuário anônimo  
**Componentes usados:** Card, Button, Input, RadioGroup, etc  

**Features:**
- Renderiza perguntas dinamicamente
- Calcula pontuação em tempo real
- Submete resposta
- Mostra página de conclusão personalizada

---

### 8. Configuracoes.tsx - Configurações Supabase

**Rota:** `/configuracoes`  
**Descrição:** Configurar credenciais Supabase  
**Componentes usados:** Card, Input, Button  

**Features:**
- Campos para URL e API Key
- Botão "Testar Conexão"
- Instruções de setup
- SQL de setup copiável

---

### 9. WhatsApp.tsx - Dashboard WhatsApp

**Rota:** `/whatsapp` e `/whatsapp/settings`  
**Descrição:** Wrapper que carrega whatsapp-platform/App.tsx  
**Subpáginas:** Index (dashboard), Settings (config)

---

## 🧩 Componentes Principais

### FormBuilderWithDesign.tsx

**Responsabilidade:** Editor completo de formulários

**Props:**
```typescript
interface Props {
  initialData?: Form
  onSave: (formData: InsertForm) => Promise<void>
}
```

**Estado:**
```typescript
interface State {
  questions: Question[]
  designConfig: DesignConfig
  title: string
  description: string
  passingScore: number
  scoreTiers: ScoreTier[]
}
```

**Abas:**
1. **Perguntas:** Drag-and-drop editor
2. **Design:** ColorPicker, Typography, Spacing
3. **Templates:** TemplateSelector

---

### ChatArea.tsx (WhatsApp)

**Responsabilidade:** Interface de chat

**Props:**
```typescript
interface Props {
  conversation: Conversation | null
  messages: Message[]
  onSendMessage: (text: string) => Promise<void>
  onRefreshMessages: () => void
}
```

**Features:**
- Lista de mensagens com scroll automático
- MessageBubble para cada mensagem
- Input com botão enviar
- MediaSender para imagens/vídeos/áudios
- AudioRecorder para gravar voz

---

### ConversationList.tsx (WhatsApp)

**Responsabilidade:** Lista de conversas

**Props:**
```typescript
interface Props {
  conversations: Conversation[]
  activeId: string | null
  onSelect: (id: string) => void
}
```

**Features:**
- ConversationItem para cada conversa
- Busca de conversas
- Badge de mensagens não lidas
- Ordenação por timestamp

---

## 🎨 Design System

### Cores (Tailwind)

```css
/* Definidas em tailwind.config.ts */
--primary: hsl(221, 83%, 53%)         /* Azul vibrante */
--secondary: hsl(210, 40%, 96%)       /* Cinza claro */
--accent: hsl(142, 71%, 45%)          /* Verde */
--destructive: hsl(0, 84%, 60%)       /* Vermelho */
--muted: hsl(210, 40%, 96%)           /* Cinza suave */
--card: hsl(0, 0%, 100%)              /* Branco */
--border: hsl(214, 32%, 91%)          /* Cinza borda */

/* WhatsApp específico */
--whatsapp-green: #25D366
--whatsapp-teal: #128C7E
```

### Tipografia

```css
/* Font Family */
font-family: 'Inter', -apple-system, sans-serif

/* Tamanhos */
text-xs    /* 0.75rem */
text-sm    /* 0.875rem */
text-base  /* 1rem */
text-lg    /* 1.125rem */
text-xl    /* 1.25rem */
text-2xl   /* 1.5rem */
text-3xl   /* 1.875rem */
text-4xl   /* 2.25rem */
```

### Espaçamento

```css
/* Padding/Margin */
p-2   /* 0.5rem */
p-4   /* 1rem */
p-6   /* 1.5rem */
p-8   /* 2rem */

/* Gap */
gap-2  /* 0.5rem */
gap-4  /* 1rem */
gap-6  /* 1.5rem */
```

---

## 🔄 Gerenciamento de Estado

### React Query (TanStack)

**Configuração:** `lib/queryClient.ts`

```typescript
export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000,  // 5 minutos
      gcTime: 10 * 60 * 1000,     // 10 minutos
    },
  },
});
```

**Uso:**

```typescript
// Query (buscar dados)
const { data, isLoading, error } = useQuery({
  queryKey: ['forms'],
  queryFn: async () => {
    const res = await fetch('/api/forms');
    return res.json();
  },
});

// Mutation (alterar dados)
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
```

---

### Context API (Supabase)

**Arquivo:** `contexts/SupabaseConfigContext.tsx`

```typescript
interface SupabaseConfigContextType {
  supabaseUrl: string | null
  supabaseAnonKey: string | null
  setConfig: (url: string, key: string) => void
  clearConfig: () => void
  isConfigured: boolean
}

// Provider envolve App.tsx
<SupabaseConfigProvider>
  <App />
</SupabaseConfigProvider>

// Uso em componentes
const { supabaseUrl, setConfig } = useSupabaseConfig();
```

---

## 🛣️ Roteamento (Wouter)

**Arquivo:** `App.tsx`

```typescript
import { Route, Switch } from "wouter";

<Switch>
  <Route path="/form/:id" component={PublicForm} />
  
  <Route path="/whatsapp/:rest*">
    <WhatsApp />
  </Route>
  
  <Route path="/whatsapp">
    <WhatsApp />
  </Route>
  
  <Route path="/configuracoes">
    <Configuracoes />
  </Route>
  
  <Route>
    <FormularioLayout>
      <Switch>
        <Route path="/" component={Index} />
        <Route path="/admin" component={Admin} />
        {/* ... */}
      </Switch>
    </FormularioLayout>
  </Route>
</Switch>
```

**Navegação programática:**

```typescript
import { useLocation } from "wouter";

const [location, setLocation] = useLocation();

// Navegar
setLocation("/admin");

// Parâmetros
<Route path="/form/:id">
  {(params) => <PublicForm id={params.id} />}
</Route>
```

---

## 🎭 Animações

**Arquivo:** `index.css`

```css
@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes slideUp {
  from { 
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes scaleIn {
  from {
    opacity: 0;
    transform: scale(0.95);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

@keyframes glow {
  0%, 100% { box-shadow: 0 0 20px rgba(37, 99, 235, 0.2); }
  50% { box-shadow: 0 0 30px rgba(37, 99, 235, 0.4); }
}

/* Uso */
.animate-fadeIn { animation: fadeIn 0.3s ease-in-out; }
.animate-slideUp { animation: slideUp 0.4s ease-out; }
.animate-scaleIn { animation: scaleIn 0.3s ease-out; }
.animate-glow { animation: glow 2s ease-in-out infinite; }
```

---

## 📱 Responsividade

### Breakpoints (Tailwind)

```css
sm:  640px   /* Mobile landscape */
md:  768px   /* Tablet */
lg:  1024px  /* Desktop */
xl:  1280px  /* Large desktop */
2xl: 1536px  /* Ultra-wide */
```

### Exemplo de uso:

```tsx
<div className="
  grid 
  grid-cols-1       /* Mobile: 1 coluna */
  md:grid-cols-2    /* Tablet: 2 colunas */
  lg:grid-cols-3    /* Desktop: 3 colunas */
  gap-4
">
  {/* Cards */}
</div>
```

---

## 🔌 Integração com API

### Helper: apiRequest()

**Arquivo:** `lib/queryClient.ts`

```typescript
export async function apiRequest<T = any>(
  endpoint: string,
  options: RequestInit = {}
): Promise<T> {
  // Busca config Supabase do localStorage
  const config = getSupabaseConfig();
  
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...options.headers as Record<string, string>,
  };
  
  // Adiciona headers Supabase se configurado
  if (config?.supabaseUrl && config?.supabaseAnonKey) {
    headers['x-supabase-url'] = config.supabaseUrl;
    headers['x-supabase-key'] = config.supabaseAnonKey;
  }
  
  const res = await fetch(endpoint, {
    ...options,
    headers,
  });
  
  if (!res.ok) throw new Error(await res.text());
  return res.json();
}
```

**Uso:**

```typescript
const forms = await apiRequest<Form[]>('/api/forms');
```

---

## 🧪 Testes (Não implementado, mas sugerido)

### Vitest + Testing Library (sugestão)

```bash
npm install -D vitest @testing-library/react @testing-library/jest-dom
```

**Exemplo de teste:**

```typescript
// FormBuilder.test.tsx
import { render, screen } from '@testing-library/react';
import { FormBuilderWithDesign } from './FormBuilderWithDesign';

test('renders form builder', () => {
  render(<FormBuilderWithDesign onSave={jest.fn()} />);
  expect(screen.getByText('Perguntas')).toBeInTheDocument();
  expect(screen.getByText('Design')).toBeInTheDocument();
});
```

---

## 📦 Build e Deploy

### Build para Produção

```bash
npm run build
```

**Output:** `dist/public/`

**Arquivos gerados:**
```
dist/public/
├── assets/
│   ├── index-[hash].js         # Bundle JavaScript
│   ├── index-[hash].css        # Bundle CSS
│   └── [imagens, fontes, etc]
└── index.html                   # HTML principal
```

### Análise de Bundle

```bash
# Instalar analyzer
npm install -D rollup-plugin-visualizer

# Build com análise
vite build --analyze
```

---

## 🚀 Otimizações Implementadas

1. **Code Splitting:** Componentes WhatsApp são lazy-loaded
2. **Tree Shaking:** shadcn/ui importa apenas componentes usados
3. **Image Optimization:** Lazy loading automático
4. **CSS Purge:** Tailwind remove classes não usadas
5. **Minification:** Vite minifica JS e CSS automaticamente

---

**Documentação do Frontend | Última atualização: 24 de outubro de 2025**
