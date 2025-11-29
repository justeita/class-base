-- Add new columns to app_users table
ALTER TABLE app_users 
ADD COLUMN full_name TEXT,
ADD COLUMN absent_number TEXT,
ADD COLUMN class_name TEXT,
ADD COLUMN date_of_birth DATE,
ADD COLUMN gender TEXT;
