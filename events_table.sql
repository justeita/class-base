-- Tabel Events
create table if not exists public.events (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  description text,
  event_date date not null,
  event_type text default 'GENERAL', -- 'ACADEMIC', 'HOLIDAY', 'SPORTS', 'GENERAL'
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Berikan akses
grant all on table public.events to anon, authenticated, service_role;

-- Policy
alter table public.events enable row level security;

create policy "Public Access Events" 
on public.events 
for all 
to anon, authenticated, service_role 
using ( true ) 
with check ( true );

-- Seed Data
insert into public.events (title, description, event_date, event_type) values
('School Anniversary', 'Celebration of the 50th anniversary.', '2025-11-28', 'GENERAL'),
('Final Exams', 'Mathematics and Physics exams.', '2025-12-01', 'ACADEMIC'),
('Class Meeting', 'Sports competition between classes.', '2025-12-15', 'SPORTS'),
('Winter Break', 'School holiday for end of semester.', '2025-12-20', 'HOLIDAY');
