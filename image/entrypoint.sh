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
BIN_SUBFINDER="subfinder/v2/subfinder"
BIN_THEHARVESTER="theHarvester/theHarvester.py"
BIN_AMASS="/root/go/bin/amass"
BIN_CRTSH="crtsh/crtsh"

## Configuration
### Amass - Non-bruteforce and working datasources only
CONFIG_AMASS="/etc/amass-config.ini"
AMASS_USED_DATASOURCES="360PassiveDNS,ASNLookup,AbuseIPDB,Ahrefs,AlienVault,AnubisDB,ArchiveIt,Arquivo,Ask,BGPTools,BGPView,Baidu,BeVigil,BigDataCloud,BinaryEdge,Bing,BufferOver,BuiltWith,C99,CIRCL,CertCentral,CertSpotter,Chaos,Cloudflare,CommonCrawl,DNSDB,DNSDumpster,DNSHistory,DNSRepo,DNSSpy,DNSlytics,Deepinfo,Detectify,Digitorus,DuckDuckGo,FOFA,FacebookCT,Gists,GitHub,GitLab,Google,GoogleCT,Greynoise,HAW,HackerOne,HackerTarget,Hunter,HyperStat,IPdata,IPinfo,IntelX,LeakIX,Maltiverse,Mnemonic,Netlas,NetworksDB,PKey,PassiveTotal,Pastebin,PentestTools,PublicWWW,Pulsedive,Quake,RADb,RapidDNS,Riddler,Robtex,SOCRadar,Searchcode,Searx,SecurityTrails,ShadowServer,Shodan,SiteDossier,SonarSearch,Spamhaus,SpyOnWeb,Spyse,Sublist3rAPI,Synapsint,TeamCymru,ThreatBook,ThreatMiner,Twitter,UKWebArchive,URLScan,Umbrella,VirusTotal,Wayback,WhoisXMLAPI,Yahoo,Yandex,ZETAlytics,ZoomEye"
### Subfinder
# Notes: SUBFINDER_ALLDATASOURCES="BeVigil,BinaryEdge,BufferOver,C99,Censys,CertSpotter,Chaos,Chinaz,DnsDB,Fofa,FullHunt,GitHub,Intelx,PassiveTotal,quake,Robtex,SecurityTrails,Shodan,ThreatBook,VirusTotal,WhoisXML API,ZoomEye,ZoomEye API,dnsrepo,Hunter"
SUBFINDER_USED_DATASOURCES="Chinaz,FullHunt"
### theHarvester
# Notes: THEHARVESTER_ALLDATASOURCES="anubis,bevigil,baidu,binaryedge,bing,bingapi,bufferoverun,censys,certspotter,crtsh,dnsdumpster,duckduckgo,fullhunt,github-code,hackertarget,hunter,intelx,omnisint,otx,pentesttools,projectdiscovery,qwant,rapiddns,rocketreach,securityTrails,shodan,sublist3r,threatcrowd,threatminer,urlscan,vhost,virustotal,yahoo,zoomeye"
THEHARVESTER_USED_DATASOURCES="qwant"

## Output files
OUTPUT_FILENAME="subdomains"
OUTPUT_FILENAME_EXTENSION="txt"
OUTPUT="results"
OUTPUT_DEFAULT="$OUTPUT/final/$INPUT_DOMAINS"
OUTPUT_TMP="$OUTPUT/tmp"
OUTPUT_CERO="$OUTPUT_TMP/cero"
OUTPUT_SUBFINDER="$OUTPUT_TMP/subfinder"
OUTPUT_THEHARVESTER="$OUTPUT_TMP/theHarvester"
OUTPUT_AMASS="$OUTPUT_TMP/amass"
OUTPUT_CRTSH="$OUTPUT_TMP/crtsh"

## Prepare results
mkdir -p "$OUTPUT_TMP" 
rm -rf $OUTPUT_TMP/*
mkdir -p "$OUTPUT_DEFAULT"
mkdir -p "$OUTPUT_CERO"
mkdir -p "$OUTPUT_SUBFINDER"
mkdir -p "$OUTPUT_THEHARVESTER"
mkdir -p "$OUTPUT_AMASS"
mkdir -p "$OUTPUT_CRTSH"

# RUN
echo -e "[*] Run ..."

## amass
echo -e "[*] amass ..."
"$BIN_AMASS" enum -config "$CONFIG_AMASS" -include "$AMASS_USED_DATASOURCES" -d "$INPUT_DOMAINS" -o "$OUTPUT_AMASS/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION" -nocolor -silent &>/dev/null
echo -e "${GREEN}[+] amass done!${NC}"

echo -e "[*] subfinder ..."
"$BIN_SUBFINDER" -s "$SUBFINDER_USED_DATASOURCES" -d "$INPUT_DOMAINS" -o "$OUTPUT_SUBFINDER/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION" -silent &> /dev/null
echo -e "${GREEN}[+] subfinder done!${NC}"

## theHarvester
echo -e "[*] theHarvester ..."
"$BIN_THEHARVESTER" -d "$INPUT_DOMAINS" -l 1000 -b "$THEHARVESTER_USED_DATASOURCES" -f "$OUTPUT_THEHARVESTER/$OUTPUT_FILENAME" &> /dev/null
cat "$OUTPUT_THEHARVESTER/$OUTPUT_FILENAME.json" | jq .hosts[] | tr -d '\"' > "$OUTPUT_THEHARVESTER/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION.tmp"
sed 's/:.*//' "$OUTPUT_THEHARVESTER/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION.tmp" > "$OUTPUT_THEHARVESTER/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION"
rm "$OUTPUT_THEHARVESTER/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION.tmp"
echo -e "${GREEN}[+] theHarvester done!${NC}"

echo -e "[*] crtsh ..."
"$BIN_CRTSH" -q "$INPUT_DOMAINS" -o > "$OUTPUT_CRTSH.$OUTPUT_FILENAME_EXTENSION"
echo -e "${GREEN}[+] crtsh done!${NC}"

# AGGREGATE
echo -e "[*] Aggregate the results ..."
cat "$OUTPUT_SUBFINDER/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION" >> "$OUTPUT_TMP/agg_tmp.txt"
cat "$OUTPUT_THEHARVESTER/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION" >> "$OUTPUT_TMP/agg_tmp.txt"
cat "$OUTPUT_AMASS/$OUTPUT_FILENAME.$OUTPUT_FILENAME_EXTENSION" >> "$OUTPUT_TMP/agg_tmp.txt"
cat "$OUTPUT_CRTSH.$OUTPUT_FILENAME_EXTENSION" >> "$OUTPUT_TMP/agg_tmp.txt"
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