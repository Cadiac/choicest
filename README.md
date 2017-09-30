[![Build Status](https://travis-ci.org/Cadiac/choicest.svg?branch=master)](https://travis-ci.org/Cadiac/choicest)

# Choicest

## Quickstart

  * Install dependencies with `mix deps.get`
  * Copy .env.sample into .env, fill in the blanks and source the file
  * Start database with `docker-compose up -d`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Requirements

  * [Elixir 1.5.x](https://elixir-lang.org/install.html)
  * [PostgreSQL 9.6](https://www.postgresql.org/)
  * [NodeJS](https://nodejs.org/en/)
  * [Docker](https://www.docker.com/) (Optional) for setting up database for development
  * [AWS](https://aws.amazon.com/) credentials

## Environment

This project utilized environment variables for secrets and app configuration.

Begin by copying `.env.sample` into `.env` file, which should never be added into version control. You can load environment variables defined in `.env` file into your environment by running

Create new IAM user on AWS with no special roles, and copy its ARN. You can then create Cloudformation stack with `tools/cloudformation.json`, which creates a bucket with proper permissions. You should create a separate bucket for dev, testing and production use. Enter the newly created AWS credentials into your `.env` file, and keep them safe.

After you have installed dependencies with `mix deps.get` you can generate secrets for `GUARDIAN_SECRET_KEY` and `SECRET_KEY_BASE` by running command

```
mix phx.gen.secret
```

Make sure you generate unique secrets for production, testing and development environments!

## Testing

To run all tests run

```
mix test
```

or for more verbose run use

```
mix test --trace
```

## Debugging

To debug code, you can stop the execution at a desired place by adding

```
require IEx;

# Debugger will stop here
IEx.pry
```

Next start a new IEx session with

```
iex -S mix phx.server
````

Execution should stop at `IEx.pry`, and you can restart it with `respawn`.


### Travis

This project supports Travis CI for automatically running tests. Remember to setup your environment variables there too!

## Deployment

The project is deployed on Heroku with Postgres plugin.

```
git push heroku master
```

