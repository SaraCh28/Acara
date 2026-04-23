-- Create local_events table for manually added events
create table if not exists public.local_events (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  description text,
  category text not null default 'General',
  date date not null,
  start_time time with time zone default '12:00:00+00',
  end_time time with time zone default '14:00:00+00',
  venue text not null,
  city text not null,
  country text not null default 'PK',
  latitude float8 not null,
  longitude float8 not null,
  price float8 not null default 0,
  image_url text,
  organizer_name text not null default 'Local Organizer',
  attendee_count int default 0,
  created_at timestamp with time zone default now()
);

-- Index for searching local events
create index if not exists local_events_location_idx on public.local_events (city, country);

-- RLS Policies
alter table public.local_events enable row level security;

create policy "Allow public read access to local events"
  on public.local_events
  for select
  using (true);

-- Populate with some sample Pakistani events
insert into public.local_events (
  title, description, category, date, venue, city, country, latitude, longitude, price, image_url, organizer_name
) values 
('Lahore Food Festival 2026', 'A massive celebration of Lahori cuisine with 100+ stalls, live music, and family fun.', 'Food & Drink', '2026-05-15', 'Jillani Park (Race Course)', 'Lahore', 'PK', 31.5414, 74.3364, 500, 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?q=80&w=1000', '7Up & Foodies'),
('FAST University Tech Week', 'Annual developer conference featuring hackathons, workshops, and recruitment stalls.', 'Technology', '2026-04-28', 'FAST-NUCES Lahore Campus', 'Lahore', 'PK', 31.4815, 74.3030, 0, 'https://images.unsplash.com/photo-1540575861501-7ad05823c9f5?q=80&w=1000', 'FAST ACM Student Chapter'),
('Karachi Music Fest', 'A night under the stars featuring the biggest names in Pakistani pop and rock music.', 'Music', '2026-06-10', 'Beach Luxury Hotel', 'Karachi', 'PK', 24.8402, 66.9984, 2500, 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?q=80&w=1000', 'Activemedia'),
('Islamabad Literature Festival', 'Celebrating the rich literary heritage of Pakistan with book launches and talks.', 'Education', '2026-05-20', 'Lok Virsa Museum', 'Islamabad', 'PK', 33.6934, 73.0673, 0, 'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?q=80&w=1000', 'Oxford University Press'),
('NUST Entrepreneurship Summit', 'Empowering the next generation of Pakistani innovators and startups.', 'Business', '2026-04-30', 'NUST H-12 Campus', 'Islamabad', 'PK', 33.6425, 72.9930, 200, 'https://images.unsplash.com/photo-1515187029135-18ee286d815b?q=80&w=1000', 'NUST CINE'),
('LUMS Music Festival', 'The biggest inter-university music competition in Lahore.', 'Music', '2026-05-02', 'LUMS Campus', 'Lahore', 'PK', 31.4704, 74.4098, 1000, 'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?q=80&w=1000', 'LUMS Music Society');
