# Community-auth instellen

De openbare pagina werkt als statische site; inloggen en posten gebruiken daarom Supabase Auth en database-RLS.

1. Maak een Supabase-project aan.
2. Kopieer de **Project URL** en de **anon/publishable key** naar `community-config.js`. Deze publieke sleutel mag in de browser staan; gebruik hier nooit de `service_role`- of een andere geheime sleutel.
3. Voer `community-schema.sql` uit in de Supabase SQL Editor.
4. Configureer e-mailauthenticatie en stel de toegestane redirect-URL's in op de URL van de gepubliceerde site.
5. Maak geen open registratie beschikbaar. Maak accounts voor goedgekeurde leden handmatig aan/invite ze in Supabase Authentication. De trigger maakt bij het aanmaken een profiel aan dat standaard niet is goedgekeurd.
6. Zet voor goedgekeurde leden `is_approved = true` in `community_profiles`. Geef alleen vertrouwde moderators `is_moderator = true`. De database-RLS beschermt lezen en schrijven; alleen de beheerder kan deze profielrechten aanpassen.
7. Test met een niet-goedgekeurd account, een goedgekeurd lid en een moderator: niet-goedgekeurde gebruikers mogen geen berichten lezen of plaatsen; moderators kunnen berichten verwijderen.

Toegangsaanvragen openen een e-mailconcept voor `ardi.oostdijk@gmail.com`. Het formulier verstuurt geen mail automatisch en slaat geen aanvraag op. Inloggen is pas actief nadat de beheerder de Supabase-configuratie heeft ingevuld.
