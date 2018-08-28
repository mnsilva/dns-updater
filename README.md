# DNS-updater for DDNS services

The purpose of this project is to provide a simple and provider-agnostic DDNS updater.

Once many DDNS service providers ceased their free account offers, currently this project only supports [Namecheap](https://www.namecheap.com/). All contributions to support other providers are very welcome!

## Installation

### Pre-requisites

This project is written in [Perl 5](https://www.perl.org/) programming language. Besides the _perl_ interpreter, it requires the following modules:
  * [YAML](https://metacpan.org/pod/YAML)
  * [Module::Pluggable](https://metacpan.org/pod/Module::Pluggable)
  * [DateTime](https://metacpan.org/pod/DateTime)
  * [LWP::UserAgent](https://metacpan.org/pod/LWP::UserAgent)
  * [URI](https://metacpan.org/pod/URI)

Packages for these modules can be found in almost all GNU/Linux distributions package managers.

### Setting up

Setting up this project is as simple as:

1. Clone this repository into your favourite system-wide projects (I personally use `/srv/dns-updater` but feel free to use `/opt/dns-updater` or anything else!)
1. Create your own configuration file (by default the application binary attempts to locate `etc/ddns-hosts.yml` under the project directory) based on `etc/ddns-hosts.yml.sample` file
1. Set a `cron` job to run regularly the updater. Example to run every 5 minutes: `*/5 * * * * /srv/dns-updater/bin/dns-updater.pl`

Please keep in mind that although there's no need for **root** access, the user that will be running the script **must** have write permission on `data/` directory under projects' directory.

## Final credits

This project was developed by Manuel Silva and it's provided under MIT License.
