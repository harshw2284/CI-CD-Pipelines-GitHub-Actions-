# CI/CD – Day 06 - Secrets, Artifacts & Running Real Tests in CI

Today our pipeline starts doing real work — storing sensitive values securely, saving build outputs, and running actual tests from your previous days.

### ✅ Task 1: GitHub Secrets

**1. Go to your repo → Settings → Secrets and Variables → Actions**

**2. Create a secret called `MY_SECRET_MESSAGE`**

**3. Create a workflow that reads it and prints: `The secret is set: true` (never print the actual value)**

**4. Try to print `${{ secrets.MY_SECRET_MESSAGE }}` directly — what does GitHub show?**

```yml
name: Secrets

on: 
    workflow_dispatch:



jobs:
    check-secret:
        runs-on: ubuntu-latest
        steps:
            - name: Check Secret
              run: |
                if [ -n "${{ secrets.MY_SECRET_MESSAGE }}" ]; then
                  echo "The secret is set: true"
                else
                  echo "The secret is set: false"
                fi

    print-secret:
        runs-on: ubuntu-latest
        steps:
            - name: Print Secret
              run: echo "Secret is ${{secrets.MY_SECRET_MESSAGE}}"
```

**Why should you never print secrets in CI logs ?**

Printing secrets in CI logs—even accidentally during debugging—is dangerous because it exposes plaintext credentials to anyone with access to the pipeline. This leads to compromised cloud environments, unauthorized access to downstream services, and violation of data security compliance standards.

---

### ✅ Task 2 : Use Secrets as Environment Variables

**1. Pass a secret to a step as an environment variable**

**2. Use it in a shell command without ever hardcoding it**

```yml
name: Secrets

on: 
    workflow_dispatch:



jobs:
    check-secret:
        runs-on: ubuntu-latest
        steps:
            - name: Check Secret
              run: |
                if [ -n "${{ secrets.MY_SECRET_MESSAGE }}" ]; then
                  echo "The secret is set: true"
                else
                  echo "The secret is set: false"
                fi

    print-secret:
        runs-on: ubuntu-latest
        steps:
            - name: Print Secret
              env:
                msg: ${{secrets.MY_SECRET_MESSAGE}}
              run: echo "Secret is $msg"
```

---

### ✅ Task 3 : Upload Artifacts

**1. Create a step that generates a file — e.g., a test report or a log file**

```yml
name: Artifact

on:
  workflow_dispatch:

jobs:
    create-artifact:
        runs-on: ubuntu-latest
        steps:
            - name: Creating an File
              run: | 
                touch file.txt
                echo "Hello from artifacts" > file.txt
```

**2. Use `actions/upload-artifact` to save it**

```yml
name: Artifact

on:
  workflow_dispatch:

jobs:
    create-artifact:
        runs-on: ubuntu-latest
        steps:
            - name: Creating an File
              run: | 
                touch file.txt
                echo "Jai Hind Dosto" > file.txt

            - name: upload Artifact
              uses: actions/upload-artifact@v7
              with:
                name: my-artifact
                path: file.txt
```

**3. After the workflow runs, download the artifact from the Actions tab**
<img width="906" height="483" alt="Screenshot 2026-06-23 153355" src="https://github.com/user-attachments/assets/6886ff71-69bf-4396-ac2d-6736f2d22bff" />

---

### ✅ Task 4 : Download Artifacts Between Jobs

**In a workflow, add:**

* Job 1: generate a file and upload it as an artifact
* Job 2: download the artifact from Job 1 and use it (print its contents)

```yml
name: Artifact

on:
  workflow_dispatch:

jobs:
    create-artifact:
        runs-on: ubuntu-latest
        steps:
            - name: Creating an File
              run: | 
                touch file.txt
                echo "Jai Hind Dosto" > file.txt

            - name: upload Artifact
              uses: actions/upload-artifact@v7
              with:
                name: my-artifact
                path: file.txt

    download-artifact:
        needs: create-artifact
        runs-on: ubuntu-latest
        steps:
            - name: Download Artifact
              uses: actions/download-artifact@v8
              with:
                name: my-artifact

            - name: Print Artifact
              run: cat file.txt
```

**When would you use artifacts in a real pipeline ?**

In a real CI/CD pipeline, you use artifacts to store the tangible, immutable outputs of a build process so they can be securely passed between pipeline stages or deployed across environments.

---

### ✅ Task 5 : Run Real Tests in CI

**Take any script from your earlier days (Python or Shell) and run it in CI:**

**Add your script to the github-actions repo**
* Write a workflow that:
* Checks out the code
* Installs any dependencies needed
* Runs the script
* Fails the pipeline if the script exits with a non-zero code

```yml
name: Shell

on: 
    workflow_dispatch:

jobs:
    check:
        runs-on: ubuntu-latest
        steps:
            - name: Code Checkout
              uses: actions/checkout@v4

            - name: Install ShellCheck
              run: sudo apt-get update && sudo apt-get install -y shellcheck

            - name: Run Shellcheck
              uses: ludeeus/action-shellcheck@master

            - name: check script
              run: shellcheck log.sh
```

---

### ✅ Task 6 : Caching

**Add `actions/cache` to a workflow that installs dependencies**

**Run it twice — observe the time difference**

```yml
name: Python Cache Demo

on:
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Cache pip dependencies
        uses: actions/cache@v4
        with:
          path: ~/.cache/pip
          key: pip-${{ runner.os }}-${{ hashFiles('requirements.txt') }}
          restore-keys: |
            pip-${{ runner.os }}-

      - name: Install dependencies
        run: pip install -r requirements.txt
```


**What is being cached and where is it stored ?**

When you use actions/cache, GitHub saves files that are expensive or time-consuming to download again, such as project dependencies, package manager caches, or build caches. For example, in a Python project, the cache might contain downloaded pip packages; in a Node.js project, it might contain npm packages. After the workflow finishes, GitHub compresses these files and stores them in GitHub's own cache storage associated with your repository and cache key. The cache is not stored on the runner machine permanently, because runners are temporary and are deleted after the job ends. In future workflow runs, GitHub checks whether a matching cache exists. If it does, GitHub downloads and restores the cached files to the specified location before the installation step runs. This makes the workflow faster because it can reuse previously downloaded files instead of fetching them again from the internet.

---
