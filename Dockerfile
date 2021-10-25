FROM ruby:2.7

RUN mkdir /app

WORKDIR /app

COPY Gemfile /app
COPY Gemfile.lock /app

RUN bundle install

CMD /bin/bash
