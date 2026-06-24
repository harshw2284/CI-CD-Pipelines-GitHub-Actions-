# CI/CD – Day 08 - Reusable Workflows & Composite Actions

I've been writing workflows from scratch every time. In the real world, teams don't repeat themselves — they create reusable workflows that any repo can call like a function. Today I will learn `workflow_call` and composite actions.

---

### ✅ Task 1 : Understand workflow_call

What is a reusable workflow?
What is the workflow_call trigger?
How is calling a reusable workflow different from using a regular action (uses:)?
Where must a reusable workflow file live?

---

### ✅ Task 2 : Build the Docker Image in CI

**Create `.github/workflows/reusable-build.yml:`**

**1. Set the trigger to `workflow_call`**

**2. Add an inputs: section with:**

* app_name (string, required)
* environment (string, required, default: staging)

```yml
name: Reusable Workflow

on:
    workflow_call:

        inputs:
            app_name: 
              description: Demo App
              required: true
              type: string

            environment:
                description: Deployment environment
                required: true
                default: staging
                type: string
```


**3. Add a secrets: section with:**

* docker_token (required)

```yml
name: Reusable Workflow

on:
    workflow_call:

        inputs:
            app_name: 
              description: Demo App
              required: true
              type: string

            environment:
                description: Deployment environment
                required: true
                default: staging
                type: string
      
        secrets:
            docker_token:
              required: true
```

**4. Create a job that:**
* Checks out the code
* Prints Building <app_name> for <environment>
* Prints Docker token is set: true (never print the actual secret)

```yml
name: Reusable Workflow

on:
    workflow_call:

        inputs:
            app_name: 
              description: Demo App
              required: true
              type: string

            environment:
                description: Deployment environment
                required: true
                default: staging
                type: string
      
        secrets:
            docker_token:
              required: true

jobs:
    task:
        
        runs-on: ubuntu-latest
        steps:
            - name: Checkout Code
              uses: actions/checkout@v4

            - name: Print
              run: echo "Building ${{inputs.app_name}} for ${{inputs.environment}}"

            - name: Print 2
              run: |
                echo "Docker Token is set :  ${{ secrets.docker_token != '' }}"  
```

**This file alone won't run — it needs a caller. That's next**

**NOTE:**

A reusable workflow can be called by at most 20 unique caller workflows in a single run

---

### ✅ Task 3 : Create a Caller Workflow

**Create `.github/workflows/call-build.yml`:**

**1. Trigger on push to main**

**2. Add a job that uses your reusable workflow**

```yml
name: Caller Workflow

on: 
    push:
        branches: [main]
    #workflow_dispatch:

jobs:
  build:
    uses: ./.github/workflows/reusable-build.yml
    with:
      app_name: "my-web-app"
      environment: "production"
    secrets:
      docker_token: ${{ secrets.DOCKERHUB_TOKEN }}
```

**3. Push to `main` and watch it run**

---

### ✅ Task 4 : Outputs to the Reusable Workflow

**Extend `reusable-build.yml`**

**1. Add an `outputs:` section that exposes a `build_version` value**

```yml
name: Reusable Workflow

on:
    workflow_call:

        inputs:
            app_name: 
              description: Demo App
              required: true
              type: string

            environment:
                description: Deployment environment
                required: true
                default: staging
                type: string
      
        secrets:
            docker_token:
              required: true

        outputs:
            build_version: 
                description: Generated build version
                value: ${{ jobs.task.outputs.build_version }}

jobs:
    task:

        outputs:
          build_version: ${{ steps.version.outputs.build_version }}
        
        runs-on: ubuntu-latest
        steps:
            - name: Checkout Code
              uses: actions/checkout@v4

            - name: Print
              run: echo "Building ${{inputs.app_name}} for ${{inputs.environment}}"

            - name: Print 2
              run: |
                echo "Docker Token is set :  ${{ secrets.docker_token != '' }}"  
```

**2. Inside the job, generate a version string (e.g., v1.0-<short-sha>) and set it as output**

```yml
name: Reusable Workflow

on:
    workflow_call:

        inputs:
            app_name: 
              description: Demo App
              required: true
              type: string

            environment:
                description: Deployment environment
                required: true
                default: staging
                type: string
      
        secrets:
            docker_token:
              required: true

        outputs:
            build_version: 
                description: Generated build version
                value: ${{ jobs.task.outputs.build_version }}

jobs:
    task:

        outputs:
          build_version: ${{ steps.version.outputs.build_version }}
        
        runs-on: ubuntu-latest
        steps:
            - name: Checkout Code
              uses: actions/checkout@v4

            - name: Print
              run: echo "Building ${{inputs.app_name}} for ${{inputs.environment}}"

            - name: Print 2
              run: |
                echo "Docker Token is set :  ${{ secrets.docker_token != '' }}"  

            - name: Generate Build Version
              id: version
              run: |
                SHORT_SHA=$(git rev-parse --short HEAD)
                VERSION="v1.0-$SHORT_SHA"
                echo "build_version=$VERSION" >> "$GITHUB_OUTPUT"
                echo "Generated version: $VERSION"
```

**3. In your caller workflow, add a second job that:**

* Depends on the build job (needs:)
* Reads and prints the build_version output

```yml
name: Caller Workflow

on: 
    push:
        branches: [main]
    #workflow_dispatch:

jobs:
  build:
    uses: ./.github/workflows/reusable-build.yml
    with:
      app_name: "my-web-app"
      environment: "production"
    secrets:
      docker_token: ${{ secrets.DOCKERHUB_TOKEN }}

  print-version:
    needs: [build]
    runs-on: ubuntu-latest

    steps:
      - name: Print Build Version
        run: |
          echo "Build version: ${{ needs.build.outputs.build_version }}"
```

---

### ✅ Task 5 : Create a Composite Action

**Create a custom composite action in your repo at `.github/actions/setup-and-greet/action.yml:`**

**1. Define inputs: `name` and `language` (default: `en`)**

```yml
name: Setup and Greet
description: Greets a user, prints the date and OS, and sets a boolean output.

inputs:
  name:
    description: The name of the person to greet
    required: true
  language:
    description: The language for the greeting (e.g., en, es, fr)
    required: false
    default: en
```


**2. Add steps that:**

* Print a greeting in the specified language
* Print the current date and runner OS
* Set an output called `greeted` with value `true`

```yml
name: Setup and Greet
description: Greets a user, prints the date and OS, and sets a boolean output.

inputs:
  name:
    description: The name of the person to greet
    required: true
  language:
    description: The language for the greeting (e.g., en, es, fr)
    required: false
    default: en

outputs:
  greeted:
    description: 'Whether the greeting was successfully completed'
    value: ${{ steps.set-status.outputs.greeted }}

runs:
  using: composite
  steps:
    - name: Print Greeting
      shell: bash
      run: |
        if [ "${{ inputs.language }}" = es ]; then
          echo "¡Hola, ${{ inputs.name }}!"
        elif [ "${{ inputs.language }}" = "fr" ]; then
          echo "Bonjour, ${{ inputs.name }}!"
        else
          echo "Hello, ${{ inputs.name }}!"
        fi

    - name: Print Date and OS
      shell: bash
      run: |
        echo "Current Date: $(date)"
        echo "Runner OS: ${{ runner.os }}"

    - name: Set Greeted Output
      id: set-status
      shell: bash
      run: echo "greeted=true" >> "$GITHUB_OUTPUT"
```

**3. Use the composite action in a new workflow with uses: `./.github/workflows/actions/setup-and-greet`**

```yml
name: Composite Action

on:
  workflow_dispatch:

jobs:
  greet:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Code (Repository)
        uses: actions/checkout@v4

      - name: Run Custom Composite Action
        id: greet_action
        uses: ./.github/workflows/actions/setup-and-greet
        with:
          name: Harsh
          language: en

      - name: Print Action Output
        run: |
          echo "Greeted: ${{ steps.greet_action.outputs.greeted }}"
```

---

### ✅ Task 6 : Reusable Workflow vs Composite Action

| Feature | Reusable Workflow | Composite Action |
| :--- | :--- | :--- |
| **Triggered by** | `on: workflow_call` | `uses:` in a step |
| **Can contain jobs?** | Yes | No (steps only) |
| **Can contain multiple steps?**| Yes | Yes |
| **Lives where?** | `.github/workflows/` directory | Any directory (defined by an `action.yml` file) |
| **Can accept secrets directly?**| Yes (via `secrets` keyword or `inherit`) | No (must be passed as standard `inputs`) |
| **Best for** | Standardizing entire CI/CD pipelines and orchestrating multiple jobs | Bundling repetitive setup scripts or step logic within a single job |

---
