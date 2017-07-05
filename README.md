# Multiview

Support multiple versions for Rails views


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'multiview'
```

And then execute:

    $ bundle


## Usage

### We project

`app/controllers/topics_controller.rb`

```
class TopicsController < ApplicationController
  def index
    render plain: 'hello'
  end
end
```

`app/controllers/v2/topics_controller.rb`

```
class V2::TopicsController < ApplicationController
  def index
    render plain: 'hello v2'
  end
end
```

`config/routes.rb`

```
resources :topics
```

### Init

`config/initializers/multiview.rb`

```
$multiview = Multiview::Manager.new({
  'topics' => 'v2'
})

# or use default manager: Multiview.manager
```


### Redispatch request by filter of controller

When get `/topics`, should redispatch to V2::TopicsController, don't call `TopicsController#index`, if we delete `V2::TopicsController` or change that config `{'topics' => 'v1'}`, it will call `TopicsController`

```
class ApplicationController < ActionController::Base
  before_aciton :set_view_version_filter

  def set_view_version_filter
    $multiview.redispatch(self)

    # or 
    # $multiview.redispatch(self, params[:controller], params[:action])

    # if exist V3::XxxController, should to call V3::XxxController
    # if not, should to call XxxController
    # $multiview.redispatch(self, params[:controller], params[:action], 'v3')
  end
end
```

### Dispatch request by middleware

```
class MultiviewMiddleware
  def initialize(app)
    @app = @app
  end

  def call(env)
    path_info = Rails.application.routes.recognize_path(env['PATH_INFO'])

    if path_info && path_info[:contorller]
      $multiview.dispatch(env, path_info[:controller], path_info[:action])
      # or 
      # $multiview.dispatch(env, path_info[:controller], path_info[:action], 'v2')
    else
      @app.call(env)
    end
  end
end
```

`config/application.rb`

```
config.middleware.insert_before Rails.application.routes, MultiviewMiddleware
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/multiview. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Multiview project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/multiview/blob/master/CODE_OF_CONDUCT.md).
