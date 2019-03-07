# syncBash

A backup script using rsync with configuration by .conf file and  "send", "receive" or "duplex" modes.

Template of the .conf file
# rsync operations config with sync.sh
# ./sync.sh --config=thisfile.conf

# operation:variable:value
set:TO:/media/username/device/
set:FROM:/my_base_directory/

# operation:mode:delete:path:newpath
# mode => duplex (send & receive, ignore delete option) 
#      => send (just send)
#      => receive (just receive)
# delete => delete (delete on target if not exists on origin/from)
#       => preserve (or blank/empty, do not delete)
# path => relative or absolutely path of directory (or file).
# newpath (optional) => new path or rename on destiny
sync:send:delete:folder1/:myhostname/folder1/
sync:send:delete:folder2/:myhostname/folder2/
sync:send::folder3/:myfordername/folder3_preserving_old_files/
sync:duplex::MyMusics/
sync:receive:delete:folder4/


