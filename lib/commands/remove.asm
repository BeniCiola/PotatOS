command_remove:
    inc si
    call efs_delete_file
    ret