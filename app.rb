require 'net/http'
require 'uri'
require 'sinatra'

configure do
  set :bind, '0.0.0.0'
end

def get_page_text(project, page)
  req = Net::HTTP::Get.new("/api/pages/#{project}/#{URI.encode(page)}/text")
  res = Net::HTTP.start('scrapbox.io', 443, use_ssl: true) { |http|
    http.request(req)
  }
  if res.code == '200'
    return res.body.split("\n", 2)[1] || ''
  end
end

get '/' do
  src = params['src']
  dst = params['dst']

  project = nil
  title = nil
  body = ' '

  if src && src =~ %r{\A([^/]+)/(.+)\z}
    body = get_page_text($1, $2)
  end

  if dst && dst =~ %r{\A([^/]+)(?:/(.+)?)?\z}
    if $1
      project = $1
    end
    if $2
      title = $2
    end
  end

  unless title
    title = Time.now.strftime('%Y-%m-%d %H:%M:%S')
  end

  if project && title
    redirect "https://scrapbox.io/#{project}/#{URI.encode(title)}?body=#{URI.encode(body)}", "redirect"
  end

  slim :index
end
