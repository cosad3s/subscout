#!/bin/sh

# Styles
GREEN="\e[32m"
RED="\e[31m"
NC="\e[0m"

# Args
INPUT_DOMAINS="$1"

# Requirements checks
if [ -z "$INPUT_DOMAINS" ]
then
    echo -e "${RED}[-] No domain to search. Quit.${NC}"
    exit 1
else
    INPUT_DOMAINS=$(printf "$INPUT_DOMAINS" | tr -d " \t\n\r" )
fi

# INIT
echo -e "[*] Init ..."
## Binaries
BIN_CERO="cero/cero"
BIN_C99="C99nl-CLI/c99nl.sh"
BIN_SUBFINDER="subfinder/v2/subfinder"
BIN_THEHARVESTER="theHarvester/theHarvester.py"

## Keys
KEYS_LOCATION="/etc/theHarvester/api-keys.yaml"
KEY_SHODAN=$(cat $KEYS_LOCATION | yq .apikeys.shodan.key | tr -d "\"")
KEY_FOFA=$(cat $KEYS_LOCATION | yq .apikeys.fofa.key | tr -d "\"")
EMAIL_FOFA=$(cat $KEYS_LOCATION | yq .apikeys.fofa.email | tr -d "\"")
KEY_C99=$(cat $KEYS_LOCATION | yq .apikeys.c99.key | tr -d "\"")

## Output files
OUTPUT_FILENAME="found"
OUTPUT_FILENAME_EXTENSION="txt"
OUTPUT="results"
OUTPUT_DEFAULT="$OUTPUT/final/$INPUT_DOMAINS"
OUTPUT_TMP="$OUTPUT/tmp/"
OUTPUT_CERO="$OUTPUT_TMP/cero"
OUTPUT_C99="$OUTPUT_TMP/c99"
OUTPUT_SUBFINDER="$OUTPUT_TMP/subfinder"
OUTPUT_THEHARVESTER="$OUTPUT_TMP/theHarvester"

## Prepare results
mkdir -p "$OUTPUT_TMP" 
rm -rf $OUTPUT_TMP/*
mkdir -p "$OUTPUT_DEFAULT"
mkdir -p "$OUTPUT_CERO"
mkdir -p "$OUTPUT_C99"
mkdir -p "$OUTPUT_SUBFINDER"
mkdir -p "$OUTPUT_THEHARVESTER"

# RUN
echo -e "[*] Run ..."
## C99nl-CLI
if [ ! -z "$KEY_C99" ]
then
    echo -e "[*] C99nl-CLI ..."
    sed -i "s/key=\"\"/key=\"$KEY_C99\"/" "$BIN_C99"
    /bin/sh "$BIN_C99" cfsub "$INPUT_DOMAINS" > "$OUTPUT_C99/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION"
    sed -i '/^\r$/d' "$OUTPUT_C99/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION"
    sed -i '/^$/d' "$OUTPUT_C99/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION"
    echo -e "${GREEN}[+] C99nl-CLI done!${NC}"
fi

## subfinder
mkdir -p "$HOME/.config/subfinder/"
if [ ! -z "$KEY_SHODAN" ]
then
    echo -e "shodan:\n  - $KEY_SHODAN\n" > "$HOME/.config/subfinder/provider-config.yaml"
fi
if [ ! -z "$KEY_FOFA" ] && [ ! -z "$EMAIL_FOFA" ]
then
    echo -e "fofa:\n  - $EMAIL_FOFA:$KEY_FOFA\n" >> "$HOME/.config/subfinder/provider-config.yaml"
fi
echo -e "[*] subfinder ..."
#"$BIN_SUBFINDER" -d "$INPUT_DOMAINS" -o "$OUTPUT_SUBFINDER/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION" -silent &> /dev/null
echo -e "${GREEN}[+] subfinder done!${NC}"

## theHarvester
echo -e "[*] theHarvester (Can take some time) ..."
# Disabled sources: hunter, projectdiscovery, threatcrowd, shodan
SOURCES_THEHARVESTER="anubis,bevigil,baidu,binaryedge,bing,bingapi,bufferoverun,censys,certspotter,crtsh,dnsdumpster,duckduckgo,fullhunt,github-code,hackertarget,intelx,omnisint,otx,pentesttools,qwant,rapiddns,rocketreach,securityTrails,sublist3r,threatminer,urlscan,vhost,virustotal,yahoo"
"$BIN_THEHARVESTER" -d "$INPUT_DOMAINS" -l 1000 -b all -f "$OUTPUT_THEHARVESTER/$OUTPUT_FILENAME" &> /dev/null
cat "$OUTPUT_THEHARVESTER/$OUTPUT_FILENAME.json" | jq .hosts[] | tr -d '\"' > "$OUTPUT_THEHARVESTER/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION.tmp"
sed 's/:.*//' "$OUTPUT_THEHARVESTER/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION.tmp" > "$OUTPUT_THEHARVESTER/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION"
rm "$OUTPUT_THEHARVESTER/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION.tmp"
echo -e "${GREEN}[+] theHarvester done!${NC}"

# AGGREGATE
echo -e "[*] Aggregate the results ..."
cat "$OUTPUT_C99/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION" > "$OUTPUT_TMP/agg_tmp.txt"
cat "$OUTPUT_SUBFINDER/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION" >> "$OUTPUT_TMP/agg_tmp.txt"
cat "$OUTPUT_THEHARVESTER/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION" >> "$OUTPUT_TMP/agg_tmp.txt"
cat "$OUTPUT_TMP/agg_tmp.txt" | sort | uniq > "$OUTPUT_TMP/agg_sorted_tmp.txt"
rm "$OUTPUT_TMP/agg_tmp.txt"
echo -e "${GREEN}[+] Aggregation done!${NC}"

# AFFINE with cero

## Process
echo -e "[*] Running cero ..."
cat "$OUTPUT_TMP/agg_sorted_tmp.txt" | "$BIN_CERO" > "$OUTPUT_CERO/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION.tmp"
## Filter
grep -E "$INPUT_DOMAINS$" "$OUTPUT_CERO/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION.tmp" > "$OUTPUT_CERO/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION"
rm "$OUTPUT_CERO/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION.tmp"
echo -e "${GREEN}[+] cero done!${NC}"

## Aggregate again then reorder
echo -e "[*] Finishing ..."
cat "$OUTPUT_CERO/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION" >> "$OUTPUT_TMP/agg_sorted_tmp.txt"
cat "$OUTPUT_TMP/agg_sorted_tmp.txt" | sort | uniq > "$OUTPUT_DEFAULT/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION"

# END
echo -e "${GREEN}[+] Done!${NC}"
cat "$OUTPUT_DEFAULT/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION"