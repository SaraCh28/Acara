-- Create cached_events table for event aggregator caching
create table if not exists public.cached_events (
  id uuid default gen_random_uuid() primary key,
  city text not null,
  country text not null,
  keyword text,
  data jsonb not null,
  created_at timestamp with time zone default now()
);

-- Index for searching cached results
create index if not exists cached_events_lookup_idx on public.cached_events (city, country, keyword);

-- Optional: RLS Policy (Enable for authenticated users if needed, or keep internal for Edge Function)
alter table public.cached_events enable row level security;

-- Policy: Allow specific roles (like service role) to manage this
create policy "Allow service role to manage cached events" 
  on public.cached_events 
  for all 
  using (true) 
  with check (true);
