FROM elixir:1.19.5

RUN apt-get update \
  && apt-get install -y build-essential git \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV MIX_ENV=dev

RUN mix local.hex --force \
  && mix local.rebar --force

COPY mix.exs mix.lock ./
COPY config ./config
RUN mix deps.get

COPY . .

CMD ["mix", "phx.server"]
