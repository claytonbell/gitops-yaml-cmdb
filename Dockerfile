FROM ruby:2.6

RUN mkdir /app

WORKDIR /app

COPY Gemfile /app
COPY Gemfile.lock /app

RUN bundle install

CMD /bin/bash