#!/usr/bin/env ruby
#
# Legend of the Sourcerer
# Written by Robert W. Oliver II <robert@cidergrove.com>
# Copyright (C) 2018 Sourcerer, All Rights Reserved.
# Licensed under GPLv3.

module LOTS
  UI_ARROW = "\u2712"
  UI_COPYRIGHT = "\u00A9"
  UI_EMAIL = "\u2709"
  UI_FRAME_HORIZONTAL = "\u2501"
  UI_FRAME_LOWER_LEFT = "\u2517"
  UI_FRAME_LOWER_RIGHT = "\u251B"
  UI_FRAME_UPPER_LEFT = "\u250F"
  UI_FRAME_UPPER_RIGHT = "\u2513"
  UI_FRAME_VERTICAL = "\u2503"

  # UI Class
  class UI
    # Clear the screen
    def clear
      print "\e[H\e[2J"
    end

    def display_map(args)
      map = args[:map]

      new_line
      draw_frame({:text => map})
      new_line
    end

    def help
      new_line
      puts "#{'Valid Commands'.light_green}"
      new_line

      puts(
        "#{UI_ARROW.light_yellow} #{'east, e, right'.light_white}, or #{'r'.light_white} - Move east (right)",
        "#{UI_ARROW.light_yellow} #{'south, s, down'.light_white} , or " + "d".light_white + " - Move south (down)",
        "#{UI_ARROW.light_yellow} #{'west, w, left'.light_white}, or " + "l".light_white + " - Move west (left)",
        "#{UI_ARROW.light_yellow} #{'north, n, up'.light_white}, or " + "u".light_white + " - Move north (up)",
        "#{UI_ARROW.light_yellow} #{'map'.light_white} - Display map",
        "#{UI_ARROW.light_yellow} #{'where'.light_white} - Describe current surroundings",
        "#{UI_ARROW.light_yellow} #{'attack'.light_white} - Attack (only in combat)",
        "#{UI_ARROW.light_yellow} #{'enemy'.light_white} - Display information about your enemy",
        "#{UI_ARROW.light_yellow} #{'lines, score, status, info'.light_white} - Display lines of code (score)",
        "#{UI_ARROW.light_yellow} #{'clear, cls'.light_white} - Clears the screen",
        "#{UI_ARROW.light_yellow} #{'quit, exit'.light_white} - Quits the game"
      )
    end

    def lines(args)
      player = args[:player]
      puts "You currently have #{player.lines.to_s.light_white} lines of code."
    end

    def enemy_info(args)
      player = args[:player]
      enemy = player.current_enemy
      puts "#{enemy.name.light_red} has #{enemy.str.to_s.light_white} strength and #{enemy.health.to_s.light_white} health."
    end

    def player_info(args)
      player = args[:player]
      puts "You have #{player.health.to_s.light_white} health and have #{player.lines.to_s.light_white} lines of code."
    end

    # Ask user a question. A regular expression filter can be applied.
    def ask(question, filter = nil)
      if filter
        match = false
        answer = nil
        while match == false
          print UI_ARROW.red + question.light_white + " "
          answer = gets.chomp
          if answer.match(filter)
            return answer
          else
            puts "#{'Sorry, please try again.'.red}"
            new_line
          end
        end
      else
        print "\u2712 ".red + question.light_white + " "
        return gets.chomp
      end
    end

    # Display welcome
    def welcome
      text = Array.new
      text << "Empire of the Rots".light_green
      text << "Written by aLukard ".white + UI_EMAIL.light_white + " aLukard@luilver.com".white
      text << "Copyright " + UI_COPYRIGHT + " EOTR, All Rights Reserved.".white
      text << "Licensed under GPLv3.".white
      draw_frame({:text => text})
      new_line
    end

    # Prints a new line. Optinally can print multiple lines.
    # TODO #5: Add new_lines method (deprecate new_line with arguments)
    def new_line(times = 1)
      times.times do
        puts
      end
    end

    # Draw text surrounded in a nice frame
    def draw_frame(args)
      # Figure out width automatically
      text = args[:text]
      width = get_max_size_from_array(text)
      draw_top_frame(width)
      text.each do |t|
        t_size = get_real_size(t)
        draw_vert_frame_begin
        if t.kind_of?(Array)
          t.each do |s|
            print s
          end
        else
          print t
        end
        (width - (t_size + 4)).times do
          print " "
        end
        draw_vert_frame_end
        new_line
      end
      draw_bottom_frame(width)
    end

    def display_version
      puts "This is " + "Legend of the Sourcerer".light_red + " Version " + LOTS_VERSION.light_white
      new_line
    end

    def not_found
      puts "Command not understood. Please try again.".red
    end

    def show_location(args)
      player = args[:player]
      puts "You are currently on row " + player.y.to_s.light_white + ", column " + player.x.to_s.light_white
      puts "Use the " + "map".light_white + " command to see the map."
    end

    def cannot_travel_combat
      puts "You are in combat and cannot travel!"
    end

    def not_in_combat
      puts "You are not in combat."
    end

    def quit
      new_line
      puts "You abandoned your journey.".red
      new_line
    end

    def get_cmd
      puts "Type ".white + "help".light_white + " for possible commands."
      print "\u2712 ".red + "Your command? ".light_white
      return gets.chomp.downcase
    end

    def out_of_bounds
      puts "x".red + " Requested move out of bounds."
    end

    def display_name(args)
      player = args[:player]
      puts "You are " + player.name.light_white + ". Have you forgotten your own name?"
    end

    def player_dead(args)
      story = args[:story]
      new_line

      text = story.player_dead
      draw_frame(:text => text)
      new_line
    end

    def enemy_greet(args)
      enemy = args[:enemy]
      print enemy.name.light_white + " attacks!"
      new_line
    end

    private

    def draw_vert_frame_begin
      print UI_FRAME_VERTICAL.yellow + " "
    end

    def draw_vert_frame_end
      print " " + UI_FRAME_VERTICAL.yellow
    end

    def draw_top_frame(width)
      print UI_FRAME_UPPER_LEFT.yellow
      (width - 2).times do
        print UI_FRAME_HORIZONTAL.yellow
      end
      puts UI_FRAME_UPPER_RIGHT.yellow
    end

    def draw_bottom_frame(width)
      print UI_FRAME_LOWER_LEFT.yellow
      (width - 2).times do
        print UI_FRAME_HORIZONTAL.yellow
      end
      puts UI_FRAME_LOWER_RIGHT.yellow
    end

    # Returns actual length of text accounting for UTF-8 and ANSI
    def get_real_size(text)
      if text.kind_of?(Array)
        text.size
      else
        text.uncolorize.size
      end
    end

    # Returns size of longest string in array
    def get_max_size_from_array(array)
      max = 0
      array.each do |s|
        s_size = get_real_size(s)
        max = s_size if s_size >= max
      end
      max + 4
    end
  end
end
