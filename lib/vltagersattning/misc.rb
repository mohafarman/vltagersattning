# lib/misc.rb

module Vltagersattning
  class Misc
    class << self

      def valid_date?(date_string)
        pattern = /\A\d{2}-\d{2}-\d{4}\z/
        !!pattern.match(date_string)
      end

    end
  end
end
