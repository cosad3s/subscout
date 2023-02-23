FROM alpine:latest

RUN apk update && apk add git py3-pip jq make go

WORKDIR /app/

RUN git clone https://github.com/projectdiscovery/subfinder && cd subfinder/v2 && make && chmod a+x subfinder
RUN git clone https://github.com/glebarez/cero && cd cero && go build && chmod a+x cero
RUN git clone https://github.com/cosad3s/SubHuntr99 && cd SubHuntr99 && pip install -r requirements.txt && chmod a+x main.py
RUN git clone https://github.com/laramies/theHarvester && cd theHarvester && pip install -r requirements/base.txt && chmod a+x theHarvester.py
# https://github.com/laramies/theHarvester/issues/393
COPY fixes/proxies.yaml /etc/theHarvester/proxies.yaml

COPY entrypoint.sh .
RUN chmod u+x ./entrypoint.sh
ENTRYPOINT [ "/app/entrypoint.sh" ]