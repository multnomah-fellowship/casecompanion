  SELECT
    email as "Email Address",
    first_name as "First Name",
    last_name as "Last Name",
    case when selected_flags::varchar[] @> ARRAY['A']::varchar[] then 'TRUE' end as FLAGA,
    case when selected_flags::varchar[] @> ARRAY['B']::varchar[] then 'TRUE' end as FLAGB,
    case when selected_flags::varchar[] @> ARRAY['C']::varchar[] then 'TRUE' end as FLAGC,
    case when selected_flags::varchar[] @> ARRAY['D']::varchar[] then 'TRUE' end as FLAGD,
    case when selected_flags::varchar[] @> ARRAY['E']::varchar[] then 'TRUE' end as FLAGE,
    case when selected_flags::varchar[] @> ARRAY['F']::varchar[] then 'TRUE' end as FLAGF,
    case when selected_flags::varchar[] @> ARRAY['G']::varchar[] then 'TRUE' end as FLAGG,
    case when selected_flags::varchar[] @> ARRAY['H']::varchar[] then 'TRUE' end as FLAGH,
    case when selected_flags::varchar[] @> ARRAY['I']::varchar[] then 'TRUE' end as FLAGI,
    case when selected_flags::varchar[] @> ARRAY['J']::varchar[] then 'TRUE' end as FLAGJ,
    case when selected_flags::varchar[] @> ARRAY['K']::varchar[] then 'TRUE' end as FLAGK,
    case when selected_flags::varchar[] @> ARRAY['L']::varchar[] then 'TRUE' end as FLAGL,
    case when selected_flags::varchar[] @> ARRAY['M']::varchar[] then 'TRUE' end as FLAGM,
    advocate_first_name as "Advocate First Name",
    advocate_last_name as "Advocate Last Name",
    advocate_phone as "Advocate Phone Number",
    advocate_email as "Advocate Email",
    da_case_nbr as "DA Case Number",
    court_case_nbr as "Court Case Number"
  FROM (
    SELECT
      victims.person_id_nbr,
      victims.case_id_nbr,

      CASE WHEN substring(victims.first_name from '^[A-Z \-]+$') IS NULL THEN
        victims.first_name
      ELSE
        concat(substring(victims.first_name from 0 for 2), lower(substring(victims.first_name from 2)))
      END as first_name,

      CASE WHEN substring(victims.last_name from '^[A-Z \-]+$') IS NULL THEN
        victims.last_name
      ELSE
        concat(substring(victims.last_name from 0 for 2), lower(substring(victims.last_name from 2)))
      END as last_name,
      victims.email,
      CASE WHEN substring(advocates.first_name from '^[A-Z \-]+$') IS NULL THEN
        advocates.first_name
      ELSE
        concat(substring(advocates.first_name from 0 for 2), lower(substring(advocates.first_name from 2)))
      END as advocate_first_name,
      CASE WHEN substring(advocates.last_name from '^[A-Z \-]+$') IS NULL THEN
        advocates.last_name
      ELSE
        concat(substring(advocates.last_name from 0 for 2), lower(substring(advocates.last_name from 2)))
      END as advocate_last_name,
      advocates.email as advocate_email,
      advocates.phone_1 as advocate_phone,
      victims.da_case_nbr,
      victims.court_case_nbr,
      array_agg(substring(flag_desc from 0 for 2)) as selected_flags
    FROM vrns
    INNER JOIN victims
      ON victims.person_id_nbr = vrns.person_id_nbr
      AND victims.case_id_nbr = vrns.case_id_nbr
    LEFT OUTER JOIN advocates
      ON victims.first_advocate_code = advocates.crimes_id
    WHERE
      victims.first_name is NOT NULL
      AND flag_desc IS NOT NULL
      AND victims.update_date > '2017-07-20'
      -- This comment is uncommented conditionally by ./copy-and-process.sh:
      -- AND victims.email IS NOT NULL
    GROUP BY victims.person_id_nbr, victims.case_id_nbr, victims.first_name, victims.last_name, victims.email,
      advocate_first_name, advocate_last_name, advocate_email, advocate_phone, da_case_nbr, court_case_nbr
  ) q
