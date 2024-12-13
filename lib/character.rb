#!/usr/bin/env ruby
#
# Legend of the Sourcerer
# Written by Robert W. Oliver II <robert@cidergrove.com>
# Copyright (C) 2018 Sourcerer, All Rights Reserved.
# Licensed under GPLv3.

module LOTS
  ATTACK_VALUE_MODIFIER = 1
  ENEMY_KILLED = "KILLED"
  HIT_CHANCE_MODIFIER = 5

  class Character
    attr_accessor :current_enemy, :dead, :health, :in_combat, :int, :level, :lines
    attr_accessor :mana, :name, :str, :x, :y

    def initialize(args)
      name = args[:name]
      world = args[:world]

      @current_enemy = nil
      @dead = 0
      @health = 100
      @in_combat = false
      @int = 5
      @level = 1
      @lines = 0
      @mana = 100
      @name = name
      @str = 5
      @x = 1
      @y = world.get_height

      "Welcome %{name}! Let's play Legend of the Sourcerer!"
    end

    # Player attacks enemy
    def attack(args)
      player = self
      enemy = args[:enemy]
      ui = args[:ui]

      # Does the player even hit the enemy?
      # We could use a hit chance stat here, but since we don't have one,
      # we'll just base it off the player/enemy stength discrepency.
      ui.enemy_info({:player => player})
      ui.player_info({:player => player})
      str_diff = (player.str - enemy.str) * 2
      hit_chance = rand(1...100) + str_diff + HIT_CHANCE_MODIFIER

      if (hit_chance > 50)
        # Determine value of the attack
        attack_value = rand(1...player.str) + ATTACK_VALUE_MODIFIER
        if attack_value > enemy.health
          puts <<-Swing
You swing and #{'hit'.light_yellow} the #{enemy.name.light_red} for \
#{attack_value.to_s.light_white} damage, killing it!
          Swing
          puts "You gain #{enemy.lines.to_s.light_white} lines of code."
          return ENEMY_KILLED
        else
          puts <<-Swing
You swing and #{'hit'.light_yellow} the #{enemy.name.light_red} for \
#{attack_value.to_s.light_white} damage!
          Swing
          return attack_value
        end
      else
        puts "You swing and #{'miss'.light_red} the #{enemy.name} !"
        return 0
      end
      return true
    end

    def move(args)
      direction = args[:direction]
      world = args[:world]
      ui = args[:ui]
      story = args[:story]
      case direction
        when :up
          if @y > 1
            @y -= 1
          else
            ui.out_of_bounds
            return false
          end
        when :down
          if @y < world.get_height
            @y += 1
          else
            ui.out_of_bounds
            return false
          end
        when :left
          if @x > 1
            @x -= 1
          else
            ui.out_of_bounds
            return false
          end
        when :right
          if @x < world.get_width
            @x += 1
          else
            ui.out_of_bounds
            return false
          end
        end
      unless world.check_area({:player => self, :ui => ui, :story => story})
        return false
      else
        return true
      end
    end
  end
end
