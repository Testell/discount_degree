Rails.application.routes.draw do
  devise_for :users

  resources :users do
    member do
      post "save_plan", to: "saved_plans#create", as: "save_plan"
      delete "remove_saved_plan", to: "saved_plans#destroy", as: "remove_saved_plan"
    end
  end

  resources :plans, only: %i[index show new create edit update destroy]

  resources :saved_plans, only: %i[show create destroy]

  resources :course_requirements

  resources :transferable_courses

  resources :courses do
    resources :transferable_courses
  end

  resources :degree_requirements do
    resources :course_requirements, only: [:create]
  end

  resources :schools do
    resources :degrees, only: [:create]
    resources :courses, only: [:create]
    resources :terms, except: [:show]
  end

  resources :terms

  resources :degrees do
    resources :degree_requirements, only: [:create]
    post "generate_cheapest_plan",
         to: "admin_cheapest_plan#create",
         as: "generate_cheapest_plan",
         on: :member
  end

  get "/plan_page", to: "pages#plan_page", as: "plan_page"

  get "/show_plan", to: "pages#show_plan", as: "show_plan"
  get "save_plan_prompt", to: "users#save_plan_prompt", as: "prompt_save_plan"
  post "/generate_plan", to: "pages#generate_plan", as: "generate_plan"

  root "pages#home"
end
