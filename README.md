# TokAccess
Handle authentication of your users using tokens.
Every 'tokified' user will have a association named
toks.

A tok is an object that consist of two attributes: token, devise_token.

You should use the devise_token to identify the user devices
in which the user has logged in and the token to authenticate the
user request.

TokAccess use bcrypt has_secure_password and has_secure_token methods to handle the authentication process and tokens generation

## Usage

#### Imagine you have a User model and a mobile app in which a user want to sign up.

```ruby
  # somewhere in a controller that handle the users registration

  def sign_up
    user = User.new(user_params)
    if user.save
      # if the user is saved, an associated tok is created
      # and you can access that tok using the following methods
      token = user.get_token
      devise_token = user.get_devise_token
      #  return the tokens to the front-end.
    else
      # code if the user can't be saved
    end
  end
```
#### So, now the user is logged in one device and start browsing the app. How to identify the user that sign up previously?

```ruby
  # somewhere in your code, probably in you ApplicationController
  # let's say that you are sending a token in a header named
  # APP_TOKEN

  def current_user
    @current_user ||= User.validate_access(token: request.headers["HTTP_APP_TOKEN"])
  end

  def user_signed_in?
    !current_user.nil?
  end

  def current_token
    current_user ? current_user.get_token : nil
  end

  def current_devise_token
    current_user ? current_user.get_devise_token : nil
  end

  # After 15 minutes, the next user request will refresh the tokens.
  # it is necessary to send the tokens to the front-end again

  def tokens_refreshed?
    if current_user and current_user.refreshed?
      # Some code that allows you to send the tokens to the front-end
    end
  end
```


#### Now the previous user wants to login in a new device

```ruby
  # somewhere in a controller that handle the users sign in

  def sign_in
    user = User.find_by(email: params[:email])
    if user.tok_auth(params[:password])
      # if the user is authenticated successfully, a new tok is created
      # and you can access that tok using the following methods
      token = user.get_token
      devise_token = user.get_devise_token
      # then you should return to the front-end the tokens.
    else
      # code if the user authentication fails
    end
  end
```

#### Now the previous user wants to login in an old device

```ruby
  # somewhere in a controller that handle the users sign in
  # let's say that you are sending a devise_token in a header named
  # APP_DEVISE_TOKEN

  def sign_in
    user = User.find_by(email: params[:email])
    if user.tok_auth(params[:password], request.headers["HTTP_APP_DEVISE_TOKEN"])
      # if the user is authenticated successfully and the tok related to the
      # given devise_token is found, the token and devise_token are regenerated
      # and you can access that tok using the get_token and get_devise_token
      # methods.
      # if the user is authenticated successfully and the tok related to the
      # given devise_token wasn't found, a new tok is created and you can access
      # that tok using the get_token and get_devise_token
      # methods.
      token = user.get_token
      devise_token = user.get_devise_token
      # then you should return to the front-end the tokens.
    else
      # code if the user authentication fails
    end
  end
```

#### Accessing the toks from the user.
```ruby

  user = User.validate_access(token: request.headers["HTTP_APP_TOKEN"])
  user.toks # UserTok collection.

```


## Installation
Add this line to your application's Gemfile:

```ruby
gem 'tok_access'
```

And then execute:
```bash
$ bundle
```

### Generating models

Generating a User model.

```bash
$ rails g tok_access:model User email:string nickname:string
```
The above command will generate two models: User and UserTok

The migration generated to create the User model will add a column named
password_digest to store the password.

#### IMPORTANT: If you already have a User model, the command will generate just the migration to add the password_digest column

#### NOTE: You can generate any model to be 'tokified' just pass the name of the model

```bash
$ rails g tok_access:model Person email:string nickname:string
```
The above command will generate two models: Person and PersonTok

#### IMPORTANT: If you use the tok_access:model generator to destroy the model, the Model and ModelTok will be destroyed. It's a better choice to do it manually

```bash
$ rails d model user
$ rails d model user_tok
```

Also, remember to remove the migrations...


## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
