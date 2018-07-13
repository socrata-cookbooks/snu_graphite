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

***snu_graphite_app***

Manages installation of Graphite apps.

Syntax:

```ruby
snu_graphite_app %w[carbon web] do
  graphite_path '/opt/graphite'
  storage_path '/opt/graphite/storage'
  user 'graphite'
  group 'graphite'
  python_runtime '2'
  version '0.9.12'
  action :install
end
```

Properties:

| Property | Default       | Description                                |
|----------|---------------|--------------------------------------------|
| app_name | Resource name | The Graphite apps to install               |
| options  | `{}`          | The options for each graphite_app resource |
| \*       |               |                                            |
| action   | `:install`    | The action(s) to perform                   |

\* Any other arbitrary properties passed in will be merged into the options propery and passed on to the underlying `graphite_app_*` resources that the resource creates.

Actions:

| Action     | Description          |
|------------|----------------------|
| `:install` | Install the app(s)   |
| `:remove`  | Uninstall the app(s) |

***snu_graphite_app_carbon***

Manages installation of Carbon.

Syntax:

```ruby
snu_graphite_app_carbon 'default' do
  graphite_path '/opt/graphite'
  storage_path '/opt/graphite/storage'
  user 'graphite'
  group 'graphite'
  python_runtime '2'
  version '0.9.12'
  twisted_version '13.1.0'
  action :install
end
```

Properties:

| Property        | Default                | Description                             |
|-----------------|------------------------|-----------------------------------------|
| graphite_path   | `'/opt/graphite'`      | Path to the Graphite installation       |
| storage_path | `'/opt/graphite/storage'` | Path to Graphite storage                |
| user            | `'graphite'`           | Graphite user                           |
| group           | `'graphite'`           | Graphite group                          |
| python_runtime  | `'2'`                  | Python runtime to install Graphite with |
| version         | `'0.9.12'`             | Version of Carbon to install            |
| twisted_version | `'13.1.0'`             | Version of Twisted to install           |
| action          | `:install`             | The action(s) to perform                |

Actions:

| Action     | Description      |
|------------|------------------|
| `:install` | Install Carbon   |
| `:remove`  | Uninstall Carbon |

***snu_graphite_app_web***

Manages installation of the Graphite web app.

Syntax:

```ruby
snu_graphite_app_web 'default' do
  graphite_path '/opt/graphite'
  storage_path '/opt/graphite/storage'
  user 'graphite'
  group 'graphite'
  python_runtime '2'
  version '0.9.12'
  django_version '1.5.5'
  action :install
end
```

Properties:

| Property        | Default                | Description                             |
|-----------------|------------------------|-----------------------------------------|
| graphite_path   | `'/opt/graphite'`      | Path to the Graphite installation       |
| storage_path | `'/opt/graphite/storage'` | Path to Graphite storage                |
| user            | `'graphite'`           | Graphite user                           |
| group           | `'graphite'`           | Graphite group                          |
| python_runtime  | `'2'`                  | Python runtime to install Graphite with |
| version         | `'0.9.12'`             | Version of Carbon to install            |
| django_version  | `'1.5.5'`              | Version of Django to install           |
| action          | `:install`             | The action(s) to perform                |

Actions:

| Action     | Description            |
|------------|------------------------|
| `:install` | Install graphite-web   |
| `:remove`  | Uninstall graphite-web |

## Maintainers

- Jonathan Hartman <j@hartman.io>
