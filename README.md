# github-runner-kaniko
Github runner adopted to k8s environments without docker

Modern k8s environments don't support docker anymore, which makes impossible to use the stock github-runner on such environments to build container images.

The humble solution was to implement a modified container image for github-runner, that contains the upstream github-runner software, kaniko and a self-baked shell script that enables kaniko builds on a non-ephemeral containers.

A possible Github action for a container build job looks like this on this runner container:

```yaml
name: build my-repo
run-name: ${{ github.actor }} is building my-repo 🚀
on:
  push:
    branches:
    - main
  workflow_dispatch:
jobs:
  builmy-repo:
    runs-on: self-hosted
    steps:
      
      - name: 🎉 The job was automatically triggered by a ${{ github.event_name }} event.
        run: echo "🎉 The job was automatically triggered by a ${{ github.event_name }} event."
      - name: 🐧 This job is now running on a ${{ runner.os }} runner hosted in by you!
        run: echo "🐧 This job is now running on a ${{ runner.os }} runner hosted by you!"
      - name: 🔎 We are on ${{ github.repository }} / ${{ github.ref }} / ${{ github.sha }}.
        run: echo "🔎 We are on ${{ github.repository }} / ${{ github.ref }} / ${{ github.sha }}."
      
      - name: 🌀 Check out repository code
        uses: actions/checkout@v3
      
      - name: 🏗️ Kaniko build
        run: kaniko-build ${{ github.workspace }}/Dockerfile public.ecr.aws/my-registry/my-service:latest

      - name: 🌛 Job status is ${{ job.status }}
        run: echo "This job's status is ${{ job.status }}."
```


## Environment

To get kaniko working you will need to set eventually sume environment varables, your mileage might vary, these are the ones to set on clusters running on AWS with IRSA enabled. The specified role needs to have access to push into the repo you specify in the pipeline.

```bash
AWS_DEFAULT_REGION # eu-central-1
AWS_REGION # eu-central-1
AWS_ROLE_ARN # arn:aws:iam::12345678:role/ecr-builder
AWS_WEB_IDENTITY_TOKEN_FILE # /var/run/secrets/eks.amazonaws.com/serviceaccount/token
```

# TODO 

- Implement the same as Github action.
 

