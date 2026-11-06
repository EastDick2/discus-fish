# Community-auth instellen

De openbare community gebruikt Supabase Auth en database-RLS. Bezoekers kunnen op `community.html` een aanvraag en account indienen; accounts hebben standaard geen toegang tot gesprekken totdat een moderator ze goedkeurt.

1. Zet de Supabase Project URL en anon/publishable key in `community-config.js`. Gebruik in browsercode nooit een service-role-key.
2. Voer `community-schema.sql`, `community-replies-migration.sql`, `community-access-requests-migration.sql` en `community-approval-sync-migration.sql` uit in de Supabase SQL Editor.
3. Als goedkeuren vanuit `community-beheer.html` de melding geeft dat de aanvraag niet kon worden bijgewerkt, voer dan ook `community-approval-fix-migration.sql` uit. Deze migratie versoepelt de reviewer-metadata-voorwaarde veilig voor goedgekeurde moderators en maakt profielgoedkeuring automatisch.
4. Schakel in Supabase Auth email/password sign-ups in. Houd e-mailbevestiging aan en configureer de bevestigingsredirect naar `https://<jouwdomein>/discussieruimte.html`.
5. Configureer een eigen SMTP-provider in Supabase Auth > SMTP Settings om bevestigings- en wachtwoordresetmails betrouwbaar te laten bezorgen. Controleer ook spam en Auth Logs.
6. Voeg `https://<jouwdomein>/**` en de exacte bevestigings- en reset-URL's toe aan Auth URL Configuration > Redirect URLs.
7. Aanvragen verschijnen in `community-beheer.html`. Bij goedkeuring wordt het bijbehorende `community_profiles.is_approved` automatisch `true`. De aanvraagmail moet overeenkomen met het e-mailadres van het Supabase Auth-account.
8. Publieke accounts zijn standaard niet goedgekeurd; RLS verhindert hen gesprekken te lezen, plaatsen of beantwoorden. Geef uitsluitend vertrouwde moderators `is_moderator = true`.
9. Test aanvragen, bevestigingsmails, wachtwoordherstel, goedkeuring en RLS met aparte testaccounts.

Aanvragen worden in Supabase opgeslagen. Het wachtwoord wordt uitsluitend verwerkt door Supabase Auth; het wordt niet opgenomen in de aanvraag.
