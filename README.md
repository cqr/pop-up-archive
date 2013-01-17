the secret configuration happens in the config/env_vars file
do not check this file in

it follows the syntax:
    
    ENV_VAR_NAME=val

POW will automatically source this file, and it can easily be submitted to heroku in this format.

To access sensitive information, put it in an environment variable and use ENV['NAME'] within ruby.

