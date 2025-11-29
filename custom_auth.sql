-- Tabel khusus untuk Custom Auth (Username & Password Hash)
-- Ini menggantikan penggunaan Supabase Auth bawaan.

create table if not exists public.app_users (
  id uuid default gen_random_uuid() primary key,
  username text unique not null,
  password text not null, -- Akan menyimpan password yang sudah di-hash (SHA256)
  role text not null check (role in ('admin', 'secretary', 'user')) default 'user',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- BERIKAN AKSES EKSPLISIT KE ROLE ANON (PENTING UNTUK MENGATASI ERROR 42501)
grant usage on schema public to anon, authenticated, service_role;
grant all on table public.app_users to anon, authenticated, service_role;

-- Matikan RLS atau buat policy terbuka karena kita tidak pakai token Supabase Auth lagi
alter table public.app_users enable row level security;

-- Hapus policy lama jika ada
drop policy if exists "Public Access" on public.app_users;

-- Buat policy yang mengizinkan aplikasi (anon key) untuk membaca dan menulis
-- PERINGATAN: Ini berarti siapa saja dengan Anon Key bisa membaca tabel ini.
-- Dalam production, ini SANGAT TIDAK AMAN. Tapi untuk prototype sekolah ini oke.
create policy "Public Access" 
on public.app_users 
for all 
to anon, authenticated, service_role 
using ( true ) 
with check ( true );

-- Masukkan satu user Admin default (Password: admin123)
-- Hash SHA256 dari 'admin123' adalah: 240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9
insert into public.app_users (username, password, role)
values ('admin', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'admin')
on conflict (username) do nothing;


-- ============================================================
-- CLEANUP (OPSIONAL): Hapus tabel dan trigger lama jika ingin bersih-bersih
-- Jalankan bagian ini HANYA jika Anda yakin ingin menghapus data lama (profiles)
-- ============================================================

-- Drop trigger lama yang otomatis membuat profile saat user signup lewat Supabase Auth
drop trigger if exists on_auth_user_created on auth.users;
drop function if exists public.handle_new_user();

-- Drop tabel profiles lama (gunakan CASCADE agar policy terkait ikut terhapus)
drop table if exists public.profiles cascade;

-- Pulihkan akses ke tabel tasks (karena policy lamanya terhapus)
-- Kita buat policy terbuka agar tasks bisa diakses oleh sistem auth baru
drop policy if exists "Public Access Tasks" on public.tasks;
create policy "Public Access Tasks" 
on public.tasks 
for all 
to anon, authenticated, service_role 
using ( true ) 
with check ( true );
