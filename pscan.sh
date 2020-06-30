#!/bin/bash

name="example-scan"

# Start fleet using the supplied name, spend $0.1 and self-destruct after 1 hour
axiom-fleet $name -i=5 --spend=0.1 --time=1

# Execute this one liner on every machine, basically scan its portion
axiom-execb 'curl -s https://easyasn.xyz/companies/vultr/ranges.txt | grep -v ":" > ranges.txt && sudo masscan -iL ranges.txt --rate=10000 -p443 --shard $i/$total -oG $name.txt' "$name*" 


# Wait until the scan has finished, then press enter to tear down!
echo "Press enter to tear down"
read

# Download all the output masscan files
for i in $(axiom-ls -d | grep -E "$name*"); do axiom-scp $i:~/$i.txt .; done

# Sort and merge the massscan files into a single sorted file
cat $name* | sort -u > tmp && rm -rf $name* && mv tmp $name.txt

# Shut down all instances that match $name
echo "Shutting down instances..."
axiom-rm "$name*" -f
