require "openai"

class DaysController < ApplicationController
    before_action :check_permission, only: [:play, :next_turn]

    def index
        @days = Day.order(created_at: :desc)
    end

    def entry
        @day = Day.find(params[:id])
        if params[:pass] == ENV['PLAY_PASS']
          session["access_granted_#{@day.id}"] = true
          redirect_to play_day_path(@day), notice: "playable in this machine"
        else
          render plain: "access denied", status: :forbidden
        end
    end
    def create
        day = Day.create(status: :active)
        
        # 初期画像のセット (.envから)
        if ENV['INITIAL_IMAGE_1'] && File.exist?(ENV['INITIAL_IMAGE_1'])
          turn = day.turns.create(turn_index: 1, prompt: ENV['INITIAL_PROMPT_1'])
          turn.image.attach(
            io: URI.open(ENV['INITIAL_IMAGE_1']),
            filename: "initial_image_1.png"
          )
        end
    
        redirect_to root_path, notice: "新しいゲーム(ID: #{day.id})を作成しました"
    end

    def show
        @day = Day.find(params[:id])
        @turns = @day.turns.order(:turn_index)
    end

    def play
        @day = Day.find(params[:id])

        if @day.turns.empty?
            render "No data found"
            return
        end
        @last_turn = @day.turns.last
    end

    def next_turn
        @day = Day.find(params[:id])
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

        redirect_to play_day_path(@day), notice: "Turn created successfully"
    end
    def check_permission
        @day = Day.find(params[:id])
        unless session["access_granted_#{@day.id}"]
          render plain: "access denied", status: :forbidden
        end
    end
end
