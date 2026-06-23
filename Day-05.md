# Docker – Day 05 -  Jobs, Steps, Env Vars & Conditionals

Today I learnd how to control the flow of your pipeline — multi-job workflows, passing data between jobs, environment variables, and running steps only when certain conditions are met.

### ✅ Task 1: Multi-Job Workflow

 **1. Create `.github/workflows/multi-job.yml` with 3 jobs:**

* `build` — prints "Building the app"
* `test` — prints "Running tests"
* `deploy` — prints "Deploying"

```yml
name: Multi-Job Workflow

on:
    workflow_dispatch:

jobs:
    build:
        runs-on: ubuntu-latest
        steps:

        - name: Build Code
          run: echo "Building the Code"
    
    test:
        runs-on: ubuntu-latest
        steps:

        - name: Test Code
          run: echo "Testing the Code"
    
    deploy:
        runs-on: ubuntu-latest
        steps:

        - name: Deploy Code
          run: echo "Deploying the Code"
```

**2. Make test run only after build succeeds. Make deploy run only after test succeeds.**

```yml
name: Multi-Job Workflow

on:
    workflow_dispatch:

jobs:
    build:
        runs-on: ubuntu-latest
        steps:

        - name: Build Code
          run: echo "Building the Code"
    
    test:
        runs-on: ubuntu-latest
        needs: [build]
        steps:

        - name: Test Code
          run: echo "Testing the Code"
    
    deploy:
        runs-on: ubuntu-latest
        needs: [test]
        steps:

        - name: Deploy Code
          run: echo "Deploying the Code"
```

**It Shows a Dependency Chain:**

<img width="1459" height="316" alt="Screenshot 2026-06-23 130441" src="https://github.com/user-attachments/assets/7ae4f4b2-19e1-46d1-8d8d-6a76da2a5d62" />


---

### ✅ Task 2 : Environment Variables

**1. In a new workflow, use environment variables at 3 levels:**

* Workflow level — `APP_NAME: myapp`
* Job level — `ENVIRONMENT: staging`
* Step level — `VERSION: 1.0.0`

**2. Print all three in a single step and verify each is accessible.**

```yml
name: Environment Variables

on:
  workflow_dispatch:

env:
    APP_NAME: myapp

jobs:
    Environment:     
        runs-on: ubuntu-latest
        env:
          ENVIRONMENT: staging
        steps:
            - name: Print Variables         
              env:
                VERSION: 1.0.0
              
              run: |
               echo "APP_NAME: $APP_NAME"
               echo "ENVIRONMENT: $ENVIRONMENT"
               echo "VERSION: $VERSION"

```

**3. Then use a GitHub context variable — print the commit SHA and the actor (who triggered the run).**

```yml
name: Environment Variables

on:
  workflow_dispatch:

env:
    APP_NAME: myapp

jobs:
    Environment:     
        runs-on: ubuntu-latest
        env:
          ENVIRONMENT: staging
        steps:
            - name: Print Variables         
              env:
                VERSION: 1.0.0
              
              run: |
               echo "APP_NAME: $APP_NAME"
               echo "ENVIRONMENT: $ENVIRONMENT"
               echo "VERSION: $VERSION"

               echo "COMMIT SHA: ${{ github.sha }}"
               echo "ACTOR: ${{ github.actor }}"
```

---

### ✅ Task 3 : Job Outputs

**1. Create a job that sets an output — e.g., today's date as a string**

```yml
name: Job Output

on: workflow_dispatch

jobs:
    Generate-date:

        outputs: 
            today: ${{ steps.date.outputs.today }}

        runs-on: ubuntu-latest
        steps:
            - name: Get Date
              id: date
              run:
                echo "today=$(date +%Y-%m-%d)" >> $GITHUB_OUTPUT
```

**2. Create a second job that reads that output and prints it**

**3. Pass the value using `outputs:` and `needs.<job>.outputs.<name>`**

```yml
name: Job Output

on: workflow_dispatch

jobs:
    Generate-date:

        outputs: 
            today: ${{ steps.date.outputs.today }}

        runs-on: ubuntu-latest
        steps:
            - name: Get Date
              id: date
              run:
                echo "today=$(date +%Y-%m-%d)" >> $GITHUB_OUTPUT

    Print-date:
        runs-on: ubuntu-latest
        needs: [Generate-date]

        steps:
            - name: Print Date
              run: echo "Date Received:${{ needs.Generate-date.outputs.today }}"
```

**Why would you pass outputs between jobs ?**

You pass outputs between jobs in GitHub Actions because each job runs on an isolated, completely fresh runner machine. Since jobs do not share local file systems or environment variables, defining and sharing explicit job outputs is the primary mechanism to drive conditional execution, determine downstream parameters, and orchestrate complex deployment pipelines.

---

### ✅ Task 4 : Conditionals

**In a workflow, add:**

* A step that only runs when the branch is main
* A step that only runs when the previous step failed
* A job that only runs on push events, not on pull requests
* A step with continue-on-error: true — what does this do?


```yml
name: Conditionals

on:
    push:

jobs:
    push-job:
        if: github.event == 'push'
        runs-on: ubuntu-latest

        steps:
            - name: Run on main branch
              if: github.ref == 'refs/heads/main'
              run: echo "This step runs only on main"

            - name: Intentionally fail
              run: exit 1  

            - name: Run on Failure
              if: failure()
              run: echo "Previous step failed!"
              

    continue-on-error:
        runs-on: ubuntu-latest

        steps:
            - name: Fail but continue
              continue-on-error: true
              run: exit 1

            - name: Still runs
              run: echo "Workflow continued despite the failure"

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
