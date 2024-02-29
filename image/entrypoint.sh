#!/bin/bash

# Styles
GREEN="\e[32m"
RED="\e[31m"
NC="\e[0m"

# Args
INPUT_DOMAINS="$1"

# Requirements checks
if [ -z "$INPUT_DOMAINS" ]
then
    echo -e "${RED}[-] No domain to search. Quit.${NC}"
    exit 1
else
    INPUT_DOMAINS=$(printf "$INPUT_DOMAINS" | tr -d " \t\n\r" )
    IFS=',' read -ra DOMAINS <<< "$INPUT_DOMAINS"
fi

# INIT
echo -e "[*] Init ..."

## Binaries
BIN_CERO="cero/cero"
BIN_SUBFINDER="./subfinder"
BIN_AMASS="/root/go/bin/amass"
BIN_FOFAX="fofax/fofax"
BIN_PUNCIA="puncia"

## Configuration
### Amass (passive, no bruteforce)
CONFIG_AMASS="/etc/amass-config.ini"
AMASS_USED_DATASOURCES="360PassiveDNS,ASNLookup,AbuseIPDB,Ahrefs,ArchiveIt,Arquivo,Ask,BGPTools,BGPView,Baidu,BigDataCloud,Bing,CIRCL,CertCentral,DNSHistory,DNSSpy,DNSlytics,Deepinfo,Detectify,DuckDuckGo,Gists,GitLab,Google,GoogleCT,Greynoise,HAW,HackerOne,HyperStat,IPdata,IPinfo,Maltiverse,Mnemonic,PKey,Pastebin,PentestTools,PublicWWW,Pulsedive,RADb,SOCRadar,Searchcode,Searx,ShadowServer,SonarSearch,Spamhaus,SpyOnWeb,Sublist3rAPI,Synapsint,TeamCymru,ThreatMiner,UKWebArchive,URLScan,Yahoo,Yandex,ZETAlytics"
### Subfinder
CONFIG_SUBFINDER="/etc/subfinder-config.yaml"
SUBFINDER_USED_DATASOURCES="alienvault,anubis,bevigil,binaryedge,bufferover,builtwith,c99,certspotter,commoncrawl,crtsh,digitorus,dnsdumpster,fullhunt,github,hackertarget,intelx,leakix,netlas,rapiddns,redhuntlabs,securitytrails,shodan,virustotal,waybackarchive,zoomeyeapi"
## fofax
"$BIN_FOFAX" -silent

## Output files
OUTPUT_FILENAME="subdomains"
OUTPUT_FILENAME_EXTENSION="txt"
OUTPUT="results"

for DOMAIN in "${DOMAINS[@]}"; do
    echo -e "${GREEN}[*] Scanning $DOMAIN ...${NC}" 

    OUTPUT_DEFAULT="$OUTPUT/final/$DOMAIN"
    OUTPUT_TMP="$OUTPUT/tmp"
    OUTPUT_CERO="$OUTPUT_TMP/cero"
    OUTPUT_SUBFINDER="$OUTPUT_TMP/subfinder"
    OUTPUT_AMASS="$OUTPUT_TMP/amass"
    OUTPUT_FOFAX="$OUTPUT_TMP/fofax"
    OUTPUT_PUNCIA="$OUTPUT_TMP/puncia"

    ## Prepare results
    mkdir -p "$OUTPUT_TMP" 
    rm -rf $OUTPUT_TMP/*
    mkdir -p "$OUTPUT_DEFAULT"
    mkdir -p "$OUTPUT_CERO"
    mkdir -p "$OUTPUT_SUBFINDER"
    mkdir -p "$OUTPUT_AMASS"
    mkdir -p "$OUTPUT_FOFAX"
    mkdir -p "$OUTPUT_PUNCIA"

    # RUN
    echo -e "[*] Run ..."

    ## amass
    echo -e "[*] amass ..."
    "$BIN_AMASS" enum -config "$CONFIG_AMASS" -include "$AMASS_USED_DATASOURCES" -d "$DOMAIN" -o "$OUTPUT_AMASS/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION" -nocolor -silent &>/dev/null
    echo -e "${GREEN}[+] amass done!${NC}"

    echo -e "[*] subfinder ..."
    "$BIN_SUBFINDER" -pc "$CONFIG_SUBFINDER" -s "$SUBFINDER_USED_DATASOURCES" -d "$DOMAIN" -o "$OUTPUT_SUBFINDER/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION" -silent &> /dev/null
    echo -e "${GREEN}[+] subfinder done!${NC}"

    ## fofax
    echo -e "[*] fofax ..."
    "$BIN_FOFAX" -q 'domain='"$DOMAIN"'' | cut -d ':' -f1 > "$OUTPUT_FOFAX/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION"
    echo -e "${GREEN}[+] fofax done!${NC}"

    ## puncia
    echo -e "[*] puncia ..."
    "$BIN_PUNCIA" subdomain "$DOMAIN" "$OUTPUT_PUNCIA/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION" &> /dev/null
    echo -e "${GREEN}[+] puncia done!${NC}"

    # AGGREGATE
    echo -e "[*] Aggregate the results ..."
    cat "$OUTPUT_SUBFINDER/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION" >> "$OUTPUT_TMP/agg_tmp.txt"
    cat "$OUTPUT_AMASS/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION" >> "$OUTPUT_TMP/agg_tmp.txt"
    cat "$OUTPUT_FOFAX/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION" >> "$OUTPUT_TMP/agg_tmp.txt"
    cat "$OUTPUT_PUNCIA/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION" | jq .[] | sed s/\"//g >> "$OUTPUT_TMP/agg_tmp.txt"
    cat "$OUTPUT_TMP/agg_tmp.txt" | LC_COLLATE=C sort | uniq > "$OUTPUT_TMP/agg_sorted_tmp.txt"
    rm "$OUTPUT_TMP/agg_tmp.txt"
    echo -e "${GREEN}[+] Aggregation done!${NC}"

    # AFFINE with cero

    ## Process
    echo -e "[*] Running cero ..."
    cat "$OUTPUT_TMP/agg_sorted_tmp.txt" | "$BIN_CERO" > "$OUTPUT_CERO/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION.tmp"
    ## Filter
    grep -E "$DOMAIN$" "$OUTPUT_CERO/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION.tmp" > "$OUTPUT_CERO/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION"
    rm "$OUTPUT_CERO/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION.tmp"
    echo -e "${GREEN}[+] cero done!${NC}"

    ## Aggregate again then reorder
    echo -e "[*] Finishing ..."
    cat "$OUTPUT_CERO/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION" >> "$OUTPUT_TMP/agg_sorted_tmp.txt"
    cat "$OUTPUT_TMP/agg_sorted_tmp.txt" | LC_COLLATE=C sort | uniq > "$OUTPUT_DEFAULT/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION"

    # END
    echo -e "${GREEN}[+] Done!${NC}"
    cat "$OUTPUT_DEFAULT/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION"
done