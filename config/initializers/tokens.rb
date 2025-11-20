OpenAI.configure do |config|
  config.access_token = ENV.fetch("OPENAI_API_TOKEN")
  #長めに待つ
  config.request_timeout = 240
end