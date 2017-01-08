module Ruboty
  module Handlers
    class RandomHatenaBookmark < Base
      on(
          /hatebu (?<user>.*?) (?<count>\d*?)\z/,
          name: 'run',
          description: ' 指定したユーザのブックマークからcount個ランダムに表示します'
      )

      Slack.configure do |config|
        config.token = ENV['SLACK_TOKEN']
      end

      def hatena_bookmark_rss(user, offset = nil)
        url = "http://b.hatena.ne.jp/#{user}/rss"
        url += "?of=#{offset}" if offset
        rss_url = URI.parse(url)
        http = Net::HTTP.new(rss_url.host, rss_url.port)
        # http.set_debug_output($stderr)
        res = http.get("#{rss_url.path}?#{rss_url.query}", {'User-Agent' => 'curl/7.51.0'})
        res.body
      end

      def total_result(user)
        rss = hatena_bookmark_rss(user)
        namespaces = {
            'opensearch' => 'http://a9.com/-/spec/opensearchrss/1.0/'
        }
        Nokogiri::XML.parse(rss).at('.//opensearch:totalResults', namespaces).text.to_i
      end

      def get_item(user, index)
        offset = index / 20 * 20
        logger.info("offset = #{offset}")
        rss = hatena_bookmark_rss(user, offset)
        namespaces = { 'rss' => 'http://purl.org/rss/1.0/' }
        item_index = index % 20
        logger.info("item_index = #{item_index}")
        item = Nokogiri::XML.parse(rss).xpath("//rss:item[#{item_index}]", namespaces)

        {
            about: item.first.attributes['about'].value,
            title: item.xpath('.//rss:title', namespaces).text,
            link: item.xpath('.//rss:link', namespaces).text,
            date: item.xpath('.//dc:date').text
        }
      end

      def run(message = nil)
        user = message[:user]
        count = message[:count] ? message[:count].to_i : 1

        total = total_result(user)
        count.times do
          index = rand(total)

          item = get_item(user, index)
          logger.info("get item: #{item[:about]}")

          title = item[:title]
          link = item[:link]
          date = Date.parse(item[:date]).strftime('%Y年%m月%d日')

          # message.reply("<#{link}|#{title}>")
          param = {
              token: ENV['SLACK_TOKEN'],
              channel: 'general',
              text: "#{date} <#{link}|#{title}>"
          }
          Slack.chat_postMessage(param)
        end
      end

      def logger
        @logger ||= Logger.new(STDERR)
      end
    end
  end
end
