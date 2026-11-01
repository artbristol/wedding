FROM ruby:3.3

ENV RAILS_SERVE_STATIC_FILES="1"

RUN apt-get update -qq &&\
  curl -sL https://deb.nodesource.com/setup_20.x | bash - &&\
  apt-get install -y --no-install-recommends build-essential libpq-dev nodejs &&\
  rm -rf /var/lib/apt/lists/* &&\
  useradd --user-group --create-home --shell /bin/false app

ENV HOME=/home/app
USER app

COPY --chown=app:app Gemfile Gemfile.lock $HOME/wedding/
WORKDIR $HOME/wedding
RUN bundle install

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

COPY --chown=app:app . $HOME/wedding/
