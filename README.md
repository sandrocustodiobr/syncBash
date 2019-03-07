# syncBash

A backup script using rsync with configuration by .conf file and  "send", "receive" or "duplex" modes.

# Valid parameters
--demo (dont execute, just compose and show the commands)
--config=file (define a config file)
--quiet (no verbose)
--debug (for debug, activate --verbose too)
--verbose (active by default, see the commands and your out)

rsync operations config with sync.sh:

./sync.sh --config=file.conf  (default sync.conf)
./sync.sh --demo (enable demo and verbose, no execute, just show the composed commands)
./sync.sh --quiet (no vebose, default: verbose active)
./sync.sh --demo --quiet --config=file.conf (show que commands composed on base of your .conf file)

# .conf file
Template of the .conf file in sync.conf

Syntax in .conf file:

operation:variable:value
set:TO:/media/username/device/
set:FROM:/my_base_directory/

operation:mode:delete:path:newpath
mode => duplex (send & receive, ignore delete option) 
     => send (just send)
     => receive (just receive)
delete => delete (delete on target if not exists on origin/from)
      => preserve (or blank/empty, do not delete)
path => relative path of directory (or file) inside the base directory
newpath (optional) => new path or rename on destiny
