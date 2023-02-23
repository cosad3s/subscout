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
BIN_SUBHUNTR99="SubHuntr99/main.py"
BIN_SUBFINDER="subfinder/v2/subfinder"
BIN_THEHARVESTER="theHarvester/theHarvester.py"
BIN_SHOSUBGO="shosubgo/main.go"
BIN_FOFAX="fofax/fofax"

## Keys
KEYS_LOCATION="/etc/theHarvester/api-keys.yaml"
KEY_SHODAN=$(cat $KEYS_LOCATION | yq .apikeys.shodan.key | tr -d "\"")
KEY_FOFA=$(cat $KEYS_LOCATION | yq .apikeys.fofa.key | tr -d "\"")
EMAIL_FOFA=$(cat $KEYS_LOCATION | yq .apikeys.fofa.email | tr -d "\"")

## Output files
OUTPUT_FILENAME="found"
OUTPUT_FILENAME_EXTENSION="txt"
OUTPUT="results"
OUTPUT_DEFAULT="$OUTPUT/default"
OUTPUT_TMP="$OUTPUT/tmp"
OUTPUT_CERO="$OUTPUT/cero"
OUTPUT_SUBHUNTR99="$OUTPUT/SubHuntr99"
OUTPUT_SUBFINDER="$OUTPUT/subfinder"
OUTPUT_THEHARVESTER="$OUTPUT/theHarvester"
OUTPUT_SHOSUBGO="$OUTPUT/shosubgo"
OUTPUT_FOFAX="$OUTPUT/fofax"

## Prepare results
rm -rf $OUTPUT/*
mkdir -p "$OUTPUT_TMP"
mkdir -p "$OUTPUT_DEFAULT"
mkdir -p "$OUTPUT_CERO"
mkdir -p "$OUTPUT_SUBHUNTR99"
mkdir -p "$OUTPUT_SUBFINDER"
mkdir -p "$OUTPUT_THEHARVESTER"
mkdir -p "$OUTPUT_SHOSUBGO"
mkdir -p "$OUTPUT_FOFAX"

# RUN
echo -e "[*] Run ..."
## SubHuntr99
echo -e "[*] SubHunter99 ..."
"$BIN_SUBHUNTR99" -q -d "$INPUT_DOMAINS" &> /dev/null
mv "Output/$INPUT_DOMAINS/sub-domains.log" "$OUTPUT_SUBHUNTR99/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION"
rm -r "Output"
echo -e "${GREEN}[+] SubHunter99 done!${NC}"

## subfinder
echo -e "[*] subfinder ..."
"$BIN_SUBFINDER" -d "$INPUT_DOMAINS" -o "$OUTPUT_SUBFINDER/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION" -silent &> /dev/null
echo -e "${GREEN}[+] subfinder done!${NC}"

## theHarvester
echo -e "[*] theHarvester ..."
"$BIN_THEHARVESTER" -d "$INPUT_DOMAINS" -l 1000 -b all -f "$OUTPUT_THEHARVESTER/$OUTPUT_FILENAME"
cat "$OUTPUT_THEHARVESTER/$OUTPUT_FILENAME.json" | jq .hosts[] | tr -d '\"' > "$OUTPUT_THEHARVESTER/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION.tmp"
sed 's/:.*//' "$OUTPUT_THEHARVESTER/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION.tmp" > "$OUTPUT_THEHARVESTER/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION"
rm "$OUTPUT_THEHARVESTER/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION.tmp"
echo -e "${GREEN}[+] theHarvester done!${NC}"

## shosubgo
if [ ! -z "$KEY_SHODAN" ]
then
    echo -e "[*] shosubgo ..."
    go run "$BIN_SHOSUBGO" -d "$INPUT_DOMAINS" -s "$KEY_SHODAN" > "$OUTPUT_SHOSUBGO/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION" &> /dev/null
    echo -e "${GREEN}[+] shosubgo done!${NC}"
fi

## fofax
if [ ! -z "$KEY_FOFA" ] && [ ! -z "$EMAIL_FOFA" ]
then
    echo -e "[*] fofax ..."
    mkdir -p ~/.config/fofax/
    touch ~/.config/fofax/fofax.yaml
    echo -e "fofa-email: $EMAIL_FOFA\n" >> ~/.config/fofax/fofax.yaml 
    echo "fofakey: $KEY_FOFA" >> ~/.config/fofax/fofax.yaml
    cat ~/.config/fofax/fofax.yaml
    echo 'domain="$INPUT_DOMAINS" && status_code="200"' | "$BIN_FOFAX" -ffi -silent > "$OUTPUT_FOFAX/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION"
    echo -e "${GREEN}[+] fofax done!${NC}"
fi

# AGGREGATE
echo -e "[*] Aggregate the results ..."
cat "$OUTPUT_SUBHUNTR99/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION" > "$OUTPUT_TMP/agg_tmp.txt"
cat "$OUTPUT_SUBFINDER/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION" >> "$OUTPUT_TMP/agg_tmp.txt"
cat "$OUTPUT_THEHARVESTER/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION" >> "$OUTPUT_TMP/agg_tmp.txt"
cat "$OUTPUT_SHOSUBGO/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION" >> "$OUTPUT_TMP/agg_tmp.txt"
cat "$OUTPUT_FOFAX/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION" >> "$OUTPUT_TMP/agg_tmp.txt"
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