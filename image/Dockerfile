FROM alpine:latest

RUN apk update && apk add git py3-pip jq make go yq curl

WORKDIR /app/

RUN wget https://github.com/projectdiscovery/subfinder/releases/download/v2.6.3/subfinder_2.6.3_linux_amd64.zip && unzip subfinder_2.6.3_linux_amd64.zip && rm subfinder_2.6.3_linux_amd64.zip && chmod a+x subfinder
RUN git clone https://github.com/glebarez/cero && cd cero && go build && chmod a+x cero
RUN go install -v github.com/owasp-amass/amass/v3/...@v3.23.3
RUN mkdir fofax && cd fofax && wget https://github.com/xiecat/fofax/releases/download/v0.1.44/fofax_v0.1.44_linux_amd64.tar.gz && tar xvzf fofax_v0.1.44_linux_amd64.tar.gz && rm fofax_v0.1.44_linux_amd64.tar.gz && chmod a+x fofax
RUN pip3 install requests puncia

COPY entrypoint.sh .
RUN chmod u+x ./entrypoint.sh
ENTRYPOINT [ "/app/entrypoint.sh" ]