Rails.application.routes.draw do
  devise_for :users
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
  end
  resources :degrees do
    resources :degree_requirements, only: [:create]
  end

  get "/plan_page" => "pages#plan_page"
  # This is a blank app! Pick your first screen, build out the RCAV, and go from there. E.g.:

  # get "/your_first_screen" => "pages#first"
  root "pages#home" 
end
