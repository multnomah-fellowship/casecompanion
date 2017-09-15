DROP TABLE IF EXISTS advocates;
CREATE TABLE advocates (
    crimes_id character varying(9) NOT NULL,
    last_name character varying(14),
    first_name character varying(9),
    email character varying(31),
    phone_1 character varying(14),
    phone_2 character varying(14)
);

DROP TABLE IF EXISTS victims;
CREATE TABLE victims (
    case_id_nbr numeric NOT NULL,
    person_id_nbr numeric NOT NULL,
    last_name character varying(200) NOT NULL,
    first_name character varying(30),
    middle_name character varying(30),
    suffix_name character varying(3),
    sex character varying(10),
    race character varying(2),
    dob date,
    update_date timestamp without time zone,
    address_type character varying(6),
    address character varying(100),
    unit character varying(5),
    suffix character varying(4),
    city character varying(100),
    state character varying(2),
    zipcode numeric,
    county boolean,
    mail_indicator boolean,
    address_update_date timestamp without time zone,
    address_nbr numeric,
    phone_type character varying(6),
    area_code numeric,
    phone numeric,
    phone_ext character varying(30),
    phone_update_date timestamp without time zone,
    phone_remark text,
    address_remark text,
    da_case_nbr numeric NOT NULL,
    court_case_nbr character varying(20),
    first_advocate_code character varying(9),
    sec_advocate_code character varying(7),
    email character varying(50),
    confidential_indicator boolean,
    person_update_date timestamp without time zone,
    person_create_date timestamp without time zone,
    case_update_date timestamp without time zone
);

DROP TABLE IF EXISTS vrns;
CREATE TABLE vrns (
    case_id_nbr numeric NOT NULL,
    person_id_nbr numeric NOT NULL,
    flag_desc character varying(63) NOT NULL
);

DROP TABLE IF EXISTS cases;
CREATE TABLE cases (
    id numeric NOT NULL,
    da_case_number numeric NOT NULL,
    advoate character varying(100),
    prosecutor_last_name character varying(100),
    prosecutor_first_name character varying(100)
);

DROP TABLE IF EXISTS digital_vrns;
CREATE TABLE digital_vrns (
  case_number character varying(100) NOT NULL,
  email character varying(200) NOT NULL
);
