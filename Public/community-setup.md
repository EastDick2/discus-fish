# Community-auth instellen

De openbare pagina werkt als statische site; inloggen, onderwerpen en threadreacties gebruiken Supabase Auth en database-RLS.

1. Maak een Supabase-project aan.
2. Zet de Project URL en anon/publishable key in `community-config.js`. Gebruik in browsercode nooit een geheime service-role-key.
3. Voer `community-schema.sql` uit in de Supabase SQL Editor.
4. Voer daarna `community-replies-migration.sql` uit om reacties in threads toe te voegen. Deze migratie is herhaalbaar.
5. Configureer e-mailauthenticatie en stel de toegestane redirect-URL's in op de URL van de gepubliceerde site.
6. Maak geen open registratie beschikbaar. Maak accounts voor goedgekeurde leden handmatig aan/invite ze in Supabase Authentication. De trigger maakt een profiel aan dat standaard niet is goedgekeurd.
7. Zet voor goedgekeurde leden `is_approved = true` in `community_profiles`. Geef alleen vertrouwde moderators `is_moderator = true`.
8. Test met een niet-goedgekeurd account, een goedgekeurd lid en een moderator: alleen leden mogen onderwerpen en reacties lezen en plaatsen; moderators kunnen onderwerpen en reacties verwijderen.

Toegangsaanvragen openen een e-mailconcept voor `ardi.oostdijk@gmail.com`; de aanvraag wordt niet automatisch verzonden of opgeslagen.
