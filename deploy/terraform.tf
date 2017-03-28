provider "twilio" {
  account_sid = "${var.twilio_account_sid}"
  auth_token = "${var.twilio_auth_token}"
}

// Specify with TF_VAR_twilio_account_sid
variable "twilio_account_sid" {
  description = "Twilio SID for the account/subaccount"
}

// Specify with TF_VAR_twilio_auth_token
variable "twilio_auth_token" {
  description = "Twilio auth token for the account/subaccount"
}

// ////////////////////////////////////////////////////////////////////////////
// HOSTED SERVICES (TWILIO, ETC)
// ////////////////////////////////////////////////////////////////////////////
// NOTE: I had to build the terraform plugin for twilio myself due to an API
// inconsistency with terraform. Installation instructions will be difficult
// until my open issue is resolved:
// https://github.com/tulip/terraform-provider-twilio/issues/2
resource "twilio_phonenumber" "prototype" {
  name = "myadvocate prototype"

  location {
    near_lat_long {
      latitude = 45.5231
      longitude = -122.6765
    }
  }
}

output "phone" {
  value = ["${twilio_phonenumber.prototype.phone_number}"]
}
