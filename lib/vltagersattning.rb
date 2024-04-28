# lib/vltagersattning.rb
require_relative 'vltagersattning/tui'
require_relative 'vltagersattning/user'
require_relative 'vltagersattning/misc'
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

# TODO: First time launch of program should generate a file to keep the API key for the user

main = Vltagersattning::Tui.new
signature_location, date = main.main_menu

user = Vltagersattning::User.new(signature_location, date)

api = Vltagersattning::TrafikverketApi.new(user.from, user.date)
