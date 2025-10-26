# Exemplos de Uso - Sistema de Tracking de Leads

Este documento mostra como usar os componentes de tracking de leads criados.

## 1. LeadStatusBadge

Badge que mostra o status real do lead baseado nos campos do banco de dados.

### Uso básico:

```typescript
import { LeadStatusBadge } from "@/components/LeadStatusBadge";

// Em um componente de lista de leads
function LeadsList() {
  const leads = [
    {
      id: "1",
      nome: "João Silva",
      telefone: "5531988887777",
      formularioEnviado: true,
      formularioAberto: true,
      formularioIniciado: true,
      formularioConcluido: false,
      statusQualificacao: null,
      pontuacao: null
    }
  ];

  return (
    <div>
      {leads.map(lead => (
        <div key={lead.id} className="flex items-center gap-4 p-4 border-b">
          <span>{lead.nome}</span>
          <LeadStatusBadge 
            lead={lead} 
            progressoPercentual={65} 
          />
        </div>
      ))}
    </div>
  );
}
```

### Possíveis status do badge:

1. **APROVADO** (verde) - Quando `formularioConcluido && statusQualificacao === 'aprovado'`
2. **Reprovado** (vermelho) - Quando `formularioConcluido && statusQualificacao === 'reprovado'`
3. **Em andamento** (amarelo) - Quando `formularioIniciado`
4. **Visualizou** (azul) - Quando `formularioAberto`
5. **Enviado (não visualizado)** (cinza) - Quando `formularioEnviado`
6. **Sem formulário** (cinza claro) - Quando nenhum formulário foi enviado

## 2. useLeadStatus Hook

Hook para buscar e atualizar automaticamente o status de um lead.

### Uso básico:

```typescript
import { useLeadStatus } from "@/hooks/useLeadStatus";

function LeadDetails({ telefone }: { telefone: string }) {
  const { data, isLoading, error } = useLeadStatus(telefone);

  if (isLoading) {
    return <div>Carregando status...</div>;
  }

  if (error) {
    return <div>Erro ao carregar status: {error.message}</div>;
  }

  if (!data?.data?.existe) {
    return <div>Lead não encontrado</div>;
  }

  const { lead, status } = data.data;

  return (
    <div>
      <h2>{lead.nome}</h2>
      <p>Telefone: {lead.telefone}</p>
      <p>Status: {status.statusQualificacao}</p>
      <p>Pontuação: {status.pontuacao}</p>
      <p>Progresso: {status.progressoPercentual}%</p>
      
      <LeadStatusBadge 
        lead={lead} 
        progressoPercentual={status.progressoPercentual} 
      />
    </div>
  );
}
```

### Recursos do hook:

- ✅ Busca automática do status do lead
- ✅ Atualização automática a cada 5 segundos
- ✅ Cache inteligente com React Query
- ✅ Tratamento de erros
- ✅ Loading states

## 3. FormularioPublico

Página pública de formulário com tracking automático em tempo real.

### Como funciona:

1. **URL**: `/formulario/:token`
2. **Validação automática** do token ao carregar
3. **Tracking em tempo real**:
   - Registra quando o lead abre o formulário
   - Registra quando começa a preencher (primeiro campo)
   - Atualiza progresso a cada mudança (debounce de 1s)
   - Registra conclusão ao submeter

### Exemplo de fluxo:

```typescript
// 1. Lead recebe link do WhatsApp
const linkFormulario = "https://seusite.com/formulario/abc123def456...";

// 2. Ao abrir o link, o componente:
//    - Valida o token
//    - Registra a abertura (POST /api/leads/validar-token)
//    - Carrega o formulário

// 3. Ao preencher primeiro campo:
//    - Registra início (POST /api/leads/registrar-inicio)

// 4. A cada mudança de campo (debounce 1s):
//    - Atualiza progresso (POST /api/leads/atualizar-progresso)
//    - Mostra % de conclusão

// 5. Ao submeter:
//    - Finaliza formulário (POST /api/leads/finalizar)
//    - Calcula pontuação
//    - Atualiza status (aprovado/reprovado)
//    - Mostra página de resultado
```

## 4. Integrando tudo - Exemplo completo

### No WhatsApp (enviar formulário):

```typescript
import { leadTrackingService } from '@/services/leadTracking';

async function enviarFormularioWhatsApp(telefone: string, formularioId: string) {
  // 1. Criar sessão com token único
  const { url, token, expiresAt } = await leadTrackingService.criarSessaoFormulario(
    telefone,
    formularioId,
    7 // expira em 7 dias
  );

  // 2. Enviar link via WhatsApp
  const mensagem = `
Olá! 👋

Criamos um formulário especial para você.
Por favor, preencha aqui: ${url}

Este link expira em 7 dias.
  `;

  await enviarMensagemWhatsApp(telefone, mensagem);

  return { url, token };
}
```

### Na lista de conversas (mostrar status):

```typescript
import { useLeadStatus } from "@/hooks/useLeadStatus";
import { LeadStatusBadge } from "@/components/LeadStatusBadge";

function ConversationItem({ telefone, nome }: { telefone: string; nome: string }) {
  const { data } = useLeadStatus(telefone);
  
  const lead = data?.data?.lead;
  const status = data?.data?.status;

  return (
    <div className="flex items-center justify-between p-4">
      <div>
        <h3>{nome}</h3>
        <p className="text-sm text-gray-500">{telefone}</p>
      </div>
      
      {lead && (
        <LeadStatusBadge 
          lead={lead}
          progressoPercentual={status?.progressoPercentual || 0}
        />
      )}
    </div>
  );
}
```

## 5. Endpoints da API

Todos os endpoints já estão implementados no backend:

### POST /api/leads/criar-sessao
Cria uma sessão de formulário com token único.

```typescript
{
  telefone: "5531988887777",
  formularioId: "uuid-do-formulario",
  diasExpiracao: 7
}
```

### POST /api/leads/validar-token
Valida token e registra abertura.

```typescript
{
  token: "abc123def456..."
}
```

### POST /api/leads/registrar-inicio
Registra início do preenchimento.

```typescript
{
  token: "abc123def456...",
  campoInicial: "contactName",
  valor: "João Silva"
}
```

### POST /api/leads/atualizar-progresso
Atualiza progresso em tempo real.

```typescript
{
  token: "abc123def456...",
  camposPreenchidos: {
    contactName: "João Silva",
    contactEmail: "joao@email.com"
  },
  totalCampos: 10
}
```

### POST /api/leads/finalizar
Finaliza formulário e calcula qualificação.

```typescript
{
  token: "abc123def456...",
  respostas: {
    "pergunta-1": "Resposta A",
    "pergunta-2": "Resposta B"
  },
  formularioId: "uuid-do-formulario"
}
```

### GET /api/leads/status/:telefone
Busca status real do lead.

```typescript
// Response
{
  success: true,
  data: {
    existe: true,
    lead: { ... },
    status: {
      formularioEnviado: true,
      formularioAberto: true,
      formularioIniciado: true,
      formularioConcluido: false,
      progressoPercentual: 65,
      pontuacao: null,
      statusQualificacao: null
    }
  }
}
```

## 6. Estrutura de dados do Lead

```typescript
interface Lead {
  id: string;
  telefone: string;
  telefoneNormalizado: string;
  nome?: string;
  email?: string;
  
  // Status do formulário
  formularioUrl?: string;
  formularioEnviado: boolean;
  formularioEnviadoEm?: Date;
  formularioAberto: boolean;
  formularioAbertoEm?: Date;
  formularioIniciado: boolean;
  formularioIniciadoEm?: Date;
  formularioConcluido: boolean;
  formularioConcluidoEm?: Date;
  formularioVisualizacoes: number;
  
  // Qualificação
  pontuacao?: number;
  statusQualificacao?: 'aprovado' | 'reprovado' | null;
  
  // Metadata
  formularioId?: string;
  submissionId?: string;
  createdAt: Date;
  updatedAt: Date;
}
```

## Conclusão

Este sistema oferece tracking completo e em tempo real de leads, desde o envio do formulário até a qualificação final, com atualizações automáticas e badges visuais para facilitar o acompanhamento.
