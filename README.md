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


Our users are now all setup, but when we create a new movie, it's not assigned to a user.       
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
We need to change the `Movie.new` to `current_user.movies.build`     
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

This will make sure that if a user who is not sign-in tries to click link and add a new movie, they are routed to the sign-up page.

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
So what we want to do is add `paperclip` gem to our `Gemfile`
```
gem 'paperclip', '~> 4.2.0'
```
https://github.com/thoughtbot/paperclip          

We need to add `has_attached_file` and `validates_attachment_content` to our movie model.         
In `app/models/movie.rb`
```ruby
class Movie < ApplicationRecord
	belongs_to :user

	has_attached_file :image, styles: { medium: "400x600#" }, default_url: "/images/:style/missing.png"
  	validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/
end
```

Next, we need to add migration.
```console
$ rails g paperclip movie image
$ rake db:migrate
```

Then we need to edit our forms and display inside of our view.      
In `app/views/movies/_form.html.erb`, change 
```html
<%= form_for(movie) do |f| %>
``` 
to 
```html
<%= form_for @movie, html: { multipart: true } do |f| %>
```

Next, we need to add a file field for our upload. So I'm just going to add that under rating.
```html

  <div class="field">
    <%= f.label :image %>
    <%= f.file_field :image %>
  </div>
```

So let's go back to our form `New Movie`, you can see we have the ability to choose an image now.
![image](https://github.com/TimingJL/movie_review/blob/master/pic/image_browse.jpeg)

In `app/views/movies/show.html.erb`, we're going to remove the notice.
We're going to add a image tag.
```html

	<%= image_tag @movie.image.url(:medium) %>
	<p>
	  <strong>Title:</strong>
	  <%= @movie.title %>
	</p>

	<p>
	  <strong>Description:</strong>
	  <%= @movie.description %>
	</p>

	<p>
	  <strong>Movie length:</strong>
	  <%= @movie.movie_length %>
	</p>

	<p>
	  <strong>Director:</strong>
	  <%= @movie.director %>
	</p>

	<p>
	  <strong>Rating:</strong>
	  <%= @movie.rating %>
	</p>

	<%= link_to 'Edit', edit_movie_path(@movie) %> |
	<%= link_to 'Back', movies_path %>
```

The image did not save to our database, yet. That is because if we go back to our `app/controllers/movies_controller.rb`, we did not add it to the permitted attributes in the movie params. So what we need to do is add `:image`.         
In `app/controllers/movies_controller.rb`
```
def movie_params
  params.require(:movie).permit(:title, :description, :movie_length, :director, :rating, :image)
end
```
![image](https://github.com/TimingJL/movie_review/blob/master/pic/show_image.jpeg)

Let's try and display the movie posters(image) on the index.      
Go to `app/views/movies/index.html.erb`. For each movie, let's just add `image_tag`:
```html

	<p id="notice"><%= notice %></p>

	<h1>Movies</h1>

	<table>
	  <thead>
	    <tr>
	      <th>Title</th>
	      <th>Description</th>
	      <th>Movie length</th>
	      <th>Director</th>
	      <th>Rating</th>
	      <th colspan="3"></th>
	    </tr>
	  </thead>

	  <tbody>
	    <% @movies.each do |movie| %>
	      <tr>
	        <td><%= image_tag movie.image.url(:medium) %></td>
	        <td><%= movie.title %></td>
	        <td><%= movie.description %></td>
	        <td><%= movie.movie_length %></td>
	        <td><%= movie.director %></td>
	        <td><%= movie.rating %></td>
	        <td><%= link_to 'Show', movie %></td>
	        <td><%= link_to 'Edit', edit_movie_path(movie) %></td>
	        <td><%= link_to 'Destroy', movie, method: :delete, data: { confirm: 'Are you sure?' } %></td>
	      </tr>
	    <% end %>
	  </tbody>
	</table>

	<br>

	<%= link_to 'New Movie', new_movie_path %>
```



# Styling and Structure
Let's take care of some styling and structure. So let's add the bootstrap gem.      
https://github.com/twbs/bootstrap-sass         

### Import Bootstrap
Open up our `Gemfile`
```
gem 'bootstrap-sass', '~> 3.2.0.2'
```
Then we'll run bundle install and restart the server.      

We need to rename the `application.css` to `application.css.scss`, and import bootstrap styles in `app/assets/stylesheets/application.css.scss`
```scss
@import "bootstrap-sprockets";
@import "bootstrap";
```

And we need to require bootstrap-sprockets within the `app/assets/javascripts/application.js`
```js
//= require jquery
//= require bootstrap-sprockets
```

### Add Header Navbar
First thing I want to do is add a header navbar. So we're going to add a partial. Let's add a new file in `app/views/layouts` and save that as `_header.html.erb`.              
And In `app/views/layouts/application.html.erb`, wr're going to add `<%= render 'layouts/header' %>`
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
	    <%= render 'layouts/header' %>
		<% flash.each do |name, msg| %>
		  		<%= content_tag(:div, msg, class: "alert alert-info") %>
		<% end %>
	    <%= yield %>
	  </body>
	</html>
```

Then I'm going to paste this in `app/views/layouts/_header.html.erb`
```html

	<nav class="navbar navbar-default" role="navigation">
	  <div class="container">
	    <div class="navbar-header">
	      <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
	        <span class="sr-only">Toggle navigation</span>
	        <span class="icon-bar"></span>
	        <span class="icon-bar"></span>
	        <span class="icon-bar"></span>
	      </button>
	      <%= link_to "Movie Reviews", root_path, class: "navbar-brand" %>
	    </div>

	    <!-- Collect the nav links, forms, and other content for toggling -->
	    <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
	      <ul class="nav navbar-nav">
	        <% if user_signed_in? %>
	          <li><%= link_to "New Movie", new_movie_path, class: "active" %></li>
	          <li><%= link_to "Account", edit_user_registration_path %></li>
	        <% else %>
	          <li><%= link_to "Sign Up", new_user_registration_path, class: "active" %></li>
	          <li><%= link_to "Sign In", new_user_session_path, class: "active" %></li>
	        <% end %>
	      </ul>
	      <form class="navbar-form navbar-right" role="search">
	        <div class="form-group">
	          <input type="text" class="form-control" placeholder="Search">
	        </div>
	        <button type="submit" class="btn btn-default">Submit</button>
	      </form>
	    </div><!-- /.navbar-collapse -->
	  </div><!-- /.container-fluid -->
	</nav>
```
![image](https://github.com/TimingJL/movie_review/blob/master/pic/navbar.jpeg)


Under `app/views/movies/index.html.erb`, we replace previous code to these:
```html

	<% if !user_signed_in? %>
	  <div class="jumbotron">
	    <h1>Your Favorite Movies Reviewed</h1>
	    <p>Hashtag hoodie mumblecore selfies. Authentic keffiyeh leggings Kickstarter, narwhal jean shorts XOXO Vice Austin cardigan. Organic drinking vinegar freegan pickled.</p>
	    <p><%= link_to "Sign Up To Write A Review", new_user_registration_path, class: "btn btn-primary btn-lg" %></p>
	  </div>
	<% end %>

	<div class="row">
	  <% @movies.each do |movie| %>
	    <div class="col-sm-6 col-md-3">
	      <div class="thumbnail">
	        <%= link_to (image_tag movie.image.url(:medium), class: 'image'), movie %>
	      </div>
	    </div>
	  <% end %>
	</div>
```

And add a container `<div class="container">......</div>` in `app/views/layouts/application.html.erb`
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
	    <%= render 'layouts/header' %>
	    <div class="container">
	      	<% flash.each do |name, msg| %>
	      	  		<%= content_tag(:div, msg, class: "alert alert-info") %>
	      	<% end %>
	        <%= yield %>
	    </div>
	  </body>
	</html>
```
![image](https://github.com/TimingJL/movie_review/blob/master/pic/index_bootstrap.jpeg)


One thing I do notice is the font looks a little funky and that is bacause scaffold generate some styles for us.      
So we have to go to `app/assets/stylesheets` to remove the file `scaffolds.scss`


### Add Some Structure To Show Page
So let's quickly add some structure to the show page.       
In `app/views/movies/show.html.erb`
```html

	<div class="panel panel-default">
	  <div class="panel-body">
	    <div class="row">
	      <div class="col-md-4">
	        <%= image_tag @movie.image.url(:medium) %>
	        <div class="table-responsive">
	          <table class="table">
	            <tbody>
	              <tr>
	                <td><strong>Title:</strong></td>
	                <td><%= @movie.title %></td>
	              </tr>
	              <tr>
	                <td><strong>Description:</strong></td>
	                <td><%= @movie.description %></td>
	              </tr>
	              <tr>
	                <td><strong>Movie length:</strong></td>
	                <td><%= @movie.movie_length %></td>
	              </tr>
	              <tr>
	                <td><strong>Director:</strong></td>
	                <td><%= @movie.director %></td>
	              </tr>
	              <tr>
	                <td><strong>Rating:</strong></td>
	                <td><%= @movie.rating %></td>
	              </tr>
	            </tbody>
	          </table>
	        </div>
	      </div>
	    </div>
	  </div>
	</div>

	<%= link_to 'Edit', edit_movie_path(@movie) %> |
	<%= link_to 'Back', movies_path %>
```

And in `app/assets/stylesheets/application.css.scss`, we paste in some quick styling.
```scss
body {
	background: #AA4847;
}

.review_title {
	margin: 0 0 20px 0;
}
.reviews {
	padding: 15px 0;
	border-bottom: 1px solid #EAEAEA;
	.star-rating {
		padding-bottom: 8px;
	}
}
```
![image](https://github.com/TimingJL/movie_review/blob/master/pic/basic_styling.jpeg)


To be continued...