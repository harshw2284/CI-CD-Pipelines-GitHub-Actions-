# CI/CD – Day 07 - Docker Build & Push in GitHub Actions

Today build a complete CI/CD pipeline — code pushed to GitHub automatically builds a Docker image and ships it to Docker Hub. No manual steps

This is exactly what happens in real production pipelines.

---

### ✅ Task 1: Prepare

**1. Use the app you Dockerized on Docker**

**2. Add the Dockerfile to your `github-actions-practice` repo (or create a minimal one)**

**3. Make sure `DOCKER_USERNAME` and `DOCKER_TOKEN` secrets are set**

---

### ✅ Task 2 : Build the Docker Image in CI

**Create `.github/workflows/docker-publish.yml` that:**

* Triggers on push to `main`
* Checks out the code
* Builds the Docker image and tags it

```yml
name : Docker Publish

on:
    push:
      branches: [main]

jobs:
    build:
        runs-on: ubuntu-latest
        steps:
            - name: Checkout Code
              uses: actions/checkout@v4

            - name: Login to Docker Hub
              uses: docker/login-action@v3
              with:
                username: ${{ vars.DOCKERHUB_USERNAME }}
                password: ${{ secrets.DOCKERHUB_TOKEN }}

            - name: Build and Push to Docker Hub
              uses: docker/build-push-action@v6
              with:
                context: .
                push: true
                tags: |
                  ${{vars.DOCKERHUB_USERNAME}}/github-actions-app:latest
                  ${{vars.DOCKERHUB_USERNAME}}/github-actions-app:${{github.sha}}
```

---

### ✅ Task 3 : Push to Docker Hub

**Add steps to:**

* Log in to Docker Hub using your secrets
* Tag the image as `username/repo:latest` and also `username/repo:sha-<short-commit-hash>`
* Push both tags

**Check Docker Hub for Pushed Image to Verify**

---

### ✅ Task 4 : Only Push on Main

**Add a condition so the push step only runs on the `main` branch — not on feature branches or PRs.:**

```yml
name : Docker Publish

on:
    push:
      branches: [main]

jobs:
    build:
        runs-on: ubuntu-latest
        steps:
            - name: Checkout Code
              uses: actions/checkout@v4

            - name: Login to Docker Hub
              uses: docker/login-action@v3
              with:
                username: ${{ vars.DOCKERHUB_USERNAME }}
                password: ${{ secrets.DOCKERHUB_TOKEN }}

            - name: Build and Push to Docker Hub
              if: github.ref == 'refs/heads/main' && github.event_name == 'push'
              uses: docker/build-push-action@v6
              with:
                context: .
                push: true
                tags: |
                  
                  ${{vars.DOCKERHUB_USERNAME}}/github-actions-app:latest
                  ${{vars.DOCKERHUB_USERNAME}}/github-actions-app:${{github.sha}}
```

**Test it**: push to a feature branch and verify the image is built but NOT pushed.

---

### ✅ Task 5 : Add a Status Badge

**Get the badge URL for your docker-publish workflow from the Actions tab**

**Badge:**

[![Docker Publish](https://github.com/harshw2284/CI-CD-Pipelines-GitHub-Actions/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/harshw2284/CI-CD-Pipelines-GitHub-Actions/actions/workflows/docker-publish.yml)

---

### ✅ Task 6 : Pull and Run It

**On your local machine (or a cloud server), pull the image you just pushed**

```bash
docker pull harsh9301/github-actions-app:latest
```

**Run it and Confirm it works**

**What is the full journey from git push to a running container ?**

In a modern CI/CD pipeline, the process starts when a developer pushes code to a GitHub repository and ends when the updated application is running inside a Docker container. The entire workflow is automated using GitHub Actions and Docker.

<img width="1264" height="843" alt="Gemini_Generated_Image_bbrryabbrryabbrr" src="https://github.com/user-attachments/assets/70f7eea1-64e1-4a0c-b6e3-11e815c915fb" />

---
