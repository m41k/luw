ps -u user | cut -c 1-6 | paste -s | tr -d 'PID' | expand -i | tr -s ' '
