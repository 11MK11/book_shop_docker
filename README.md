# Book Shop - Phase 2 CI/CD

Django book shop application for the Phase 2 CI/CD pipeline assignment.

Group size: 2 students, so the `test` and `prod` pipelines use Docker Hub as the container registry.

Students:
- Malek Al-Qurany 20210083
- Hashem Al-Kilani 20210047

## Branch Strategy

The repository uses three deployment branches:

- `dev`: artifact-first. The workflow packages the app into `artifacts/app-<commit-sha>.tar.gz`, commits that unique artifact back to the `dev` branch, builds the image from that committed tarball, and deploys it to EC2.
- `test`: image-first. The workflow rebuilds a fresh artifact from source, builds an image from that fresh artifact, pushes the image to Docker Hub, and deploys EC2 by pulling that image.
- `prod`: promotion only. The workflow reads `vars.IMAGE_VERSION`, pulls that existing Docker Hub image, and deploys it. It does not package or create images.

## Artifact Image Build

`Dockerfile` is artifact-based. It receives `ARTIFACT_FILE` as a build argument, copies only that archive into the image, extracts it, and installs dependencies from the wheel files inside the artifact.

Create a local artifact and image with:

```bash
bash scripts/build_artifact.sh local artifacts
docker build --build-arg ARTIFACT_FILE=artifacts/app-local.tar.gz -t bookshop-app:local .
```

## Local Compose Run

Create `.env` from `.env.example`, then set `APP_IMAGE` to an image that already exists locally or in a registry.

```bash
docker-compose -p bookshop-local up -d
```

## EC2 Coexistence Plan

All three branches deploy to the same EC2 instance, but they do not share compose projects:

- `dev`: compose project `bookshop-dev`, default host port `8001`, database volume owned by that project.
- `test`: compose project `bookshop-test`, default host port `8002`, database volume owned by that project.
- `prod`: compose project `bookshop-prod`, default host port `8000`, database volume owned by that project.

The workflows copy the same `docker-compose.yml` and Nginx config to separate directories under `/home/<EC2_USER>/book-shop/` and generate branch-specific `.env` files on the server. This keeps container names, networks, volumes, image versions, and host ports separate. Nginx receives the public host port and proxies requests to the Django backend container.

## GitHub Variables

Configure these under Settings -> Secrets and variables -> Actions -> Variables:

- `IMAGE_VERSION`: production version to promote, for example `test-abc123`.
- `EC2_HOST`: EC2 public DNS or IP.
- `EC2_USER`: SSH username, optional; defaults to `ubuntu`.
- `REGISTRY_NAME`: Docker Hub username or organization.
- `IMAGE_NAME`: Docker Hub repository name.
- `ALLOWED_HOSTS`: comma-separated Django hosts, optional.
- `DEV_PORT`: optional, defaults to `8001`.
- `TEST_PORT`: optional, defaults to `8002`.
- `PROD_PORT`: optional, defaults to `8000`.
- `POSTGRES_DB`: optional base database name; workflows also provide branch defaults.
- `POSTGRES_USER`: optional database user; defaults to `bookshop`.

## GitHub Secrets

Configure these under Settings -> Secrets and variables -> Actions -> Secrets:

- `EC2_SSH_KEY`: private SSH key for the EC2 instance.
- `DOCKERHUB_USERNAME`: Docker Hub username.
- `DOCKERHUB_TOKEN`: Docker Hub access token.
- `SECRET_KEY`: Django secret key.
- `POSTGRES_PASSWORD`: PostgreSQL password.

Do not commit `.env`, database files, SSH keys, Docker Hub tokens, or production passwords.
