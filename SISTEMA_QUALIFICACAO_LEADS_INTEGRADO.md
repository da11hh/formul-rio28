# 🎯 Sistema Integrado de Qualificação de Leads
## Formulários Premium + WhatsApp Dashboard

**Data:** 24 de outubro de 2025  
**Versão:** 3.0.0 - Integração Completa  
**Status:** 📋 Plano de Implementação Detalhado

---

## 📊 VISÃO GERAL DA INTEGRAÇÃO

### Conceito Central

Este documento detalha a **integração completa** entre:
1. **Plataforma de Formulários** - Sistema de qualificação de leads
2. **Dashboard WhatsApp** - Gerenciamento de conversas

**Fluxo Unificado:**
```
WhatsApp Conversa → Envio de Link Formulário → Preenchimento → 
→ Qualificação Automática → Badge no WhatsApp → Follow-up Personalizado
```

### Objetivos da Integração

✅ **Rastreamento Completo**: Acompanhar jornada do lead do primeiro contato até conversão  
✅ **Qualificação Automática**: Sistema de pontuação baseado nas respostas  
✅ **Visualização Unificada**: Ver status de qualificação direto no WhatsApp  
✅ **Automação Inteligente**: Fluxos automáticos baseados no score  
✅ **Histórico Auditável**: Todas interações registradas

---

## 🗄️ NOVA ESTRUTURA DO BANCO DE DADOS

### 1. Tabela `leads` (NOVA - Tabela Central)

**Propósito:** Fonte única de verdade para todos os leads

```typescript
// shared/schema.ts - ADICIONAR

export const leads = pgTable("leads", {
  // Identificação Única
  id: uuid("id").primaryKey().default(sql`gen_random_uuid()`),
  
  // Informações de Contato
  telefone: text("telefone").notNull(),
  telefoneNormalizado: text("telefone_normalizado").notNull().unique(),
  nome: text("nome"),
  email: text("email"),
  
  // Origem do Lead
  origem: text("origem").notNull().default("whatsapp"),
  // Valores possíveis: 'whatsapp', 'formulario', 'manual', 'indicacao', 'website'
  
  // Status do Formulário (Funil de Conversão)
  formularioEnviado: boolean("formulario_enviado").default(false),
  formularioEnviadoEm: timestamp("formulario_enviado_em", { withTimezone: true }),
  formularioIniciado: boolean("formulario_iniciado").default(false),
  formularioIniciadoEm: timestamp("formulario_iniciado_em", { withTimezone: true }),
  formularioConcluido: boolean("formulario_concluido").default(false),
  formularioConcluidoEm: timestamp("formulario_concluido_em", { withTimezone: true }),
  
  // Link único do formulário gerado para este lead
  formularioLinkId: uuid("formulario_link_id"),
  formularioId: uuid("formulario_id").references(() => forms.id, { onDelete: "set null" }),
  
  // Qualificação (Resultado da Análise)
  pontuacao: integer("pontuacao"),
  statusQualificacao: text("status_qualificacao").default("pendente"),
  // Valores: 'aprovado', 'reprovado', 'pendente', 'em_analise', 'desqualificado'
  
  nivelQualificacao: text("nivel_qualificacao"),
  // Valores: 'hot', 'warm', 'cold', 'unqualified' (baseado no score)
  
  motivoReprovacao: text("motivo_reprovacao"),
  
  // Dados do WhatsApp (Evolution API)
  whatsappId: text("whatsapp_id"),
  whatsappInstance: text("whatsapp_instance"),
  primeiraMensagemEm: timestamp("primeira_mensagem_em", { withTimezone: true }),
  ultimaMensagemEm: timestamp("ultima_mensagem_em", { withTimezone: true }),
  ultimaInteracaoEm: timestamp("ultima_interacao_em", { withTimezone: true }),
  totalMensagens: integer("total_mensagens").default(0),
  
  // Engagement e Comportamento
  tempoResposta: integer("tempo_resposta_segundos"),
  // Tempo entre envio do link e início do formulário
  
  tempoPreenchimento: integer("tempo_preenchimento_segundos"),
  // Tempo para completar o formulário
  
  tentativasPreenchimento: integer("tentativas_preenchimento").default(0),
  // Quantas vezes iniciou mas não completou
  
  // Metadados e Organização
  tags: text("tags").array(),
  observacoes: text("observacoes"),
  responsavelId: uuid("responsavel_id"),
  // ID do atendente responsável
  
  prioridade: text("prioridade").default("normal"),
  // Valores: 'alta', 'normal', 'baixa'
  
  // Tracking de Dispositivo
  dispositivo: text("dispositivo"),
  // mobile, desktop, tablet
  
  navegador: text("navegador"),
  ipAddress: text("ip_address"),
  
  // Timestamps
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
  
  // Soft delete
  deletedAt: timestamp("deleted_at", { withTimezone: true }),
}, (table) => ({
  // Índices para Performance
  telefoneNormIdx: index("idx_leads_telefone_norm").on(table.telefoneNormalizado),
  statusQualifIdx: index("idx_leads_status_qualif").on(table.statusQualificacao),
  nivelQualifIdx: index("idx_leads_nivel_qualif").on(table.nivelQualificacao),
  whatsappIdIdx: index("idx_leads_whatsapp_id").on(table.whatsappId),
  formularioIdIdx: index("idx_leads_formulario_id").on(table.formularioId),
  createdAtIdx: index("idx_leads_created_at").on(table.createdAt.desc()),
  ultimaInteracaoIdx: index("idx_leads_ultima_interacao").on(table.ultimaInteracaoEm.desc()),
}));
```

### 2. Atualização da Tabela `form_submissions`

**Mudança:** Adicionar referência ao lead

```typescript
// shared/schema.ts - ATUALIZAR

export const formSubmissions = pgTable("form_submissions", {
  id: uuid("id").primaryKey().default(sql`gen_random_uuid()`),
  formId: uuid("form_id").notNull().references(() => forms.id, { onDelete: "cascade" }),
  
  // NOVO: Referência ao lead
  leadId: uuid("lead_id").references(() => leads.id, { onDelete: "set null" }),
  
  answers: jsonb("answers").notNull(),
  totalScore: integer("total_score").notNull(),
  passed: boolean("passed").notNull(),
  
  // Informações de contato (mantidas por compatibilidade)
  contactName: text("contact_name"),
  contactEmail: text("contact_email"),
  contactPhone: text("contact_phone"),
  
  // NOVO: Detalhamento da pontuação
  pontuacaoDetalhes: jsonb("pontuacao_detalhes"),
  // Exemplo: { "pergunta1": { "resposta": "A", "pontos": 10 }, ... }
  
  // NOVO: Tracking de preenchimento
  tempoPreenchimentoSegundos: integer("tempo_preenchimento_segundos"),
  ipAddress: text("ip_address"),
  userAgent: text("user_agent"),
  dispositivo: text("dispositivo"),
  navegador: text("navegador"),
  
  // Timestamps
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
}, (table) => ({
  formIdIdx: index("idx_submissions_form_id").on(table.formId),
  leadIdIdx: index("idx_submissions_lead_id").on(table.leadId),
  createdAtIdx: index("idx_submissions_created_at").on(table.createdAt.desc()),
}));
```

### 3. Tabela `lead_historico` (NOVA - Auditoria)

**Propósito:** Rastrear todas interações e mudanças de status

```typescript
// shared/schema.ts - ADICIONAR

export const leadHistorico = pgTable("lead_historico", {
  id: uuid("id").primaryKey().default(sql`gen_random_uuid()`),
  leadId: uuid("lead_id").notNull().references(() => leads.id, { onDelete: "cascade" }),
  
  // Tipo de Evento
  tipoEvento: text("tipo_evento").notNull(),
  // Valores: 'criacao', 'whatsapp_mensagem', 'formulario_enviado', 
  //          'formulario_iniciado', 'formulario_concluido', 
  //          'aprovacao', 'reprovacao', 'mudanca_status', 
  //          'atribuicao', 'nota_adicionada', 'tag_adicionada'
  
  descricao: text("descricao"),
  dados: jsonb("dados"),
  // Dados contextuais do evento em JSON
  
  // Quem fez a ação (se aplicável)
  usuarioId: uuid("usuario_id"),
  usuarioNome: text("usuario_nome"),
  
  // Metadados
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
}, (table) => ({
  leadIdIdx: index("idx_historico_lead_id").on(table.leadId, table.createdAt.desc()),
  tipoEventoIdx: index("idx_historico_tipo").on(table.tipoEvento),
}));
```

### 4. Tabela `formulario_links` (NOVA - Links Únicos)

**Propósito:** Gerar links únicos rastreáveis de formulários para cada lead

```typescript
// shared/schema.ts - ADICIONAR

export const formularioLinks = pgTable("formulario_links", {
  id: uuid("id").primaryKey().default(sql`gen_random_uuid()`),
  
  // Relacionamentos
  formId: uuid("form_id").notNull().references(() => forms.id, { onDelete: "cascade" }),
  leadId: uuid("lead_id").references(() => leads.id, { onDelete: "cascade" }),
  
  // Token único para o link
  token: text("token").notNull().unique(),
  // Exemplo: https://seu-app.com/form/abc123def456
  
  // Tracking de Uso
  acessos: integer("acessos").default(0),
  primeiroAcessoEm: timestamp("primeiro_acesso_em", { withTimezone: true }),
  ultimoAcessoEm: timestamp("ultimo_acesso_em", { withTimezone: true }),
  
  // Status
  ativo: boolean("ativo").default(true),
  expiracaoEm: timestamp("expiracao_em", { withTimezone: true }),
  
  // Metadados
  criadoPor: text("criado_por"),
  observacoes: text("observacoes"),
  
  // Timestamps
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
}, (table) => ({
  tokenIdx: index("idx_formulario_links_token").on(table.token),
  leadIdIdx: index("idx_formulario_links_lead").on(table.leadId),
  formIdIdx: index("idx_formulario_links_form").on(table.formId),
}));
```

### 5. View: `leads_dashboard` (NOVA - Para Dashboards)

**Propósito:** Visão consolidada para exibição rápida

```sql
-- Executar direto no PostgreSQL ou criar via migration

CREATE OR REPLACE VIEW leads_dashboard AS
SELECT 
  l.id,
  l.nome,
  l.telefone,
  l.email,
  l.origem,
  l.status_qualificacao,
  l.nivel_qualificacao,
  l.pontuacao,
  l.formulario_enviado,
  l.formulario_iniciado,
  l.formulario_concluido,
  l.whatsapp_id,
  l.ultima_interacao_em,
  l.prioridade,
  l.tags,
  l.created_at,
  
  -- Tempo desde última interação (em horas)
  EXTRACT(EPOCH FROM (NOW() - l.ultima_interacao_em)) / 3600 AS horas_desde_ultima_interacao,
  
  -- Status do formulário em texto
  CASE 
    WHEN l.formulario_concluido THEN 'Concluído'
    WHEN l.formulario_iniciado THEN 'Em Andamento'
    WHEN l.formulario_enviado THEN 'Aguardando Início'
    ELSE 'Sem Formulário'
  END AS status_formulario_texto,
  
  -- Badge de prioridade visual
  CASE 
    WHEN l.nivel_qualificacao = 'hot' THEN '🔥 Hot Lead'
    WHEN l.nivel_qualificacao = 'warm' THEN '☀️ Warm Lead'
    WHEN l.nivel_qualificacao = 'cold' THEN '❄️ Cold Lead'
    ELSE '⏳ Pendente'
  END AS badge_visual,
  
  -- Última submissão
  fs.total_score AS ultima_pontuacao,
  fs.created_at AS data_ultima_submissao,
  
  -- Total de interações no histórico
  (SELECT COUNT(*) FROM lead_historico WHERE lead_id = l.id) AS total_interacoes

FROM leads l
LEFT JOIN LATERAL (
  SELECT total_score, created_at 
  FROM form_submissions 
  WHERE lead_id = l.id 
  ORDER BY created_at DESC 
  LIMIT 1
) fs ON true
WHERE l.deleted_at IS NULL;
```

---

## 📡 NOVAS ROTAS DA API

### Endpoints de Leads

```typescript
// server/routes.ts - ADICIONAR

// ============================================================================
// LEADS MANAGEMENT ROUTES
// ============================================================================

// 1. Criar lead a partir de contato WhatsApp
app.post("/api/leads", async (req, res) => {
  try {
    const { telefone, nome, whatsappId, whatsappInstance } = req.body;
    
    // Normalizar telefone (remover caracteres especiais)
    const telefoneNormalizado = normalizarTelefone(telefone);
    
    // Verificar se lead já existe
    let lead = await storage.getLeadByTelefone(telefoneNormalizado);
    
    if (lead) {
      // Atualizar última interação
      lead = await storage.updateLead(lead.id, {
        ultimaInteracaoEm: new Date(),
        totalMensagens: lead.totalMensagens + 1,
      });
      
      return res.json(lead);
    }
    
    // Criar novo lead
    lead = await storage.createLead({
      telefone,
      telefoneNormalizado,
      nome,
      whatsappId,
      whatsappInstance,
      origem: 'whatsapp',
      primeiraMensagemEm: new Date(),
      ultimaInteracaoEm: new Date(),
      totalMensagens: 1,
    });
    
    // Registrar no histórico
    await storage.createLeadHistorico({
      leadId: lead.id,
      tipoEvento: 'criacao',
      descricao: 'Lead criado a partir de contato WhatsApp',
      dados: { whatsappId, whatsappInstance },
    });
    
    res.status(201).json(lead);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// 2. Buscar lead por telefone
app.get("/api/leads/telefone/:telefone", async (req, res) => {
  try {
    const telefoneNormalizado = normalizarTelefone(req.params.telefone);
    const lead = await storage.getLeadByTelefone(telefoneNormalizado);
    
    if (!lead) {
      return res.status(404).json({ error: "Lead não encontrado" });
    }
    
    res.json(lead);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// 3. Listar todos os leads com filtros
app.get("/api/leads", async (req, res) => {
  try {
    const {
      statusQualificacao,
      nivelQualificacao,
      origem,
      formularioConcluido,
      prioridade,
      limit = 100,
      offset = 0,
    } = req.query;
    
    const leads = await storage.getLeads({
      statusQualificacao: statusQualificacao as string,
      nivelQualificacao: nivelQualificacao as string,
      origem: origem as string,
      formularioConcluido: formularioConcluido === 'true',
      prioridade: prioridade as string,
      limit: parseInt(limit as string),
      offset: parseInt(offset as string),
    });
    
    res.json(leads);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// 4. Atualizar lead
app.patch("/api/leads/:id", async (req, res) => {
  try {
    const lead = await storage.updateLead(req.params.id, req.body);
    
    // Registrar mudanças no histórico
    await storage.createLeadHistorico({
      leadId: lead.id,
      tipoEvento: 'mudanca_status',
      descricao: 'Informações do lead atualizadas',
      dados: req.body,
    });
    
    res.json(lead);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// 5. Gerar link único de formulário para lead
app.post("/api/leads/:id/gerar-link-formulario", async (req, res) => {
  try {
    const { formId, expiracaoDias = 7 } = req.body;
    const leadId = req.params.id;
    
    // Verificar se lead existe
    const lead = await storage.getLeadById(leadId);
    if (!lead) {
      return res.status(404).json({ error: "Lead não encontrado" });
    }
    
    // Gerar token único
    const token = gerarTokenUnico();
    
    // Calcular data de expiração
    const expiracaoEm = new Date();
    expiracaoEm.setDate(expiracaoEm.getDate() + expiracaoDias);
    
    // Criar link
    const link = await storage.createFormularioLink({
      formId,
      leadId,
      token,
      expiracaoEm,
      ativo: true,
    });
    
    // Atualizar lead
    await storage.updateLead(leadId, {
      formularioEnviado: true,
      formularioEnviadoEm: new Date(),
      formularioLinkId: link.id,
      formularioId: formId,
    });
    
    // Registrar no histórico
    await storage.createLeadHistorico({
      leadId,
      tipoEvento: 'formulario_enviado',
      descricao: 'Link do formulário gerado e enviado',
      dados: { formId, token, expiracaoEm },
    });
    
    // Construir URL completa
    const baseUrl = process.env.BASE_URL || `http://localhost:5000`;
    const linkCompleto = `${baseUrl}/form/link/${token}`;
    
    res.json({
      link,
      url: linkCompleto,
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// 6. Acessar formulário via link único
app.get("/api/formulario-links/:token", async (req, res) => {
  try {
    const { token } = req.params;
    
    const link = await storage.getFormularioLinkByToken(token);
    
    if (!link) {
      return res.status(404).json({ error: "Link não encontrado" });
    }
    
    // Verificar se está ativo e não expirado
    if (!link.ativo || (link.expiracaoEm && new Date() > new Date(link.expiracaoEm))) {
      return res.status(410).json({ error: "Link expirado ou inativo" });
    }
    
    // Incrementar contador de acessos
    await storage.updateFormularioLink(link.id, {
      acessos: link.acessos + 1,
      ultimoAcessoEm: new Date(),
      primeiroAcessoEm: link.primeiroAcessoEm || new Date(),
    });
    
    // Se é o primeiro acesso, atualizar lead
    if (!link.primeiroAcessoEm && link.leadId) {
      await storage.updateLead(link.leadId, {
        formularioIniciado: true,
        formularioIniciadoEm: new Date(),
      });
      
      await storage.createLeadHistorico({
        leadId: link.leadId,
        tipoEvento: 'formulario_iniciado',
        descricao: 'Lead iniciou o preenchimento do formulário',
      });
    }
    
    // Buscar o formulário
    const form = await storage.getFormById(link.formId);
    
    res.json({
      link,
      form,
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// 7. Submeter formulário via link (com qualificação automática)
app.post("/api/formulario-links/:token/submit", async (req, res) => {
  try {
    const { token } = req.params;
    const { answers, contactName, contactEmail, contactPhone, tempoPreenchimento } = req.body;
    
    const link = await storage.getFormularioLinkByToken(token);
    
    if (!link) {
      return res.status(404).json({ error: "Link não encontrado" });
    }
    
    // Buscar formulário para calcular pontuação
    const form = await storage.getFormById(link.formId);
    
    if (!form) {
      return res.status(404).json({ error: "Formulário não encontrado" });
    }
    
    // Calcular pontuação
    const { totalScore, passed, pontuacaoDetalhes } = calcularPontuacao(
      form.questions,
      answers
    );
    
    // Criar submission
    const submission = await storage.createFormSubmission({
      formId: form.id,
      leadId: link.leadId,
      answers,
      totalScore,
      passed,
      contactName,
      contactEmail,
      contactPhone,
      pontuacaoDetalhes,
      tempoPreenchimentoSegundos: tempoPreenchimento,
      ipAddress: req.ip,
      userAgent: req.get('User-Agent'),
    });
    
    // Determinar status e nível de qualificação
    const { statusQualificacao, nivelQualificacao } = determinarQualificacao(
      totalScore,
      form.passingScore,
      form.scoreTiers
    );
    
    // Atualizar lead
    if (link.leadId) {
      await storage.updateLead(link.leadId, {
        formularioConcluido: true,
        formularioConcluidoEm: new Date(),
        pontuacao: totalScore,
        statusQualificacao,
        nivelQualificacao,
        nome: contactName || undefined,
        email: contactEmail || undefined,
        tempoPreenchimento: tempoPreenchimento,
      });
      
      // Registrar no histórico
      await storage.createLeadHistorico({
        leadId: link.leadId,
        tipoEvento: statusQualificacao === 'aprovado' ? 'aprovacao' : 'reprovacao',
        descricao: `Formulário concluído - ${statusQualificacao}`,
        dados: {
          pontuacao: totalScore,
          nivelQualificacao,
          submissionId: submission.id,
        },
      });
    }
    
    res.status(201).json({
      submission,
      statusQualificacao,
      nivelQualificacao,
      totalScore,
      passed,
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// 8. Buscar histórico do lead
app.get("/api/leads/:id/historico", async (req, res) => {
  try {
    const historico = await storage.getLeadHistorico(req.params.id);
    res.json(historico);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// 9. Estatísticas de leads
app.get("/api/leads/stats/dashboard", async (req, res) => {
  try {
    const stats = await storage.getLeadsStats();
    res.json(stats);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// 10. Integração WhatsApp - Enviar link de formulário via mensagem
app.post("/api/whatsapp/enviar-formulario", async (req, res) => {
  try {
    const { telefone, formId, mensagemPersonalizada } = req.body;
    
    // Buscar ou criar lead
    const telefoneNormalizado = normalizarTelefone(telefone);
    let lead = await storage.getLeadByTelefone(telefoneNormalizado);
    
    if (!lead) {
      lead = await storage.createLead({
        telefone,
        telefoneNormalizado,
        origem: 'whatsapp',
      });
    }
    
    // Gerar link único
    const token = gerarTokenUnico();
    const expiracaoEm = new Date();
    expiracaoEm.setDate(expiracaoEm.getDate() + 7);
    
    const link = await storage.createFormularioLink({
      formId,
      leadId: lead.id,
      token,
      expiracaoEm,
      ativo: true,
    });
    
    // Construir mensagem
    const baseUrl = process.env.BASE_URL || 'http://localhost:5000';
    const linkCompleto = `${baseUrl}/form/link/${token}`;
    
    const mensagem = mensagemPersonalizada || 
      `Olá! 👋\n\nPara continuar nosso atendimento, por favor preencha este formulário rápido:\n\n${linkCompleto}\n\n✅ Leva apenas 2 minutos\n🔒 Suas informações estão seguras`;
    
    // Enviar via Evolution API
    const config = await storage.getConfiguration('default');
    
    if (!config) {
      return res.status(400).json({ error: "WhatsApp não configurado" });
    }
    
    const resultado = await enviarMensagemWhatsApp({
      apiUrl: config.apiUrlWhatsapp,
      apiKey: config.apiKeyWhatsapp,
      instance: config.instanceWhatsapp,
      numero: telefone,
      mensagem,
    });
    
    // Atualizar lead
    await storage.updateLead(lead.id, {
      formularioEnviado: true,
      formularioEnviadoEm: new Date(),
      formularioLinkId: link.id,
      formularioId: formId,
    });
    
    // Registrar histórico
    await storage.createLeadHistorico({
      leadId: lead.id,
      tipoEvento: 'formulario_enviado',
      descricao: 'Link do formulário enviado via WhatsApp',
      dados: { formId, linkCompleto },
    });
    
    res.json({
      sucesso: true,
      link: linkCompleto,
      lead,
      whatsappResponse: resultado,
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});
```

---

## 🔧 FUNÇÕES UTILITÁRIAS

### utils/phone.ts

```typescript
/**
 * Normaliza número de telefone removendo caracteres especiais
 * e convertendo para formato padrão
 */
export function normalizarTelefone(telefone: string): string {
  // Remove tudo exceto números
  let normalizado = telefone.replace(/\D/g, '');
  
  // Adiciona código do país se não tiver (Brasil = 55)
  if (normalizado.length === 11 && !normalizado.startsWith('55')) {
    normalizado = '55' + normalizado;
  }
  
  return normalizado;
}

/**
 * Formata telefone para exibição
 * Exemplo: 5511999887766 -> +55 (11) 99988-7766
 */
export function formatarTelefone(telefone: string): string {
  const normalizado = normalizarTelefone(telefone);
  
  if (normalizado.length === 13) {
    // Formato: +55 (11) 99988-7766
    const pais = normalizado.slice(0, 2);
    const ddd = normalizado.slice(2, 4);
    const parte1 = normalizado.slice(4, 9);
    const parte2 = normalizado.slice(9, 13);
    
    return `+${pais} (${ddd}) ${parte1}-${parte2}`;
  }
  
  return telefone;
}
```

### utils/scoring.ts

```typescript
/**
 * Calcula pontuação baseada nas respostas do formulário
 */
export function calcularPontuacao(
  questions: any[],
  answers: Record<string, any>
): {
  totalScore: number;
  passed: boolean;
  pontuacaoDetalhes: Record<string, any>;
} {
  let totalScore = 0;
  const pontuacaoDetalhes: Record<string, any> = {};
  
  for (const question of questions) {
    const answer = answers[question.id];
    let pontos = 0;
    
    if (question.type === 'multiple-choice' && question.options) {
      const selectedOption = question.options.find((opt: any) => opt.id === answer);
      pontos = selectedOption?.points || 0;
      
      pontuacaoDetalhes[question.id] = {
        pergunta: question.text,
        resposta: selectedOption?.text,
        pontos,
      };
    } else if (question.type === 'rating') {
      pontos = answer || 0;
      
      pontuacaoDetalhes[question.id] = {
        pergunta: question.text,
        resposta: answer,
        pontos,
      };
    }
    
    totalScore += pontos;
  }
  
  return {
    totalScore,
    passed: totalScore >= (questions[0]?.passingScore || 0),
    pontuacaoDetalhes,
  };
}

/**
 * Determina status e nível de qualificação baseado na pontuação
 */
export function determinarQualificacao(
  pontuacao: number,
  pontuacaoMinima: number,
  scoreTiers?: any
): {
  statusQualificacao: string;
  nivelQualificacao: string;
} {
  // Status básico
  const passed = pontuacao >= pontuacaoMinima;
  const statusQualificacao = passed ? 'aprovado' : 'reprovado';
  
  // Determinar nível (hot/warm/cold)
  let nivelQualificacao = 'cold';
  
  if (scoreTiers && Array.isArray(scoreTiers)) {
    // Encontrar o tier correspondente
    for (const tier of scoreTiers) {
      if (pontuacao >= tier.min && pontuacao <= tier.max) {
        nivelQualificacao = tier.level || tier.name?.toLowerCase();
        break;
      }
    }
  } else {
    // Fallback: calcular baseado em percentual
    const percentual = (pontuacao / 100) * 100;
    
    if (percentual >= 80) nivelQualificacao = 'hot';
    else if (percentual >= 60) nivelQualificacao = 'warm';
    else nivelQualificacao = 'cold';
  }
  
  return {
    statusQualificacao,
    nivelQualificacao,
  };
}

/**
 * Gera token único para links de formulário
 */
export function gerarTokenUnico(): string {
  const crypto = require('crypto');
  return crypto.randomBytes(16).toString('hex');
}
```

### utils/whatsapp.ts

```typescript
import axios from 'axios';

/**
 * Envia mensagem via Evolution API
 */
export async function enviarMensagemWhatsApp({
  apiUrl,
  apiKey,
  instance,
  numero,
  mensagem,
}: {
  apiUrl: string;
  apiKey: string;
  instance: string;
  numero: string;
  mensagem: string;
}) {
  try {
    const response = await axios.post(
      `${apiUrl}/message/sendText/${instance}`,
      {
        number: numero,
        text: mensagem,
      },
      {
        headers: {
          'Content-Type': 'application/json',
          'apikey': apiKey,
        },
      }
    );
    
    return response.data;
  } catch (error: any) {
    console.error('Erro ao enviar mensagem WhatsApp:', error);
    throw new Error(`Falha ao enviar mensagem: ${error.message}`);
  }
}
```

---

## 🎨 COMPONENTES FRONTEND

### LeadStatusBadge.tsx

```typescript
import { Badge } from "@/components/ui/badge";
import { CheckCircle, XCircle, Clock, Flame, Sun, Snowflake } from "lucide-react";

interface LeadStatusBadgeProps {
  statusQualificacao?: string;
  nivelQualificacao?: string;
  pontuacao?: number;
}

export function LeadStatusBadge({ 
  statusQualificacao, 
  nivelQualificacao, 
  pontuacao 
}: LeadStatusBadgeProps) {
  // Badge de nível (hot/warm/cold)
  if (nivelQualificacao) {
    const nivelConfig = {
      hot: {
        icon: Flame,
        label: 'Hot Lead',
        variant: 'destructive' as const,
        className: 'bg-red-500 text-white',
      },
      warm: {
        icon: Sun,
        label: 'Warm Lead',
        variant: 'default' as const,
        className: 'bg-orange-500 text-white',
      },
      cold: {
        icon: Snowflake,
        label: 'Cold Lead',
        variant: 'secondary' as const,
        className: 'bg-blue-500 text-white',
      },
    };
    
    const config = nivelConfig[nivelQualificacao as keyof typeof nivelConfig];
    
    if (config) {
      const Icon = config.icon;
      return (
        <Badge className={config.className}>
          <Icon className="w-3 h-3 mr-1" />
          {config.label}
          {pontuacao !== undefined && ` (${pontuacao})`}
        </Badge>
      );
    }
  }
  
  // Badge de status (aprovado/reprovado/pendente)
  const statusConfig = {
    aprovado: {
      icon: CheckCircle,
      label: 'Aprovado',
      variant: 'default' as const,
      className: 'bg-green-500 text-white',
    },
    reprovado: {
      icon: XCircle,
      label: 'Reprovado',
      variant: 'destructive' as const,
      className: 'bg-red-500 text-white',
    },
    pendente: {
      icon: Clock,
      label: 'Pendente',
      variant: 'secondary' as const,
      className: 'bg-gray-500 text-white',
    },
  };
  
  const config = statusConfig[statusQualificacao as keyof typeof statusConfig] || statusConfig.pendente;
  const Icon = config.icon;
  
  return (
    <Badge className={config.className}>
      <Icon className="w-3 h-3 mr-1" />
      {config.label}
    </Badge>
  );
}
```

### WhatsAppChatWithLeadInfo.tsx

```typescript
import { useState, useEffect } from 'react';
import { useQuery } from '@tanstack/react-query';
import { LeadStatusBadge } from './LeadStatusBadge';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Send } from 'lucide-react';

interface Lead {
  id: string;
  nome?: string;
  telefone: string;
  statusQualificacao?: string;
  nivelQualificacao?: string;
  pontuacao?: number;
  formularioEnviado: boolean;
  formularioConcluido: boolean;
}

interface WhatsAppChatWithLeadInfoProps {
  telefone: string;
}

export function WhatsAppChatWithLeadInfo({ telefone }: WhatsAppChatWithLeadInfoProps) {
  const [formularioSelecionado, setFormularioSelecionado] = useState('');
  
  // Buscar informações do lead
  const { data: lead, isLoading } = useQuery<Lead>({
    queryKey: ['lead', telefone],
    queryFn: async () => {
      const response = await fetch(`/api/leads/telefone/${telefone}`);
      if (!response.ok) return null;
      return response.json();
    },
    enabled: !!telefone,
  });
  
  const handleEnviarFormulario = async () => {
    if (!formularioSelecionado) return;
    
    try {
      const response = await fetch('/api/whatsapp/enviar-formulario', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          telefone,
          formId: formularioSelecionado,
        }),
      });
      
      if (response.ok) {
        alert('Formulário enviado com sucesso!');
      }
    } catch (error) {
      console.error('Erro ao enviar formulário:', error);
    }
  };
  
  return (
    <div className="flex flex-col h-full">
      {/* Header com informações do lead */}
      {lead && (
        <Card className="p-4 mb-4 bg-gradient-to-r from-purple-50 to-blue-50">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="font-semibold">{lead.nome || 'Lead sem nome'}</h3>
              <p className="text-sm text-gray-600">{lead.telefone}</p>
            </div>
            
            <div className="flex flex-col gap-2 items-end">
              <LeadStatusBadge
                statusQualificacao={lead.statusQualificacao}
                nivelQualificacao={lead.nivelQualificacao}
                pontuacao={lead.pontuacao}
              />
              
              {lead.formularioConcluido && (
                <span className="text-xs text-green-600">
                  ✓ Formulário Concluído
                </span>
              )}
              
              {lead.formularioEnviado && !lead.formularioConcluido && (
                <span className="text-xs text-orange-600">
                  ⏳ Aguardando Preenchimento
                </span>
              )}
            </div>
          </div>
          
          {/* Ação rápida: Enviar formulário */}
          {!lead.formularioEnviado && (
            <div className="mt-4 flex gap-2">
              <select
                className="flex-1 px-3 py-2 border rounded"
                value={formularioSelecionado}
                onChange={(e) => setFormularioSelecionado(e.target.value)}
              >
                <option value="">Selecione um formulário</option>
                {/* Carregar formulários disponíveis */}
              </select>
              
              <Button onClick={handleEnviarFormulario} size="sm">
                <Send className="w-4 h-4 mr-2" />
                Enviar Formulário
              </Button>
            </div>
          )}
        </Card>
      )}
      
      {/* Resto do chat */}
      {/* ... */}
    </div>
  );
}
```

---

## 📊 FLUXO COMPLETO DE INTEGRAÇÃO

### Cenário 1: Lead Vindo do WhatsApp

```
1. Cliente envia mensagem no WhatsApp
   ↓
2. Sistema cria/atualiza lead na tabela `leads`
   - telefoneNormalizado para identificação única
   - origem: 'whatsapp'
   ↓
3. Atendente visualiza no dashboard WhatsApp
   - Vê se lead já tem qualificação
   - Badge visual mostra status
   ↓
4. Atendente envia link de formulário
   - Sistema gera token único
   - Cria registro em `formulario_links`
   - Atualiza lead: formularioEnviado = true
   ↓
5. Cliente acessa link e inicia formulário
   - Sistema registra: formularioIniciado = true
   - Tracking de primeira interação
   ↓
6. Cliente completa formulário
   - Cria `form_submission` vinculada ao lead
   - Calcula pontuação automaticamente
   - Determina status: aprovado/reprovado
   - Determina nível: hot/warm/cold
   - Atualiza lead com todas informações
   ↓
7. Atendente vê atualização em tempo real
   - Badge muda para status qualificado
   - Pode ver detalhes da pontuação
   - Histórico completo disponível
   ↓
8. Follow-up personalizado
   - Mensagens diferentes para hot/warm/cold
   - Automação baseada em score
```

### Cenário 2: Lead Direto do Formulário

```
1. Cliente acessa formulário direto (sem WhatsApp)
   ↓
2. Preenche e submete formulário
   ↓
3. Sistema cria lead automaticamente
   - telefone do formulário normalizado
   - origem: 'formulario'
   - Já qualificado na criação
   ↓
4. Se cliente depois entrar em contato via WhatsApp
   - Sistema identifica pelo telefone
   - Merge de informações
   - Histórico preservado
```

---

## 🚀 PLANO DE IMPLEMENTAÇÃO

### Fase 1: Database (1-2 dias)

1. ✅ Criar tabelas novas:
   - `leads`
   - `lead_historico`
   - `formulario_links`

2. ✅ Atualizar tabela existente:
   - `form_submissions` (adicionar leadId)

3. ✅ Criar views e índices

4. ✅ Executar migration:
   ```bash
   npm run db:push
   ```

### Fase 2: Backend (2-3 dias)

1. ✅ Criar funções utilitárias:
   - `utils/phone.ts`
   - `utils/scoring.ts`
   - `utils/whatsapp.ts`

2. ✅ Adicionar métodos no storage:
   - CRUD de leads
   - CRUD de histórico
   - CRUD de formulário links

3. ✅ Implementar rotas da API:
   - 10 novos endpoints para leads
   - Integração com WhatsApp

### Fase 3: Frontend (3-4 dias)

1. ✅ Criar componentes:
   - `LeadStatusBadge`
   - `WhatsAppChatWithLeadInfo`
   - `LeadDashboard`
   - `LeadTimeline`

2. ✅ Integrar com WhatsApp Dashboard:
   - Mostrar badges nas conversas
   - Botão de enviar formulário
   - View de detalhes do lead

3. ✅ Criar página de gerenciamento de leads:
   - Lista com filtros
   - Detalhes individuais
   - Histórico de interações

### Fase 4: Testes e Ajustes (1-2 dias)

1. ✅ Testar fluxo completo
2. ✅ Validar cálculos de pontuação
3. ✅ Verificar performance
4. ✅ Ajustar UX

---

## 📈 MÉTRICAS E KPIs

### Dashboard de Leads

```typescript
interface LeadsMetrics {
  totalLeads: number;
  
  // Por Status
  aprovados: number;
  reprovados: number;
  pendentes: number;
  
  // Por Nível
  hotLeads: number;
  warmLeads: number;
  coldLeads: number;
  
  // Conversão
  taxaConversaoFormulario: number; // % que completaram formulário
  taxaAprovacao: number; // % de aprovados entre os que completaram
  
  // Tempo Médio
  tempoMedioResposta: number; // segundos entre envio e início
  tempoMedioPreenchimento: number; // segundos para completar
  
  // Engagement
  leadsCom mensagensHoje: number;
  leadsInativos7Dias: number;
}
```

---

## 🎯 PRÓXIMOS PASSOS E MELHORIAS FUTURAS

1. **Automação de Follow-up**
   - Mensagens automáticas baseadas em score
   - Lembretes para leads que não completaram formulário

2. **Segmentação Avançada**
   - Tags automáticas baseadas em respostas
   - Criação de públicos para campanhas

3. **Relatórios**
   - Exportação de leads qualificados
   - Análise de desempenho de formulários

4. **Integração CRM**
   - Exportar leads aprovados para CRM externo
   - Webhook para notificações

5. **IA e Machine Learning**
   - Previsão de conversão
   - Sugestão de mensagens personalizadas

---

**Desenvolvido com ❤️ para potencializar vendas**

