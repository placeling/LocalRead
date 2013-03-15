require 'set'
TWITTER_URL_LENGTH = 23

# dice coefficient = bigram overlap * 2 / bigrams in a + bigrams in b
# From: http://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Dice%27s_coefficient#Ruby
def dice_coefficient(a, b)
  a_bigrams = a.each_char.each_cons(2).to_set
  b_bigrams = b.each_char.each_cons(2).to_set
  
  overlap = (a_bigrams & b_bigrams).size
  
  total = a_bigrams.size + b_bigrams.size
  dice  = overlap * 2.0 / total
  
  dice
end

def twitter_shrink(title, remaining)
  if title.length > remaining
    title = "#{title[0..remaining-4]}..."
  end
  
  return title
end

class CityPostTweet
  include ApplicationHelper
  @queue = :twitter

  def self.perform()
    City.each do |city|
      if city.twitter_access_token
        begin
          entry = $redis.lpop( city.city_queue_key )
        end while !entry.nil? && city.tweeted_links.include?( entry[0] )

        unless entry.nil?
          entry = JSON.parse( entry )
          twitter_client = Twitter::Client.new(
              :oauth_token => city.twitter_access_token,
              :oauth_token_secret => city.twitter_access_secret
          )
          
          # entry[]
          # 0 = entry['url']
          # 1 = blogger['title']
          # 2 = entry.place['name']
          # 3 = blogger['twitter']
          # 4 = entry.place['twitter']
          # 5 = entry['title']
          
          title = nil
          coeff = nil
          if !entry[5].nil? && entry[5] != ''
            title = entry[5]
            coeff = dice_coefficient(title.downcase, entry[2].downcase)
          end
          
          blogger = nil
          if false #!entry[3].nil? && entry[3] != ""
            blogger = entry[3]
          else
            blogger = entry[1]
          end

          placename = nil
          if false #!entry[4].nil? && entry[4] != ""
            placename = entry[4]
          else
            placename = entry[2]
          end

          link = ApplicationHelper.short_url( entry[0], true )
          
          if title.nil?
            if entry[4].nil? || entry[4] == ""
              if !entry[3].nil? && entry[3] != ""
                text = "#{blogger}(#{entry[3]}) wrote about #{placename}: #{link} #yvr"
              else
                text = "#{blogger} wrote about #{placename}: #{link} #yvr"
              end
            else
              text = "#{blogger} wrote about #{placename} (#{entry[4]}): #{link} #yvr"
            end
          else
            if coeff > 0.25 # Determined experimentally. >0.25 means place name is also in blog post title
              value = rand(4)
              if entry[4].nil? || entry[4] == "" # No Twitter for place
                # NOT TESTING TO SEE IF TWITTER HANDLE FOR BLOGGER
                # THINK LIMITED VALUE IN TWEETING TO BLOGGERS - AS WILL HAVE ALREADY TWEETED IT
                # OPEN TO CHANGING THIS SO SHOUTING IN COMMENTS
                case value
                when 0
                  remaining = 140 - 4 - entry[1].length - 1 - TWITTER_URL_LENGTH
                  title = twitter_shrink(title,remaining)
                  
                  text = "#{title} by #{entry[1]} #{link}"
                when 1
                  remaining = 140 - entry[1].length - 2 - 1 - TWITTER_URL_LENGTH
                  title = twitter_shrink(title,remaining)
                  
                  text = "#{entry[1]}: #{title} #{link}"
                when 2
                  remaining = 140 - entry[1].length - 8 - 2 - TWITTER_URL_LENGTH
                  title = twitter_shrink(title,remaining)
                  
                  text = "#{entry[1]} wrote \"#{title}\" #{link}"
                when 3
                  remaining = 140 - 3 - entry[1].length - 1 - TWITTER_URL_LENGTH
                  title = twitter_shrink(title,remaining)
                  
                  text = "#{title} - #{entry[1]} #{link}"
                end
              else
                case value
                when 0
                  remaining = 140 - 4 - entry[1].length - 2 - entry[4].length - 2 - TWITTER_URL_LENGTH
                  title = twitter_shrink(title,remaining)
                  
                  text = "#{title} by #{entry[1]} (#{entry[4]}) #{link}"
                when 1
                  remaining = 140 - entry[1].length - 2 - 2 - entry[4].length - 2 - TWITTER_URL_LENGTH
                  title = twitter_shrink(title,remaining)
                  
                  text = "#{entry[1]}: #{title} (#{entry[4]}) #{link}"
                when 2
                  remaining = 140 - entry[1].length - 8 - 3 -entry[4].length - 2 - TWITTER_URL_LENGTH
                  title = twitter_shrink(title,remaining)
                  
                  text = "#{entry[1]} wrote \"#{title}\" (#{entry[4]}) #{link}"
                when 3
                  remaining = 140 - 3 - entry[1].length - 2 - entry[4].length - 2 - TWITTER_URL_LENGTH
                  title = twitter_shrink(title,remaining)
                  
                  text = "#{title} - #{entry[1]} (#{entry[4]}) #{link}"
                end
              end
            else
              value = rand(4)
              if entry[4].nil? || entry[4] == "" # No Twitter for place
                # NOT TESTING TO SEE IF TWITTER HANDLE FOR BLOGGER
                # THINK LIMITED VALUE IN TWEETING TO BLOGGERS - AS WILL HAVE ALREADY TWEETED IT
                # OPEN TO CHANGING THIS SO SHOUTING IN COMMENTS
                case value
                when 0
                  remaining = 140 - entry[1].length - 8 - 8 - entry[2].length - 1 - TWITTER_URL_LENGTH
                  title = twitter_shrink(title,remaining)
                  
                  text = "#{entry[1]} wrote \"#{title}\" about #{entry[2]} #{link}"
                when 1
                  remaining = 140 - 3 - entry[2].length - 3 - entry[1].length - 1 - TWITTER_URL_LENGTH
                  title = twitter_shrink(title,remaining)
                  
                  text = "#{title} | #{entry[2]} | #{entry[1]} #{link}"
                when 2
                  remaining = 140 - 4 - entry[1].length - 3 - entry[2].length - 1 - TWITTER_URL_LENGTH
                  title = twitter_shrink(title,remaining)
                  
                  text = "#{title} by #{entry[1]} - #{entry[2]} #{link}"
                when 3
                  remaining = 140 - entry[2].length - 2 - 3 - entry[1].length - 1 - TWITTER_URL_LENGTH
                  title = twitter_shrink(title,remaining)
                  
                  text = "#{entry[2]}: #{title} - #{entry[1]} #{link}"
                end
              else
                case value
                when 0
                  remaining = 140 - entry[1].length - 8 - 8 - entry[2].length - 2 - entry[4].length - 2 - TWITTER_URL_LENGTH
                  title = twitter_shrink(title,remaining)
                  
                  text = "#{entry[1]} wrote \"#{title}\" about #{entry[2]} (#{entry[4]}) #{link}"
                when 1
                  remaining = 140 - 3 - entry[2].length - 3 - entry[1].length - 2 - entry[4].length - 2 - TWITTER_URL_LENGTH
                  title = twitter_shrink(title,remaining)
                  
                  text = "#{title} | #{entry[2]} | #{entry[1]} (#{entry[4]}) #{link}"
                when 2
                  remaining = 140 - 1 - 5 - entry[1].length - 3 - entry[2].length - 2 - entry[4].length - 2 - TWITTER_URL_LENGTH
                  title = twitter_shrink(title,remaining)
                  
                  text = "\"#{title}\" by #{entry[1]} - #{entry[2]} (#{entry[4]}) #{link}"
                when 3
                  remaining = 140 - entry[2].length - 3 - 4 - entry[1].length - 2 - entry[4].length - 2 - TWITTER_URL_LENGTH
                  title = twitter_shrink(title,remaining)
                  
                  text = "#{entry[2]}: \"#{title}\" - #{entry[1]} (#{entry[4]}) #{link}"
                end
              end
              
            end
          end
          


          puts "#{text} :: #{text.length}"

          city.tweeted_links << entry[0]
          city.save

          if Rails.env.production?
            twitter_client.update( text.html_safe )
          end
        end

      end
    end
  end
end