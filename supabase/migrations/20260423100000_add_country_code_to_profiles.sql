-- Addition of country_code column to profiles table
alter table public.profiles 
add column if not exists country_code text;

-- Add a comment to confirm column name
comment on column public.profiles.country_code is 'ISO country code for the user location (e.g., PK, US)';
