class LinebotController < ApplicationController
    require 'line/bot'
    protect_from_forgery :except => [:callback]
    def callback
        body = request.body.read
        signature = request.env['HTTP_X_LINE_SIGNATURE']
        seeds = ["うんこ", "ちんこ", "おちんちん", "おっぱい", "おまんちんスプラッシュ", 
                 "ちんちん", "お尻がおまんこになっちゃう"]
        greetings = ["おはよう。今日も頑張ってね", "いってらっしゃい", "お帰り、一日お疲れ様", "お休みなさい。"]
        praises = ["いつも頑張っててすごいね", "よしよし、毎日お疲れ様", "無理しなくてもいいんだよ？",
                   "身体壊さないようにね", "今日はゆっくり休んでね", "今日も大変だったね"]
        complaints = ["つかれた", "疲れた", "つらい", "辛い", "褒めて", "誉めて", "ほめて"]
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
                    if word.include?("おはよう")
                        seed = greetings[0]
                    elsif word.include?("行ってきます")
                        seed = greetings[1]
                    elsif word.include?("ただいま")
                        seed = greetings[2]
                    elsif word.include?("お休み")
                        seed = greetings[3]
                    elsif word.include?(complaints.to_s)
                        seed = praises.sample
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
