# lib/user.rb

module Vltagersattning
  class User
    attr_reader :from, :date

    def initialize(from, date)
      @from = from
      @date = date
    end
  end
end
