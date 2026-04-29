-- Ensure country_code exists
do $$
begin
  if not exists (select 1 from information_schema.columns where table_name='profiles' and column_name='country_code') then
    alter table public.profiles add column country_code text;
  end if;
end $$;

-- Add created_at column if not exists
alter table public.profiles add column if not exists created_at timestamp with time zone default now();

-- Ensure updated_at exists
do $$
begin
  if not exists (select 1 from information_schema.columns where table_name='profiles' and column_name='updated_at') then
    alter table public.profiles add column updated_at timestamp with time zone default now();
  end if;
end $$;

-- Notify PostgREST to reload schema cache
notify pgrst, 'reload schema';

-- Update the handle_new_user function to be more robust
create or replace function public.handle_new_user() 
returns trigger as $$
begin
  insert into public.profiles (id, name, avatar_url, created_at, updated_at)
  values (
    new.id, 
    coalesce(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1), 'User'), 
    'assets/avatars/avatar_0.png',
    now(),
    now()
  )
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer set search_path = public;

-- Ensure trigger for updated_at
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists set_profiles_updated_at on public.profiles;
create trigger set_profiles_updated_at
  before update on public.profiles
  for each row execute procedure public.set_updated_at();

-- Ensure trigger for new user
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
