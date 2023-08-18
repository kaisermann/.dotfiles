abbr mkdir mkdir -pv
abbr wget wget -c

# vtex related
if command -v exa >/dev/null
    abbr ls exa
else
    abbr ls ls -GFh
    abbr ll ls -lhAls
end

function zcode
    z $argv[1]
    code .
end

function killport
    if test (count $argv) -lt 1
        echo "Please specify a port"
        return 1
    end

    # Fetch the process details running on the specified port
    set process_info (lsof -i tcp:$argv[1] | grep LISTEN)

    # Extract the PID from the process details
    set pid (echo $process_info | awk '{print $2}')

    if test -n "$pid"
        # Extract useful information about the process
        set command (echo $process_info | awk '{print $1}')
        set user (echo $process_info | awk '{print $3}')

        # Display the process details in a concise format
        echo "Killing process '$command' (PID: $pid) running on port" $argv[1]

        # Kill the process
        kill -9 $pid
    else
        echo "No process running on port" $argv[1]
    end
end
