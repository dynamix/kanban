# Typus: Admin interface for Rails applications

**Typus** is designed for a single activity:

    Trusted users editing structured content.

**Typus** doesn't try to be all the things to all the people but it's 
extensible enough to match lots of use cases.

## Key Features

- Access control by users and roles.
- CRUD and custom actions for your models on a clean interface.
- Internationalized.
- Extensible and overwritable templates.
- Low memory footprint.
- Released under the MIT License.

## Links

- [Project site and documentation](http://intraducibles.com/projects/typus)
- [Plugin source](http://github.com/fesplugas/typus)
- [Mailing list](http://groups.google.com/group/typus)
- [Bug reports](http://github.com/fesplugas/typus/issues)
- [Gems](http://gemcutter.org/gems/typus)

## Impatients to see it working?

**Step 1:** Create a Rails application using a template.

    $ rails example.com -m http://tr.im/typus_example

**Step 2:** Start the server.

    $ cd example.com && script/server

**Step 3:** Go to the admin area (<http://0.0.0.0:3000/admin>) and enjoy it!


## Want to see a demo working?

Demo application is hosted at Heroku (<http://typus.heroku.com/>).

Use the following credentials to log in.

    Email: userdemo@intraducibles.com
    Password: userdemo

## Installing

Install from GitHub the latest version which it's compatible with Rails 2.3.4.

    $ script/plugin install git://github.com/fesplugas/typus.git

Once `typus` is installed, run the generator to create required files and migrate your 
database. (<tt>typus_users</tt> table is created)

    $ script/generate typus
    $ rake db:migrate

To create the first user, start the application server, go to 
http://0.0.0.0:3000/admin and follow the instructions.

## Support

As an experiment we encourage you to support this project by 
[donating][1] 90 &euro; if you are a developer or studio. Donations do 
allow us to spend more time working and supporting the project.

## License

Copyright &copy; 2007-2009 Francesc Esplugas Marti, released under the 
MIT license

[1]:http://intraducibles.com/projects/typus/donate