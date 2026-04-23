-- Create profiles table to store user information
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  name text not null,
  avatar_url text,
  interests text[] default '{}',
  latitude double precision,
  longitude double precision,
  city text,
  country text,
  updated_at timestamp with time zone default now()
);

-- Index for id lookup
create index if not exists profiles_id_idx on public.profiles (id);

-- Enable RLS
alter table public.profiles enable row level security;

-- Policies
create policy "Public profiles are viewable by everyone" 
  on public.profiles 
  for select 
  using (true);

create policy "Users can insert their own profile" 
  on public.profiles 
  for insert 
  with check (auth.uid() = id);

create policy "Users can update their own profile" 
  on public.profiles 
  for update 
  using (auth.uid() = id);

-- Function to handle profile creation on signup
create or replace function public.handle_new_user() 
returns trigger as $$
begin
  insert into public.profiles (id, name, avatar_url)
  values (new.id, coalesce(new.raw_user_meta_data->>'name', 'User'), null);
  return new;
end;
$$ language plpgsql security definer;

-- Trigger for new user
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
