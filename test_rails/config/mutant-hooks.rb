hooks.register(:env_infection_post) do
  ::Rails.application.eager_load!
end
