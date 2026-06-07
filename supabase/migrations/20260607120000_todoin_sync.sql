-- toDoin Cloud Sync — produção (app_sync_v2) + fallback MVP (app_sync)

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

create table if not exists public.app_sync (
  device_id text primary key,
  payload jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.app_sync enable row level security;

drop policy if exists "anon_all_app_sync" on public.app_sync;

create policy "anon_all_app_sync"
  on public.app_sync
  for all
  to anon
  using (true)
  with check (true);

create index if not exists app_sync_updated_at_idx
  on public.app_sync (updated_at desc);
