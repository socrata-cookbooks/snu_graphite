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

***snu_graphite_app_base***

Manages installation of the scaffolding that the other app resources install into.

Syntax:

```ruby
snu_graphite_app_base 'default' do
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

| Property        | Default                   | Description                             |
|-----------------|---------------------------|-----------------------------------------|
| graphite_path   | `'/opt/graphite'`         | Path to the Graphite installation       |
| storage_path    | `'/opt/graphite/storage'` | Path to Graphite storage                |
| user            | `'graphite'`              | Graphite user                           |
| group           | `'graphite'`              | Graphite group                          |
| python_runtime  | `'2'`                     | Python runtime to install Graphite with |
| version         | `'0.9.12'`                | Version of Carbon to install            |
| action          | `:install`                | The action(s) to perform                |

Actions:

| Action     | Description                                      |
|------------|--------------------------------------------------|
| `:install` | Install Python, create the Graphite user, etc.   |
| `:remove`  | Delete the Graphite user, uninstall Python, etc. |

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

| Property        | Default                   | Description                             |
|-----------------|---------------------------|-----------------------------------------|
| graphite_path   | `'/opt/graphite'`         | Path to the Graphite installation       |
| storage_path    | `'/opt/graphite/storage'` | Path to Graphite storage                |
| user            | `'graphite'`              | Graphite user                           |
| group           | `'graphite'`              | Graphite group                          |
| python_runtime  | `'2'`                     | Python runtime to install Graphite with |
| version         | `'0.9.12'`                | Version of Carbon to install            |
| twisted_version | `'13.1.0'`                | Version of Twisted to install           |
| action          | `:install`                | The action(s) to perform                |

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

***snu_graphite_config_carbon***

Manages configuration of Carbon.

Syntax:

```ruby
snu_graphite_config_carbon 'relay' do
  service :relay
  enable_logrotation false
  user 'root'
  group 'root'
  max_cache_size 123_456
  action :create
end
```

Properties:

| Property      | Default                            | Description                        |
|---------------|------------------------------------|------------------------------------|
| service       | Resource name                      | One of cache, relay, or aggregator |
| graphite_path | `'/opt/graphite'`                  | Path to the Graphite installation  |
| storage_path  | `'/opt/graphite/storage'`          | Path to Graphite storage           |
| user          | `'graphite'`                       | Graphite user                      |
| group         | `'graphite'`                       | Graphite group                     |
| path          | `'/opt/graphite/conf/carbon.conf'` | Path to the `carbon.conf`          |
| config        | \*                                 | \*                                 |
| \*            | \*                                 | \*                                 |
| action        | `:create`                          | The action(s) to perform           |


\* The default configs for the three Carbon services are:

_Cache_

```
{
  enable_logrotation: true,
  user: '%<user>s',
  max_cache_size: 'inf',
  max_updates_per_second: 100,
  max_creates_per_minute: 200,
  line_receiver_interface: '0.0.0.0',
  line_receiver_port: 2003,
  udp_receiver_port: 2003,
  pickle_receiver_port: 2004,
  enable_udp_listener: true,
  cache_query_port: 7002,
  cache_write_strategy: 'sorted',
  use_flow_control: true,
  log_updates: false,
  log_cache_hits: false,
  whisper_autoflush: false,
  local_data_dir: '%<storage_path>s/whisper'
}

_Relay_

N/A

_Aggregator_

N/A

The config property can be overridden in its entirety by passing in a new one with e.g. `config(some: 'stuff')`. Individual settings can be overridden and merged into the config by calling them as properties, e.g. `enable_logrotation false`. Any properties called are automatically translated into a format suitable for a `carbon.conf`.

Actions:

| Action    | Description              |
|-----------|--------------------------|
| `:create` | Create the `carbon.conf` |
| `:remove` | Delete the `carbon.conf` |

***snu_graphite_config_storage_schema***

Accumulates storage schemas and writes them out to Graphite's `storage-schemas.conf` file.

Syntax:

```ruby
snu_graphite_config_storage_schema '500_metrics_default' do
  entry_name '500_metrics_default'
  graphite_path '/opt/graphite'
  # TODO: storage_path doesn't actually do anything here.
  # storage_path '/opt/graphite/storage'
  user 'graphite'
  group 'graphite'
  path '/opt/graphite/conf/storage-schemas.conf'
  pattern '^metrics\\.'
  retentions '60s:1d,15m:7d,1h:365d'
  action :create
end
```

Properties:

| Property      | Default                                     | Description                       |
|---------------|---------------------------------------------|-----------------------------------|
| entry_name    | Resource name                               | The name of the schema entry      |
| graphite_path | `'/opt/graphite'`                           | Path to the Graphite installation |
| user          | `'graphite'`                                | Graphite user                     |
| group         | `'graphite'`                                | Graphite group                    |
| path          | `'/opt/graphite/conf/storage-schemas.conf'` | Path to the config file           |
| pattern       | `nil`                                       | The PATTERN option                |
| retentions    | `nil`                                       | The RETENTIONS option             |
| action        | `:create`                                   | The action(s) to perform          |

Actions:

| Action    | Description                       |
|-----------|-----------------------------------|
| `:create` | Create the `storage-schemas.conf` |
| `:remove` | Delete the `storage-schemas.conf` |

## Maintainers

- Jonathan Hartman <j@hartman.io>
