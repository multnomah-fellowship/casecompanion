-- Find all recently-updated Victims or Victim-Witnesses and store their IDs in
-- a table to simplify other queries.
SELECT CASE_ID_NBR, PERSON_ID_NBR
INTO CFA_TOM_VRN
FROM CASE_PERSON
WHERE (UPDATE_DATE BETWEEN DATEADD(month, -2, GETDATE()) AND GETDATE())
AND (CASE_PERSON_TYPE = 'VICTIM' OR CASE_PERSON_TYPE = 'VIC/WIT');
