pg_configfile="$PGDATA/postgresql.conf"
backup_signal="$WAL_DIR/backup_in_progress"

function enable_archiving {
		
	if grep -q "#archive_mode = off" "$pg_configfile" ; then
		echo "set archive command in $pg_configfile"
		sed -i.bak "s;#archive_mode = off;archive_mode = on;
								s;#wal_level = minimal;wal_level = archive;
								s;#wal_compression = off;wal_compression = on;
			 			 	  s;#archive_command = '';archive_command = 'test ! -f $backup_signal || (test ! -f $WAL_DIR/%f \&\& cp %p $WAL_DIR/%f)';" "$pg_configfile"
	fi
	grep -q "archive_mode = on" "$pg_configfile"
}

enable_archiving || exit 1
