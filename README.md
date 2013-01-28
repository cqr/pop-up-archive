<table>
  <tr>
    <th>
      Ruby Version
    </th>
    <td>
      1.9.3p327
    </td>
  </tr>
  <tr>
    <th>
      Rails Version
    </th>
    <td>
      3.2.8
    </td>
  </tr>
  <tr>
    <th>
      Production Deployment
    </th>
    <td>
      git@heroku.com:pop-up-archive.git - http://pop-up-archive.herokuapp.com
    </td>
  </tr>
</table>

### Recommended setup

This guide expects that you have git and homebrew installed, and have a ruby environment set up with 1.9.3 (using RVM or rbenv). We also assume you are using Pow, and have the development site running at http://pop-up-archive.dev. This is not required, but some aspects of the guide may not be appropriate for different configurations.

    brew install redis elasticsearch postgres
    git clone git@github.com:PRX/pop-up-archive.git
    curl get.pow.cx | sh
    gem install powder bundler
    cd pop-up-archive
    bundle install
    powder link
    cp config/env_vars.example config/env_vars

#### Environment variables

In order to mimic the way Heroku works, many application configuration settings are defined with environment variables. If you are using foreman/etc you may have a different way of accomplishing this.  You can also use the included support for the config/env_vars file. 

##### You should not check config/env_vars into source control

You will need to set the SECRET_TOKEN value for the app to start (the default value is too short). The other default value may not be required. If need to point the app to a database or database user different than what is in the included database.yml, you should do that with an environment variable. Once complete:

	rake db:setup
	rake db:migrate
	
### Development

	powder open

The site should now be running. If you need to use sidekiq, or elasticsearch, you may need to start other services manually.