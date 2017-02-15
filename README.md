# docker-rails-boilerplate

## How to use

```
# Start container
$ docker-compose up -d

# Create database
$ docker-compose run --rm app rails db:create

# Generate scaffold
$ docker-compose run --rm app rails g scaffold post title:string body:text published:boolean

# Migrate database
$ docker-compose run --rm app rails db:migrate

# Add gem and update Gemfile.lock
$ echo "gem 'rspec-rails', group: [:development, :test]" >> Gemfile
$ docker-compose run --rm app bundle install
```
