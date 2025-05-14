#!/bin/sh

READ_SLEEP=0
WRITE_SLEEP=0
OPEN_SLEEP=0
CLOSE_SLEEP=0
ALL_SLEEP=0
CRAWLIO_LIB="./crawlio.so"
DEBUG=0

show_usage() {
	echo "Usage: $0 [options] -- program [args...]"
	echo
	echo "Options:"
	echo "  -h, --help                 Show this help message"
	echo "  -a, --all-sleep MS         Set sleep duration for all syscalls (in milliseconds)"
	echo "  -r, --read-sleep MS        Set sleep duration for read syscalls (in milliseconds)"
	echo "  -w, --write-sleep MS       Set sleep duration for write syscalls (in milliseconds)"
	echo "  -o, --open-sleep MS        Set sleep duration for open syscalls (in milliseconds)"
	echo "  -c, --close-sleep MS       Set sleep duration for close syscalls (in milliseconds)"
	echo "  -l, --lib PATH             Path to the crawlio.so library (default: ./crawlio.so)"
	echo
	echo "Examples:"
	echo "  $0 -a 25 -- vim                     # Add 100ms delay to all syscalls"
	echo "  $0 -r 50 -w 100 -- cat /etc/passwd  # 50ms for read, 100ms for write"
	echo "  $0 -o 200 -- find / -name '*.txt'   # 200ms delay for open syscalls"
}

while [[ $# -gt 0 ]]; do
	case "$1" in
		-h|--help)
			show_usage
			exit 0
			;;
		-a|--all-sleep)
			ALL_SLEEP="$2"
			shift 2
			;;
		-r|--read-sleep)
			READ_SLEEP="$2"
			shift 2
			;;
		-w|--write-sleep)
			WRITE_SLEEP="$2"
			shift 2
			;;
		-o|--open-sleep)
			OPEN_SLEEP="$2"
			shift 2
			;;
		-c|--close-sleep)
			CLOSE_SLEEP="$2"
			shift 2
			;;
		-l|--lib)
			CRAWLIO_LIB="$2"
			shift 2
			;;
		--debug)
			DEBUG=1
			shift
			;;
		--)
			shift
			break
			;;
		*)
			echo "Unknown option: $1"
			show_usage
			exit 1
			;;
	esac
done

if [ $# -eq 0 ]; then
	echo "Error: No program specified"
	show_usage
	exit 1
fi

if [ ! -f "$CRAWLIO_LIB" ]; then
	echo "Error: crawlio library not found at $CRAWLIO_LIB"
	exit 1
fi

export_vars=""

if [ "$ALL_SLEEP" -ne 0 ]; then
	export_vars="CRAWLIO_SLEEP_MS=$ALL_SLEEP"
fi

if [ "$READ_SLEEP" -ne 0 ]; then
	export_vars="$export_vars CRAWLIO_READ_SLEEP_MS=$READ_SLEEP"
fi

if [ "$WRITE_SLEEP" -ne 0 ]; then
	export_vars="$export_vars CRAWLIO_WRITE_SLEEP_MS=$WRITE_SLEEP"
fi

if [ "$OPEN_SLEEP" -ne 0 ]; then
	export_vars="$export_vars CRAWLIO_OPEN_SLEEP_MS=$OPEN_SLEEP"
fi

if [ "$CLOSE_SLEEP" -ne 0 ]; then
	export_vars="$export_vars CRAWLIO_CLOSE_SLEEP_MS=$CLOSE_SLEEP"
fi

if [ "$DEBUG" -ne 0 ]; then
	export_vars="$export_vars CRAWLIO_DEBUG=1"
fi

PROGRAM="$1"
shift

env $export_vars LD_PRELOAD="$CRAWLIO_LIB" "$PROGRAM" "$@"
