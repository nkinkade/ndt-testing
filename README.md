# ndt-testing

To run an ndt stress test:
 * start an NDT server
 * update `stress_test.sh` with the correct server & port numbers.
 * run `./stress_test.sh &`
 * run `./killer.sh &`

## Don't run out of disk space on the server.

If the stress test does not need to preserve server-collected data, and to
avoid running out of disk space during the test, start the following on the ndt
server. This will remove log files older than 10 minutes.

    while /bin/true; do
        find /var/spool/iupui_ndt/$(date +%Y)/ -mmin +10 -a -type f \
            -a -exec rm -f {} \;
        sleep 600
    done &

# After testing

## Check the server

There should be no running or deadlocked NDT processes.

## Count the client logs

    ls stress_test_results/*/* | wc

## Check the client logs

Processes exit with code 137 (128 + 9) when `killer.sh` kills them. So, skip
these files when looking for errors.

To find all `ws` and `wss` tests without successful upload & download tests:
NOTE: as of this writing, `node ndt_client.js` stil returns exit status `0` on
error states.

    for file in `grep -L 'Exited with code 137' *` ; do
        awk 'BEGIN { up=0 ; down=0 ; }
            /Measured download/ {down=$5}
            /Measured upload/ {up=$5}
            END {
              if (up > 0 && down > 0) {
                print "ok";
              } else {
                print FILENAME;
              }
            }' $file | grep -v ok
    done


To find all `raw` tests without successful tests:

    grep -L 'Exited with code 0' * | xargs grep -L 'Exited with code 137'
