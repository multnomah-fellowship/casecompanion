# frozen_string_literal: true

namespace :systemd do
  task :validate do
    unless fetch(:systemd_service)
      raise StandardError, <<~ERROR
        No systemd_service set!
        Make sure Capistrano config contains `set :systemd_service, "something"`
      ERROR
    end
  end
end

namespace :deploy do
  desc 'Restart the application'
  task :restart do
    on roles(:web), in: :sequence do
      execute "sudo systemctl restart #{fetch(:systemd_service)}"
    end
  end
end

before 'deploy:starting', 'systemd:validate'
after 'deploy:published', 'deploy:restart'
