# frozen_string_literal: true

class Right < ActiveRecord::Base
  RIGHTS = {
    flag_a: 'A-DDA to assert and enforce Victim Rights',
    flag_b: 'B-Notified in advance of Critical Stage Proceedings',
    flag_c: 'C-Talk with DDA before a Plea Agreement',
    flag_d: 'D-Notified in advance of Release Hrgs',
    flag_e: 'E-Notified in advance of Probation Revocation Hrgs',
    flag_f: 'F-Request HIV Testing',
    flag_g: 'G-DUII Auto Collision, request info given to Def',
    flag_h: 'H-Limited distribution of visual or recording of sexual conduct',
    flag_i: 'I-No media coverage of Sex Offense Proceedings',
    flag_j: 'J-Def not to live w/in 3mi of Vic',
    flag_k: 'K-Right to Restitution',
    flag_l: 'L-Requested other specific rights',
    flag_m: 'M-Involvement after conviction',
    flag_n: 'N-No VRN or Vic Ltr for Victim, THIS CASE',
    flag_o: 'O-CARES NW',
    flag_p: 'P-Medical Records Subpoenaed',
    flag_q: 'Q-No Trial Readiness Notice - THIS CASE',
    flag_r: 'R-Restitution: Best Effort/No Reply',
  }.freeze

  # TODO: Remove this by refactoring all usages of this constant
  NAMES = RIGHTS.values.freeze

  # All the rights should be represented in a group exactly once
  # Some of these keys match the names used in the VRN right selection flow for
  # consistency.
  GROUPS = {
    who_assert: %i[flag_a],
    to_notification: %i[flag_b flag_d flag_e],
    to_financial_assistance: %i[flag_k],
    in_special_cases: %i[flag_c flag_f flag_g flag_h flag_i flag_j flag_m],

    # These flags are used to designate something non-user-facing:
    not_actually_rights: %i[flag_n flag_o flag_l flag_p flag_q flag_r],
  }.freeze

  belongs_to :court_case_subscription
  validates :name, inclusion: RIGHTS.values
end
