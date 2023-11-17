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
      - uses: Taucher2003/GitLab-Pipeline-Action@<version>
        name: Run pipeline
        with:
          GL_SERVER_URL: https://gitlab.com
          GL_PROJECT_ID: '<project-id>'
          GL_RUNNER_TOKEN: ${{ secrets.GL_RUNNER_TOKEN }}
          GL_API_TOKEN: ${{ secrets.GL_API_TOKEN }}
```

## Known issues

GitHub does not pass secrets to actions triggered by pull requests from forks.
This causes the `GL_API_TOKEN` and `GL_RUNNER_TOKEN` to be empty when triggered from a fork.

The action will fail in this case as the `GL_API_TOKEN` is required.
