# lib/user.rb

module Vltagersattning
  attr_reader :from, :date

  class User
    def initialize(from, date)
      @from = from
      @date = date
    end
  end
end
