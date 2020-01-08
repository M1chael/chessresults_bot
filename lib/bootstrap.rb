$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'yaml'
require 'bot'

wd = File.join(File.expand_path(File.dirname(__FILE__)), '..')
CONFIG = YAML.load_file(File.join(wd, 'assets', 'config.yml'))
DB = Sequel.sqlite(File.join(wd, 'assets', CONFIG[:db]))
@logger = Logger.new(File.join(wd, CONFIG[:log]), 'monthly')
@bot = Bot.new(token: CONFIG[:telegram_token], logger: @logger)
