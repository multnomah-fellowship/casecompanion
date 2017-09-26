# frozen_string_literal: true

namespace :systemd do
  task :validate do
    unless fetch(:systemd_web_service)
      raise StandardError, <<~ERROR
        No systemd_service set!
        Make sure Capistrano config contains `set :systemd_web_service, "something"`
      ERROR
    end

    unless fetch(:systemd_worker_service)
      raise StandardError, <<~ERROR
        No systemd_worker_service set!
        Make sure Capistrano config contains `set :systemd_worker_service, "something"`
      ERROR
    end

    unless fetch(:systemd_worker_role)
      raise StandardError, <<~ERROR
        No systemd_worker_role set!
        Make sure Capistrano config contains `set :systemd_worker_role, "something"`
      ERROR
    end
  end
end

namespace :deploy do
  desc 'Restart the application'
  task :restart do
    on roles(:web), in: :sequence do
      execute "sudo systemctl restart #{fetch(:systemd_web_service)}"
    end

    on roles(fetch(:systemd_worker_role)), in: :sequence do
      execute "sudo systemctl restart #{fetch(:systemd_worker_service)}"
    end
  end
end

before 'deploy:starting', 'systemd:validate'
after 'deploy:published', 'deploy:restart'
