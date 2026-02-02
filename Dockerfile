FROM ruby:4.0.1

WORKDIR /gitlab_pipeline_action
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY bin/ bin/
COPY lib/ lib/

ENV BUNDLE_GEMFILE=/gitlab_pipeline_action/Gemfile
ENTRYPOINT ["bundle", "exec", "ruby"]
