# Keep vendor/admin databases and append our keyboard database. Dconf locks have
# reverse priority, so our keyboard keys override stale greeter values only.
/^[[:space:]]*system-db:dotfiles-keyboard[[:space:]]*$/ { next }
{ print }
END { print "system-db:dotfiles-keyboard" }
