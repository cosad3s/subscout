# Subscout

All-in-one subdomain aggregator image.
No tool is perfect. Several subdomain finders exists and some of them are combined in this single Docker image to give one sorted output.

## Requirements

- Docker

## Usage

```bash
sudo ./subscout.sh example.org
```

*All results will be in the `output/example.org` folder*

## What's included ?

- [subfinder](https://github.com/projectdiscovery/subfinder): 
  - Powered by: *BeVigil, BinaryEdge, BufferOver, C99, Censys, CertSpotter, Chaos, Chinaz, DnsDB, Fofa, FullHunt, GitHub, Intelx, PassiveTotal, quake, Robtex, SecurityTrails, Shodan, ThreatBook, VirusTotal, WhoisXML API, ZoomEye, ZoomEye API, dnsrepo, Hunter*
- [C99nl-CLI](https://github.com/Baud-Hacker/C99nl-CLI):
  - Powered by: *[https://subdomainfinder.c99.nl/](https://subdomainfinder.c99.nl/)*
- [theHarvester](https://github.com/laramies/theHarvester):
  - Powered by: *anubis, bevigil, baidu, binaryedge, bing, bingapi, bufferoverun, censys, certspotter, crtsh, dnsdumpster, duckduckgo, fullhunt, github-code, hackertarget, hunter, intelx, omnisint, otx, pentesttools, projectdiscovery, qwant, rapiddns, rocketreach, securityTrails, shodan, sublist3r, threatcrowd, threatminer, urlscan, vhost, virustotal, yahoo, zoomeye*
- [cero](https://github.com/glebarez/cero)

## Configuration

Edit your api keys in `api-keys.yaml` file if necessary for better result.
