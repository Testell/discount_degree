Rails.application.routes.draw do
  resources :course_requirements
  resources :users
  resources :transferable_courses
  resources :courses
  resources :degree_requirements
  resources :schools
  resources :degrees

  # This is a blank app! Pick your first screen, build out the RCAV, and go from there. E.g.:

  # get "/your_first_screen" => "pages#first"
  root "schools#index" 
end
