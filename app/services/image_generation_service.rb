require "openai"

class ImageGenerationService
  def initialize(turn)
    @turn = turn
    @client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_TOKEN"))
  end

  def call
    response = @client.images.generate(
      parameters: {
        model: "dall-e-2",
        prompt: @turn.prompt,
        n: 1,
        size: "512x512"
      }
    )
    
    image_url = response.dig("data", 0, "url")
    image_data = URI.open(image_url)
    @turn.image.attach(
      io: image_data,
      filename: "turn_#{@turn.turn_index}.png"
    )
    
    @turn
  rescue => e
    Rails.logger.error "画像生成エラー: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise ImageGenerationError, "画像生成に失敗しました: #{e.message}"
  end

  class ImageGenerationError < StandardError; end
end

