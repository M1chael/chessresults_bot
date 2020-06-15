FROM ruby:2.7.1-alpine3.12

RUN apk add --no-cache sqlite sqlite-dev build-base

WORKDIR /app

COPY . /app

RUN chown -R guest /app
RUN bundle install

USER guest

CMD ["ruby", "bin/chessresults_bot.rb", "--listen"]
#ENTRYPOINT ["sh", "-c", "sleep 2073600"]
