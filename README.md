# Publish Docker Image action

Build Docker image and push it to Google Container Registry (GCR).


## Inputs

### `gcloud_auth_key`

**Required** The JSON key that is used to access GCR.

### `gcloud_project_id`

**Required** Your Google Cloud Platform project ID.

### `hostname`

**Required** The GCR hostname, which specifies the region of the registry's storage.

### `dockerfile_path`

**Required** The path of Dockerfile. Default `"."`.

### `image_name`

**Required** The name of docker image (without hostname and tag).


## Outputs

### `image_repository`

The repository of the pushed image.

### `image_version`

The image version correspond to the git branch or tag.


## Example usage

    uses: hahow/publish-docker-image-action@v1.0.0
    with:
      gcloud_auth_key: ${{ secrets.GCLOUD_AUTH_KEY }}
      gcloud_project_id: ${{ secrets.GCLOUD_PROJECT_ID }}
      hostname: asia.gcr.io
      image_name: core/payment-system
