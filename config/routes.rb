Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#home'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'
  get '/login' => 'users#login'
  post '/login' => 'users#login'
  post '/authenticate' => 'users#authenticate'
  get '/new_stock' => 'home#new_stock'
  post '/new_stock' => 'home#new_stock'
  get '/adjust_stock' => 'home#adjust_stock'
  post '/adjust_stock' => 'home#adjust_stock'
  get '/product_stock_details' => 'home#product_stock_details'
  post '/product_stock_details' => 'home#product_stock_details'
  get '/view_stock' => 'home#view_stock'
  post '/view_stock' => 'home#view_stock'
  get '/void_stock' => 'home#void_stock'
  post '/void_stock' => 'home#void_stock' #void_cash_in
  post '/create_stock' => 'home#create_stock'
  post '/void_incoming_stock' => 'home#void_incoming_stock'
  post '/void_outgoing_stock' => 'home#void_outgoing_stock'
  get '/get_incoming_stock' => 'home#get_incoming_stock'
  get '/get_outgoing_stock' => 'home#get_outgoing_stock'
  get '/get_product_details' => 'home#get_product_details'
  post '/add_products' => 'home#add_products'

  get '/set_prices' => 'home#set_prices'
  post '/set_prices' => 'home#set_prices'
  get '/manage_product_prices' => 'home#manage_product_prices'
  post '/manage_product_prices' => 'home#manage_product_prices'
  get '/view_prices' => 'home#view_prices'
  post '/view_prices' => 'home#view_prices'
  get '/void_prices' => 'home#void_prices'
  post '/void_prices' => 'home#void_prices'

  get '/new_products' => 'home#new_products'
  post '/new_products' => 'home#new_products'
  get '/edit_products' => 'home#edit_products'
  get '/edit_this_product' => 'home#edit_this_product'
  post '/edit_this_product' => 'home#edit_this_product'
  post '/edit_products' => 'home#edit_products'
  get '/view_products' => 'home#view_products'
  post '/view_products' => 'home#view_products'
  get '/void_products' => 'home#void_products'
  post '/void_products' => 'home#void_products'

  get '/add_stock' => 'home#add_stock'
  post '/add_stock' => 'home#add_stock'

  get '/close_stock' => 'home#close_stock'
  post '/close_stock' => 'home#close_stock'

  get '/stock_card' => 'home#stock_card'
  get '/edit_stock_card' => 'home#edit_stock_card'

  post '/update_stock' => 'home#update_stock'

  get '/new_user' => 'users#new_user'
  get '/my_profile' => 'users#my_profile'
  post '/update_profile' => 'users#update_profile'
  post '/update_password' => 'users#update_password'
  post '/new_user' => 'users#new_user'
  get '/edit_user' => 'users#edit_user'
  post '/edit_user' => 'users#edit_user'
  get '/view_users' => 'users#view_users'
  post '/view_users' => 'users#view_users'
  get '/void_users' => 'users#void_users'
  post '/void_users' => 'users#void_users'

  get '/reports' => 'home#reports'

  get '/incoming_stock_report' => 'reports#incoming_stock_report'
  post '/incoming_stock_report' => 'reports#incoming_stock_report'

  get '/products_with_enough_stock_report' => 'reports#products_with_enough_stock_report'
  post '/products_with_enough_stock_report' => 'reports#products_with_enough_stock_report'

  get '/outgoing_stock_report' => 'reports#outgoing_stock_report'
  post '/outgoing_stock_report' => 'reports#outgoing_stock_report'

  get '/products_not_in_stock_report' => 'reports#products_not_in_stock_report'
  post '/products_not_in_stock_report' => 'reports#products_not_in_stock_report'

  get '/products_running_out_of_stock_report' => 'reports#products_running_out_of_stock_report'
  post '/products_running_out_of_stock_report' => 'reports#products_running_out_of_stock_report'

  get '/incoming_stock_report_printable' => 'reports#incoming_stock_report_printable'
  get '/print_incoming_stock_report_printable' => 'reports#print_incoming_stock_report_printable'

  get '/products_with_enough_stock_report_printable' => 'reports#products_with_enough_stock_report_printable'
  get '/print_products_with_enough_stock_report_printable' => 'reports#print_products_with_enough_stock_report_printable' #outgoing_stock_report_printable

  get '/outgoing_stock_report_printable' => 'reports#outgoing_stock_report_printable'
  get '/print_outgoing_stock_report_printable' => 'reports#print_outgoing_stock_report_printable'

  get '/products_running_out_of_stock_report_printable' => 'reports#products_running_out_of_stock_report_printable'
  get '/print_products_running_out_of_stock_report_printable' => 'reports#print_products_running_out_of_stock_report_printable'

  get '/products_not_in_stock_report_printable' => 'reports#products_not_in_stock_report_printable'
  get '/print_products_not_in_stock_report_printable' => 'reports#print_products_not_in_stock_report_printable'

  get '/logout' => 'users#logout'
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
