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
    case_update_date timestamp without time zone,
    dda_first_name character varying(40),
    dda_last_name character varying(40)
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
    court_case_number character varying(20),
    advocate character varying(100),
    prosecutor_last_name character varying(100),
    prosecutor_first_name character varying(100)
);

DROP TABLE IF EXISTS digital_vrns;
CREATE TABLE digital_vrns (
  case_number character varying(100) NOT NULL,
  email character varying(200) NOT NULL
);

DROP TABLE IF EXISTS closed_charge_victims;
CREATE TABLE closed_charge_victims (
  case_id_nbr numeric NOT NULL,
  case_nbr numeric NOT NULL,
  charge_nbr numeric NOT NULL,
  charge_id_nbr numeric NOT NULL,
  sentence_id_nbr numeric NOT NULL,
  postprison_qty boolean,
  postprison_qty_unit boolean,
  probation_type_code character varying(4) NOT NULL,
  probation_type character varying(44) NOT NULL,
  total_prob_qty numeric,
  total_prob_qty_unit character varying(1),
  prob_jail_qty numeric,
  prob_jail_qty_unit character varying(1),
  jail_qty_susp numeric,
  jail_qty_susp_unit character varying(1),
  person_id_nbr numeric NOT NULL,
  dda_first_name character varying(11),
  dda_last_name character varying(10),
  probation boolean,
  court_nbr character varying(9) NOT NULL,
  form_name character varying(18) NOT NULL,
  case_person_nbr numeric NOT NULL,
  sentence_nbr numeric NOT NULL,
  sentence_desc character varying(25) NOT NULL,
  case_update_date timestamp without time zone,
  probation_create_date timestamp without time zone,
  charge_update_date timestamp without time zone,
  update_date timestamp without time zone,
  commence_when character varying(2),
  commence_date timestamp without time zone,
  prob_consecutive_charge character varying(11),
  prob_concurrent_charge character varying(80),
  prob_consecutive_case boolean,
  prob_concurrent_case character varying(98),
  jail_consecutive_charge numeric,
  jail_concurrent_charge character varying(21),
  jail_consecutive_case boolean,
  jail_concurrent_case character varying(19),
  prob_credit character varying(4),
  prob_credit_value character varying(50),
  victim_person_id_nbr numeric NOT NULL,
  victim_person_type character varying(7) NOT NULL,
  victim_first_name character varying(12),
  victim_last_name character varying(49) NOT NULL,
  victim_address_prefix character varying(2),
  victim_address character varying(23),
  victim_address_unit character varying(5),
  victim_address_2 boolean,
  victim_address_suffix character varying(4),
  victim_address_city character varying(16),
  victim_address_state character varying(2),
  victim_address_zipcode numeric,
  victim_address_confidential boolean NOT NULL,
  victim_phone_area_code numeric NOT NULL,
  victim_phone numeric NOT NULL,
  sentence_type character varying(4) NOT NULL,
  email character varying(50),
  last_name character varying(19) NOT NULL,
  first_name character varying(13) NOT NULL,
  oregon_sid_nbr numeric,
  offender_dob timestamp without time zone,
  restitution_type character varying(4),
  amount numeric,
  award_designation character varying(9),
  flag_b character varying(5)
)
