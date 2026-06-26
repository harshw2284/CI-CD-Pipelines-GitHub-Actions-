# CI/CD – Day 09 -  Advanced Triggers: PR Events, Cron Schedules & Event-Driven Pipelines

I've used push and basic pull_request triggers. But GitHub Actions supports dozens of event types — today I will go deep into PR lifecycle events, scheduled cron jobs, and chaining workflows together.

---

### ✅ Task 1 : Prepare

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

### ✅ Task 3 : Scheduled Workflows (Cron Deep Dive)

**Create `.github/workflows/scheduled-tasks.yml:`**

**1. Add a schedule trigger with cron: '30 2 * * 1' (every Monday at 2:30 AM UTC)**

**2. Add another cron entry: '0 */6 * * *' (every 6 hours)**

```yml
name: Schedule Workflow

on:
    workflow_dispatch:
        
    schedule:
        - cron: '30 2 * * 1'
        - cron: '0 */6 * * *'
```

**3. In the job, print which schedule triggered using ${{ github.event.schedule }}**

```yml
name: Schedule Workflow

on:
    workflow_dispatch:
        
    schedule:
        - cron: '30 2 * * 1'
        - cron: '0 */6 * * *'
jobs:
    trigger:
        runs-on: ubuntu-latest
        steps:
            - name: Schedule Triggered
              run: echo "schedule triggered is ${{ github.event.schedule }}"
```

**4. Add a step that acts as a health check — curl a URL and check the response code**

```yml
name: Schedule Workflow

on:
    workflow_dispatch:
        
    schedule:
        - cron: '30 2 * * 1'
        - cron: '0 */6 * * *'
jobs:
    trigger:
        runs-on: ubuntu-latest
        steps:
            - name: Schedule Triggered
              run: echo "schedule triggered is ${{ github.event.schedule }}"

            - name: Run Health Check
              run: |
                TARGET_URL="https://example.com" 

                STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET_URL")

                echo "Response HTTP Status Code is $STATUS"

                if [ "$STATUS" -ne 200 ]; then
                  echo "Error ! Health check failed with status code $STATUS"
                  exit 1
                fi
                echo "Health check passed successfully!"
```

**Q&A :**

**1. The cron expression for: every weekday at 9 AM IST**

0 9 * * 1-5

**2. The cron expression for: first day of every month at midnight**

0 0 1 * *

**3. Why GitHub says scheduled workflows may be delayed or skipped on inactive repos**

GitHub explicitly states that scheduled workflows (on: schedule) may be delayed or skipped on inactive repositories as part of an automated resource management policy designed to optimize compute capacity and prevent server strain.

Core Reasons:

* Resource Optimization: Millions of repositories run scheduled cron jobs every day. If a repository has been completely abandoned but its cron job continues to execute daily or hourly, it consumes massive amounts of cloud compute resources for no active user benefit.

* Abuse and Cost Prevention: This policy cuts down on automated "ghost" runs on public and free-tier repositories, ensuring GitHub's infrastructure remains available for active development projects.

---

### ✅ Task 4 : Path & Branch Filters

**Create `.github/workflows/smart-triggers.yml:`**

**1. Trigger on push but only when files in `src/` or `app/` change:**

```yml
name: Path

on:
    push:
      paths:
        - 'src/**'
        - 'app/**'

jobs:
    build:
        runs-on: ubuntu-latest
        steps:
            - name: Print
              run: echo "Running"
```

**2. Add `paths-ignore` in a second workflow that skips runs when only docs change:**

```yml
name: Path Ignore

on:
    push:
        paths-ignore:
          - '*.md'
          - 'docs/**'
jobs:
    build:
        runs-on: ubuntu-latest
        steps:
          - name: Print
            run: echo "ignore path"
```

**3. Add branch filters to only trigger on `main` and `release/*` branches**

```yml
name: Path Ignore

on:
    push:
        paths-ignore:
          - '*.md'
          - 'docs/**'

        branches:
            - main
            - release/*

jobs:
    build:
        runs-on: ubuntu-latest
        steps:
          - name: Print
            run: echo "ignore path"
```

**4. Test it: push a change to a `.md` file — does the workflow skip ?**

YES !

**When would you use paths vs paths-ignore ?**

In GitHub Actions, you use paths when you want a workflow to run only when specific files change, and paths-ignore when you want it to run for all changes except when specific files are modified.You cannot use both paths and paths-ignore for the same event in a single workflow. 

Choosing between them depends entirely on whether your filtering logic focuses on inclusion or exclusion.

---

### ✅ Task 5 : workflow_run — Chain Workflows Together

**Create two workflows:**

**1. `.github/workflows/tests.yml` — runs tests on every push**

```yml
name: Run Tests

on:
    push:
        branches: [main]

jobs:
    test:
        runs-on: ubuntu-latest
        steps:
            - name: Run Tests
              run: |
                echo "Running the Test ..."
                echo "Test Succesfull"
```


**2. `.github/workflows/deploy-after-tests.yml` — triggers only after tests.yml completes successfully:**

```yml
name: Deploy after test

on:
    workflow_run:
        workflows: ["Run Tests"]
        types: [completed]
```

**3. In the deploy workflow, add a conditional:**

* Only proceed if the triggering workflow succeeded (`${{ github.event.workflow_run.conclusion == 'success' }}`)
* Print a warning and exit if it failed

```yml
name: Deploy after test

on:
    workflow_run:
        workflows: ["Run Tests"]
        types: [completed]


jobs:
    deploy:
        if: ${{ github.event.workflow_run.conclusion == 'success' }}
        runs-on: ubuntu-latest
        steps: 
            - name: Deploy Application
              run: |
                echo "Test Passed"
                echo "Application Deployed"

    deploy-failed:
        if: ${{ github.event.workflow_run.conclusion != 'success' }}
        runs-on: ubuntu-latest
        steps: 
            - name: Deploy Application
              run: |
                echo "Test Failed"
                echo "Deployment cancelled"
```

**

**Verify:** Push a commit — does the test workflow run first, then trigger the deploy workflow ?

YES !

---

### ✅ Task 6 : repository_dispatch — External Event Triggers

**1. Create `.github/workflows/external-trigger.yml` with trigger `repository_dispatch`**

**2. Set it to respond to event type: `deploy-request`**

```yml
name:  External Event Triggers

on:
    repository_dispatch:
        types:
            - deploy-request
```

**3. Print the client payload: `${{ github.event.client_payload.environment }}`**

```yml
name:  External Event Triggers

on:
    repository_dispatch:
        types:
            - deploy-request

jobs:
    deploy:

      runs-on: ubuntu-latest
      steps:
        - name: Print Client payload
          run: |
            echo "Client payload is ${{ github.event.client_payload.environment }}"
```

**4. Trigger it using `curl` or `gh`:**

**Using `gh` :**

```bash
gh api repos/<owner>/<repo>/dispatches \
  -f event_type=deploy-request \
  -f client_payload='{"environment":"production"}'
```

**Using `curl` :**

Create a Personal Access Token (PAT) with the repo scope (or Contents: Read & Write and Metadata: Read for fine-grained tokens).

```bash
curl -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer <YOUR_GITHUB_TOKEN>" \
  https://api.github.com/repos/<owner>/<repo>/dispatches \
  -d '{
    "event_type":"deploy-request",
    "client_payload":{
      "environment":"production"
    }
  }'
```

**When would an external system (like a Slack bot or monitoring tool) trigger a pipeline ?**

An external system (such as a Slack bot, monitoring tool, or deployment platform) triggers a pipeline when an external event occurs, like an alert, approval, deployment request, or system failure, using APIs or webhooks (e.g., GitHub repository_dispatch).

Examples:

* Slack bot triggers deployment after approval.
* Monitoring tool triggers rollback after detecting a failure.
* CI/CD tool starts deployment from another system.

---
