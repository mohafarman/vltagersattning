# lib/tui.rb
require 'terminal-table'
require 'pastel'
require 'date'

module Vltagersattning
  class Tui
    class << self
    end

    def main_menu
      # Welcoming message
      pastel = Pastel.new
      puts pastel.red.on_white.bold("\t\t VL Tågersättning ")
      puts pastel.black.on_white("\t Välkommen till vltagersattning. Expressersättning! ")
      puts pastel.black.on_white("\t Skapad och underhålls av Mohamad Farman ")

      location_signature = select_location_from

      date = select_date

      return location_signature, date
    end

    private

    def select_location_from
      pastel = Pastel.new

      input = nil
      location = nil
      msg_from = pastel.black.on_white.bold.underline(" From ")
      msg_choice = pastel.black.on_white("Var god välj stationen du reser från:")
      msg_error = pastel.red.on_white("Fel inmatning. Var god välj en station från 1 till 25.")

      locations = {"Sl"=>"Sala",
                   "Rt"=>"Ransta",
                   "Vå"=>"Västerås C",
                   "Dt"=>"Dingtuna",
                   "Kbä"=>"Kolbäck",
                   "Ksu"=>"Kvicksund",
                   "Kp"=>"Köping",
                   "Arb"=>"Arboga",
                   "Kör"=>"Kungsör",
                   "Hh"=>"Hallstahammar",
                   "Shr"=>"Surahammar",
                   "Rmn"=>"Ramnäs",
                   "Vso"=>"Virsbo",
                   "Äbg"=>"Ängelsberg",
                   "Kbn"=>"Karbenning",
                   "Avky"=>"Avesta Krylbo",
                   "Fgc"=>"Fagersta C",
                   "Fgn"=>"Fagersta Norra",
                   "Vad"=>"Vad",
                   "Sre"=>"Söderbärke",
                   "Smj"=>"Smedjebacken",
                   "Skb"=>"Skinnskatteberg",
                   "Fv"=>"Frövi",
                   "Ör"=>"Örebro C",
                   "Öb"=>"Örebro S"}
      rows = []
      locations_table = [[1, "Sala"], [2, "Ransta"], [3, "Västerås C"], [4, "Dingtuna"], [5, "Kolbäck"], [6, "Kvicksund"], [7, "Köping"], [8, "Arboga"], [9, "Kungsör"], [10, "Hallstahammar"], [11, "Surahammar"], [12, "Ramnäs"], [13, "Virsbo"], [14, "Ängelsberg"], [15, "Karbenning"], [16, "Avesta Krylbo"], [17, "Fagersta C"], [18, "Fagersta Norra"], [19, "Vad"], [20, "Söderbärke"], [21, "Smedjebacken"], [22, "Skinnskatteberg"], [23, "Frövi"], [24, "Örebro C"], [25, "Örebro S"]]

      # Turn it into an array with arrays before it can be used to create a table
      # Weird, because stations_table already is an array of an array but it still did not work
      locations_table.map { |item|
        rows << item
      }

      table = Terminal::Table.new :title => msg_from, :rows => rows
      puts table

      loop do
        puts msg_choice
        input = gets.chomp.to_i

        if (1..25).include?(input)
          location = locations_table[input - 1][1]
          break
        else
          puts msg_error
        end
      end

      # Returns the location_signature for the selected location
      locations.key(location)
    end

    def select_date
      pastel = Pastel.new

      msg_choice = pastel.black.on_white("Välj datum för när resan inträffade (dd-mm-yyyy, ex. 05-02-2024:")
      msg_choice2 = pastel.black.on_white( "(Alternativt: 1 = idag, 2 = igår)")
      msg_error = pastel.red.on_white("Fel inmatning. dd-mm-yyyy. Försök igen:")
      date = nil

      puts msg_choice
      loop do
        puts msg_choice2
        input = gets.chomp.to_s

        if 1 == input.to_i
          date = Date.today.strftime('%Y/%m/%d')
          break
        elsif 2 == input.to_i
          date = Date.today.prev_day.strftime('%Y/%m/%d')
          break
        elsif Vltagersattning::Misc.valid_date?(input)
          date = Vltagersattning::Misc.parse_date(input)
          break
        else
          puts msg_error
        end
      end

      date
    end

  end
end
