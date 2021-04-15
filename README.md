# Rails Photo Store

A Ruby on Rails eCommerce app for selling photography prints

[Demo](https://photos.grahamhemsley.com)

![Homepage example](./homepage.png)

## Installation

Make sure Ruby 2.6.6 with `bundler` and NodeJS with `yarn` are installed, then run `bundle install` and `yarn install` to install dependencies.
This app currently has no default server configured.
I recommend `passenger`. It will need to be added to the `Gemfile` prior to launch unless it is installed some other way.
Consult Passenger's documentation for more information.

This project relies on having a FoxyCart store set up for the shopping cart feature to work.
Consult the documentation at https://www.foxy.io/ for info on how to create your own FoxyCart store running in test mode.
You will need to update some references to the store URL throughout the app for things to work right. 
You will also want to configure your store to use SSO and a webhook pointed at the respective routes in `config/routes.rb`.
These features rely on your app being accessible over HTTPS.
Further, your store configuration needs to use a bcrypt cost factor that matches your Rails bcrypt configuration (default 10).
Refer to FoxyCart's documentation for more information.

You will need various credentials from FoxyCart to be set up within a Rails encrypted credentials container.
There is also a credential called `session_secret` and an `admin_secret` credential that enables creation of admin accounts which will need to be set first as well.
To set those encrypted variables, run `rails credentials:edit`. 
For specifics on how to name them, refer to the references to the credential store in the file `app/controllers/application_controller.rb` and `config/initializers/session_store.rb`

Before trying to run the app, don't forget to run the migrations with `rails db:migrate`.

For a convenient way to run in development mode, install `foreman` globally with `yarn global add foreman`.
Then run the app from the project root with `yarn start`.

## Usage

If setting up a new store, first, navigate to the `/admins/new` route to create a new admin account.
Make sure you enter a password that matches your `admin_secret` credential.
Then sign into that account using the `/admin_signin` route.

From there, you will want to create your first category, then add some products.
Currently, products expect a length and width, but height and weight are unused (those fields are left intact for future expansion).
Length units are currently expected to be in inches ('in') and price units are expected to be in USD ('USD') when you fill out the product creation form.

It usually makes the most sense to set a price modifier of `0` for your product's first set of dimensions,
then add a second dimension if desired with a nonzero price modifier.

For the 'Popular' products page to populate, a regular user must be created and they must purchase a product while signed in (or they can sign in at the checkout page).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ghemsley/rails-photo-store

## License

[MIT License](./LICENSE)
