class DaysController < ApplicationController
    before_action :check_permission, only: [:play, :next_turn]

    def index
        @days = Day.order(created_at: :asc)
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
        @day = Day.create(status: :active)
        
        # 初期画像のセット (.envから)
        if ENV['INITIAL_IMAGE_#{@day.id}'] && File.exist?(ENV['INITIAL_IMAGE_#{@day.id}'])
          turn = @day.turns.create(turn_index: 1, prompt: ENV['INITIAL_PROMPT_#{@day.id}'])
          turn.image.attach(
            io: URI.open(ENV['INITIAL_IMAGE_#{@day.id}']),
            filename: "initial_image_#{@day.id}.png"
          )
        end
    
        redirect_to root_path, notice: "新しいゲーム(ID: #{@day.id})を作成しました"
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
        
        # 新しく生成されたターンがあるかチェック
        if session["new_turn_id_#{@day.id}"]
            @new_turn = @day.turns.find_by(id: session["new_turn_id_#{@day.id}"])
            session.delete("new_turn_id_#{@day.id}")
        end
    end

    def next_turn
        @day = Day.find(params[:id])
        prompt = params[:prompt]

        #次のターン
        next_turn_index = @day.turns.count + 1
        @new_turn = @day.turns.create(turn_index: next_turn_index, prompt: prompt)
        
        begin
            ImageGenerationService.new(@new_turn).call
            # 新しく生成されたターンIDをセッションに保存
            session["new_turn_id_#{@day.id}"] = @new_turn.id
            redirect_to play_day_path(@day), notice: "Turn created successfully"
        rescue ImageGenerationService::ImageGenerationError => e
            redirect_to play_day_path(@day), alert: e.message
        end
    end
    def check_permission
        @day = Day.find(params[:id])
        unless session["access_granted_#{@day.id}"]
          render plain: "access denied", status: :forbidden
        end
    end
end
