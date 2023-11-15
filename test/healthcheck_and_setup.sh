#!/usr/bin/env sh

# This script is intended to be used as a Docker HEALTHCHECK for the GitLab container.
# It prepares GitLab prior to running tests.
#
# This is a known workaround for docker-compose lacking lifecycle hooks.
# See: https://github.com/docker/compose/issues/1809#issuecomment-657815188

set -e

# Check for a successful HTTP status code from GitLab.
curl --silent --show-error --fail --output /dev/null 127.0.0.1:80

# Because this script runs on a regular health check interval,
# this file functions as a marker that tells us if initialization already finished.
done=/var/gitlab-test-initialized

test -f $done || {
  echo 'Initializing GitLab for tests'

  echo 'Creating access token'
  (
    printf 'token = PersonalAccessToken.create('
    printf 'user_id: 1, '
    printf 'scopes: [:api, :write_repository], '
    printf 'expires_at: Time.now + 30.days, '
    printf 'name: :token);'
    printf "token.set_token('TEST1234567890123456');"
    printf 'token.save!;'

    printf 'settings = ApplicationSetting.current;'
    printf 'settings.import_sources << "git";'
    printf 'settings.save!;'

    printf 'Projects::CreateService.new(User.find(1), {'
    printf 'namespace_id: User.first.namespace.id,'
    printf 'name: "Test",'
    printf 'path: "test",'
    printf 'ci_config_path: "test/.gitlab-ci.yml",'
    printf 'id: 1000,'
    printf 'import_type: "git",'
    printf 'import_url: "https://github.com/Taucher2003/Gitlab-Pipeline-Action.git"'
    printf '}).execute;'

    printf 'Ci::Runners::CreateRunnerService.new('
    printf 'user: User.first,'
    printf 'params: {'
    printf 'runner_type: "instance_type",'
    printf 'token: "some_long_runner_token"'
    printf '}'
    printf ').execute;'

    printf 'Ci::ChangeVariableService.new('
    printf 'container: Project.find(1000),'
    printf 'current_user: User.first,'
    printf 'params: { action: :create, variable_params: { key: "GIT_STRATEGY", value: "none", protected: false } }'
    printf ').execute;'
  ) | gitlab-rails console

  touch $done
}

echo 'GitLab is ready for tests'
