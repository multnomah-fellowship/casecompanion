# frozen_string_literal: true

# Capistrano expects that the git repo was initialized with `git clone
# --mirror`, which sets up a refspec that fetches all branches.
#
# We can ninja-fix this right before running `git fetch`, which is easier than
# doing surgery on the Ansible module to add the backwards-incompatible
# `--merge` flag.

namespace :git do
  task :fix_config do
    on roles(:all) do
      execute :git, 'config', 'remote.origin.fetch', '+refs/*:refs/*'
      execute :git, 'config', 'remote.origin.mirror', 'true'
    end
  end
end

before 'git:update', 'git:fix_config'
