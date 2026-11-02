-- the app is now a plain spending log; the note is the only record of what
-- the money was for, so it can't be empty.
alter table public.expenses
  add constraint expenses_note_required check (char_length(btrim(note)) >= 3);
