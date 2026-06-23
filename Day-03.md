# CI/CD – Day 03 - Triggers & Matrix Builds

Today I will learn every way to trigger a workflow and how to run jobs across multiple environments at once.

### ✅ Task 1: Trigger on Pull Request

**1. First I Created a workflow `.github/workflows/pr-check.yml`**

**2. Trigger it only when a pull request is opened or updated against `main`**

```yml
name: PR check

on:
    pull_request:
        branches: [main]
        types: [ opened, synchronize ]
```

**3. Add a step that prints: `PR check running for branch: <branch name>`**

```yml
jobs:
    pr-check:
        runs-on: ubuntu-latest 

        steps:
            - name: Print PR Branch
              run: echo "PR check running for branch:${{ github.head_ref }}"

```
**4. Created a new branch, pushed a commit, and open a PR**

workflow runs automatically

**Verify: Does it show up on the PR page?**

Yes!

---

### ✅ Task 2 : Scheduled Trigger

**Add a `schedule:` trigger to any workflow using cron syntax**

```yml
name: hello

on:
  schedule:
    - cron: '*/5 * * * *'  #runs every 5 minutes

jobs:
  greet:
    runs-on: ubuntu-latest
    steps:
      - name: say hello to users
        run: echo "Hello Everyone"
```

---

### ✅ Task 3 : Manual Trigger

**1. Create `.github/workflows/manual.yml` with a `workflow_dispatch:` trigger**

```yml
name: Code check

on: 
    workflow_dispatch:
```

**2. Add an input that asks for an `environment` name (staging/production)**

```yml
name: Code check

on: 
    workflow_dispatch:
        inputs:
            environment:
                description: Choose the env value
                default: dev
                required: true
                type: choice
                options:
                    - prod
                    - dev
                    - staging
```

**3. Print the input value in a step**

```yml
name: Code check

on: 
    workflow_dispatch:
        inputs:
            environment:
                description: Choose the env value
                default: dev
                required: true
                type: choice
                options:
                    - prod
                    - dev
                    - staging

                
jobs:
    Check:
        runs-on: ubuntu-latest
        steps:
        - name: Code check
          run: echo "checking the code"
```

**4. Go to the Actions tab → find the workflow → click Run workflow**

**Verify: Can you trigger it manually and see your input printed?**

Yes!

---

### ✅ Task 4 : Matrix Builds

**1. Create `.github/workflows/matrix.yml` that:**

* Uses a matrix strategy to run the same job across:
* Python versions: 3.10, 3.11, 3.12
* Each job installs Python and prints the version
* Watch all 3 run in parallel

```yml

name: matrix build

on: 
    workflow_dispatch:

jobs:
    build:
        runs-on: ubuntu-latest
        strategy: 
            matrix:
                python-version: ["3.10","3.11","3.12"]

        steps:
            - name: Code Checkout
              uses: actions/checkout@v4

            - name: setup python
              uses: actions/setup-python@v5
              with:
                python-version: ${{ matrix.python-version }}
            
            - name: Print Python version
              run: echo "python --version"

```

**2. Extend the matrix to also include 2 operating systems — how many total jobs run now ?**

```yml
name: matrix build

on: 
    workflow_dispatch:

jobs:
    build:
        runs-on: ubuntu-latest
        strategy: 
            matrix:
                python-version: ["3.10","3.11","3.12"]
                os: [ windows-latest , macos-latest ]

        steps:
            - name: Code Checkout
              uses: actions/checkout@v4

            - name: setup python
              uses: actions/setup-python@v5
              with:
                python-version: ${{ matrix.python-version }}
            
            - name: Print Python version
              run: echo "python --version"
```

**Total Jobs Running: 2 Operating Systems × 3 Python Versions = 6 Jobs**

---

### ✅ Task 5 : Exclude & Fail-Fast

**1. In your matrix, exclude one specific combination (e.g., Python 3.10 on Windows)**

```yml
name: matrix build

on: 
    workflow_dispatch:

jobs:
    build:
        runs-on: ubuntu-latest

        strategy: 
            matrix:
                os: [ windows-latest , macos-latest ]
                python-version: ["3.10","3.11","3.12"]
                exclude:
                    - os: windows-latest 
                      python-version: "3.10" 
```

**2. Set `fail-fast: false` — trigger a failure in one job and observe what happens to the rest**

```yml
name: matrix build

on: 
    workflow_dispatch:

jobs:
    build:
        runs-on: ubuntu-latest
        strategy: 
            
            fail-fast: false
            matrix:
                os: [ windows-latest , macos-latest ]
                python-version: ["3.10","3.11","3.12"]
                exclude:
                    - os: windows-latest 
                      python-version: "3.10" 

        steps:
            - name: Code Checkout
              uses: actions/checkout@v4

            - name: setup python
              uses: actions/setup-python@v5
              with:
                python-version: ${{ matrix.python-version }}
            
            - name: Print Python version
              run: echo "python --version"

            - name: Simulate Failure
              if: ${{ matrix.python-version == '3.11'}}
              run: exit 1
```
**What does fail-fast: true (the default) do vs false ?**

`fail-fast: true` (default)	= Stop the matrix early when a job fails; cancel remaining jobs.

`fail-fast: false` = Let all matrix jobs run to completion even if some fail.

---
