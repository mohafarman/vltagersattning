# lib/vltagersattning.rb
require_relative 'vltagersattning/tui'
require_relative 'vltagersattning/user'
require_relative 'vltagersattning/trafikverket_api'

module Vltagersattning
  VERSION='0.0.1'

  class << self
    def initialize
      tui = Vltagersattning::Tui.new
      signature_location = tui.main_menu
    end
  end
end

# Vltagersattning.initialize
main = Vltagersattning::Tui.new
signature_location, date = main.main_menu

user = Vltagersattning::User.new(signature_location, date)
