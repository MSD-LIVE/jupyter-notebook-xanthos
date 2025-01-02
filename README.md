# MSD-LIVE Statemodify Notebook

This repo contains the Dockerfile to build the notebook image as well as the notebooks
used in the MSD-LIVE deployment. It will rebuild the image and redeploy the notebooks
whenever changes are pushed to the main branch.

**The data folder is too big, so we are not checking this into github. You will have
to pull from s3 if you want to test locally**

## Testing the notebook locally

1. Get the data

   ```bash
   # make sure you are in the jupyter-notebook-xanthos folder
   mkdir data
   cd data
   aws s3 cp s3://xanthos-notebook-bucket/data . --recursive

   ```

2. Start the notebook via docker compose
   ```bash
   # make sure you are in the jupyter-notebook-xanthos folder
   docker compose up
   ```

Notebook repos need to set these secrets (use *_uploader user to generate new access keys):  

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_S3_BUCKET

## Testing a dev deployment notebook in the cloud

Zoe does this when debugging the base notebook:
1. Build a new base notebook image:
   ```bash
   ~/msdlive/jupyter/jupyter-stacks/images/hub-notebook$ docker compose build
   ```
1. Retag the base notebook image with 'dev':
   ```bash
   ~/msdlive/jupyter/jupyter-stacks/images/hub-notebook$ docker tag ghcr.io/msd-live/jupyter/python-notebook:latest notebook:dev
   ```
1. Build the xanthos image to use 'dev' tag:

   Edit Dockerfile to use
   ```bash
   FROM ghcr.io/msd-live/jupyter/python-notebook:dev AS build-image
   ```
   build and publish the dev image:
   ```bash
   ~/msdlive/jupyter/notebook_repos/jupyter-notebook-xanthos$ docker build -t ghcr.io/msd-live/jupyter/xanthos-notebook:dev -f Dockerfile .
   ~/msdlive/jupyter/notebook_repos/jupyter-notebook-xanthos$ docker push ghcr.io/msd-live/jupyter/xanthos-notebook:dev
   ```
1. You might need to update the xanthos stack deployment if it was deployed to use 'latest' instead of 'dev':

   Edit jupyter-stack/deployments/xanthos/config.dev.yaml to have 
   ```bash
   notebook_image: ghcr.io/msd-live/jupyter/xanthos-notebook:dev
   ```
   Redeploy the stack:
   ```bash
   ~/msdlive/jupyter/jupyter-stacks/stacks$ ./stack.sh run_deployment deploy xanthos dev
   ```