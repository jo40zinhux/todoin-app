-- toDoin Cloud Sync (Supabase)
-- Execute no SQL Editor do projeto Supabase.

-- ═══════════════════════════════════════════════════════════════
-- PRODUÇÃO — sync com Auth anônimo + RLS por usuário
-- Pré-requisito: Authentication → Providers → habilitar "Anonymous Sign-ins"
-- ═══════════════════════════════════════════════════════════════

create table if not exists public.app_sync_v2 (
  user_id uuid not null references auth.users (id) on delete cascade,
  device_id text not null,
  payload jsonb not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, device_id)
);

alter table public.app_sync_v2 enable row level security;

drop policy if exists "users_own_app_sync_v2" on public.app_sync_v2;

create policy "users_own_app_sync_v2"
  on public.app_sync_v2
  for all
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create index if not exists app_sync_v2_updated_at_idx
  on public.app_sync_v2 (updated_at desc);

-- Tabela legada app_sync removida — ver migration 20260608120000_drop_legacy_app_sync.sql
