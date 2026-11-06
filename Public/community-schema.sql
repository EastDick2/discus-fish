-- Run this SQL in the Supabase SQL Editor for the project configured in community-config.js.
-- Authenticated users still need an approved profile. RLS enforces membership on the database.
create table if not exists public.community_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'Discusliefhebber',
  is_approved boolean not null default false,
  is_moderator boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.community_posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  author_name text not null,
  topic text not null check (topic in ('Houden & verzorging','Kweek','Aquarium & techniek','Energie besparen','Vraag aan de community')),
  title text not null check (char_length(title) between 1 and 120),
  body text not null check (char_length(body) between 1 and 4000),
  created_at timestamptz not null default now()
);
create index if not exists community_posts_created_at_idx on public.community_posts (created_at desc);

create or replace function public.create_community_profile()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.community_profiles (id, display_name)
  values (new.id, coalesce(nullif(new.raw_user_meta_data ->> 'display_name', ''), 'Discusliefhebber'))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_community_profile on auth.users;
create trigger on_auth_user_created_community_profile
after insert on auth.users
for each row execute procedure public.create_community_profile();

alter table public.community_profiles enable row level security;
alter table public.community_posts enable row level security;
revoke all on public.community_profiles from anon, authenticated;
revoke all on public.community_posts from anon, authenticated;
grant select on public.community_profiles to authenticated;
grant select, insert, delete on public.community_posts to authenticated;

drop policy if exists "Members can read own community profile" on public.community_profiles;
create policy "Members can read own community profile"
on public.community_profiles for select to authenticated
using (id = (select auth.uid()));

drop policy if exists "Approved members can read posts" on public.community_posts;
create policy "Approved members can read posts"
on public.community_posts for select to authenticated
using (exists (select 1 from public.community_profiles p where p.id = (select auth.uid()) and p.is_approved));

drop policy if exists "Approved members can create posts as themselves" on public.community_posts;
create policy "Approved members can create posts as themselves"
on public.community_posts for insert to authenticated
with check (
  user_id = (select auth.uid())
  and exists (select 1 from public.community_profiles p where p.id = (select auth.uid()) and p.is_approved)
);

drop policy if exists "Moderators can delete posts" on public.community_posts;
create policy "Moderators can delete posts"
on public.community_posts for delete to authenticated
using (exists (select 1 from public.community_profiles p where p.id = (select auth.uid()) and p.is_approved and p.is_moderator));

-- Admin workflow after a member requests access:
-- 1) Create/invite the user in Supabase Authentication (do not enable unrestricted public sign-ups).
-- 2) Find the user's UUID in Authentication > Users.
-- 3) Approve the member and set a display name using the SQL Editor, e.g.:
-- update public.community_profiles set is_approved = true, display_name = 'Forumnaam' where id = 'USER-UUID';
-- Make a trusted moderator with:
-- update public.community_profiles set is_approved = true, is_moderator = true where id = 'MODERATOR-UUID';
-- Do not expose a service-role key in browser code. Review and remove inappropriate posts through the moderator account.
