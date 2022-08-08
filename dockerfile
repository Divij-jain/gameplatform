# File: base dockerfile
FROM elixir:1.13-alpine AS build-base

RUN apk add --no-cache \
    git \
    npm \ 
    openssh-client 

ARG github_access_token 
RUN git config --global url."https://${github_access_token}:x-oauth-basic@github.com/".insteadOf "git@github.com:"


#setting the working directory
WORKDIR /gameplatform

# install Hex + Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# TOOL Configuration 
ADD .formatter.exs ./


#installing mix dependencies
ADD mix.* ./
COPY config config/

RUN mix deps.get 
RUN mix deps.compile

# build assets

COPY priv priv
COPY lib lib
COPY assets assets

ENV MIX_ENV=prod

RUN mix phx.digest

RUN mix compile
RUN mix release  

EXPOSE 4000

CMD ["/gameplatform/_build/prod/rel/gameplatform/bin/gameplatform", "start_iex"]




