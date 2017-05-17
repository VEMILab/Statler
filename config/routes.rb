Rails.application.routes.draw do
  # resources :annotations
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'
  get 'search/' => 'search#index', as: :search
  get 'searchtag/' => 'search#index', as: :searchtag
  #  get 'login/' => 'welcome#index'
  #get 'user/' => 'users#new'
  #get 'annotators/bork' => 'annotators#bork'
  get    'api/getAnnotationsByLocation' => 'api_session#getAnnotationsByLocation'
  post   'api/addAnnotation' => 'api_session#addAnnotation'
  post   'api/editAnnotation' => 'api_session#editAnnotation'
  delete 'api/deleteAnnotation' => 'api_session#deleteAnnotation'
  post   'api/login' => 'api_session#login'
  delete 'api/logout' => 'api_session#logout'
  post    'api/generateKey' => 'api_session#generateKey'

  # Configures store endpoint in your app
  mount AnnotatorStore::Engine, at: '/annotator_store'

  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  get '/logout' => 'sessions#destroy'

  get '/signup' => 'users#new'
  post '/users' => 'users#create'

  # get '/annotation' => 'annotation#new'
  post '/annotation' => 'annotations#create'

  get '/root' => 'welcome#index'

end
