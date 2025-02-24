# GitLab Pipeline Action

With this action, you can run your pipelines on GitLab for your GitHub project.

This action takes care of the following things:

- Pushing the relevant code to GitLab
- Starting a pipeline on the relevant code
- Hosting a GitLab Runner
- Waiting for the GitLab pipeline to finish
- Removing the code from GitLab after the pipeline finished
- Failing the workflow if the GitLab pipeline did not complete successful.

## Setup

### Preparation

1. Create a project on GitLab [[Create project](https://docs.gitlab.com/ee/user/project/#create-a-blank-project)]
2. Create a personal access token and save it in the secrets on GitHub (A group or project access token also works)
   [[Create personal access token](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html#create-a-personal-access-token)]
   [[Create a secret](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-a-repository)]
3. Create a runner and save the runner token in the secrets on GitHub (this step can be skipped if you want to use shared runners)
   [[Create runner](https://docs.gitlab.com/ee/ci/runners/runners_scope.html#create-a-project-runner-with-a-runner-authentication-token)]
   [[Create a secret](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-a-repository)]

### Setup Action

Create a workflow with the following content.

Replace `<project-id>` with the ID of the project you created in step one.
The snippet assumes that the secret from step 2 and 3 were created with the name `GL_API_TOKEN` and `GL_RUNNER_TOKEN`.

If your project is hosted on gitlab.com, you can omit the `GL_SERVER_URL` configuration.

```yaml
name: GitLab

on:
  push:
  pull_request:

jobs:
  pipeline:
    runs-on: ubuntu-latest
    steps:
      - uses: Taucher2003/GitLab-Pipeline-Action@1.9.5
        name: Run pipeline
        with:
          GL_SERVER_URL: https://gitlab.com
          GL_PROJECT_ID: '<project-id>'
          GL_RUNNER_TOKEN: ${{ secrets.GL_RUNNER_TOKEN }}
          GL_API_TOKEN: ${{ secrets.GL_API_TOKEN }}
```

## Pass variables to the GitLab Pipeline

You can define variables that should be passed to the GitLab pipeline.

Every environment variable starting with `GLPA_` will be passed to the GitLab pipeline
with the `GLPA_` prefix removed.

<details>
<summary>Example with variable</summary>

With this setup, the `GITHUB_TOKEN` is available in the GitLab pipeline.
It is accessible in the GitLab pipeline with `$GITHUB_TOKEN`, because the `GLPA_`
prefix is stripped before passing it to GitLab.

```yaml
name: GitLab

on:
  push:
  pull_request:

jobs:
  pipeline:
    runs-on: ubuntu-latest
    steps:
      - uses: Taucher2003/GitLab-Pipeline-Action@1.9.5
        name: Run pipeline
        with:
          GL_SERVER_URL: https://gitlab.com
          GL_PROJECT_ID: '<project-id>'
          GL_RUNNER_TOKEN: ${{ secrets.GL_RUNNER_TOKEN }}
          GL_API_TOKEN: ${{ secrets.GL_API_TOKEN }}
        env:
          GLPA_GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

</details>

## Show job logs

By adding the `SHOW_JOB_LOGS` to the input section (`with`), you can show the job logs
from the GitLab pipeline in the output of the GitHub Action Run.

Available options are `none`, `failures` and `all`. \
When using `none` or not specifying the option, no job logs will be shown. \
With `failures`, the job logs of failed jobs will be shown. \
`all` shows the job log of all jobs in the pipeline.

## Known issues

GitHub does not pass secrets to actions triggered by pull requests from forks.
This causes the `GL_API_TOKEN` and `GL_RUNNER_TOKEN` to be empty when triggered from a fork.

You can work around that by using the `pull_request_target` trigger. Because this triggers
the workflow against the base branch instead of the head branch, you need to set overrides
for the action to checkout the code from the PR instead of the base branch.

Before adopting this solution, think about the security implications. You can read more about
them in the [GitHub documentation](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#pull_request_target).

If the GitLab project contains CI/CD variables, they can be extracted from an external
contributor by just opening a PR on GitHub.

You can work around that with an environment that requires a review to deploy. That will
hold the job until it is approved by a repository collaborator.

```yml
name: GitLab

on:
   pull_request_target:

jobs:
   pipeline:
      runs-on: ubuntu-latest
      steps:
         - uses: Taucher2003/GitLab-Pipeline-Action@1.9.5
           name: Run pipeline
           with:
              GL_SERVER_URL: https://gitlab.com
              GL_PROJECT_ID: '<project-id>'
              GL_RUNNER_TOKEN: ${{ secrets.GL_RUNNER_TOKEN }}
              GL_API_TOKEN: ${{ secrets.GL_API_TOKEN }}
              OVERRIDE_GITHUB_SHA: ${{ github.event.pull_request.head.sha }}
              OVERRIDE_GITHUB_REF_NAME: ${{ github.event.pull_request.head.ref }}
```
