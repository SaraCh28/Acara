-- Force PostgREST to reload its schema cache.
-- This resolves PGRST204 errors ("column not found in schema cache")
-- that occur after adding new columns (e.g. country_code) to the profiles table.
NOTIFY pgrst, 'reload schema';
