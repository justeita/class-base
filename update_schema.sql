-- Add icon column to schedules table
ALTER TABLE schedules ADD COLUMN icon text;

-- Add end_date column to events table
ALTER TABLE events ADD COLUMN end_date timestamp with time zone;
