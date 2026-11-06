-- Run this migration in Supabase SQL Editor to accept access requests on the site.
-- Only moderators can read or review requests. Visitors can submit pending requests; they cannot list or change them.
create table if not exists public.community_access_requests (
  id uuid primary key default gen_random_uuid(),
  full_name text not null check (char_length(full_name) between 1 and 80),
  email text not null check (char_length(email) between 3 and 160),
  interests text not null default '' check (char_length(interests) <= 500),
  rules_accepted boolean not null check (rules_accepted),
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  created_at timestamptz not null default now(),
  reviewed_at timestamptz,
  reviewed_by uuid references auth.users(id) on delete set null
);
create index if not exists community_access_requests_pending_idx
  on public.community_access_requests (created_at asc) where status = 'pending';
alter table public.community_access_requests enable row level security;
revoke all on public.community_access_requests from anon, authenticated;
grant insert (full_name,email,interests,rules_accepted) on public.community_access_requests to anon, authenticated;
grant select on public.community_access_requests to authenticated;
grant update (status,reviewed_at,reviewed_by) on public.community_access_requests to authenticated;
drop policy if exists "Visitors can submit access requests" on public.community_access_requests;
create policy "Visitors can submit access requests"
on public.community_access_requests for insert to anon, authenticated
with check (rules_accepted = true and status = 'pending' and reviewed_at is null and reviewed_by is null);
drop policy if exists "Moderators can read access requests" on public.community_access_requests;
create policy "Moderators can read access requests"
on public.community_access_requests for select to authenticated
using (exists (select 1 from public.community_profiles p where p.id = (select auth.uid()) and p.is_approved and p.is_moderator));
drop policy if exists "Moderators can review access requests" on public.community_access_requests;
create policy "Moderators can review access requests"
on public.community_access_requests for update to authenticated
using (exists (select 1 from public.community_profiles p where p.id = (select auth.uid()) and p.is_approved and p.is_moderator) and status = 'pending')
with check (exists (select 1 from public.community_profiles p where p.id = (select auth.uid()) and p.is_approved and p.is_moderator) and status in ('approved','rejected') and reviewed_by = (select auth.uid()));
