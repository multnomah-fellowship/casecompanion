class Right < ActiveRecord::Base
  belongs_to :court_case_subscription

  NAMES = [
    'A-DDA to assert and enforce Victim Rights',
    'B-Notified in advance of Critical Stage Proceedings',
    'C-Talk with DDA before a Plea Agreement',
    'D-Notified in advance of Release Hrgs',
    'E-Notified in advance of Probation Revocation Hrgs',
    'F-Request HIV Testing',
    'G-DUII Auto Collision, request info given to Def',
    'H-Limited distribution of visual or recording of sexual conduct',
    'I-No media coverage of Sex Offense Proceedings',
    'J-Def not to live w/in 3mi of Vic',
    'K-Right to Restitution',
    'L-Requested other specific rights',
    'M-Involvement after conviction',
    'N-No VRN or Vic Ltr for Victim, THIS CASE',
    'O-CARES NW',
    'P-Medical Records Subpoenaed',
    'Q-No Trial Readiness Notice - THIS CASE',
    'R-Restitution: Best Effort/No Reply',
  ]
end
