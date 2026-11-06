# Community-auth instellen

Inloggen, onderwerpen en threadreacties gebruiken Supabase Auth en database-RLS. Toegangsaanvragen worden via het formulier op de communitypagina opgeslagen in Supabase; er wordt geen e-mailconcept geopend.

1. Zet de Supabase Project URL en anon/publishable key in `community-config.js`. Gebruik in browsercode nooit een geheime service-role-key.
2. Voer `community-schema.sql` en `community-replies-migration.sql` uit in de Supabase SQL Editor als dit nog niet is gedaan.
3. Voer `community-access-requests-migration.sql` uit om aanvragen via de website en moderatorbeoordeling in te schakelen.
4. Configureer e-mailauthenticatie en toegestane redirect-URL's op de gepubliceerde site.
5. Houd publieke accountregistratie uit. De beheerder maakt accounts handmatig aan/invite ze in Supabase Auth.
6. Goedgekeurde moderators beheren aanvragen op `community-beheer.html`. De RLS-beveiliging laat alleen goedgekeurde moderators aanvragen lezen en beoordelen; gewone bezoekers kunnen alleen een nieuwe aanvraag indienen.
7. Na goedkeuring van een aanvraag maakt/invite de beheerder het account in Supabase Auth en zet het profiel apart op `is_approved = true`. Geef uitsluitend vertrouwde moderators `is_moderator = true`.
8. Test aanvragen, toegang, threadreacties en moderatorbevoegdheden met aparte testaccounts.

De aanvraag wordt opgeslagen in de Supabase-database. De publieke website toont geen lijst met aanvragers of hun e-mailadressen.
