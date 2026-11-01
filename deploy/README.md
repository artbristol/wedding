# Bare-metal deployment (Debian 13, systemd)

This is how the production site (example-site.example) is deployed: Puma on a
single small VM behind a **Cloudflare Tunnel** (no public ports, no local
TLS; see AGENTS.md). PostgreSQL from apt. Adjust the `art` user and
`/home/USER/wedding` paths to taste.

The `Caddyfile` here is a **fallback** for a direct deployment without the
tunnel (Caddy on ports 80/443 with automatic Let's Encrypt); production
does not use it.

Files:

- `wedding.service` — systemd unit for the app; install to
  `/etc/systemd/system/wedding.service`
- `Caddyfile` — reverse proxy with automatic Let's Encrypt certificates;
  install to `/etc/caddy/Caddyfile`

## 1. Packages and swap

    sudo apt-get install -y ruby-full ruby-dev build-essential libpq-dev \
      postgresql postgresql-contrib caddy nodejs git bundler

On small VMs add swap so `bundle install` and asset precompilation do not OOM:

    sudo fallocate -l 1G /swapfile && sudo chmod 600 /swapfile
    sudo mkswap /swapfile && sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

## 2. PostgreSQL

    sudo systemctl enable --now postgresql
    sudo -u postgres psql -c "CREATE ROLE wedding LOGIN PASSWORD '<password>';"
    sudo -u postgres psql -c "CREATE DATABASE wedding_production OWNER wedding;"

Debian's default `pg_hba.conf` uses peer auth for local connections; add this
line **above** the other `local` rules so the app can authenticate with a
password over the unix socket:

    local wedding_production wedding scram-sha-256

Then `sudo systemctl reload postgresql@17-main`.

## 3. Application

    git clone -b revival/rails-modern \
      https://github.com/artbristol/wedding.git ~/wedding
    cd ~/wedding
    bundle config set --local path vendor/bundle
    bundle config set --local without "development test"
    bundle install
    bundle binstubs puma --force
    RAILS_ENV=production SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

## 4. Environment file

`/home/USER/wedding/.env.production` (mode 600), referenced by the systemd
unit. See the main README for the full list of variables.

    RAILS_ENV=production
    SECRET_KEY_BASE=$(openssl rand -hex 64)
    WEDDING_DATABASE_PASSWORD=<password from step 2>
    CANONICAL_HOST=example-site.example
    RAILS_SERVE_STATIC_FILES=1
    # SMTP_ADDRESS etc. — unset until SMTP is configured; emails are then
    # logged and discarded instead of being sent.

## 5. Database setup and admin user

    cd ~/wedding
    set -a; . ./.env.production; set +a
    bundle exec rails db:migrate db:seed

`db:seed` prints the generated admin credentials — save them somewhere safe
and change the password after first login at `https://<domain>/admin`.

## 6. Services

    sudo cp deploy/wedding.service /etc/systemd/system/
    sudo cp deploy/Caddyfile /etc/caddy/Caddyfile
    sudo systemctl daemon-reload
    sudo systemctl enable --now wedding caddy

Caddy obtains and renews the TLS certificate automatically; an IPv6-only
AAAA record is sufficient for Let's Encrypt.

## Updating

Deploys are automated: pushing to `main` triggers the self-hosted GitHub
Actions runner on the server (`.github/workflows/deploy.yml`), which pulls,
bundles, precompiles, migrates, restarts and smoke-tests. The steps below are
the manual fallback.

    cd ~/wedding
    git pull
    bundle install
    RAILS_ENV=production SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile
    set -a; . ./.env.production; set +a
    bundle exec rails db:migrate
    sudo systemctl restart wedding

Always run `bundle install` after `git pull` and **before** restarting: if the
Gemfile changed (e.g. a dependency was removed) and Puma restarts against the
old bundle, it can crash-loop at boot (a fresh boot only loads the code plus
whatever gems are installed). The app boots its Rack middleware stack from
`config.ru`, so root-level files matter too — grep the whole repo before
declaring a gem unused.
