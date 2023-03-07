# Subscout

**All-in-one subdomains passive scout tool Docker image.**  
*No tool is perfect. Several subdomain finders exists and some of them are combined in this single Docker image to give one sorted output.*

## Requirements

- Docker

## Usage

```bash
sudo ./subscout.sh example.org
```

*All results will be in the `output/example.org` folder*

## What's included ?

- [amass](https://github.com/OWASP/Amass):
  - Powered by:
    - APIs:	*360PassiveDNS, Ahrefs, AnubisDB, BeVigil, BinaryEdge, BufferOver, BuiltWith, C99, Chaos, CIRCL, Cloudflare, DNSDB, DNSRepo, Deepinfo, Detectify, FOFA, FullHunt, GitHub, GitLab, Greynoise, HackerTarget, Hunter, IntelX, LeakIX, Maltiverse, Mnemonic, Netlas, Pastebin, PassiveTotal, PentestTools, Pulsedive, Quake, SOCRadar, Searchcode, Shodan, SonarSearch, Spamhaus, Spyse, Sublist3rAPI, ThreatBook, ThreatCrowd, ThreatMiner, Twitter, URLScan, VirusTotal, Yandex, ZETAlytics, ZoomEye*
    - Certificates:	*Active pulls (optional), Censys, CertCentral, CertSpotter, Crtsh, Digitorus, FacebookCT, GoogleCT*
    - DNS: *Brute forcing, Reverse DNS sweeping, NSEC zone walking, Zone transfers, FQDN alterations/permutations, FQDN Similarity-based Guessing*
    - Routing:	*ASNLookup, BGPTools, BGPView, BigDataCloud, IPdata, IPinfo, NetworksDB, RADb, Robtex, ShadowServer, TeamCymru*
    - Scraping:	*AbuseIPDB, Ask, Baidu, Bing, DNSDumpster, DNSHistory, DNSSpy, DuckDuckGo, Gists, Google, HackerOne, HyperStat, PKey, RapidDNS, Riddler, Searx, SiteDossier, Synapsint, Yahoo*
    - Web Archives:	*ArchiveIt, Arquivo, CommonCrawl, HAW, PublicWWW, UKWebArchive, Wayback*
    - WHOIS:	*AlienVault, AskDNS, DNSlytics, ONYPHE, SecurityTrails, SpyOnWeb, Umbrella, WhoisXMLAPI*
  - **Set with:** *360PassiveDNS,ASNLookup,AbuseIPDB,Ahrefs,AlienVault,AnubisDB,ArchiveIt,Arquivo,Ask,BGPTools,BGPView,Baidu,BeVigil,BigDataCloud,BinaryEdge,Bing,BufferOver,BuiltWith,C99,CIRCL,CertCentral,CertSpotter,Crtsh,Chaos,Cloudflare,CommonCrawl,Crtsh,DNSDB,DNSDumpster,DNSHistory,DNSRepo,DNSSpy,DNSlytics,Deepinfo,Detectify,Digitorus,DuckDuckGo,FOFA,FacebookCT,Gists,GitHub,GitLab,Google,GoogleCT,Greynoise,HAW,HackerOne,HackerTarget,Hunter,HyperStat,IPdata,IPinfo,IntelX,LeakIX,Maltiverse,Mnemonic,Netlas,NetworksDB,PKey,PassiveTotal,Pastebin,PentestTools,PublicWWW,Pulsedive,Quake,RADb,RapidDNS,Riddler,Robtex,SOCRadar,Searchcode,Searx,SecurityTrails,ShadowServer,Shodan,SiteDossier,SonarSearch,Spamhaus,SpyOnWeb,Spyse,Sublist3rAPI,Synapsint,TeamCymru,ThreatBook,ThreatMiner,Twitter,UKWebArchive,URLScan,Umbrella,VirusTotal,Wayback,WhoisXMLAPI,Yahoo,Yandex,ZETAlytics,ZoomEye*
- [subfinder](https://github.com/projectdiscovery/subfinder): 
  - Powered by: *BeVigil, BinaryEdge, BufferOver, C99, Censys, CertSpotter, Chaos, Chinaz, DnsDB, Fofa, FullHunt, GitHub, Intelx, PassiveTotal, quake, Robtex, SecurityTrails, Shodan, ThreatBook, VirusTotal, WhoisXML API, ZoomEye, ZoomEye API, dnsrepo, Hunter*
  - **Set with:** *Chinaz,FullHunt*
- [theHarvester](https://github.com/laramies/theHarvester):
  - Powered by: *anubis, bevigil, baidu, binaryedge, bing, bingapi, bufferoverun, censys, certspotter, crtsh, dnsdumpster, duckduckgo, fullhunt, github-code, hackertarget, hunter, intelx, otx, pentesttools, projectdiscovery, qwant, rapiddns, rocketreach, securityTrails, shodan, sublist3r, threatcrowd, threatminer, urlscan, vhost, virustotal, yahoo, zoomeye*
  - **Set with**: *qwant,rocketreach*
- [cero](https://github.com/glebarez/cero)

## Configuration

Add your api keys in `config/api-keys.yaml` file if necessary for better result.
Use the file `config/api-keys-example.yaml` as an example.
