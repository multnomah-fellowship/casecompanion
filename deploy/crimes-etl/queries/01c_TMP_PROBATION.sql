-- Find all recently-updated probation sentences.
SELECT     CASE_CHARGE.CASE_ID_NBR, CASE_CHARGE.PERSON_ID_NBR AS OFFENDER_PERSON_ID_NBR, PROBATION.PROBATION_ID_NBR,
                      CASE_CHARGE.CHARGE_STATE, CHARGE_SENTENCE.SENTENCE_ID_NBR, CASE_CHARGE.CHARGE_ID_NBR, PROBATION.TOTAL_PROB_QTY,
                      PROBATION.TOTAL_PROB_QTY_UNIT, PROBATION.PROBATION_TYPE, PROBATION.CREATE_DATE
INTO            CFA_TOM_PROBATION
FROM         PROBATION INNER JOIN
                      CHARGE_SENTENCE ON PROBATION.SENTENCE_ID_NBR = CHARGE_SENTENCE.SENTENCE_ID_NBR INNER JOIN
                      CASE_CHARGE ON CHARGE_SENTENCE.CHARGE_ID_NBR = CASE_CHARGE.CHARGE_ID_NBR
WHERE     (PROBATION.CREATE_DATE BETWEEN DATEADD(month, - 2, GETDATE()) AND GETDATE()) AND (CASE_CHARGE.CHARGE_STATE = 'CONVICTED') AND
                      (PROBATION.TOTAL_PROB_QTY IS NOT NULL) AND (PROBATION.PROBATION_TYPE IS NOT NULL)
