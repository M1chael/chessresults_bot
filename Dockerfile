FROM ruby:2.7.1-alpine3.12

RUN apk add --no-cache sqlite sqlite-dev build-base

WORKDIR /app

COPY . /app

RUN bundle install --without=test

CMD ["ruby", "bin/chessresults_bot.rb", "--listen"]
