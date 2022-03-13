---
title: Flexible Passwordless Rails Authentication with <code>devise-passwordless</code>
tags: rails
---
For [PodQueue](https://podqueue.fm), I wanted users to be able to sign up with *just* an email address, instead of having to also pick a username and password at sign-up time. You've probably seen this strategy with some other online services like Slack, where the login process can be handled by a so-called "magic link" that gets emailed to the email address associated with your account, and clicking the link logs you in. The problem is, I already had users with passwords, and I still wanted to support password-based authentication for users who want it&mdash;the passwordless login flow is just available for users who find that easier.

You may be concerned that passwordless email-based login is "insecure", but if you allow for email-based account/password recovery (e.g. [the Devise `:recoverable` strategy](https://www.rubydoc.info/github/plataformatec/devise/master/Devise/Models/Recoverable)), *you already have an email-based login process even if you don't call it that*.

I was already using [Devise](https://github.com/heartcombo/devise) for authentication, and settled on the [`devise-passwordless` gem](https://github.com/abevoelker/devise-passwordless) to provide the core of my passwordless authentication strategy. Out of the box, `devise-passwordless` assumes you're *only* going to use a passwordless authentication strategy, but with a little work you can adapt it to work flexibly alongside password-based authentication. This assumes you've already set up Devise, and followed the default install intructions for `devise-passwordless` for your Devise resources. The only resource I'm using Devise for is my `User` model, which I assume will be the case for most other projects as well, but obviously you'll need to adapt things for your particular goals and Devise configuration.

I also assume you have templates generated for overriding your Devise controllers, with e.g.:

    rails generate devise:controllers devise/users

You should now have overridable Devise controllers in `app/controllers/devise/users/` and `app/controllers/devise/devise-passwordless/`. Your `config/routes.rb` should have a Devise configuration like the following:

```ruby
devise_for :users, controllers: { registrations: 'devise/users/registrations',
                                  sessions: 'devise/passwordless/sessions' }
devise_scope :user do
  get '/users/magic_link',
      to: 'devise/passwordless/magic_links#show',
      as: 'users_magic_link'
end
```

You then need to override the default `devise-passwordless` sessions controller at `app/controllers/devise/devise-passwordless/sessions_controller.rb` so that it will use the default password-based authentication method if a password parameter is present. Mine looks like the following:

```ruby
# frozen_string_literal: true

module Devise
  module Passwordless
    class SessionsController < Devise::SessionsController
      def create
        super and return if create_params[:password].present?

        self.resource = resource_class.find_by(email: create_params[:email])
        self.resource ||= resource_class.find_by(username: create_params[:email])
        if self.resource
          resource.send_magic_link(create_params[:remember_me])
          set_flash_message(:notice, :magic_link_sent, now: true)
        else
          set_flash_message(:alert, :not_found_in_database, now: true)
        end

        self.resource = resource_class.new(create_params)
        render :new
      end

      protected

      def translation_scope
        if action_name == 'create'
          'devise.passwordless'
        else
          super
        end
      end

      private

      def create_params
        resource_params.permit(:email, :password, :remember_me)
      end
    end
  end
end
```

The main things I've modified here are permitting the `:password` param in `create_params`, and calling out to `super` if it's present. I also allow logging in by username or email address, so there's some extra code to do that as well.

You'll also need to allow users to modify their account without a password. I have this in `app/controllers/devise/users/registrations_controller.rb` to allow this for all users:

```ruby
protected

# Allow updating Devise resources without the current password
def update_resource(resource, params)
  if params[:password].blank?
    params.delete(:password)
    params.delete(:password_confirmation) if params[:password_confirmation].blank?
  end
  resource.update(params)
end
```

Since we're using `devise-passwordless` for our sessions controller, we also need to add a few extra keys to `config/locales/devise.en.yml`, e.g.:

```yml
en:
  devise:
    passwordless:
      user:
        signed_in: "Signed in successfully."
        signed_out: "Signed out successfully."
        already_signed_out: "Signed out successfully."
```

You may also want to customize some user flows, account settings, or email views depending on if a user has a password set or not. You can easily check this with e.g. `current_user.encrypted_password.blank?`.
