-- À exécuter dans l'éditeur SQL du projet Supabase avant activation des comptes.
-- RLS : chaque utilisateur n'accède qu'à ses propres données.
create table if not exists public.private_sheets (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  subject text not null,
  level text,
  topic text,
  summary text,
  body text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.user_progress (
  owner_id uuid primary key references auth.users(id) on delete cascade,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table public.private_sheets enable row level security;
alter table public.user_progress enable row level security;
drop policy if exists "own private sheets" on public.private_sheets;
create policy "own private sheets" on public.private_sheets for all to authenticated
  using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);
drop policy if exists "own progress" on public.user_progress;
create policy "own progress" on public.user_progress for all to authenticated
  using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);
create index if not exists private_sheets_owner_idx on public.private_sheets(owner_id);
