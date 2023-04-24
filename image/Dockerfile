FROM alpine:latest

RUN apk update && apk add git py3-pip jq make go yq curl

WORKDIR /app/

RUN git clone https://github.com/projectdiscovery/subfinder && cd subfinder/v2 && make && chmod a+x subfinder
RUN git clone https://github.com/glebarez/cero && cd cero && go build && chmod a+x cero
RUN git clone https://github.com/laramies/theHarvester && cd theHarvester && pip install -r requirements/base.txt && chmod a+x theHarvester.py
# https://github.com/laramies/theHarvester/issues/393
COPY fixes/proxies.yaml /etc/theHarvester/proxies.yaml
RUN go install -v github.com/owasp-amass/amass/v3/...@master
RUN git clone https://github.com/famasoon/crtsh && cd crtsh && go build && chmod a+x crtsh

COPY entrypoint.sh .
RUN chmod u+x ./entrypoint.sh
ENTRYPOINT [ "/app/entrypoint.sh" ]