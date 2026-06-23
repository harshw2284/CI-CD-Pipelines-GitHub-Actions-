# CI/CD – Day 02 -  My First GitHub Actions Workflow

Today you write your first GitHub Actions pipeline and watch it run in the cloud.

This is the moment CI/CD stops being a concept and becomes real.

### ✅ Task 1: Set Up

**1. First I Created a new public GitHub repository called `github-actions`**

**2. Clone it locally**

**3. Create the folder structure: `.github/workflows/`**

---

### ✅ Task 2 : Hello Workflow

**Create `.github/workflows/hello.yml` with a workflow that:**

* Triggers on every push
* Has one job called `greet`
* Runs on `ubuntu-latest`
Has two steps:
* Step 1: Check out the code using actions/checkout
* Step 2: Print Hello from GitHub Actions!**

```yml
name: hello

on: 
    push:
        branches: [main]

jobs:
    greet:
        runs-on: ubuntu-latest
        steps:
            - name: checkout code
              uses: actions/checkout@v4

            - name: say hello
              run: echo "hello from GitHub Actions"
```

**Then I pushed it and verify my Workflow in Actions Tab**

**Verify: Green Dot**

---

### ✅ Task 3 : Understand the Anatomy

**`on`**: Defines the event that triggers the workflow, such as a push, pull request, or schedule.

**`jobs`**: Contains all the jobs that the workflow will execute.

**`runs-on`**: Specifies the operating system or runner (virtual machine) where the job will run (for example, Ubuntu).

**`steps`**: Lists the individual actions or commands inside a job.

**`uses`**: Runs a pre-built action created by GitHub or the community.

**`run`**: Executes a shell command or script directly in the workflow.

**`name`**: Gives a step a readable name so it is easier to identify in the workflow logs.

---

### ✅ Task 4 : Add More Steps

**Update `hello.yml` to also:**

* Print the current date and time
* Print the name of the branch that triggered the run (hint: GitHub provides this as a variable)
* List the files in the repo
* Print the runner's operating system

```yml

print:                                     #Job name
                                           #Runner
        runs-on: ubuntu-latest
        steps:
            - name: Print the current date and time
              run: date
            
            - name: Print the name of the branch that triggered the run
              run: echo "This run was triggered by a push to the ${{ github.ref_name }} branch."

            - name: List the files in the repo
              run: ls

            - name: Print the runner's operating system 
              run: echo "Running on ${{ runner.os }}"

```

---

### ✅ Task 5 : Break It On Purpose

I added a step that runs a command that will fail (misspelled command)

I Pushed it and observed what happened in Actions tab

Then I Fixed it and Push again

A failed pipeline usually shows a red X, failed status, or error message in the CI/CD tool. The pipeline stops at the stage or step where the problem occurred, such as testing, building, or deployment.

---
