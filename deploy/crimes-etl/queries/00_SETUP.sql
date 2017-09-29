DROP TABLE CFA_TOM_VRN;
DROP TABLE CFA_TOM_PROBATION;
DROP TABLE CFA_TOM_RESTITUTION;
DROP TABLE CFA_TOM_VICTIM_LATEST_ADDRESS;
DROP TABLE CFA_TOM_VICTIM_INFO;
DROP TABLE CFA_TOM_DEFENDANT_INFO;

-- These queries will all run faster with the following indices:
IF NOT EXISTS(SELECT * FROM sysindexes where name = 'cfa_tom_case_person') BEGIN
CREATE INDEX cfa_tom_case_person ON CASE_PERSON (CASE_ID_NBR, CASE_PERSON_TYPE, PERSON_ID_NBR);
END
IF NOT EXISTS(SELECT * FROM sysindexes where name = 'cfa_tom_cp_address') BEGIN
CREATE INDEX cfa_tom_cp_address ON CASE_PERSON_ADDRESS (PERSON_ID_NBR, SUB_ONLY, ALL_DOCS);
END
IF NOT EXISTS(SELECT * FROM sysindexes where name = 'cfa_tom_cp_phone') BEGIN
CREATE INDEX cfa_tom_cp_phone ON CASE_PERSON_PHONE (PERSON_ID_NBR, DEFAULT_PHONE);
END
IF NOT EXISTS(SELECT * FROM sysindexes where name = 'cfa_tom_cp_info') BEGIN
CREATE INDEX cfa_tom_cp_info ON CASE_PERSON_INFO (PERSON_ID_NBR);
END
IF NOT EXISTS(SELECT * FROM sysindexes where name = 'cfa_tom_case_main') BEGIN
CREATE INDEX cfa_tom_case_main ON CASE_MAIN (CASE_ID_NBR);
END
IF NOT EXISTS(SELECT * FROM sysindexes where name = 'cfa_tom_cp_flag') BEGIN
CREATE INDEX cfa_tom_cp_flag ON CASE_FLAG (CASE_ID_NBR, PERSON_ID_NBR);
END
