#!/bin/bash
#ps -eo %cpu --sort=-%cpu | awk '{print $1}'
#Somme des pourcentage de l'utilisation CPU : ps -eo %cpu --sort=-%cpu | awk '{s+=$1} END {print s}'

utilProcess=$(ps -eo %cpu --sort=-%cpu | awk '{s+=$1} END {print s}' )

#conso cpu https://www.intel.fr/content/www/fr/fr/products/sku/83356/intel-xeon-processor-e52630-v3-20m-cache-2-40-ghz/specifications.html
#En watt
pdt=85

#Cross product of the CPU utilization and the power consumption in watts
#https://www.intel.fr/content/www/fr/fr/support/articles/000005850/processors/desktop-processors/understanding-intel-processor-power-consumption.html
#Actual consumption
consumption=$(echo "scale=2; $utilProcess * $pdt / 100" | bc)


nbLog=0
meanConsum=0
TTconsum=0
#Verify if logConso file exist
if [[ -f logConso ]]; then
    read -r TTconsum nbLog meanConsum < logConso
fi
nbLog=$((nbLog + 1))

#Total Consumption
TTconsum=$(echo "scale=2; $consumption + $TTconsum" | bc)

#(meanConsum*nbLog+consumption)/nb
newMeanConsum=$(echo "scale=2; ($meanConsum * ($nbLog - 1) + $consumption)/ $nbLog" | bc)
#Order : Total consumption number of log Mean consumption
formatlogConso=$(printf "%s %s %s" $TTconsum $nbLog $newMeanConsum)

echo $formatlogConso > logConso
