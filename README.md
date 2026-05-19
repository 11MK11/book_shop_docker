# book_shop — Phase 2: CI/CD Pipelines

**Team:** Malek Al-Qurany (20210083) · Hashem Al-Kilani (20210047)
**Group size:** 2 → Registry: Docker Hub

---

## Branch Strategy

| Branch | Philosophy | What ships |
|--------|-----------|-----------|
| `dev` | Artifact-first | Image built from a committed `.tar.gz` artifact |
| `test` | Image-first | Fresh image rebuilt from source, pushed to Docker Hub |
| `prod` | Promotion-only | Pulls the exact version in `vars.IMAGE_VERSION` — never builds |

---

## How Each Pipeline Works

### `dev` — Artifact-First
1. Installs dependencies and freezes them into `requirements.frozen.txt`.
2. Packages the entire source tree into `artifacts/app-<sha>.tar.gz`.
3. Commits the artifact back to the `dev` branch — every build keeps its own file (audit trail).
4. Builds the Docker image using `--build-arg ARTIFACT_NAME=...`. The Dockerfile copies and extracts the artifact; it does **not** run `pip install` from source.
5. SSHs into EC2 and runs `docker compose -p dev` on port **8001**.

### `test` — Image-First
1. Rebuilds entirely from source — the `artifacts/` folder committed by `dev` is intentionally ignored.
2. Freezes dependencies and packages a fresh artifact inside the runner.
3. Builds the Docker image from that fresh artifact and pushes it to Docker Hub tagged with the commit SHA.
4. SSHs into EC2, pulls the new image, and runs `docker compose -p test` on port **8002**.

### `prod` — Promotion-Only
1. Reads `IMAGE_VERSION` from the GitHub Actions repo variable (Settings → Secrets and variables → Actions → Variables).
2. SSHs into EC2, pulls `dockerhub_user/image_name:<IMAGE_VERSION>`, and runs `docker compose -p prod` on port **8000**.
3. Contains zero `docker build` / `docker buildx` commands — it only promotes what `test` already verified.

To promote a new version to prod: update `IMAGE_VERSION` in repo variables to a SHA that was pushed by the `test` pipeline, then push to `prod`.

---

## How Three Deployments Coexist on One EC2

All three stacks run on the same EC2 instance without colliding because of three isolation layers:

1. **Compose project name** (`-p dev` / `-p test` / `-p prod`) — gives every stack its own network and container name namespace.
2. **Separate host ports** — `dev` on **8001**, `test` on **8002**, `prod` on **8000**.
3. **Separate `.env` files** (`.env.dev`, `.env.test`, `.env.prod`) and separate Postgres databases (`bookshop_dev`, `bookshop_test`, `bookshop_prod`) — each stack has its own data volume.

---

## Secrets & Variables Reference

| Type | Name | Purpose |
|------|------|---------|
| Variable | `IMAGE_VERSION` | Tag of the image to deploy to prod |
| Variable | `EC2_HOST` | Public DNS / IP of the EC2 instance |
| Variable | `IMAGE_NAME` | Docker Hub repository name (e.g. `book_shop`) |
| Secret | `EC2_SSH_KEY` | Private key for SSH access to EC2 |
| Secret | `DOCKERHUB_USERNAME` | Docker Hub username |
| Secret | `DOCKERHUB_TOKEN` | Docker Hub access token |
| Secret | `POSTGRES_PASSWORD` | Database password |
| Secret | `SECRET_KEY` | Django secret key |

---

## Local Development

```bash
cp .env.example .env
# fill in values
docker compose up --build
# app available at http://localhost:8000
```
