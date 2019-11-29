FROM ruby:latest

WORKDIR /usr/src/app
COPY Gemfile* ./
RUN bundle install
# COPY . .

EXPOSE 3000

CMD bundle exec rails s --binding 0.0.0.0

