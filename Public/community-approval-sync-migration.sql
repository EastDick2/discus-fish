-- Run this migration in Supabase SQL Editor after community-access-requests-migration.sql.
-- When a moderator approves an access request, mark the matching Auth user's profile approved as well.
-- The request's email and profile's auth user are matched server-side; no service-role key is exposed in browser code.

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
    select u.id
      into matching_user_id
      from auth.users as u
      where lower(u.email) = lower(trim(new.email))
      limit 1;

    if matching_user_id is null then
      raise exception 'No Supabase Auth account exists for the approved access request email';
    end if;

    update public.community_profiles
       set is_approved = true,
           display_name = new.full_name
     where id = matching_user_id;

    if not found then
      raise exception 'No community profile exists for the approved Auth account';
    end if;
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
