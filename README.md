# EzTemplate

EzTemplate is a template engine intended for use by end users. You can create a template with variables. It parses a base template only once and renders multiple times with each set of context variables.

## Usage

### Normal variables

```ruby
class SampleTemplate < EzTemplate::Base
  variable :current_username do |user|
    user.name
  end
end

renderer = SampleTemplate.parse(str)
puts renderer.render(user: current_user)
```

### Regex variables

```ruby
require 'uri'

class SampleTemplate < EzTemplate::Base
  variable %r{\Ahttps://.*\Z} do |match_data, path|
    uri = URI.parse(match_data[0])
    "#{uri.scheme}://#{uri.host}/#{path}"
  end
end

renderer = SampleTemplate.parse(str)
puts renderer.render(path: current_path)
```

### Append variables after parsing

```ruby
class SampleTemplate < EzTemplate::Base
end

renderer = SampleTemplate.parse(str)
renderer.append(EzTemplate::Variable("foo") |hoge|
  "bar"
end)
puts renderer.render(user: current_user)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/shunsuke44/ez_template.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
