-- Create bookmarks table for saved events
create table if not exists public.bookmarks (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  event_id text not null,
  created_at timestamp with time zone default now(),
  unique(user_id, event_id)
);

-- Index for lookup by user
create index if not exists bookmarks_user_idx on public.bookmarks (user_id);

-- Enable RLS
alter table public.bookmarks enable row level security;

-- Policies
create policy "Users can view their own bookmarks" 
  on public.bookmarks 
  for select 
  using (auth.uid() = user_id);

create policy "Users can insert their own bookmarks" 
  on public.bookmarks 
  for insert 
  with check (auth.uid() = user_id);

create policy "Users can delete their own bookmarks" 
  on public.bookmarks 
  for delete 
  using (auth.uid() = user_id);
