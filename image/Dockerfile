FROM debian:bookworm-slim

RUN apt update && apt install -y git python3-pip jq make curl unzip

WORKDIR /app/

RUN curl https://go.dev/dl/go1.22.0.linux-amd64.tar.gz -L -o go1.22.0.linux-amd64.tar.gz && tar -C /usr/bin -xzf go1.22.0.linux-amd64.tar.gz && chmod a+x /usr/bin/go && rm go1.22.0.linux-amd64.tar.gz
RUN curl https://github.com/projectdiscovery/subfinder/releases/download/v2.6.5/subfinder_2.6.5_linux_amd64.zip -L -o subfinder_2.6.5_linux_amd64.zip && unzip subfinder_2.6.5_linux_amd64.zip && rm subfinder_2.6.5_linux_amd64.zip && chmod a+x subfinder
RUN git clone https://github.com/glebarez/cero && cd cero && /usr/bin/go/bin/go build && chmod a+x cero
RUN /usr/bin/go/bin/go install -v github.com/owasp-amass/amass/v3/...@v3.23.3
RUN mkdir fofax && cd fofax && curl https://github.com/xiecat/fofax/releases/download/v0.1.47/fofax_v0.1.47_linux_amd64.tar.gz -L -o fofax_v0.1.47_linux_amd64.tar.gz && tar xvzf fofax_v0.1.47_linux_amd64.tar.gz && rm fofax_v0.1.47_linux_amd64.tar.gz && chmod a+x fofax
RUN pip3 install requests puncia --break-system-packages

COPY entrypoint.sh .
RUN chmod u+x ./entrypoint.sh
ENTRYPOINT [ "/app/entrypoint.sh" ]