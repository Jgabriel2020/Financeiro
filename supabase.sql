-- ============================================================
--  FINANCEIROPRO · SQL de Configuração do Supabase
--  Execute este script no SQL Editor do seu projeto Supabase
-- ============================================================

-- 1. TABELA DE SOLICITAÇÕES DE PAGAMENTO
CREATE TABLE public.payment_requests (
  id            UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
  protocol      TEXT        UNIQUE,
  pix_key       TEXT        NOT NULL,
  value         NUMERIC(10,2) NOT NULL,
  name          TEXT        NOT NULL,
  reason        TEXT        NOT NULL,
  city          TEXT        NOT NULL,
  status        TEXT        DEFAULT 'pendente'
                            CHECK (status IN ('pendente','em_analise','pago','rejeitado')),
  payment_type  TEXT        CHECK (payment_type IN ('Pagamento','Operacional','Mão de Obra')),
  proof_url     TEXT,
  admin_notes   TEXT,
  responded_at  TIMESTAMPTZ,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- 2. TABELA DE APORTES DE OBRAS
CREATE TABLE public.work_contributions (
  id              UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
  work_name       TEXT        NOT NULL,
  description     TEXT,
  amount          NUMERIC(10,2),
  attachment_url  TEXT,
  attachment_name TEXT,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 3. TRIGGER: atualiza updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_payment_requests_updated_at
  BEFORE UPDATE ON public.payment_requests
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- 4. ROW LEVEL SECURITY
ALTER TABLE public.payment_requests  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.work_contributions ENABLE ROW LEVEL SECURITY;

-- Qualquer pessoa (anon) pode INSERIR uma solicitação (formulário público)
CREATE POLICY "anon_insert_payment_requests"
  ON public.payment_requests
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- Usuário autenticado (admin) tem acesso total às solicitações
CREATE POLICY "admin_all_payment_requests"
  ON public.payment_requests
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Apenas admin acessa aportes de obras
CREATE POLICY "admin_all_work_contributions"
  ON public.work_contributions
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- 5. BUCKETS DE STORAGE
INSERT INTO storage.buckets (id, name, public)
VALUES ('comprovantes', 'comprovantes', true)
ON CONFLICT DO NOTHING;

INSERT INTO storage.buckets (id, name, public)
VALUES ('aportes', 'aportes', true)
ON CONFLICT DO NOTHING;

-- Policies de storage: admin faz upload, público lê
CREATE POLICY "admin_upload_comprovantes"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'comprovantes');

CREATE POLICY "public_read_comprovantes"
  ON storage.objects FOR SELECT
  TO anon
  USING (bucket_id = 'comprovantes');

CREATE POLICY "admin_read_comprovantes"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (bucket_id = 'comprovantes');

CREATE POLICY "admin_all_aportes"
  ON storage.objects FOR ALL
  TO authenticated
  USING (bucket_id = 'aportes')
  WITH CHECK (bucket_id = 'aportes');

-- ============================================================
--  APÓS EXECUTAR O SQL:
--
--  1. Acesse Authentication > Users no painel do Supabase
--  2. Clique em "Add user" e crie o usuário admin com e-mail e senha
--  3. Copie a Project URL e a anon public key em Settings > API
--  4. Cole os valores no arquivo  js/config.js  do projeto
-- ============================================================
