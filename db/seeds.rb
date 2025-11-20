# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb

4.times do |index|
  day = Day.create!(status: :active)
  puts "新しいゲーム(ID: #{day.id})を作成しました"
  image_path = ENV["INITIAL_IMAGE_#{index+1}"]
  prompt = ENV["INITIAL_PROMPT_#{index+1}"]
  turn = day.turns.create!(turn_index: 1, prompt: prompt)
  turn.image.attach(
    io: URI.open(image_path),
    filename: "initial_image_#{index+1}.png"
  )
  puts "初期画像をセットしました！"
end
