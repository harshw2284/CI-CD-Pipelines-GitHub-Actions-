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

---

### ✅ Task 5 : Putting It Together

**Create `.github/workflows/smart-pipeline.yml` that:**

* Triggers on push to any branch
* Has a lint job and a test job running in parallel
* Has a summary job that runs after both, prints whether it's a main branch push or a feature branch push, and prints the commit message


```yml
name: Smart Pipeline

on:
    push:
        branches: '**'

jobs:
    lint:
        runs-on: ubuntu-latest
        steps:
            - name: Code Lint
              run: echo "Linting the code .."

    test:
        runs-on: ubuntu-latest
        steps: 
            - name: Test Code 
              run: echo "Testing the code .."

    summary:
        runs-on: ubuntu-latest
        needs: [lint,test]
        steps:
            - name: Branch Type
              run: |
                if [ "${{ github.ref_name }}" = "main" ]; then
                  echo "This is Main Branch"
                else
                    echo "Feature branch push detected"
                fi
            
            - name: Print Commit Message
              run: echo "Commit message is ${{ github.event.head_commit.message }}"
```

---
