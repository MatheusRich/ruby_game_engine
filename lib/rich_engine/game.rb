# frozen_string_literal: true

require_relative "canvas"
require_relative "io"

module RichEngine
  # Example:
  #
  #   class MyGame < RichEngine::Game
  #     def on_create
  #       @title = "My Awesome Game"
  #     end
  #
  #     def on_update(elapsed_time, key)
  #       quit! if key == :q
  #
  #       @canvas.write_string(@title, x: 1, y: 1)
  #     end
  #   end
  #
  #   MyGame.play
  #
  class Game
    class Exit < StandardError; end

    def initialize(width, height)
      @width = width
      @height = height
      @io = RichEngine::IO.new(width, height)
      @canvas = RichEngine::Canvas.new(width, height)
    end

    def self.play(width = 50, height = 10)
      new(width, height).play
    end

    def play
      Terminal.clear
      Terminal.hide_cursor
      Terminal.disable_echo

      on_create

      previous_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      loop do
        current_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        elapsed_time = current_time - previous_time
        previous_time = current_time

        key = read_input
        should_keep_playing = check_exit { on_update(elapsed_time, key) }
        draw

        break unless should_keep_playing
      end

      on_destroy
    ensure
      Terminal.display_cursor
      Terminal.enable_echo
    end

    def on_create
    end

    def on_update(_elapsed_time, _key)
    end

    def on_destroy
    end

    def draw
      @io.write(@canvas.canvas)
    end

    def quit!
      raise Exit
    end

    private

    def read_input
      @io.read_async
    end

    def render
      @io.write(@canvas.canvas)
    end

    def check_exit
      yield

      true
    rescue Exit
      false
    end
  end
end
