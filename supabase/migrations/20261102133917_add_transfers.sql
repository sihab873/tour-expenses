-- cash handed between people (advances, repayments). not an expense:
-- the giver's balance goes up by amount, the receiver's goes down.
create table public.transfers (
  id bigint generated always as identity primary key,
  from_id smallint not null references public.people (id),
  to_id smallint not null references public.people (id),
  amount numeric(12, 2) not null check (amount > 0),
  note text not null default '' check (char_length(note) <= 200),
  spent_on date not null default current_date,
  created_at timestamptz not null default now(),
  check (from_id <> to_id)
);

create index transfers_from_id_idx on public.transfers (from_id);
create index transfers_to_id_idx on public.transfers (to_id);

alter table public.transfers enable row level security;

revoke all on public.transfers from anon, authenticated;
grant select, insert, update, delete on public.transfers to anon, authenticated;

create policy "transfers readable" on public.transfers
  for select to anon, authenticated using (true);
create policy "transfers insertable" on public.transfers
  for insert to anon, authenticated with check (true);
create policy "transfers updatable" on public.transfers
  for update to anon, authenticated using (true) with check (true);
create policy "transfers deletable" on public.transfers
  for delete to anon, authenticated using (true);

alter publication supabase_realtime add table public.transfers;
