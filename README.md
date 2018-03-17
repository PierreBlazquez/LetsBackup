# LetsBackup

LetsBackup is a dead simple shell script that uses rsync to backup a directory to another directory and sendmail to send a simple HTML backup report by email.

## Getting Started

### Prerequisites

- Any UNIX derivative of your choice

### Installing

- Copy the script to a known location (like /opt or /usr/local or whatever)
- Edit it to set your wanted settings
- chmod/chown it
- Edit your crontab in order to launch it periodically

## How does it work?
**First, you must edit the parameters like origin, destination and email_[stuff] to make LetsBackup behave the way you want.**

The script starts by checking that rsync is present. Sendmail is also checked but is not required. If it is present then LetsBackup will try to send an email.
Once dependencies are checked, the script check your parameters.
If everything's fine, then LetsBackup starts... the backup! (Captain Obvious is in da house yo!)
When the backup ends, and if email sending is enabled /and/ sendmail is present, LetsBackup will generate a report (HTML style!) and send it to you right away.

## Authors

- **Pierre Blazquez** - @pierre_blzqz - http://www.pierreblazquez.com/ - *Developer*

## License

If you want to contact me, feel free to reach me on Twitter or on my website.
If you want to include parts of this code (it *must* be for educational purposes), please include this GitHub page in your credits.
Otherwise the Do What the Fuck You Want to Public License applies to this project.

DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
Version 2, December 2004

Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>

Everyone is permitted to copy and distribute verbatim or modified
copies of this license document, and changing it is allowed as long
as the name is changed.

DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

0. You just DO WHAT THE FUCK YOU WANT TO.
