-- Run this migration in Supabase SQL Editor after community-schema.sql.
-- It adds threaded replies to existing community topics. It is safe to run more than once.
create table if not exists public.community_replies (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.community_posts(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  author_name text not null,
  body text not null check (char_length(body) between 1 and 2000),
  created_at timestamptz not null default now()
);

create index if not exists community_replies_post_created_idx
  on public.community_replies (post_id, created_at asc);

alter table public.community_replies enable row level security;
revoke all on public.community_replies from anon, authenticated;
grant select, insert, delete on public.community_replies to authenticated;

drop policy if exists "Approved members can read replies" on public.community_replies;
create policy "Approved members can read replies"
on public.community_replies for select to authenticated
using (
  exists (
    select 1 from public.community_profiles p
    where p.id = (select auth.uid()) and p.is_approved
  )
);

drop policy if exists "Approved members can reply as themselves" on public.community_replies;
create policy "Approved members can reply as themselves"
on public.community_replies for insert to authenticated
with check (
  user_id = (select auth.uid())
  and exists (
    select 1 from public.community_profiles p
    where p.id = (select auth.uid()) and p.is_approved
  )
  and exists (select 1 from public.community_posts t where t.id = post_id)
);

drop policy if exists "Moderators can delete replies" on public.community_replies;
create policy "Moderators can delete replies"
on public.community_replies for delete to authenticated
using (
  exists (
    select 1 from public.community_profiles p
    where p.id = (select auth.uid()) and p.is_approved and p.is_moderator
  )
);
