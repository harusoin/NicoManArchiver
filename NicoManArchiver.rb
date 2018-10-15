require 'selenium-webdriver'
require 'io/console'
require 'open-uri'
require 'optparse'

class NicoManArchiver
    def initialize()
        @driver = Selenium::WebDriver.for :chrome
        @driver.manage.timeouts.implicit_wait = 10
    end
    def login(id, pass)
        @driver.get("https://account.nicovideo.jp/login")
        begin
            element = @driver.find_element(:id, 'input__mailtel')
            element.send_keys(id)
            element = @driver.find_element(:id, 'input__password')
            element.send_keys(pass)
            element = @driver.find_element(:id, 'login__submit')
            element.click
        rescue
            self.quit
        end
    end
    def get_all(url)
        @driver.get(url)
        loop do
            get_content()
            element = @driver.find_element(:id, 'full_episode_control_bar').
                            find_element(:class, 'next').
                            find_element(:tag_name, 'a')
            break unless(element.attribute('href'))
            element.click
        end
    end
    def quit
        @driver.quit
    end
    private
    def download_data(url, filePath)
        dirPath = File.dirname(filePath)
        FileUtils.mkdir_p(dirPath) unless FileTest.exist?(dirPath)
        open(filePath, 'wb') do |output|
            open(url) do |data|
                output.write(data.read)
            end
        end
        sleep(1)
    end
    def get_content
        element = @driver.find_element(:id,"full_watch_head_bar").
                            find_element(:class,"manga_info")
        dirPath = element.find_element(:class,"author_name").text
        dirPath += "/" + element.find_element(:class,"manga_title").
                                find_element(:tag_name,"a").text
        dirPath += "/" + @driver.find_element(:id,"full_watch_head_bar").
                                find_element(:class,"episode_title").text
        element = @driver.find_element(:id, 'page_contents')
        elements = element.find_elements(:class, "lazyload")
        elements.each_with_index do |e,i|
            filePath=dirPath + "/" + format('%04d', i+1) + ".jpg"
            download_data(e.attribute("data-original"),filePath)
        end
    end
end

option={}
OptionParser.new do |opt|
    opt.on("-u", "--url=VALUE", "VALUE is base download URL"){|v| option[:url] = v}
    opt.on("-i", "--id=VALUE", "niconico account ID"){|v| option[:id] = v}
    opt.on("-p", "--password=VALUE", "niconico account password"){|v| option[:password] = v}
    opt.parse!(ARGV)
end

maintask = NicoManArchiver.new
if option[:id] == nil then
    puts "login id?"
    login_id = STDIN.gets.chomp
else
    login_id = option[:id]
end
if option[:password] == nil then
    puts "login password?"
    login_pass = STDIN.noecho(&:gets).chomp
else
    login_pass = option[:password]
end
maintask.login(login_id, login_pass)
maintask.get_all(option[:url]) if option[:url] != nil
maintask.quit()