 # TUM SM Server

Backend of our TUM SM system for telemonitoring athletes and patients.

## Initial Setup

1. Requirements

    Make sure you have up-to-date versions of the following tools

        $ docker --version
        Docker version 20.10.6, build 370c289

        $ docker-compose --version
        docker-compose version 1.29.1, build c34c88b2

2. Copy the `.env.example` template file

        cp .env.example .env

3. Create an empty file for the sqlite database

        touch dev.db

4. Upgrade the database to the current layout using

        docker-compose run --rm manage db upgrade

5. Now you are ready to run the `tumsm_server` using

        docker-compose up flask-dev

## Docker Quickstart

This app can be run completely using `Docker` and `docker-compose`. **Using Docker is recommended, as it guarantees the application is run using compatible versions of Python and Node**.

There are three main services:

To run the development version of the app

```bash
docker-compose up flask-dev
```

To run the production version of the app

```bash
docker-compose up flask-prod
```

The list of `environment:` variables in the `docker-compose.yml` file takes precedence over any variables specified in `.env`.

To run any commands using the `Flask CLI`

```bash
docker-compose run --rm manage <<COMMAND>>
```

Therefore, to initialize a database you would run

```bash
docker-compose run --rm manage db init
docker-compose run --rm manage db migrate
docker-compose run --rm manage db upgrade
```

A docker volume `node-modules` is created to store NPM packages and is reused across the dev and prod versions of the application. For the purposes of DB testing with `sqlite`, the file `dev.db` is mounted to all containers. This volume mount should be removed from `docker-compose.yml` if a production DB server is used.

### Running locally

Run the following commands to bootstrap your environment if you are unable to run the application using Docker

```bash
cd tumsm_server
pip install -r requirements/dev.txt
npm install
npm run-script build
npm start  # run the webpack dev server and flask server using concurrently
```

You will see a pretty welcome screen.

#### Database Initialization (locally)

Once you have installed your DBMS, run the following to create your app's
database tables and perform the initial migration

```bash
flask db init
flask db migrate
flask db upgrade
```

## Deployment

### Manual Deployment

* To be able to access [ios21tumsm.ase.in.tum.de](), you need to be connected to the TUM VPN.

```sh
ssh rmm@ios21tumsm.ase.in.tum.de  # get password from Denis
cd ios21tumsm-repo/tumsm_server  # change into tumsm_server directory

# attach to screen session, so that server process keeps running when you disconnect
screen -x  # omit -x, if there is no session to attach to

# if the server is currently running, kill it using CTRL+C

# optional: pull changes to update server (enter your bitbucket credentials when asked)
git pull

# optional: upgrade database
python3 -m flask db upgrade

# start server
sudo python3 -m waitress --port=80 --call 'autoapp:create_app'

# detach from screen session by pressing `CTRL+a` and then `d`

# exit ssh session
exit
```

* server can be configured via `.env` file (will be picked up automatically and does not need to be sourced)

### Docker Deployment (currently not working)

When using Docker, reasonable production defaults are set in `docker-compose.yml`

```text
FLASK_ENV=production
FLASK_DEBUG=0
```

Therefore, starting the app in "production" mode is as simple as

```bash
docker-compose up flask-prod
```

If running without Docker

```bash
export FLASK_ENV=production
export FLASK_DEBUG=0
export DATABASE_URL="<YOUR DATABASE URL>"
npm run build   # build assets with webpack
flask run       # start the flask server
```

## Shell

To open the interactive shell, run

```bash
docker-compose run --rm manage db shell
flask shell # If running locally without Docker
```

By default, you will have access to the flask `app`.

## Running Tests/Linter

To run all tests, run

```bash
docker-compose run --rm manage test
flask test # If running locally without Docker
```

To run the linter, run

```bash
docker-compose run --rm manage lint
flask lint # If running locally without Docker
```

The `lint` command will attempt to fix any linting/style errors in the code. If you only want to know if the code will pass CI and do not wish for the linter to make changes, add the `--check` argument.

## Migrations

Whenever a database migration needs to be made. Run the following commands

```bash
docker-compose run --rm manage db migrate
flask db migrate # If running locally without Docker
```

This will generate a new migration script. Then run

```bash
docker-compose run --rm manage db upgrade
flask db upgrade # If running locally without Docker
```

To apply the migration.

For a full migration command reference, run `docker-compose run --rm manage db --help`.

If you will deploy your application remotely (e.g on Heroku) you should add the `migrations` folder to version control.
You can do this after `flask db migrate` by running the following commands

```bash
git add migrations/*
git commit -m "Add migrations"
```

Make sure folder `migrations/versions` is not empty.

## Asset Management

Files placed inside the `assets` directory and its subdirectories
(excluding `js` and `css`) will be copied by webpack's
`file-loader` into the `static/build` directory. In production, the plugin
`Flask-Static-Digest` zips the webpack content and tags them with a MD5 hash.
As a result, you must use the `static_url_for` function when including static content,
as it resolves the correct file name, including the MD5 hash.
For example

```html
<link rel="shortcut icon" href="{{static_url_for('static', filename='build/img/favicon.ico') }}">
```

If all of your static files are managed this way, then their filenames will change whenever their
contents do, and you can ask Flask to tell web browsers that they
should cache all your assets forever by including the following line
in ``.env``:

```text
SEND_FILE_MAX_AGE_DEFAULT=31556926  # one year
```

## Troubleshooting

### Delete old docker images

Use the command below to find and delete old docker images related to tumsm_server:

    docker image rm --force <tab>

*If tab completion is not working, use `docker images` for a list of image tags*

## FAQ

### What are all these files doing?

This project is based on the [cookiecutter-flask](https://github.com/cookiecutter-flask/cookiecutter-flask) template (on [this commit](https://github.com/cookiecutter-flask/cookiecutter-flask/commit/6d27fddae7bb26a435c111b26e39d747477f2884), to be exact). You can read up on the template there. Also, the [issues](https://github.com/cookiecutter-flask/cookiecutter-flask/issues?q=is%3Aissue) might help you with any questions not answered by this FAQ.

### Why are my new requirements missing in the running instance?

New requirements are not automatically installed but require rebuilding the docker containers. This can be done with

    docker-compose build flask-dev
    docker-compose build manage

In case you are testing with the production container also, you also need to rebuild this one

    docker-compose build flask-prod

### How can I debug the server when it runs within docker?

I haven't figured out how to use the builtin debuggers in many IDEs (PyCharm, VSCode) with the server running within a docker container. I have resorted to running the server on my local machine for debugging purposes.

### How can I configure the database for local execution?

Link the file to `/tmp/dev.db` to use the same location as is used within the docker container

    ln dev.db /tmp/dev.db

Alternatively, update the `DATABASE_URL` value in `.env` with the local path to `dev.db`

    DATABASE_URL=sqlite:////Users/mkj/Developer/tum/iPraktikum/ios21tumsm-repo/tumsm_server/dev.db
