-- Tabel Tasks
create table if not exists public.tasks (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  description text,
  deadline timestamp with time zone,
  is_completed boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Berikan akses
grant all on table public.tasks to anon, authenticated, service_role;

-- Policy
alter table public.tasks enable row level security;

create policy "Public Access Tasks" 
on public.tasks 
for all 
to anon, authenticated, service_role 
using ( true ) 
with check ( true );
