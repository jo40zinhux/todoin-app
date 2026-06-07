-- Remove tabela legada app_sync (RLS aberto para anon — não usar em produção).

drop policy if exists "anon_all_app_sync" on public.app_sync;
drop table if exists public.app_sync;
