Rails.application.routes.draw do

  root 'application#index'

  get 'member' => 'member#index', as: 'member_index'
  get 'member/:id' => 'member#show', as: 'member'
  get 'member/:id/votes' => 'votes#show_member'

  match '/search', to: 'member#search', via: 'post'

  get 'electoral_district/:fednum' => 'electoral_district#show'

  get 'party' => 'party#index', as: 'party_index'
  get 'party/:id' => 'party#show', as: 'party'
  get 'party/:id/votes' => 'votes#show_party'

  get 'bill/:id' => 'bill#show', as: 'bill'

  get 'vote-tally/:id' => 'vote_tally#show', as: 'vote_tally'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
