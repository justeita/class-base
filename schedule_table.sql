-- Tabel Jadwal Pelajaran
drop table if exists public.schedules;
create table public.schedules (
  id uuid default gen_random_uuid() primary key,
  day text not null, -- 'SENIN', 'SELASA', 'RABU', 'KAMIS', 'JUMAT', 'SABTU'
  subject text not null,
  start_time text not null, -- Format 'HH:MM'
  end_time text not null,   -- Format 'HH:MM'
  teacher text not null,
  week_type text default 'ALL' check (week_type in ('ALL', 'ODD', 'EVEN')), -- 'ALL', 'ODD' (Ganjil), 'EVEN' (Genap)
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Berikan akses ke anon (karena kita pakai custom auth)
grant all on table public.schedules to anon, authenticated, service_role;

-- Policy terbuka (seperti app_users)
alter table public.schedules enable row level security;

create policy "Public Access Schedules" 
on public.schedules 
for all 
to anon, authenticated, service_role 
using ( true ) 
with check ( true );

-- Seed Data
insert into public.schedules (day, subject, start_time, end_time, teacher, week_type) values
-- SENIN (ALL)
('SENIN', 'Sholat Dhuha, Tartil, Asmaul Husna', '07:00', '07:30', '-', 'ALL'),
('SENIN', 'Sejarah Indonesia', '07:30', '08:50', 'Ade Sa''diyah, S.Pd.', 'ALL'),
('SENIN', 'Istirahat', '08:50', '09:05', '-', 'ALL'),
('SENIN', 'Bhs. Indonesia', '09:05', '09:45', 'Syuhadak, S.Pd., M.Li.', 'ALL'),
('SENIN', 'Bhs. Inggris', '09:45', '10:25', 'Rodhiyah, S.Pd.', 'ALL'),
('SENIN', 'Kimia', '10:25', '11:45', 'Drs. Ali Al Mu''tasim, M.Pd.', 'ALL'),
('SENIN', 'Istirahat & Sholat Dhuhur', '11:45', '12:25', '-', 'ALL'),
('SENIN', 'Matematika (P)', '12:25', '13:45', 'Nur Kolis, S.Pd., M.Sc.', 'ALL'),
('SENIN', 'Akidah Akhlak', '13:45', '15:05', 'Ahmad Sayadi, S.Pd.I.', 'ALL'),
('SENIN', 'Sholat Ashar', '15:05', '15:30', '-', 'ALL'),

-- SELASA (ALL)
('SELASA', 'Sholat Dhuha, Tartil, Asmaul Husna', '07:00', '07:30', '-', 'ALL'),
('SELASA', 'Matematika', '07:30', '08:50', 'Eko Sulistyningsih, S.Pd.', 'ALL'),
('SELASA', 'Istirahat', '08:50', '09:05', '-', 'ALL'),
('SELASA', 'PKn', '09:05', '10:25', 'Umriyatin, S.H.', 'ALL'),
('SELASA', 'Fisika', '10:25', '11:45', 'Sofia Ratnaningsih, S.Pd.', 'ALL'),
('SELASA', 'Istirahat & Sholat Dhuhur', '11:45', '12:25', '-', 'ALL'),
('SELASA', 'Seni Budaya', '12:25', '13:45', 'Drs. Moh. Natsir', 'ALL'),
('SELASA', 'Bhs. & Sastra Inggris (LM)/TOEFL', '13:45', '15:05', 'Roisatul Wahdiyah, M.Pd.', 'ALL'),
('SELASA', 'Sholat Ashar', '15:05', '15:30', '-', 'ALL'),

-- RABU (ALL)
('RABU', 'Sholat Dhuha, Tartil, Asmaul Husna', '07:00', '07:30', '-', 'ALL'),
('RABU', 'Al-Qur''an-Hadits', '07:30', '08:50', 'Ahmad, S.Ag., M.Pd.I.', 'ALL'),
('RABU', 'Istirahat', '08:50', '09:05', '-', 'ALL'),
('RABU', 'Kimia', '09:05', '10:25', 'Drs. Ali Al Mu''tasim, M.Pd.', 'ALL'),
('RABU', 'Matematika (P)', '10:25', '11:45', 'Nur Kolis, S.Pd., M.Sc.', 'ALL'),
('RABU', 'Istirahat & Sholat Dhuhur', '11:45', '12:25', '-', 'ALL'),
('RABU', 'Bahasa Arab', '12:25', '13:45', 'Moh. Fanni Labib, S.Pd.I.', 'ALL'),
('RABU', 'Biologi', '13:45', '15:05', 'Erna Kristiana Dewi, S.Pd., M.Si.', 'ALL'),
('RABU', 'Sholat Ashar', '15:05', '15:30', '-', 'ALL'),

-- KAMIS GANJIL (ODD)
('KAMIS', 'Sholat Dhuha, Tartil, Asmaul Husna', '07:00', '07:30', '-', 'ODD'),
('KAMIS', 'Penjaskes', '07:30', '08:50', 'Ali Qomarul Zaman, S.Pd.', 'ODD'),
('KAMIS', 'Istirahat', '08:50', '09:05', '-', 'ODD'),
('KAMIS', 'Fikih', '09:05', '10:25', 'Samhadi Ifriandi Putra, S.Pd.I.', 'ODD'),
('KAMIS', 'Fisika', '10:25', '11:45', 'Sofia Ratnaningsih, S.Pd.', 'ODD'),
('KAMIS', 'Istirahat & Sholat Dhuhur', '11:45', '12:25', '-', 'ODD'),
('KAMIS', 'SKI', '12:25', '13:45', 'Ahmad Hasyim As''yari, S.Pd.I.', 'ODD'),
('KAMIS', 'PK (Komputer)', '13:45', '15:05', 'Ulfa Mazidah, S.Pd.', 'ODD'),
('KAMIS', 'Sholat Ashar', '15:05', '15:30', '-', 'ODD'),

-- KAMIS GENAP (EVEN)
('KAMIS', 'Matematika', '09:05', '10:25', 'Eko Sulistyningsih, S.Pd.', 'EVEN'),
('KAMIS', 'Bahasa Indonesia', '10:25', '11:45', 'Syuhadak, S.Pd., M.Li.', 'EVEN'),
('KAMIS', 'Bahasa Inggris', '12:25', '13:45', 'Rodhiyah, S.Pd.', 'EVEN'),

-- JUMAT (ALL)
('JUMAT', 'Sholat Dhuha, Tartil, Asmaul Husna', '07:00', '07:30', '-', 'ALL'),
('JUMAT', 'Biologi', '07:30', '08:40', 'Erna Kristiana Dewi, S.Pd., M.Si.', 'ALL'),
('JUMAT', 'Istirahat', '08:40', '08:55', '-', 'ALL'),
('JUMAT', 'Bhs. & Sastra Inggris (LM)/TOEFL', '08:55', '10:05', 'Roisatul Wahdiyah, M.Pd.', 'ALL'),
('JUMAT', 'Bhs. Indonesia', '10:05', '10:40', 'Syuhadak, S.Pd., M.Li.', 'ALL'),
('JUMAT', 'Istirahat & Sholat Dhuhur', '10:40', '11:00', '-', 'ALL'),

-- SABTU GANJIL (ODD)
('SABTU', 'Sholat Dhuha, Tartil, Asmaul Husna', '07:00', '07:30', '-', 'ODD'),
('SABTU', 'Bahasa Inggris', '07:30', '08:50', 'Rodhiyah, S.Pd.', 'ODD'),
('SABTU', 'Istirahat', '08:50', '09:05', '-', 'ODD'),
('SABTU', 'Matematika', '09:05', '10:25', 'Eko Sulistyningsih, S.Pd.', 'ODD'),
('SABTU', 'Bahasa Indonesia', '10:25', '11:45', 'Syuhadak, S.Pd., M.Li.', 'ODD'),
('SABTU', 'Istirahat & Sholat Dhuhur', '11:45', '12:15', '-', 'ODD'),
('SABTU', 'Mulok Tahfidz', '12:15', '13:35', 'Moh. Fanni Labib, S.Pd.I.', 'ODD'),

-- SABTU GENAP (EVEN)
('SABTU', 'SKI', '07:30', '08:50', 'Ahmad Hasyim As''yari, S.Pd.I.', 'EVEN'),
('SABTU', 'Fikih', '09:05', '10:25', 'Samhadi Ifriandi Putra, S.Pd.I.', 'EVEN'),
('SABTU', 'Fisika', '10:25', '11:45', 'Sofia Ratnaningsih, S.Pd.', 'EVEN');