module Helpers
  def stub_web(type, request, file_name)
	  stub_request(type, request).
	    with(:headers => {'User-Agent' => 'Telegram bot for the notifying about results: @chessresults_bot'}).
	    to_return(File.read(File.join('test/pages/', file_name)))
  end
end
