require 'selenium-webdriver'
require 'io/console'
require 'open-uri'

class NicoManArchiver
    def initialize()
        @driver = Selenium::WebDriver.for :chrome
        @driver.manage.timeouts.implicit_wait = 10
        @driver.get("https://account.nicovideo.jp/login")
        id, pass = get_loginInfo()
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
    def get_loginInfo
        puts "login id?"
        id = STDIN.gets.chomp
        puts "login password?"
        pass = STDIN.noecho(&:gets).chomp
        return id, pass
    end
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

maintask = NicoManArchiver.new
ARGV.each_with_index do |arg, i|
    if arg == "--url" then
        maintask.get_all(ARGV[i+1])
    end
end
maintask.quit