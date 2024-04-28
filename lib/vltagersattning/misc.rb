# lib/misc.rb

module Vltagersattning
  class Misc
    class << self

      def valid_date?(date_string)
        pattern = /\A\d{2}-\d{2}-\d{4}\z/
        !!pattern.match(date_string)
      end

      def parse_date(string_date)
        # Change the dd-mm-yyyy string to a Date with format yyyy/mm/dd
        parsed_date = Date.strptime(string_date, '%d-%m-%Y')
        parsed_date.strftime('%Y/%m/%d')
      end

    end
  end
end
