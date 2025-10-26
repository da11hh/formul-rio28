-- ========================================
-- SQL PARA CRIAR TABELAS NO SUPABASE
-- ========================================
-- Execute este script no SQL Editor do seu projeto Supabase
-- Dashboard → SQL Editor → New Query → Cole e Execute
-- ========================================

-- 1. Criar tabela de formulários
CREATE TABLE IF NOT EXISTS public.forms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  questions JSONB NOT NULL,
  passing_score INTEGER NOT NULL DEFAULT 0,
  score_tiers JSONB,
  design_config JSONB DEFAULT '{
    "colors": {
      "primary": "hsl(221, 83%, 53%)",
      "secondary": "hsl(210, 40%, 96%)",
      "background": "hsl(0, 0%, 100%)",
      "text": "hsl(222, 47%, 11%)"
    },
    "typography": {
      "fontFamily": "Inter",
      "titleSize": "2xl",
      "textSize": "base"
    },
    "logo": null,
    "spacing": "comfortable"
  }'::JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Criar tabela de submissões de formulários
CREATE TABLE IF NOT EXISTS public.form_submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  form_id UUID NOT NULL REFERENCES public.forms(id) ON DELETE CASCADE,
  answers JSONB NOT NULL,
  total_score INTEGER NOT NULL,
  passed BOOLEAN NOT NULL,
  contact_name TEXT,
  contact_email TEXT,
  contact_phone TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Criar tabela de templates de formulários
CREATE TABLE IF NOT EXISTS public.form_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  questions JSONB NOT NULL,
  design_config JSONB NOT NULL,
  thumbnail_url TEXT,
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_forms_created_at ON public.forms (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_submissions_form_id ON public.form_submissions (form_id);
CREATE INDEX IF NOT EXISTS idx_submissions_created_at ON public.form_submissions (created_at DESC);

-- 5. Habilitar RLS (Row Level Security)
ALTER TABLE public.forms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.form_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.form_templates ENABLE ROW LEVEL SECURITY;

-- 6. Criar políticas de acesso público
-- IMPORTANTE: Estas políticas permitem acesso total. 
-- Em produção, configure políticas mais restritivas conforme suas necessidades.

-- Remover políticas antigas se existirem
DROP POLICY IF EXISTS "forms_public_access" ON public.forms;
DROP POLICY IF EXISTS "submissions_public_access" ON public.form_submissions;
DROP POLICY IF EXISTS "templates_public_access" ON public.form_templates;

-- Criar novas políticas
CREATE POLICY "forms_public_access" 
  ON public.forms 
  FOR ALL 
  USING (true);

CREATE POLICY "submissions_public_access" 
  ON public.form_submissions 
  FOR ALL 
  USING (true);

CREATE POLICY "templates_public_access" 
  ON public.form_templates 
  FOR ALL 
  USING (true);

-- ========================================
-- TEMPLATES PADRÃO (OPCIONAL)
-- ========================================
-- Inserir templates de exemplo

INSERT INTO public.form_templates (name, description, design_config, questions, is_default)
VALUES 
(
  'Template Moderno Azul',
  'Design profissional com tons de azul',
  '{
    "colors": {
      "primary": "hsl(221, 83%, 53%)",
      "secondary": "hsl(210, 40%, 96%)",
      "background": "hsl(0, 0%, 100%)",
      "text": "hsl(222, 47%, 11%)"
    },
    "typography": {
      "fontFamily": "Inter",
      "titleSize": "2xl",
      "textSize": "base"
    },
    "spacing": "comfortable"
  }'::JSONB,
  '[
    {
      "id": "q1",
      "type": "text",
      "text": "Qual é o nome da sua empresa?",
      "required": true,
      "points": 0
    },
    {
      "id": "q2",
      "type": "email",
      "text": "Qual é o seu e-mail de contato?",
      "required": true,
      "points": 0
    }
  ]'::JSONB,
  true
)
ON CONFLICT DO NOTHING;

-- ========================================
-- VERIFICAÇÃO
-- ========================================
-- Execute estas queries para verificar se tudo foi criado:

-- Ver tabelas criadas
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('forms', 'form_submissions', 'form_templates')
ORDER BY table_name;

-- Ver políticas criadas
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename IN ('forms', 'form_submissions', 'form_templates');

-- Contar registros
SELECT 
  (SELECT COUNT(*) FROM public.forms) as total_forms,
  (SELECT COUNT(*) FROM public.form_submissions) as total_submissions,
  (SELECT COUNT(*) FROM public.form_templates) as total_templates;

-- ========================================
-- CONCLUÍDO!
-- ========================================
-- Agora volte para a aplicação e configure:
-- 1. Vá em Configurações
-- 2. Cole sua URL do Supabase (Settings → API → Project URL)
-- 3. Cole sua Chave Anônima (Settings → API → anon public key)
-- 4. Clique em "Testar Conexão"
-- 5. Clique em "Salvar Configurações"
-- ========================================
