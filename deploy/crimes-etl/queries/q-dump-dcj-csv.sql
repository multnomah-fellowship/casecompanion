  SELECT
    "EMAIL" as "Email Address",
    CASE WHEN substring("VICTIM_FIRST_NAME" from '^[A-Z \-]+$') IS NULL THEN
      "VICTIM_FIRST_NAME"
    ELSE
      concat(substring("VICTIM_FIRST_NAME" from 0 for 2), lower(substring("VICTIM_FIRST_NAME" from 2)))
    END as "First Name",
    CASE WHEN substring("VICTIM_LAST_NAME" from '^[A-Z \-]+$') IS NULL THEN
      "VICTIM_LAST_NAME"
    ELSE
      concat(substring("VICTIM_LAST_NAME" from 0 for 2), lower(substring("VICTIM_LAST_NAME" from 2)))
    END as "Last Name",
    CASE WHEN ("DDA_FIRST_NAME" = 'Legal' AND "DDA_LAST_NAME" = 'Intern') THEN
      NULL
    ELSE
      concat("DDA_FIRST_NAME", ' ', "DDA_LAST_NAME")
    END as "DDA Name",
    "COURT_NBR" as "Court Case Number",
    "CASE_NBR" as "DA Case Number",
    "OREGON_SID_NBR" as "Offender SID",
    CASE WHEN substring("FIRST_NAME" from '^[A-Z \-]+$') IS NULL THEN
      "FIRST_NAME"
    ELSE
      concat(substring("FIRST_NAME" from 0 for 2), lower(substring("FIRST_NAME" from 2)))
    END as "Offender First Name",
    CASE WHEN substring("LAST_NAME" from '^[A-Z \-]+$') IS NULL THEN
      "LAST_NAME"
    ELSE
      concat(substring("LAST_NAME" from 0 for 2), lower(substring("LAST_NAME" from 2)))
    END as "Offender Last Name"
  FROM closed_charge_victims
  WHERE "EMAIL" IS NOT NULL AND "VICTIM_FIRST_NAME" IS NOT NULL
  GROUP BY "CASE_NBR", "VICTIM_FIRST_NAME", "VICTIM_LAST_NAME", "EMAIL", "COURT_NBR", "DDA_FIRST_NAME", "DDA_LAST_NAME", "FIRST_NAME", "LAST_NAME", "OREGON_SID_NBR"
