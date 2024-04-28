# lib/tui.rb
require 'terminal-table'
require 'pastel'

module Vltagersattning
  class Tui
    class << self
    end

    def main_menu
      # Welcoming message
      pastel = Pastel.new
      puts pastel.red.on_white.bold("\t VL Tågersättning ")
      puts pastel.black.on_white("\t Välkommen till vltagersattning. Expressersättning! ")
      puts pastel.black.on_white("\t Skapad och underhålls av Mohamad Farman ")

      select_location_from
    end

    private

    def select_location_from
      input = nil
      location = nil

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

      table = Terminal::Table.new :title => "Från (from)", :rows => rows
      puts table

      loop do
        puts "Var god välj stationen du reser från:"
        input = gets.chomp.to_i

        if (1..25).include?(input)
          location = locations_table[input - 1][1]
          break
        else
          puts "Invalid input. Please enter a number between 1 and 25."
        end
      end

      # Returns the location_signature for the selected location
      locations.key(location)
    end
  end
end
