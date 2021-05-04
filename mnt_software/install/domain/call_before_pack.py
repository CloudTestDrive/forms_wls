    print "<before_pack>"
    # Activate before. Else the change are not visible in the Admin Server yet
    activate(timeout_in_millis, 'true')

    # Call before_pack.sh on the AdminServer to execute offline commands that are not available at Managed server side
    before_pack='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no %s@%s "/mnt/software/install/bin/before_pack.sh %s %s "' \
                 % ( 'oracle', admin_host_name, server_name, machine_name)
    return_code = os.system(before_pack)
    print "return_code: " + str(return_code)
    
    # Restart an edit session
    edit()
    startEdit(wait_time_millis, timeout_in_millis, 'true')
    print "</before_pack>"
