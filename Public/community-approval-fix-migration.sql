-- Run this migration in Supabase SQL Editor if the admin page says an application could not be updated.
-- It allows the admin page to omit reviewer metadata and makes profile approval an idempotent upsert.

-- Keep approval changes restricted to an already-approved moderator.
drop policy if exists "Moderators can review access requests" on public.community_access_requests;
create policy "Moderators can review access requests"
on public.community_access_requests for update to authenticated
using (
  status = 'pending'
  and exists (
    select 1 from public.community_profiles p
    where p.id = (select auth.uid()) and p.is_approved and p.is_moderator
  )
)
with check (
  status in ('approved','rejected')
  and (reviewed_by is null or reviewed_by = (select auth.uid()))
  and exists (
    select 1 from public.community_profiles p
    where p.id = (select auth.uid()) and p.is_approved and p.is_moderator
  )
);

-- On approval, find the corresponding Auth account and ensure its profile is approved.
create or replace function public.approve_community_profile_for_access_request()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  matching_user_id uuid;
begin
  if new.status = 'approved' and old.status is distinct from new.status then
    select u.id into matching_user_id
    from auth.users as u
    where lower(u.email) = lower(trim(new.email))
    limit 1;

    if matching_user_id is null then
      raise exception 'Geen Supabase Auth-account gevonden voor dit e-mailadres. Controleer of de aanvrager hetzelfde e-mailadres heeft gebruikt.';
    end if;

    insert into public.community_profiles (id, display_name, is_approved)
    values (matching_user_id, new.full_name, true)
    on conflict (id) do update
      set display_name = excluded.display_name,
          is_approved = true;
  end if;
  return new;
end;
$$;

revoke all on function public.approve_community_profile_for_access_request() from public, anon, authenticated;
drop trigger if exists approve_community_profile_after_request on public.community_access_requests;
create trigger approve_community_profile_after_request
after update of status on public.community_access_requests
for each row
when (new.status = 'approved' and old.status is distinct from new.status)
execute function public.approve_community_profile_for_access_request();
