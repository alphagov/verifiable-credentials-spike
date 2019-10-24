# Verifiable Credentials Spike

## Setup

`bundle install`

`bundle exec rails s`

## Issuing Credentials

Currently has 2 different endpoints:

`/issue/:type`

`/issue/jwt/:type`

Type can be either `credential` or `presentation`
