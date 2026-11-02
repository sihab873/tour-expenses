-- no login by design: the anon role can read and write everything here.
-- the group agreed the data isn't sensitive.

create table public.people (
  id smallint primary key,
  name text not null unique
);

insert into public.people (id, name) values
  (1, 'Akib'), (2, 'Didarul'), (3, 'Habiba'), (4, 'Mim'), (5, 'Misti'),
  (6, 'Sihab'), (7, 'Mirza'), (8, 'Tarek'), (9, 'Toshi');

-- participants holds people.id values; the amount is split equally among them.
-- split_type 'personal' means participants = {paid_by}, so it never affects balances.
create table public.expenses (
  id bigint generated always as identity primary key,
  paid_by smallint not null references public.people (id),
  amount numeric(12, 2) not null check (amount > 0),
  note text not null default '' check (char_length(note) <= 200),
  category text check (category in ('transport', 'stay', 'food', 'tickets', 'shopping', 'other')),
  split_type text not null check (split_type in ('everyone', 'selected', 'personal')),
  participants smallint[] not null check (cardinality(participants) between 1 and 9),
  spent_on date not null default current_date,
  created_at timestamptz not null default now()
);

create index expenses_paid_by_idx on public.expenses (paid_by);
create index expenses_spent_on_idx on public.expenses (spent_on desc);

alter table public.people enable row level security;
alter table public.expenses enable row level security;

revoke all on public.people, public.expenses from anon, authenticated;
grant select on public.people to anon, authenticated;
grant select, insert, update, delete on public.expenses to anon, authenticated;

create policy "people readable" on public.people
  for select to anon, authenticated using (true);

create policy "expenses readable" on public.expenses
  for select to anon, authenticated using (true);
create policy "expenses insertable" on public.expenses
  for insert to anon, authenticated with check (true);
create policy "expenses updatable" on public.expenses
  for update to anon, authenticated using (true) with check (true);
create policy "expenses deletable" on public.expenses
  for delete to anon, authenticated using (true);

-- live refresh on every open phone when someone adds an expense
alter publication supabase_realtime add table public.expenses;
