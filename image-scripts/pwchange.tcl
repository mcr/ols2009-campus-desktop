log_user 1
spawn sudo chroot $env(TARGET_DIR) passwd -q root   
#spawn screwup
expect "sword:"
send "fred919\r"
expect "sword:"
send "fred919\r"
expect eof
