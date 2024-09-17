FROM gcr.io/kaniko-project/executor AS kaniko
FROM ubuntu

RUN apt update; apt install -y  bash git python3 sudo dotnet-sdk-8.0 libicu74 curl ca-certificates podman unzip

RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip && cd /tmp && unzip awscliv2.zip && ./aws/install

COPY --from=kaniko /kaniko/executor /kaniko/executor
COPY --from=kaniko /kaniko/docker-credential-gcr /kaniko/docker-credential-gcr
COPY --from=kaniko /kaniko/docker-credential-ecr-login /kaniko/docker-credential-ecr-login
COPY --from=kaniko /kaniko/docker-credential-acr-env /kaniko/docker-credential-acr-env
COPY --from=kaniko /etc/nsswitch.conf /etc/nsswitch.conf
COPY --from=kaniko /kaniko/.docker /kaniko/.docker

ENV PATH $PATH:/usr/local/bin:/kaniko
ENV DOCKER_CONFIG /kaniko/.docker/
ENV DOCKER_CREDENTIAL_GCR_CONFIG /kaniko/.config/gcloud/docker_credential_gcr_config.json

RUN cd /tmp; curl -O -L https://github.com/actions/runner/releases/download/v2.317.0/actions-runner-linux-x64-2.317.0.tar.gz

COPY sudoers /etc/sudoers.d/sudoers
COPY registries.conf /etc/containers/registries.conf
COPY kaniko-build /usr/bin

RUN mkdir /app
WORKDIR /app
RUN tar xzf /tmp/actions-runner-linux-x64-2.317.0.tar.gz
RUN chown -R ubuntu:ubuntu /app
RUN chown -R ubuntu:ubuntu /kaniko
RUN  ./bin/installdependencies.sh 
USER ubuntu
