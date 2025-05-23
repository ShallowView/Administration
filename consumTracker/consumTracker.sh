#!/bin/bash
# TODO: Use functions.

PROGRAM_NAME=$(basename "$0")

# https://www.intel.fr/content/www/fr/fr/products/sku/83356/intel-xeon-processor-e52630-v3-20m-cache-2-40-ghz/specifications.html
UNIVERSITY_SERVERS_PDT=85

CONSO_OUTPUT_FILE="$HOME/consumption"

# ---
showUsage=0
showTable=0
dryRun=0

eval set -- "$(getopt -n "$PROGRAM_NAME" \
	-o "ht" \
	--long "help,dry" \
	-- "$@" \
)"

while true; do
	case "$1" in
		"-h"|"--help")
			showUsage=1
			shift
		;;
		"-t")
			showTable=1
			shift
		;;
		"--dry")
			dryRun=1
			shift
		;;
		"--")
			break
		;;
	esac
done

if [[ $showUsage == 1 ]]; then
	echo "Usage: $PROGRAM_NAME"
	echo
	echo "Options:"
	column -t -s $'\\' <<-EOF
		 -h, --help\Shows this text.
		 -t\Prints the update in a human-readable format.
		 --dry\Makes a dry run; i.e. without saving the update.
	EOF
	exit 2
fi

# ---
calc(){
	bc <<< "$1"
	return
}

# ---
totalConsum=0
nbUpdates=0
meanConsum=0

if [[ -f $CONSO_OUTPUT_FILE ]]; then
    read -r totalConsum nbUpdates meanConsum < "$CONSO_OUTPUT_FILE"
fi

nbUpdates=$((nbUpdates + 1))

# ---
# Somme des pourcentage de l'utilisation CPU
utilProcess=$(ps -eo %cpu --sort=-%cpu | awk '{s+=$1} END {print s}' )

# TODO: Get this value automatically (Maybe from MSR registers?).
# For Intel, see:
#	- 64-ia-32-architectures-software-developer Volume 3b part 2
#	- 64-ia-32-architectures-software-developer Volume 4
# For AMD, see:
#	- https://github.com/tetrau/ryzen-power/blob/master/ryzen-power.py
pdt=$UNIVERSITY_SERVERS_PDT # In watts

# Cross product of the CPU utilization and the power consumption in watts.
# https://www.intel.fr/content/www/fr/fr/support/articles/000005850/processors/desktop-processors/understanding-intel-processor-power-consumption.html
consumption=$(calc "scale=2; $utilProcess * $pdt / 100")

totalConsum=$(calc "scale=2; $totalConsum + $consumption")
newMeanConsum=$(
	calc "scale=2; ($meanConsum*($nbUpdates - 1) + $consumption)/$nbUpdates"
)

# ---
if [[ $dryRun == 0 ]]; then
	printf "%.2f %d %.2f\n" "$totalConsum" "$nbUpdates" "$newMeanConsum" \
		> "$CONSO_OUTPUT_FILE"
fi

if [[ $showTable == 1 ]]; then
	creationDate=$(date -d @"$(stat -c %W "$CONSO_OUTPUT_FILE")")
	modificationDate=$(date -d @"$(stat -c %Y "$CONSO_OUTPUT_FILE")")

	echo "CURRENT CONSO | TOTAL CONSO | AVG CONSO | UPDATES COUNT"
	printf "%11.2f W | %8.2f Wh | %7.2f W | %13d\n" \
		"$consumption" "$totalConsum" "$newMeanConsum" $nbUpdates
	printf "Since: %s;\nLast update: %s\n" "$creationDate" "$modificationDate"
fi