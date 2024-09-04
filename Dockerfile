FROM ruby:3.3.5-bullseye

WORKDIR /gitlab_pipeline_action
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY bin/ bin/
COPY lib/ lib/

ENV BUNDLE_GEMFILE=/gitlab_pipeline_action/Gemfile
ENTRYPOINT ["bundle", "exec", "ruby"]
