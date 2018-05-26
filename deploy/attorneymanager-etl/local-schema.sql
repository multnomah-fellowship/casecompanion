-- TODO: potentially separate victims from cases?
DROP TABLE IF EXISTS victim_cases;
CREATE TABLE victim_cases (
  party_id numeric NOT NULL,
  case_id numeric NOT NULL,
  name_first character varying(100),
  name_last character varying(200) NOT NULL,
  email text,
  name_inactive boolean,
  address_id numeric,
  address_1 character varying(100),
  address_2 character varying(100),
  city character varying(100),
  state character varying(20),
  zip character varying(10),
  addr_inactive boolean,
  dob_inactive boolean,
  phone_num_home character varying(20),
  phone_ext_home character varying(20),
  phone_num_cell character varying(20),
  phone_ext_cell character varying(20),
  da_case_number character varying(20),
  base_conn_ky character varying(5),
  case_party_conn_id numeric,
  last_case_event_date date
);
