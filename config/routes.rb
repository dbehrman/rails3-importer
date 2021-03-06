Rails3Importer::Application.routes.draw do
  resources :submissions
  resources :members
  resources :groups
  resources :admins, :only => [:index, :show, :edit, :update ]

  root :to => "home#index"
  match '/auth/:provider/callback' => 'sessions#create'

  match '/members/:id/export' => 'members#export'
  match '/members/:id/assign' => 'members#assign'
  match '/members/import' => 'members#import_csv'
  match '/new_members/export_all' => 'members#export_all'
  match '/new_members/assign_all' => 'members#assign_all'
  match '/new_members/clear_errors' => 'members#clear_errors'
  match '/new_members/live' => 'members#live'
  match '/new_members/get_roles' => 'members#get_roles'
  match '/new_members/get_submissions' => 'members#get_submissions'
  match '/new_members/add_members_job' => 'members#add_members_job'
  match '/new_members/get_webform_data' => 'members#get_webform_data'
  match '/new_members/add_to_all_groups' => 'members#add_to_group_and_subgroups'
  match '/new_members/remove_from_group' => 'members#remove_from_group'
  match '/new_members/remove_from_group_and_subgroups' => 'members#remove_from_group_and_subgroups'
  match '/new_members/set_completed' => 'members#set_completed'

  match '/groups/:id/export' => 'groups#export'
  match '/groups/:id/get_members' => 'groups#get_members'
  match '/groups/:id/get_roles' => 'groups#get_roles'
  match '/new_groups/export_all' => 'groups#export_all'
  match '/new_groups/clear_errors' => 'groups#clear_errors'
  match '/new_groups/import' => 'groups#import_csv'
  match '/new_groups/sync' => 'groups#get_groups'

  match '/submissions/:id/getid' => 'submissions#getid'
  match '/submissions/:id/assign' => 'submissions#assign'
  match '/submissions/import' => 'submissions#import_csv'
  match '/get_all_submissions' => 'submissions#getall'
  match '/assign_all_submissions' => 'submissions#assign_all'

  match '/signin' => 'sessions#new', :as => :signin
  match '/signout' => 'sessions#destroy', :as => :signout
  match '/auth/failure' => 'sessions#failure'
end
