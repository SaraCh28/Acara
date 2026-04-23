-- Create bookings table to store user ticket purchases
create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade not null,
  event_id text not null,
  ticket_count integer not null default 1,
  regular_ticket_count integer not null default 0,
  vip_ticket_count integer not null default 0,
  total_price double precision not null,
  payment_method_id text not null,
  ticket_code text not null unique,
  status text not null default 'confirmed', -- confirmed, cancelled, used
  booker_name text not null,
  booker_email text not null,
  booker_phone text not null,
  created_at timestamp with time zone default now()
);

-- Index for user_id lookup
create index if not exists bookings_user_id_idx on public.bookings (user_id);

-- Enable RLS
alter table public.bookings enable row level security;

-- Policies
create policy "Users can view their own bookings" 
  on public.bookings 
  for select 
  using (auth.uid() = user_id);

create policy "Users can insert their own bookings" 
  on public.bookings 
  for insert 
  with check (auth.uid() = user_id);

-- Update profiles table to include country_code
do $$
begin
  if not exists (select 1 from information_schema.columns where table_name='profiles' and column_name='country_code') then
    alter table public.profiles add column country_code text;
  end if;
end $$;
