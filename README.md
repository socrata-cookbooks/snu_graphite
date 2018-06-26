# Snu Graphite Cookbook README

[![Cookbook Version](https://img.shields.io/cookbook/v/snu_graphite.svg)][cookbook]
[![Build Status](https://img.shields.io/travis/socrata-cookbooks/snu_graphite.svg)][travis]

[cookbook]: https://supermarket.chef.io/cookbooks/snu_graphite
[travis]: https://travis-ci.org/socrata-cookbooks/snu_graphite

A Socrata-maintained and -opinionated version of a graphite cookbook, originally based on the existing community one.

## Requirements

This cookbook is continuously tested against the following matrix of platforms and Chef versions:

- Ubuntu 18.04
- Ubuntu 16.04
- Ubuntu 14.04
- Debian 9
- Debian 8

X

- Chef 14
- Chef 13
- Chef 12

## Usage

TODO: Describe how to use the included public API (whether it be recipes or resources).

## Recipes

***default***

- Sets up the graphite base components.

## Attributes

***default***

TODO: Describe any important attributes.

## Resources

***snu_graphite_base***

Sets up base functionality (user, directories, Python environment) shared by the other graphite resources.

Syntax:

```ruby
snu_graphite_base 'default' do
  graphite_path '/opt/graphite'
  storage_path '/opt/graphite/storage'
  user 'graphite'
  group 'graphite'
  python_runtime '2'
  action :create
end
```

Properties:

| Property          | Default                      | Description                           |
|-------------------|------------------------------|---------------------------------------|
| graphite_path     | `'/opt/graphite'`            | Path to the graphite installation     |
| storage_path      | `"#{graphite_path}/storage"` | Path to graphite data storage         |
| user              | `'graphite'`                 | The graphite user                     |
| group             | `'graphite'`                 | The graphite group                    |
| python_runtime    | `'2'`                        | The runtime to install Graphite with  |
| action            | `:create`                    | The action(s) to perform              |

Actions:

| Action    | Description                        |
|-----------|------------------------------------|
| `:create` | Create the base Graphite resources |
| `:remove` | Delete the base Graphite resources |

## Maintainers

- Jonathan Hartman <j@hartman.io>
