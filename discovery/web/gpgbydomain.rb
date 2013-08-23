require 'open-uri'
require 'set'
require 'plugins'

#
# Check against GPG keyserver.
#
class HostmapPlugin < Hostmap::Plugins::BasePlugin

  def info
    {
      :name => "GPGByDomain",
      :author => "Alessandro Tanasi",
      :version => "0.3",
      :require => :domain,
      :description => "Check against GPG keyserver."
    }
  end

  def execute(domain, opts = {})
    begin
      page = open("http://pgp.mit.edu:11371/pks/lookup?search=#{domain}&op=index").read
    rescue
      return @res
    end

    page.scan(/&lt;.*@(.*?)&gt;<\/a>/).each do |url|
      @res << { :hostname => url.to_s }
    end

    return @res
  end
end
