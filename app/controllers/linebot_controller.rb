class LinebotController < ApplicationController
    require 'line/bot'
    protect_from_forgery :except => [:callback]
    def callback
        body = request.body.read
        signature = request.env['HTTP_X_LINE_SIGNATURE']
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
                        message = [type: 'text', text: 'おかえり']
                        client.reply_message(event['replyToken'], message)
                    elsif word.include?("いってきます")
                        message = [type: 'text', text: "いってらいっしゃい"]
                        client.reply_message(event['replyToken'], message)
                    else
                        seed = select_word.sample
                        message = [type: 'text', text: "#{seed}"]
                        client.reply_message(event['replyToken'], message)
                    end
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
    def select_word
        seeds = ["うんこ", "ちんこ", "おちんちん", "おっぱい", "おまんちん
            スプラッシュ"]
        #seeds.sample
    end

    def reply
        
    end
end
