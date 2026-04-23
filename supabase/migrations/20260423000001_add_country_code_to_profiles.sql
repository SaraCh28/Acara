-- Add country_code to profiles table
alter table public.profiles add column if not exists country_code text;
