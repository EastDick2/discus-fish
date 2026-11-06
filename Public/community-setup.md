# Community-auth instellen

De openbare community gebruikt Supabase Auth en database-RLS. Bezoekers kunnen op `community.html` een aanvraag én account indienen; accounts hebben standaard geen toegang tot gesprekken totdat een moderator ze goedkeurt.

1. Zet de Supabase Project URL en anon/publishable key in `community-config.js`. Gebruik in browsercode nooit een service-role-key.
2. Voer `community-schema.sql`, `community-replies-migration.sql` en `community-access-requests-migration.sql` uit in de Supabase SQL Editor.
3. Schakel in Supabase Auth email/password sign-ups in. Houd e-mailbevestiging aan en configureer de bevestigingsredirect naar `https://<jouwdomein>/discussieruimte.html`.
4. Configureer een eigen SMTP-provider in Supabase Auth > SMTP Settings om bevestigings- en wachtwoordresetmails betrouwbaar te laten bezorgen. De standaard testmailservice van Supabase is beperkt; controleer ook spam en Auth Logs.
5. Voeg `https://<jouwdomein>/**` en de exacte bevestigings- en reset-URL's toe aan Auth URL Configuration > Redirect URLs.
6. Aanvragen verschijnen in `community-beheer.html`. Na goedkeuring moet een moderator/beheerder het aangemaakte profiel op `is_approved = true` zetten in `community_profiles`. De gebruiker bevestigt het e-mailadres via de Auth-mail en kan daarna met het bij de aanvraag gekozen wachtwoord inloggen.
7. Publieke accounts zijn standaard niet goedgekeurd; RLS verhindert hen gesprekken te lezen, plaatsen of beantwoorden. Geef uitsluitend vertrouwde moderators `is_moderator = true`.
8. Test aanvragen, bevestigingsmails, wachtwoordherstel, goedkeuring en RLS met aparte testaccounts.

Aanvragen worden in Supabase opgeslagen. Het wachtwoord wordt uitsluitend verwerkt door Supabase Auth; het wordt niet opgenomen in de aanvraag.
