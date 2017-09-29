  WITH probation_sentences_with_days as (
    -- Normalize all probation sentences to days, for purposes of finding the longest
    SELECT *,
    CASE total_prob_qty_unit
    WHEN 'Y' THEN total_prob_qty * 365
    WHEN 'M' THEN total_prob_qty * 30
    WHEN 'D' THEN total_prob_qty
    END AS total_prob_days_approx
    FROM probation_sentences
  ),
  max_probation_sentence AS (
    -- Calculate the max probation sentence, under the assumption that all
    -- probation sentences are served concurrently
    SELECT DISTINCT
      probation_sentences_with_days.case_id_nbr,
      probation_sentences_with_days.offender_person_id_nbr,
      probation_sentences_with_days.total_prob_qty,
      probation_sentences_with_days.total_prob_qty_unit,
      probation_sentences_with_days.probation_type
    FROM probation_sentences_with_days
    INNER JOIN (
      SELECT case_id_nbr, offender_person_id_nbr, max(total_prob_days_approx) as max_sentence
      FROM probation_sentences_with_days
      GROUP BY case_id_nbr, offender_person_id_nbr
    ) max_sentences
    ON probation_sentences_with_days.case_id_nbr = max_sentences.case_id_nbr
    AND probation_sentences_with_days.offender_person_id_nbr = max_sentences.offender_person_id_nbr
    AND probation_sentences_with_days.total_prob_days_approx = max_sentences.max_sentence
  )
  SELECT
    email as "Email Address",
    CASE WHEN substring(all_victims.first_name from '^[A-Z \-]+$') IS NULL THEN
      all_victims.first_name
    ELSE
      concat(substring(all_victims.first_name from 0 for 2), lower(substring(all_victims.first_name from 2)))
    END as "First Name",
    CASE WHEN substring(all_victims.last_name from '^[A-Z \-]+$') IS NULL THEN
      all_victims.last_name
    ELSE
      concat(substring(all_victims.last_name from 0 for 2), lower(substring(all_victims.last_name from 2)))
    END as "Last Name",
    court_case_nbr as "Court Case Number",
    da_case_nbr as "DA Case Number",
    oregon_sid_nbr as "Offender SID",
    CASE WHEN substring(defendants.first_name from '^[A-Z \-]+$') IS NULL THEN
      defendants.first_name
    ELSE
      concat(substring(defendants.first_name from 0 for 2), lower(substring(defendants.first_name from 2)))
    END as "Offender First Name",
    CASE WHEN substring(defendants.last_name from '^[A-Z \-]+$') IS NULL THEN
      defendants.last_name
    ELSE
      concat(substring(defendants.last_name from 0 for 2), lower(substring(defendants.last_name from 2)))
    END as "Offender Last Name",
    defendants.dob AS "Offender DOB",
    concat(
      CASE
      WHEN total_prob_qty_unit = 'Y' THEN concat(total_prob_qty, ' year')
      WHEN total_prob_qty_unit = 'M' THEN concat(total_prob_qty, ' month')
      WHEN total_prob_qty_unit = 'D' THEN concat(total_prob_qty, ' day')
      END,
      CASE WHEN total_prob_qty != 1 THEN 's' END
    )
    as "Probation Length",
    amount as "Restitution Amount",
    CASE WHEN address IS NULL THEN NULL
    ELSE
    concat(address_nbr, ' ', prefix, ' ',
      (SELECT array_to_string(array_agg(concat(upper(substring(address_part from 0 for 2)), substring(address_part from 2))), '') from regexp_split_to_table(lower(address), '\m') address_part),
      ' ', suffix,
      CASE WHEN unit IS NOT NULL THEN concat(' Unit ', unit) END,
      ', ',
      (SELECT array_to_string(array_agg(concat(upper(substring(city_part from 0 for 2)), substring(city_part from 2))), '') from regexp_split_to_table(lower(city), '\m') city_part),
      ', ', state, ' ', zipcode
    )
    END as "Address",
    CASE flag_b WHEN 'VICR2' THEN 'TRUE' ELSE NULL END AS "Flag B"
  FROM all_victims

  INNER JOIN max_probation_sentence
    ON max_probation_sentence.case_id_nbr = all_victims.case_id_nbr

  INNER JOIN defendants
    ON defendants.case_id_nbr = max_probation_sentence.case_id_nbr
    AND defendants.person_id_nbr = max_probation_sentence.offender_person_id_nbr

  LEFT OUTER JOIN restitution_sentences
    ON defendants.case_id_nbr = restitution_sentences.case_id_nbr
    AND defendants.person_id_nbr = restitution_sentences.offender_person_id_nbr
    AND all_victims.person_id_nbr = restitution_sentences.victim_person_id_nbr
  WHERE email is not null
  AND all_victims.first_name is not null
  AND probation_type = 'PROY'
  ORDER BY all_victims.case_id_nbr
