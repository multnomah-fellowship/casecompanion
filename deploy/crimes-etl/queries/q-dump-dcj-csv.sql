  SELECT
    email as "Email Address",
    CASE WHEN substring(victim_first_name from '^[A-Z \-]+$') IS NULL THEN
      victim_first_name
    ELSE
      concat(substring(victim_first_name from 0 for 2), lower(substring(victim_first_name from 2)))
    END as "First Name",
    CASE WHEN substring(victim_last_name from '^[A-Z \-]+$') IS NULL THEN
      victim_last_name
    ELSE
      concat(substring(victim_last_name from 0 for 2), lower(substring(victim_last_name from 2)))
    END as "Last Name",
    CASE WHEN (dda_first_name = 'Legal' AND dda_last_name = 'Intern') THEN
      NULL
    ELSE
      concat(dda_first_name, ' ', dda_last_name)
    END as "DDA Name",
    court_nbr as "Court Case Number",
    case_nbr as "DA Case Number",
    oregon_sid_nbr as "Offender SID",
    CASE WHEN substring(first_name from '^[A-Z \-]+$') IS NULL THEN
      first_name
    ELSE
      concat(substring(first_name from 0 for 2), lower(substring(first_name from 2)))
    END as "Offender First Name",
    CASE WHEN substring(last_name from '^[A-Z \-]+$') IS NULL THEN
      last_name
    ELSE
      concat(substring(last_name from 0 for 2), lower(substring(last_name from 2)))
    END as "Offender Last Name"
  FROM closed_charge_victims
  WHERE email IS NOT NULL AND victim_first_name IS NOT NULL
  GROUP BY case_nbr, victim_first_name, victim_last_name, email, court_nbr, dda_first_name, dda_last_name, first_name, last_name, oregon_sid_nbr
