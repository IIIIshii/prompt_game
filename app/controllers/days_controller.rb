require "openai"

class DaysController < ApplicationController
    before_action :check_permission, only: [:play, :next_turn]

    def entry
        if params[:pass] == ENV['PLAY_PASS']
          session[:access_granted] = true
          redirect_to play_days_path, notice: "playable in this machine"
        else
          render plain: "access denied", status: :forbidden
        end
      end

    def play
        @day = Day.last

        if @day.nil? || @day.turns.empty?
            render "No data found"
            return
        end
        @last_turn = @day.turns.last
    end

    def next_turn
        @day = Day.last
        prompt = params[:prompt]

        #次のターン
        next_turn_index = @day.turns.count + 1
        @new_turn = @day.turns.create(turn_index: next_turn_index, prompt: prompt)
        @client = OpenAI::Client.new
        response = @client.images.generate(
            parameters: {
                model: "dall-e-2",
                prompt: @new_turn.prompt,
                n: 1,
                size: "512x512"
            }
        )
        image_url = response.dig("data", 0, "url")
        image_data = URI.open(image_url)
        @new_turn.image.attach(io: image_data, filename: "turn_#{next_turn_index}.png")

        redirect_to play_days_path, notice: "Turn created successfully"
    end
    def check_permission
        unless session[:access_granted]
          render plain: "access denied", status: :forbidden
        end
    end
    def index
        @day = Day.last
        if @day
          @turns = @day.turns.order(:turn_index)
        else
          @turns = []
        end
        render "index"
    end
end
