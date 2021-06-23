ARG MIX_ENV="prod"

FROM hexpm/elixir:1.11.2-erlang-23.1.2-alpine-3.12.1 as build

# install build dependencies
RUN apk add --no-cache build-base npm git python3 curl

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
  mix local.rebar --force

# set build ENV
ARG MIX_ENV
ENV MIX_ENV="${MIX_ENV}"

# install mix dependencies
COPY mix.exs mix.lock .
RUN mix deps.get --only $MIX_ENV
RUN mkdir config
# Dependencies sometimes use compile-time configuration. Copying
# these compile-time config files before we compile dependencies
# ensures that any relevant config changes will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/$MIX_ENV.exs config/
RUN mix deps.compile

# build assets
COPY assets/package.json assets/package-lock.json ./assets/
# install all npm dependencies from scratch
RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error

COPY priv priv

# Note: if your project uses a tool like https://purgecss.com/,
# which customizes asset compilation based on what it finds in
# your Elixir templates, you will need to move the asset compilation step
# down so that `lib` is available.
COPY assets assets
# use webpack to compile npm dependencies - https://www.npmjs.com/package/webpack-deploy
RUN npm run --prefix ./assets deploy
RUN mix phx.digest

# compile and build the release
COPY lib lib
RUN mix compile
# changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/
# uncomment COPY if rel/ exists
# COPY rel rel
RUN mix release


# Start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM alpine:3.12.1 AS app
RUN apk add --no-cache openssl ncurses-libs

ARG MIX_ENV
ENV USER="elixir"

WORKDIR "/home/${USER}/app"
# Creates an unprivileged user to be used exclusively to run the Phoenix app
RUN \
  addgroup \
  -g 1000 \
  -S "${USER}" \
  && adduser \
  -s /bin/sh \
  -u 1000 \
  -G "${USER}" \
  -h /home/elixir \
  -D "${USER}" \
  && su "${USER}"

# Everything from this line onwards will run in the context of the unprivileged user.
USER "${USER}"

COPY --from=build --chown="${USER}":"${USER}" /app/_build/"${MIX_ENV}"/rel/drops ./

ENTRYPOINT ["bin/drops"]

# Usage:
#  * build: sudo docker image build -t drops/app .
#  * shell: sudo docker container run --rm -it --entrypoint "" -p 127.0.0.1:4000:4000 drops/app sh
#  * run:   sudo docker container run --rm -it -p 127.0.0.1:4000:4000 --name drops drops/app
#  * exec:  sudo docker container exec -it drops sh
#  * logs:  sudo docker container logs --follow --tail 100 drops
CMD ["start"]
