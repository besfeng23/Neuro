-- Visual Graph OS / Neuro Supabase schema reference
-- Apply this in the Neuro Supabase project if rebuilding from scratch.

create extension if not exists pgcrypto;

create table if not exists public.maps (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  title text not null default 'Untitled Map',
  status text not null default 'Idea',
  target_name text,
  context text,
  score_percent integer not null default 0,
  red_flags jsonb not null default '[]'::jsonb,
  current_data jsonb not null default '{}'::jsonb,
  archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.map_versions (
  id uuid primary key default gen_random_uuid(),
  map_id uuid not null references public.maps(id) on delete cascade,
  user_id uuid not null,
  snapshot jsonb not null,
  score_percent integer,
  red_flags jsonb not null default '[]'::jsonb,
  change_type text not null default 'manual_save',
  note text,
  created_at timestamptz not null default now()
);

create table if not exists public.prediction_reviews (
  id uuid primary key default gen_random_uuid(),
  map_id uuid not null references public.maps(id) on delete cascade,
  user_id uuid not null,
  prediction text,
  confidence integer,
  prove_right text,
  prove_wrong text,
  actual_outcome text,
  accuracy_score integer,
  lesson text,
  reviewed_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create table if not exists public.daily_reps (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  rep_date date not null,
  map_id uuid references public.maps(id) on delete set null,
  target text,
  real_power text,
  real_money text,
  real_pain text,
  real_blocker text,
  evidence text,
  assumption text,
  next_move text,
  knife text,
  completed boolean not null default true,
  created_at timestamptz not null default now(),
  unique(user_id, rep_date)
);

create table if not exists public.vgos_activity_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  map_id uuid references public.maps(id) on delete set null,
  action text not null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.maps enable row level security;
alter table public.map_versions enable row level security;
alter table public.prediction_reviews enable row level security;
alter table public.daily_reps enable row level security;
alter table public.vgos_activity_log enable row level security;

create policy "maps owner access" on public.maps for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "map versions owner access" on public.map_versions for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "prediction reviews owner access" on public.prediction_reviews for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "daily reps owner access" on public.daily_reps for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "vgos activity log owner access" on public.vgos_activity_log for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
