# Subscout

**All-in-one subdomains passive scout tool Docker image.**  
*No tool is perfect. Several subdomain finders exists and some of them are combined in this single Docker image to give one sorted output.*

## Requirements

- Docker

## Usage

```bash
┌─┐┬ ┬┌┐ ┌─┐┌─┐┌─┐┬ ┬┌┬┐
└─┐│ │├┴┐└─┐│  │ ││ │ │ 
└─┘└─┘└─┘└─┘└─┘└─┘└─┘ ┴ 

Usage of subscout by cosad3s.

-d  Domain(s) to scout (separated by comma).
-f  Force subscout Docker image to be rebuilt.
-h  --Displays this help message. No further functions are performed.
```

**Example**

```bash
sudo ./subscout.sh -d example.org
```

*All results will be in the `output/example.org` folder*

## What's included ?

- [amass v3.23.3](https://github.com/OWASP/Amass):
  - Powered by:
    - APIs:	*360PassiveDNS, Ahrefs, AnubisDB, BeVigil, BinaryEdge, BufferOver, BuiltWith, C99, Chaos, CIRCL, Cloudflare, DNSDB, DNSRepo, Deepinfo, Detectify, FOFA, FullHunt, GitHub, GitLab, Greynoise, HackerTarget, Hunter, IntelX, LeakIX, Maltiverse, Mnemonic, Netlas, Pastebin, PassiveTotal, PentestTools, Pulsedive, Quake, SOCRadar, Searchcode, Shodan, SonarSearch, Spamhaus, Sublist3rAPI, ThreatBook, ThreatCrowd, ThreatMiner, URLScan, VirusTotal, Yandex, ZETAlytics, ZoomEye*
    - Certificates:	*Active pulls (optional), Censys, CertCentral, CertSpotter, Crtsh, Digitorus, FacebookCT, GoogleCT*
    - DNS: *Brute forcing, Reverse DNS sweeping, NSEC zone walking, Zone transfers, FQDN alterations/permutations, FQDN Similarity-based Guessing*
    - Routing:	*ASNLookup, BGPTools, BGPView, BigDataCloud, IPdata, IPinfo, RADb, Robtex, ShadowServer, TeamCymru*
    - Scraping:	*AbuseIPDB, Ask, Baidu, Bing, DNSDumpster, DNSHistory, DNSSpy, DuckDuckGo, Gists, Google, HackerOne, HyperStat, PKey, RapidDNS, Riddler, Searx, SiteDossier, Synapsint, Yahoo*
    - Web Archives:	*ArchiveIt, Arquivo, CommonCrawl, HAW, PublicWWW, UKWebArchive, Wayback*
    - WHOIS:	*AlienVault, AskDNS, DNSlytics, ONYPHE, SecurityTrails, SpyOnWeb, Umbrella, WhoisXMLAPI*
  - **Set with:** *360PassiveDNS,ASNLookup,AbuseIPDB,Ahrefs,ArchiveIt,Arquivo,Ask,BGPTools,BGPView,Baidu,BigDataCloud,Bing,CIRCL,CertCentral,Cloudflare,DNSHistory,DNSSpy,DNSlytics,Deepinfo,Detectify,DuckDuckGo,FOFA,Gists,GitLab,Google,GoogleCT,Greynoise,HAW,HackerOne,HyperStat,IPdata,IPinfo,Maltiverse,Mnemonic,PKey,Pastebin,PentestTools,PublicWWW,Pulsedive,RADb,SOCRadar,Searchcode,Searx,ShadowServer,SonarSearch,Spamhaus,SpyOnWeb,Sublist3rAPI,Synapsint,TeamCymru,ThreatMiner,UKWebArchive,URLScan,Umbrella,Yahoo,Yandex,ZETAlytics*
- [subfinder](https://github.com/projectdiscovery/subfinder): 
  - Powered by: *AlienVault, AnubisDB, BeVigil, BinaryEdge, BufferOver, BuiltWith, C99, Censys, CertSpotter, Chaos, Chinaz, CommonCrawl, Digitorus, DnsDB, dnsdumpster, dnsrepo, FullHunt, Intelx, hackertarget, Hunter, LeakIX, PassiveTotal, quake, Netlas, RedHunt Labs, Robtex, SecurityTrails, Shodan, ThreatBook, VirusTotal, WhoisXML API, ZoomEye, ZoomEye API*
  - **Set with:** *AlienVault, AnubisDB, BeVigil, BinaryEdge, BufferOver, BuiltWith, c99, CertSpotter, CommonCrawl, crtsh, Digitorus, dnsdumpster, FullHunt, GitHub, hackertarget, IntelX, LeakIX, Netlas, RapidDNS, Riddler, RedHunt Labs, Sitedossier, SecurityTrails, Shodan, VirusTotal, Wayback, ZoomEye API*
- [theHarvester](https://github.com/laramies/theHarvester):
  - Powered by: *anubis, bevigil, baidu, binaryedge, bing, bingapi, bufferoverun, censys, certspotter, crtsh, dnsdumpster, duckduckgo, facebook, fullhunt, github-code, hackertarget, intelx, otx, pentesttools, projectdiscovery, qwant, rapiddns, rocketreach, securityTrails, shodan, sublist3r, threatcrowd, threatminer, urlscan, vhost, virustotal, yahoo, Wayback, zoomeye*
  - **Set with**: *qwant*
- [puncia](https://github.com/ARPSyndicate/puncia):
  - **Powered by:** [SubdomainCenter](https://www.subdomain.center/)
- [fofax](https://github.com/xiecat/fofax):
  - **Powered by**: Fofa
- [cero](https://github.com/glebarez/cero): to get domain names from certificates.

## Configuration

Add your credentials in `config/amass-config.ini` file if necessary for better result.
Use the file `config/amass-config-example.ini` as an example.

Add your Redhunt credentials in `config/subfinder-config.yaml` file if necessary for better result.
Use the file `config/subfinder-config-example.yaml` as an example.