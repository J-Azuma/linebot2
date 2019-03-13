class LinebotController < ApplicationController
    require 'line/bot'
    protect_from_forgery :except => [:callback]
    def callback
        body = request.body.read
        signature = request.env['HTTP_X_LINE_SIGNATURE']
        seeds = ["うんこ", "ちんこ", "おちんちん", "おっぱい", "おまんちん
            スプラッシュ", "おかえり", "いってらっしゃい"]
        unless client.validate_signature(body, signature)
            head :bad_request
        end
        events = client.parse_events_from(body)
        events.each{ |event|
            case event
            when Line::Bot::Event::Message
                case event.type
                when Line::Bot::Event::MessageType::Text
                    word = event.message['text'] 
                    if word.include?("ただいま")
                        seed = seeds[5]
                    elsif word.include?("いってきます")
                        seed = seeds[6]
                    else
                        seed = seeds.sample
                    end
                    message = [type: 'text', text: "#{seed}"]
                    client.reply_message(event['replyToken'], message)
                end
            end   
        }
        head :ok
    end
    #private 
    def client
        @client ||= Line::Bot::Client.new { |config|
            config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
            config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
        }
    end

        #seeds = ["うんこ", "ちんこ", "おちんちん", "おっぱい", "おまんちんスプラッシュ", "おかえり", "いってらっしゃい"]
end
