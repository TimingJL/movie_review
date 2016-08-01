# Learning by Doing 

![Ubuntu version](https://img.shields.io/badge/Ubuntu-16.04%20LTS-orange.svg)
![Rails version](https://img.shields.io/badge/Rails-v5.0.0-blue.svg)
![Ruby version](https://img.shields.io/badge/Ruby-v2.3.1p112-red.svg)

Mackenzie Child's video really inspired me. So I decided to follow all of his rails video tutorial to learn how to build a web app. Through the video, I would try to build the web app by my self and record the courses step by step in text to facilitate the review.


# Project 5: How To Build A Movie Review App With Rails

This time I built a movie rating and review application. We have a bunch of different movies and each movie has multiple review which is rated on a one to five star scale. And then another cool feature is we have the ability to search. The cool thing about this search gem that we are using is it's able to distinguish between correct spelling and misspelled or pluralization and all that. And obviouly we have the ability to sign-up/sign-in, and only sign-in users have the ability to write review.

https://mackenziechild.me/12-in-12/5/  



### Highlights of this course
1. Users
2. Reviews
3. Ratings
4. Search
5. HAML
6. Bootstrap


# Create A Movie Review App
```console
$ rails new movie_review
```


Chage directory to the pin_board. Under `Gemfile`, add `gem 'therubyracer'`, save and run `bundle install`.      

Note: 
Because there is no Javascript interpreter for Rails on Ubuntu Operation System, we have to install `Node.js` or `therubyracer` to get the Javascript interpreter.

```console
$ bundle install
```

Then run the `rails server` and go to `http://localhost:3000` to make sure everything is correct.


I'm just going to quickly get the ability to create movies, add users, and add images. And we're going to focus most of the time on the reviews and the ability to search. So we're going to use a scaffold to generate the movies.


# Using Scaffold To Generate The Movies

```console
$ rails g scaffold Movie title:string description:text movie_length:string director:string rating:string
$ rake db:migrate
```
![image](https://github.com/TimingJL/movie_review/blob/master/pic/movie_scaffold.jpeg)



# Add Users
We're going to use the `devise` gem for our users. 
https://github.com/plataformatec/devise      

In `Gemfile`:
```
gem 'devise'
```

Then run `bundle install` and restart the server.

Getting started, we installed the devise gem. Next, we need to install devise by running:
```console
$ rails g devise:install
```

```
Some setup you must do manually if you haven't yet:

  1. Ensure you have defined default url options in your environments files. Here
     is an example of default_url_options appropriate for a development environment
     in config/environments/development.rb:

       config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

     In production, :host should be set to the actual host of your application.

  2. Ensure you have defined root_url to *something* in your config/routes.rb.
     For example:

       root to: "home#index"

  3. Ensure you have flash messages in app/views/layouts/application.html.erb.
     For example:

       <p class="notice"><%= notice %></p>
       <p class="alert"><%= alert %></p>

  4. You can copy Devise views (for customization) to your app by running:

       rails g devise:views
```

Next, we need to do some manual setup for devise.      
First step, we copy `config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }` to the bottom of `config/environments/development.rb`.

Second, we want the movies to be the root of our application.          
In `app/config/routes.rb`
```ruby
Rails.application.routes.draw do
  resources :movies
  
  root 'movies#index'
end
```

Now, we need to ensure we have flash messages in `app/views/layouts/application.html.erb`.
The devise gem gives you some alert tou can just copu and paste, but I'm going to add some specific to bootstrap.
```html

	<!DOCTYPE html>
	<html>
	  <head>
	    <title>MovieReview</title>
	    <%= csrf_meta_tags %>

	    <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track': 'reload' %>
	    <%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload' %>
	  </head>

	  <body>
		<% flash.each do |name, msg| %>
		  		<%= content_tag(:div, msg, class: "alert alert-info") %>
		<% end %>
	    <%= yield %>
	  </body>
	</html>
```

You can copy Devise views (for customization) to your app by running:
```console
$ rails g devise:views
```

We need to generate a devise user model to work.
```console
$ rails g devise User
$ rake db:migrate
```

You can see that worked by going to `http://localhost:3000/users/sign_up`
![image](https://github.com/TimingJL/movie_review/blob/master/pic/basic_signup.jpeg)


Our users are now all setup, bu when we create a new movie, it's not assigned to a user.       
To do that, we need to add a migration.       
```console
$ rails g migraiton add_user_id_to_movies user_id:integer
$ rake db:migrate
```


If we go to our rails console `rails c`:
```console
> @movie = Movie.first
```

You can see the `user_id: nil`
```
  Movie Load (0.6ms)  SELECT  "movies".* FROM "movies" ORDER BY "movies"."id" ASC LIMIT ?  [["LIMIT", 1]]         
=> #<Movie id: 1, title: "Iron Man", description: "Iron Man (Tony Stark) is a fictional superhero app...",         
movie_length: "2:06", director: "Jon Favreau", rating: "PG-12", created_at: "2016-08-01 12:28:38",        
updated_at: "2016-08-01 12:28:38", user_id: nil>
```

So we need to make sure when we create a new movie, it's assigned to the current user.     
Open up our `app/controllers/movies_controller.rb`      
We need to change the `Movie.new` ot `current_user.movies.build`     
```ruby
  def new
    @movie = current_user.movies.build
  end

  ...
  ...

  def create
    @movie = current_user.movies.build(movie_params)

    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: 'Movie was successfully created.' }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end
```


Then, we want to authenticate the users.      
In `app/controllers/movies_controller.rb`   
```ruby
class MoviesController < ApplicationController
  before_action :set_movie, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]
  ...
  ...
```

This will make sure that if a user who is not signed in tries to click link and add a new movie, they are routed to the sign-up page.

Then, let's go into our models and add association between movie a user.      
In `app/models/movie.rb`
```ruby
class Movie < ApplicationRecord
	belongs_to :user
end
```

In `app/models/user.rb`
```ruby
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :movies
end
```

# Image Uploading
Let's next add the ability to upload an image for each movie.


To be continued...