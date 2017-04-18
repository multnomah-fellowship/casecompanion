# require custom Haml filters in here; this can't be done until after
# application.rb runs since something in there adds 'lib' to the $LOAD_PATH.
require 'haml/filters/styleguide'
