# Community-auth instellen

De openbare community gebruikt Supabase Auth en database-RLS. Bezoekers kunnen op `community.html` een aanvraag en account indienen; accounts hebben standaard geen toegang tot gesprekken totdat een moderator ze goedkeurt.

1. Zet de Supabase Project URL en anon/publishable key in `community-config.js`. Gebruik in browsercode nooit een service-role-key.
2. Voer `community-schema.sql`, `community-replies-migration.sql`, `community-access-requests-migration.sql` en `community-approval-sync-migration.sql` uit in de Supabase SQL Editor.
3. Schakel in Supabase Auth email/password sign-ups in. Houd e-mailbevestiging aan en configureer de bevestigingsredirect naar `https://<jouwdomein>/discussieruimte.html`.
4. Configureer een eigen SMTP-provider in Supabase Auth > SMTP Settings om bevestigings- en wachtwoordresetmails betrouwbaar te laten bezorgen. Controleer ook spam en Auth Logs.
5. Voeg `https://<jouwdomein>/**` en de exacte bevestigings- en reset-URL's toe aan Auth URL Configuration > Redirect URLs.
6. Aanvragen verschijnen in `community-beheer.html`. Wanneer een moderator daar een aanvraag goedkeurt, zet de migratie `community-approval-sync-migration.sql` automatisch het bijbehorende `community_profiles.is_approved` op `true`. De e-mail van de aanvraag moet overeenkomen met het e-mailadres van het Auth-account. Als het account of profiel ontbreekt, mislukt goedkeuren met een databasefout.
7. Publieke accounts zijn standaard niet goedgekeurd; RLS verhindert hen gesprekken te lezen, plaatsen of beantwoorden. Geef uitsluitend vertrouwde moderators `is_moderator = true`.
8. Test aanvragen, bevestigingsmails, wachtwoordherstel, goedkeuring en RLS met aparte testaccounts.

Aanvragen worden in Supabase opgeslagen. Het wachtwoord wordt uitsluitend verwerkt door Supabase Auth; het wordt niet opgenomen in de aanvraag.
