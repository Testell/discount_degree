Rails.application.routes.draw do
  resources :course_requirements
  resources :users
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

  # This is a blank app! Pick your first screen, build out the RCAV, and go from there. E.g.:

  # get "/your_first_screen" => "pages#first"
  root "schools#index" 
end
