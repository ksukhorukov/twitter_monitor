cat stream_parse.rb 
require "rubygems"
require "tweetstream"
require "active_support/core_ext"


trap("SIGINT") { 
  @client.stop
  @report.close
  puts "[+] Stoped"
  exit!
}

TweetStream.configure do |config|
  config.consumer_key = ''
  config.consumer_secret = ''
  config.oauth_token = ''
  config.oauth_token_secret = ''
  config.auth_method        = :oauth
end


report_name = "report_" + Time.now.strftime('%Y%m%d%H%M%S%L') + ".log"
@report = File.open(report_name, "w")

@client = TweetStream::Client.new

@client.on_error do |msg|
  puts "[-] Error: #{msg}"
end


puts "[+] Starting twitter monitor"


@client.track('такой', 'такая', 'такое', 'такие') do |status|
   puts "@#{status.user[:name]} http://twitter.com/#{status.user[:id]}/status/#{status.id} #{status.text}"
   message = status.text
   message.gsub!(/[[:punct:]]/, ' ')
   message = message.mb_chars.downcase.to_s
   unless message.empty?
     parts = message.partition(/такой|такая|такое|такие/i).map(&:strip)
     head = parts[0].split(/\s+/)
     tail = parts[2].split(/\s+/)
     maxSize = [ head.length, tail.length ].min
     wordIndex = 1
     if maxSize >= 1
       while(wordIndex <= maxSize)
         if head.slice(-wordIndex, wordIndex).join(' ') == tail.slice(0, wordIndex).join(' ')
           @report <<  "@#{status.user[:name]} http://twitter.com/#{status.user[:id]}/status/#{status.id} #{status.text}\n"
           break
         end
         wordIndex += 1
       end
     end
   end
end


