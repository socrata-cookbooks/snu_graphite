# Snu Graphite Cookbook README

[![Cookbook Version](https://img.shields.io/cookbook/v/snu_graphite.svg)][cookbook]
[![Build Status](https://img.shields.io/travis/socrata-cookbooks/snu_graphite.svg)][travis]

[cookbook]: https://supermarket.chef.io/cookbooks/snu_graphite
[travis]: https://travis-ci.org/socrata-cookbooks/snu_graphite

TODO: Enter a brief cookbook description here.

## Requirements

TODO: Describe the supported platforms and Chef versions, additional dependencies, etc.

## Usage

TODO: Describe how to use the included public API (whether it be recipes or resources).

## Recipes

***default***

TODO: Describe the default recipe.

## Attributes

***default***

TODO: Describe any important attributes.

## Resources

***snu_graphite***

TODO: Describe the default custom resource.

Syntax:

```ruby
snu_graphite 'default' do
  property1 'value1'
  property2 'value2'
  action :create
end
```

Properties:

| Property  | Default   | Description              |
|-----------|-----------|--------------------------|
| property1 | 'value1'  | A property               |
| property2 | 'value2'  | Another property         |
| action    | `:create` | The action(s) to perform |

Actions:

| Action    | Description         |
|-----------|---------------------|
| `:create` | Create the resource |
| `:remove` | Remove the resource |

## Maintainers

- Jonathan Hartman <j@hartman.io>
