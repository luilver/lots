#!/usr/bin/env ruby

# Legend of the Sourcerer
# Written by Robert W. Oliver II <robert@cidergrove.com>
# Copyright (C) 2018 Sourcerer, All Rights Reserved.
# Licensed under GPLv3.

LOTS_VERSION = "1.00"

# Create a new UI and world
ui = LOTS::UI.new
world = LOTS::World.new

# Clear the screen and print welcome message
ui.clear
ui.welcome

# Ask name
name = ui.ask("What is your name?", /\w/)

# Create a new player
player = LOTS::Character.new({:name => name, :world => world})

# Show intro story
ui.new_line
story = LOTS::Story.new
ui.draw_frame({:text => story.intro})

# Show the map for the first time
map = world.get_map({:player => player})
ui.draw_frame({:text => map})

# MAIN INPUT LOOP
running = 1
while running
  ui.new_line
  # Get command from user
  cmd = ui.get_cmd
  case cmd
    when "~"
      binding.pry
    when "map", "m"
      map = world.get_map({:player => player})
      ui.draw_frame({:text => map})
    when "version", "ver"
      ui.display_version
    when "clear", "cls"
      ui.clear
    when "name", "whoami"
      ui.display_name({:player => player})
    when "location", "loc", "where", "whereami"
      ui.show_location({:player => player})
    when "look", "what", "around"
      world.check_area({:player => player, :ui => ui, :story => story})
    when "up", "north", "u", "n"
      unless player.in_combat
        if !player.move({:direction => :up, :world => world, :ui => ui, :story => story})
          player.in_combat = 1
	      end
      else
        ui.cannot_travel_combat
      end
    when "down", "south", "d", "s"
      unless player.in_combat
        if !player.move({:direction => :down, :world => world, :ui => ui, :story => story})
          player.in_combat = 1
	      end
      else
        ui.cannot_travel_combat
      end
    when "left", "west", "l", "w"
      unless player.in_combat
        if !player.move({:direction => :left, :world => world, :ui => ui, :story => story})
          player.in_combat = 1
	      end
      else
        ui.cannot_travel_combat
      end
    when "right", "east", "r", "e"
      unless player.in_combat
        if !player.move({:direction => :right, :world => world, :ui => ui, :story => story})
          player.in_combat = 1
	      end
      else
        ui.cannot_travel_combat
      end
    when "attack", "a"
      if player.in_combat
        retval = player.attack({:enemy => player.current_enemy, :ui => ui})
	      if retval == LOTS::ENEMY_KILLED
          player.lines += player.current_enemy.lines
          # Remove enemy from map
          world.the_map[player.y-1][player.x-1] = LOTS::MAP_KEY_GRASS
          # Take player out of combat
          player.current_enemy = nil
	        player.in_combat = false
	      end
	      if retval.is_a? Numeric
          player.current_enemy.health -= retval
	        retval = player.current_enemy.attack({:player => player})
	        if retval.is_a? Numeric
            player.health -= retval
          end
	      if retval == LOTS::PLAYER_DEAD
          player.dead = 1
	      end
	    end
    else
      ui.not_in_combat
    end
    when "player", "me", "info", "status", "i"
      ui.player_info({:player => player})
    when "enemy"
      if player.in_combat
        ui.enemy_info({:player => player})
      else
        ui.not_in_combat
      end
    when "lines", "score"
      ui.lines({:player => player})
    when "suicide"
      player.dead = 1
    when "help", "h", "?"
      ui.help
    when "quit", "exit"
      ui.quit
      running = nil
    else
      ui.not_found
  end
  # Is player in combat but has no enemy? Assign one.
  if player.in_combat && !player.current_enemy
    enemy = LOTS::Enemy.new
    player.current_enemy = enemy
    ui.enemy_greet({:enemy => enemy})
  end
  # Player is dead!
  if player.dead == 1
      ui.player_dead({:story => story})
    exit
  end
  # If player has reached Sourcerer
  if player.x == LOTS::MAP_WIDTH && player.y == 1
    ui.draw_frame({:text => story.ending})
    ui.new_line
    running = false
  end
end
