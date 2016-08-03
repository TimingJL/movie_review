# Learning by Doing 

![Ubuntu version](https://img.shields.io/badge/Ubuntu-16.04%20LTS-orange.svg)
![Rails version](https://img.shields.io/badge/Rails-v5.0.0-blue.svg)
![Ruby version](https://img.shields.io/badge/Ruby-v2.3.1p112-red.svg)

Mackenzie Child's video really inspired me. So I decided to follow all of his rails video tutorial to learn how to build a web app. Through the video, I would try to build the web app by my self and record the courses step by step in text to facilitate the review.


# Project 5: How To Build A Movie Review App With Rails

This time I built a movie rating and review application. We have a bunch of different movies and each movie has multiple review which is rated on a one to five star scale. And then another cool feature is we have the ability to search. The cool thing about this search gem that we are using is it's able to distinguish between correct spelling and misspelled or pluralization and all that. And obviouly we have the ability to sign-up/sign-in, and only sign-in users have the ability to write review.

https://mackenziechild.me/12-in-12/5/  

![image](https://github.com/TimingJL/movie_review/blob/master/pic/index_demo.jpeg)

### Highlights of this course
1. Users
2. Reviews
3. Ratings
4. Search
5. Bootstrap


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

# Add Review
Next thing we want to do is add reviews for each movie. To do that, I'm going to generate another scaffold.
```console
$ rails g scaffold Review rating:integer comment:text
$ rake db:migrate
```

Next, we want to make sure that a review belongs to a user.     
```console
$ rails g migration add_user_id_to_reviews user_id:integer
$ rake db:migrate
```

So let's pop into our console `rails c` to confirm that worked.
```console
$ rails c

> @review = Review.first
```

```
  Review Load (0.5ms)  SELECT  "reviews".* FROM "reviews" ORDER BY "reviews"."id" ASC LIMIT ?  [["LIMIT", 1]]        
=> #<Review id: 1, rating: 5, comment: "This movie was freaking awesome!", created_at: "2016-08-02 08:04:09",        
updated_at: "2016-08-02 08:04:09", user_id: nil>
```
So you can see the very end, the `user_id` is `nil` now.       
Next, we need to add association between the review and the user model.     
So let's open up our models.      
In `app/models/review.rb` 
```ruby
class Review < ApplicationRecord
	belongs_to :user
end
```

In `app/models/user.rb`        
One note on this is we want to add a line that says `dependent: :destroy`. Because if someone deltes their account, if a user gets deleted, we also want all the reviews associated with that user to be deleted as well. Or else, you could run into errors because you may find that no user is associated with certain review. Adding `dependent: :destroy` will  destroy any reviews that is associated with that user in case that user gets destroyed.
```ruby
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :movies
  has_many :reviews, dependent: :destroy
end
```

In `app/controllers/reviews_controller.rb`, when a user writes a new review, the user_id will get assigned to them.
```ruby
  def create
    @review = Review.new(review_params)
    @review.user_id = current_user.id

    respond_to do |format|
      if @review.save
        format.html { redirect_to @review, notice: 'Review was successfully created.' }
        format.json { render :show, status: :created, location: @review }
      else
        format.html { render :new }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end
```


And we want to add `before_action`.          
In `app/controllers/reviews_controller.rb`
```ruby
class ReviewsController < ApplicationController
  before_action :set_review, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  ...
  ...

 end
```

In `app/views/reviews/show.html.erb`, we add to test the association setup between the review and the user.

	<p>
	  <strong>User:</strong>
	  <%= @review.user.email %>
	</p>



This is working, but we don't want to have a separate page for the reviews. We don't want to have the slash `/reviews` to list all the reviews.      
We only want to show the reviews on the movie page.     
To do that, we need to link the reviews to the movies and had an association between them.     
And then, we'll also go through and remove the routes and controller actions for the index and the show. Because we only want to have the ability to create, edit and destroy a review on it.         


Let's get started by delete:         
1. `app/reviews/index.html.erb`          
2. `app/reviews/index.json.jbuilder`        
3. `app/reviews/show.html.erb`          
4. `app/reviews/show.json.jbuilder`        


Now, let's add a migration to add the movie ID to the reviews.
```console
$ rails g migration add_movie_id_to_reviews movie_id:integer
$ rake db:migrate
```

That's pop into the `rails console`
```console
$ rails c

> @review = Review.last
```

You can see the `movie_id` is `nil`. So that means the `movie_id` column was added to the review's table for us.
```
  Review Load (0.5ms)  SELECT  "reviews".* FROM "reviews" ORDER BY "reviews"."id" DESC LIMIT ?  [["LIMIT", 1]]        
=> #<Review id: 2, rating: 3, comment: "This movie sucked!", created_at: "2016-08-02 13:49:45",       
updated_at: "2016-08-02 13:49:45", user_id: 1, movie_id: nil>     
```


Let's add an association between the review and the movie.
In `app/models/movie.rb`
```ruby
class Movie < ApplicationRecord
	belongs_to :user
	has_many :reviews

	has_attached_file :image, styles: { medium: "400x600#" }, default_url: "/images/:style/missing.png"
  	validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/
end
```

And in In `app/models/review.rb`
```ruby
class Review < ApplicationRecord
	belongs_to :user
	belongs_to :movie
end
```

So one thing we need to do next is our form.           
In `app/views/reviews/_form.html.erb`, instead of building from `review`, we gonna want to do:
```
<%= form_for([@movie, review]) do |f| %>
...
...
```
This is because we're going to do a nested route for this form.

In `config/routes.rb`
```ruby
Rails.application.routes.draw do  
  devise_for :users

  resources :movies do
  	resources :reviews, except: [:show, :index]
  end

  root 'movies#index'
end
```

Then in our `app/controllers/reviews_controller`, we add a private action `set_movie`. And on the top, we add `before_action :set_movie`. And we tweak the `create action`, add `@review.movie_id = @movie.id`. And we don't actually have index and show, that's remove those as well.
```ruby
class ReviewsController < ApplicationController
  before_action :set_review, only: [:show, :edit, :update, :destroy]
  before_action :set_movie
  before_action :authenticate_user!

  # GET /reviews/new
  def new
    @review = Review.new
  end

  # GET /reviews/1/edit
  def edit
  end

  def create
    @review = Review.new(review_params)
    @review.user_id = current_user.id
    @review.movie_id = @movie.id

    if @review.save
      redirect_to @movie
    else
      render 'new'
    end
  end

  # PATCH/PUT /reviews/1
  # PATCH/PUT /reviews/1.json
  def update
    respond_to do |format|
      if @review.update(review_params)
        format.html { redirect_to @review, notice: 'Review was successfully updated.' }
        format.json { render :show, status: :ok, location: @review }
      else
        format.html { render :edit }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reviews/1
  # DELETE /reviews/1.json
  def destroy
    @review.destroy
    respond_to do |format|
      format.html { redirect_to reviews_url, notice: 'Review was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_review
      @review = Review.find(params[:id])
    end

    def set_movie
      @movie = Movie.find(params[:movie_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def review_params
      params.require(:review).permit(:rating, :comment)
    end
end
```

Now, when we pop into the `rails console`, we can see the `movie_id` of `@review = Review.last` is not `nil`.

So next, let's fix those links.
First, I want to add a link to write a new review.
Inside of `app/views/movies/show.html.erb`, we add `<%= link_to "Write a Review", new_movie_review_path(@movie) %>` under the table.
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
	          <%= link_to "Write a Review", new_movie_review_path(@movie) %>
	        </div>
	      </div>
	    </div>
	  </div>
	</div>

	<%= link_to 'Edit', edit_movie_path(@movie) %> |
	<%= link_to 'Back', movies_path %>
```

Under `app/views/reviews/new.html.erb`
```html

	<h1>New Review</h1>

	<%= render 'form', review: @review %>

	<%= link_to 'Back', movie_path(@movie) %>
```

Under `app/views/reviews/edit.html.erb`
```html

	<h1>Editing Review</h1>

	<%= render 'form', review: @review %>
	
	<%= link_to 'Back', movie_path(@movie) %>

```

So next thing we need to do is list out all the reviews on the show page.     
To do that, let's go back to `app/views/movies/show.html.erb`
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
	          <%= link_to "Write a Review", new_movie_review_path(@movie) %>
	        </div>
	      </div>
	      <div class="col-md-7 col-md-offset-1">
	        <h1 class="review_title"><%= @movie.title %></h1>
	        <p><%= @movie.description %></p>

	        <% if @reviews.blank? %>
	          <h3>No reviews just yet, would you like to add the first!</h3>
	          <%= link_to "Write Review", new_movie_review_path(@movie), class: "btn btn-danger" %>
	        <% else %>
	          <% @reviews.each do |review| %>
	            <div class="reviews">
	              <p><%= review.rating %></p>
	              <p><%= review.comment %></p>
	            </div>
	          <% end %>
	        <% end %>
	      </div>
	    </div>
	  </div>
	</div>

	<%= link_to 'Edit', edit_movie_path(@movie) %> |
	<%= link_to 'Back', movies_path %>
```

In `app/controllers/movies_controller.rb`
```ruby
def show
	@reviews = Review.where(movie_id: @movie.id).order("created_at DESC")
end
```

# Rating Star
So the next thing we need to do is convert the rating to stars. To do that, we're going to the `Raty.js`.       
https://github.com/wbotelhos/raty       
http://www.dglives.com/demo/A%20Star%20Rating%20Plugin/        

Let's download the raty file and then we need to put that in our `app/assets/javascripts`.
In `app/assets/javascripts/jquery.raty.js`
```js
/*!
 * jQuery Raty - A Star Rating Plugin
 *
 * The MIT License
 *
 * @author  : Washington Botelho
 * @doc     : http://wbotelhos.com/raty
 * @version : 2.7.0
 *
 */

;
(function($) {
  'use strict';

  var methods = {
    init: function(options) {
      return this.each(function() {
        this.self = $(this);

        methods.destroy.call(this.self);

        this.opt = $.extend(true, {}, $.fn.raty.defaults, options);

        methods._adjustCallback.call(this);
        methods._adjustNumber.call(this);
        methods._adjustHints.call(this);

        this.opt.score = methods._adjustedScore.call(this, this.opt.score);

        if (this.opt.starType !== 'img') {
          methods._adjustStarType.call(this);
        }

        methods._adjustPath.call(this);
        methods._createStars.call(this);

        if (this.opt.cancel) {
          methods._createCancel.call(this);
        }

        if (this.opt.precision) {
          methods._adjustPrecision.call(this);
        }

        methods._createScore.call(this);
        methods._apply.call(this, this.opt.score);
        methods._setTitle.call(this, this.opt.score);
        methods._target.call(this, this.opt.score);

        if (this.opt.readOnly) {
          methods._lock.call(this);
        } else {
          this.style.cursor = 'pointer';

          methods._binds.call(this);
        }
      });
    },

    _adjustCallback: function() {
      var options = ['number', 'readOnly', 'score', 'scoreName', 'target'];

      for (var i = 0; i < options.length; i++) {
        if (typeof this.opt[options[i]] === 'function') {
          this.opt[options[i]] = this.opt[options[i]].call(this);
        }
      }
    },

    _adjustedScore: function(score) {
      if (!score) {
        return score;
      }

      return methods._between(score, 0, this.opt.number);
    },

    _adjustHints: function() {
      if (!this.opt.hints) {
        this.opt.hints = [];
      }

      if (!this.opt.halfShow && !this.opt.half) {
        return;
      }

      var steps = this.opt.precision ? 10 : 2;

      for (var i = 0; i < this.opt.number; i++) {
        var group = this.opt.hints[i];

        if (Object.prototype.toString.call(group) !== '[object Array]') {
          group = [group];
        }

        this.opt.hints[i] = [];

        for (var j = 0; j < steps; j++) {
          var
            hint = group[j],
            last = group[group.length - 1];

          if (last === undefined) {
            last = null;
          }

          this.opt.hints[i][j] = hint === undefined ? last : hint;
        }
      }
    },

    _adjustNumber: function() {
      this.opt.number = methods._between(this.opt.number, 1, this.opt.numberMax);
    },

    _adjustPath: function() {
      this.opt.path = this.opt.path || '';

      if (this.opt.path && this.opt.path.charAt(this.opt.path.length - 1) !== '/') {
        this.opt.path += '/';
      }
    },

    _adjustPrecision: function() {
      this.opt.half = true;
    },

    _adjustStarType: function() {
      var replaces = ['cancelOff', 'cancelOn', 'starHalf', 'starOff', 'starOn'];

      this.opt.path = '';

      for (var i = 0; i < replaces.length; i++) {
        this.opt[replaces[i]] = this.opt[replaces[i]].replace('.', '-');
      }
    },

    _apply: function(score) {
      methods._fill.call(this, score);

      if (score) {
        if (score > 0) {
          this.score.val(score);
        }

        methods._roundStars.call(this, score);
      }
    },

    _between: function(value, min, max) {
      return Math.min(Math.max(parseFloat(value), min), max);
    },

    _binds: function() {
      if (this.cancel) {
        methods._bindOverCancel.call(this);
        methods._bindClickCancel.call(this);
        methods._bindOutCancel.call(this);
      }

      methods._bindOver.call(this);
      methods._bindClick.call(this);
      methods._bindOut.call(this);
    },

    _bindClick: function() {
      var that = this;

      that.stars.on('click.raty', function(evt) {
        var
          execute = true,
          score   = (that.opt.half || that.opt.precision) ? that.self.data('score') : (this.alt || $(this).data('alt'));

        if (that.opt.click) {
          execute = that.opt.click.call(that, +score, evt);
        }

        if (execute || execute === undefined) {
          if (that.opt.half && !that.opt.precision) {
            score = methods._roundHalfScore.call(that, score);
          }

          methods._apply.call(that, score);
        }
      });
    },

    _bindClickCancel: function() {
      var that = this;

      that.cancel.on('click.raty', function(evt) {
        that.score.removeAttr('value');

        if (that.opt.click) {
          that.opt.click.call(that, null, evt);
        }
      });
    },

    _bindOut: function() {
      var that = this;

      that.self.on('mouseleave.raty', function(evt) {
        var score = +that.score.val() || undefined;

        methods._apply.call(that, score);
        methods._target.call(that, score, evt);
        methods._resetTitle.call(that);

        if (that.opt.mouseout) {
          that.opt.mouseout.call(that, score, evt);
        }
      });
    },

    _bindOutCancel: function() {
      var that = this;

      that.cancel.on('mouseleave.raty', function(evt) {
        var icon = that.opt.cancelOff;

        if (that.opt.starType !== 'img') {
          icon = that.opt.cancelClass + ' ' + icon;
        }

        methods._setIcon.call(that, this, icon);

        if (that.opt.mouseout) {
          var score = +that.score.val() || undefined;

          that.opt.mouseout.call(that, score, evt);
        }
      });
    },

    _bindOver: function() {
      var that   = this,
          action = that.opt.half ? 'mousemove.raty' : 'mouseover.raty';

      that.stars.on(action, function(evt) {
        var score = methods._getScoreByPosition.call(that, evt, this);

        methods._fill.call(that, score);

        if (that.opt.half) {
          methods._roundStars.call(that, score, evt);
          methods._setTitle.call(that, score, evt);

          that.self.data('score', score);
        }

        methods._target.call(that, score, evt);

        if (that.opt.mouseover) {
          that.opt.mouseover.call(that, score, evt);
        }
      });
    },

    _bindOverCancel: function() {
      var that = this;

      that.cancel.on('mouseover.raty', function(evt) {
        var
          starOff = that.opt.path + that.opt.starOff,
          icon    = that.opt.cancelOn;

        if (that.opt.starType === 'img') {
          that.stars.attr('src', starOff);
        } else {
          icon = that.opt.cancelClass + ' ' + icon;

          that.stars.attr('class', starOff);
        }

        methods._setIcon.call(that, this, icon);
        methods._target.call(that, null, evt);

        if (that.opt.mouseover) {
          that.opt.mouseover.call(that, null);
        }
      });
    },

    _buildScoreField: function() {
      return $('<input />', { name: this.opt.scoreName, type: 'hidden' }).appendTo(this);
    },

    _createCancel: function() {
      var icon   = this.opt.path + this.opt.cancelOff,
          cancel = $('<' + this.opt.starType + ' />', { title: this.opt.cancelHint, 'class': this.opt.cancelClass });

      if (this.opt.starType === 'img') {
        cancel.attr({ src: icon, alt: 'x' });
      } else {
        // TODO: use $.data
        cancel.attr('data-alt', 'x').addClass(icon);
      }

      if (this.opt.cancelPlace === 'left') {
        this.self.prepend('&#160;').prepend(cancel);
      } else {
        this.self.append('&#160;').append(cancel);
      }

      this.cancel = cancel;
    },

    _createScore: function() {
      var score = $(this.opt.targetScore);

      this.score = score.length ? score : methods._buildScoreField.call(this);
    },

    _createStars: function() {
      for (var i = 1; i <= this.opt.number; i++) {
        var
          name  = methods._nameForIndex.call(this, i),
          attrs = { alt: i, src: this.opt.path + this.opt[name] };

        if (this.opt.starType !== 'img') {
          attrs = { 'data-alt': i, 'class': attrs.src }; // TODO: use $.data.
        }

        attrs.title = methods._getHint.call(this, i);

        $('<' + this.opt.starType + ' />', attrs).appendTo(this);

        if (this.opt.space) {
          this.self.append(i < this.opt.number ? '&#160;' : '');
        }
      }

      this.stars = this.self.children(this.opt.starType);
    },

    _error: function(message) {
      $(this).text(message);

      $.error(message);
    },

    _fill: function(score) {
      var hash = 0;

      for (var i = 1; i <= this.stars.length; i++) {
        var
          icon,
          star   = this.stars[i - 1],
          turnOn = methods._turnOn.call(this, i, score);

        if (this.opt.iconRange && this.opt.iconRange.length > hash) {
          var irange = this.opt.iconRange[hash];

          icon = methods._getRangeIcon.call(this, irange, turnOn);

          if (i <= irange.range) {
            methods._setIcon.call(this, star, icon);
          }

          if (i === irange.range) {
            hash++;
          }
        } else {
          icon = this.opt[turnOn ? 'starOn' : 'starOff'];

          methods._setIcon.call(this, star, icon);
        }
      }
    },

    _getFirstDecimal: function(number) {
      var
        decimal = number.toString().split('.')[1],
        result  = 0;

      if (decimal) {
        result = parseInt(decimal.charAt(0), 10);

        if (decimal.slice(1, 5) === '9999') {
          result++;
        }
      }

      return result;
    },

    _getRangeIcon: function(irange, turnOn) {
      return turnOn ? irange.on || this.opt.starOn : irange.off || this.opt.starOff;
    },

    _getScoreByPosition: function(evt, icon) {
      var score = parseInt(icon.alt || icon.getAttribute('data-alt'), 10);

      if (this.opt.half) {
        var
          size    = methods._getWidth.call(this),
          percent = parseFloat((evt.pageX - $(icon).offset().left) / size);

        score = score - 1 + percent;
      }

      return score;
    },

    _getHint: function(score, evt) {
      if (score !== 0 && !score) {
        return this.opt.noRatedMsg;
      }

      var
        decimal = methods._getFirstDecimal.call(this, score),
        integer = Math.ceil(score),
        group   = this.opt.hints[(integer || 1) - 1],
        hint    = group,
        set     = !evt || this.move;

      if (this.opt.precision) {
        if (set) {
          decimal = decimal === 0 ? 9 : decimal - 1;
        }

        hint = group[decimal];
      } else if (this.opt.halfShow || this.opt.half) {
        decimal = set && decimal === 0 ? 1 : decimal > 5 ? 1 : 0;

        hint = group[decimal];
      }

      return hint === '' ? '' : hint || score;
    },

    _getWidth: function() {
      var width = this.stars[0].width || parseFloat(this.stars.eq(0).css('font-size'));

      if (!width) {
        methods._error.call(this, 'Could not get the icon width!');
      }

      return width;
    },

    _lock: function() {
      var hint = methods._getHint.call(this, this.score.val());

      this.style.cursor = '';
      this.title        = hint;

      this.score.prop('readonly', true);
      this.stars.prop('title', hint);

      if (this.cancel) {
        this.cancel.hide();
      }

      this.self.data('readonly', true);
    },

    _nameForIndex: function(i) {
      return this.opt.score && this.opt.score >= i ? 'starOn' : 'starOff';
    },

    _resetTitle: function(star) {
      for (var i = 0; i < this.opt.number; i++) {
        this.stars[i].title = methods._getHint.call(this, i + 1);
      }
    },

     _roundHalfScore: function(score) {
      var integer = parseInt(score, 10),
          decimal = methods._getFirstDecimal.call(this, score);

      if (decimal !== 0) {
        decimal = decimal > 5 ? 1 : 0.5;
      }

      return integer + decimal;
    },

    _roundStars: function(score, evt) {
      var
        decimal = (score % 1).toFixed(2),
        name    ;

      if (evt || this.move) {
        name = decimal > 0.5 ? 'starOn' : 'starHalf';
      } else if (decimal > this.opt.round.down) {               // Up:   [x.76 .. x.99]
        name = 'starOn';

        if (this.opt.halfShow && decimal < this.opt.round.up) { // Half: [x.26 .. x.75]
          name = 'starHalf';
        } else if (decimal < this.opt.round.full) {             // Down: [x.00 .. x.5]
          name = 'starOff';
        }
      }

      if (name) {
        var
          icon = this.opt[name],
          star = this.stars[Math.ceil(score) - 1];

        methods._setIcon.call(this, star, icon);
      }                                                         // Full down: [x.00 .. x.25]
    },

    _setIcon: function(star, icon) {
      star[this.opt.starType === 'img' ? 'src' : 'className'] = this.opt.path + icon;
    },

    _setTarget: function(target, score) {
      if (score) {
        score = this.opt.targetFormat.toString().replace('{score}', score);
      }

      if (target.is(':input')) {
        target.val(score);
      } else {
        target.html(score);
      }
    },

    _setTitle: function(score, evt) {
      if (score) {
        var
          integer = parseInt(Math.ceil(score), 10),
          star    = this.stars[integer - 1];

        star.title = methods._getHint.call(this, score, evt);
      }
    },

    _target: function(score, evt) {
      if (this.opt.target) {
        var target = $(this.opt.target);

        if (!target.length) {
          methods._error.call(this, 'Target selector invalid or missing!');
        }

        var mouseover = evt && evt.type === 'mouseover';

        if (score === undefined) {
          score = this.opt.targetText;
        } else if (score === null) {
          score = mouseover ? this.opt.cancelHint : this.opt.targetText;
        } else {
          if (this.opt.targetType === 'hint') {
            score = methods._getHint.call(this, score, evt);
          } else if (this.opt.precision) {
            score = parseFloat(score).toFixed(1);
          }

          var mousemove = evt && evt.type === 'mousemove';

          if (!mouseover && !mousemove && !this.opt.targetKeep) {
            score = this.opt.targetText;
          }
        }

        methods._setTarget.call(this, target, score);
      }
    },

    _turnOn: function(i, score) {
      return this.opt.single ? (i === score) : (i <= score);
    },

    _unlock: function() {
      this.style.cursor = 'pointer';
      this.removeAttribute('title');

      this.score.removeAttr('readonly');

      this.self.data('readonly', false);

      for (var i = 0; i < this.opt.number; i++) {
        this.stars[i].title = methods._getHint.call(this, i + 1);
      }

      if (this.cancel) {
        this.cancel.css('display', '');
      }
    },

    cancel: function(click) {
      return this.each(function() {
        var self = $(this);

        if (self.data('readonly') !== true) {
          methods[click ? 'click' : 'score'].call(self, null);

          this.score.removeAttr('value');
        }
      });
    },

    click: function(score) {
      return this.each(function() {
        if ($(this).data('readonly') !== true) {
          score = methods._adjustedScore.call(this, score);

          methods._apply.call(this, score);

          if (this.opt.click) {
            this.opt.click.call(this, score, $.Event('click'));
          }

          methods._target.call(this, score);
        }
      });
    },

    destroy: function() {
      return this.each(function() {
        var self = $(this),
            raw  = self.data('raw');

        if (raw) {
          self.off('.raty').empty().css({ cursor: raw.style.cursor }).removeData('readonly');
        } else {
          self.data('raw', self.clone()[0]);
        }
      });
    },

    getScore: function() {
      var score = [],
          value ;

      this.each(function() {
        value = this.score.val();

        score.push(value ? +value : undefined);
      });

      return (score.length > 1) ? score : score[0];
    },

    move: function(score) {
      return this.each(function() {
        var
          integer  = parseInt(score, 10),
          decimal  = methods._getFirstDecimal.call(this, score);

        if (integer >= this.opt.number) {
          integer = this.opt.number - 1;
          decimal = 10;
        }

        var
          width   = methods._getWidth.call(this),
          steps   = width / 10,
          star    = $(this.stars[integer]),
          percent = star.offset().left + steps * decimal,
          evt     = $.Event('mousemove', { pageX: percent });

        this.move = true;

        star.trigger(evt);

        this.move = false;
      });
    },

    readOnly: function(readonly) {
      return this.each(function() {
        var self = $(this);

        if (self.data('readonly') !== readonly) {
          if (readonly) {
            self.off('.raty').children('img').off('.raty');

            methods._lock.call(this);
          } else {
            methods._binds.call(this);
            methods._unlock.call(this);
          }

          self.data('readonly', readonly);
        }
      });
    },

    reload: function() {
      return methods.set.call(this, {});
    },

    score: function() {
      var self = $(this);

      return arguments.length ? methods.setScore.apply(self, arguments) : methods.getScore.call(self);
    },

    set: function(options) {
      return this.each(function() {
        $(this).raty($.extend({}, this.opt, options));
      });
    },

    setScore: function(score) {
      return this.each(function() {
        if ($(this).data('readonly') !== true) {
          score = methods._adjustedScore.call(this, score);

          methods._apply.call(this, score);
          methods._target.call(this, score);
        }
      });
    }
  };

  $.fn.raty = function(method) {
    if (methods[method]) {
      return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
    } else if (typeof method === 'object' || !method) {
      return methods.init.apply(this, arguments);
    } else {
      $.error('Method ' + method + ' does not exist!');
    }
  };

  $.fn.raty.defaults = {
    cancel       : false,
    cancelClass  : 'raty-cancel',
    cancelHint   : 'Cancel this rating!',
    cancelOff    : 'cancel-off.png',
    cancelOn     : 'cancel-on.png',
    cancelPlace  : 'left',
    click        : undefined,
    half         : false,
    halfShow     : true,
    hints        : ['bad', 'poor', 'regular', 'good', 'gorgeous'],
    iconRange    : undefined,
    mouseout     : undefined,
    mouseover    : undefined,
    noRatedMsg   : 'Not rated yet!',
    number       : 5,
    numberMax    : 20,
    path         : undefined,
    precision    : false,
    readOnly     : false,
    round        : { down: 0.25, full: 0.6, up: 0.76 },
    score        : undefined,
    scoreName    : 'score',
    single       : false,
    space        : true,
    starHalf     : 'star-half.png',
    starOff      : 'star-off.png',
    starOn       : 'star-on.png',
    starType     : 'img',
    target       : undefined,
    targetFormat : '{score}',
    targetKeep   : false,
    targetScore  : undefined,
    targetText   : '',
    targetType   : 'hint'
  };

})(jQuery);
```

Add add star image `star-half.png`, `star-off.png`, and `star-on.png` to the `app/assets/images/`


Let's go to `app/views/movies/show.html.erb`, we change `<p><%= review.rating %></p>` to `<div class="star-rating" data-score= <%= review.rating %> ></div>`, and add some `script` at the bottom.
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
	          <%= link_to "Write a Review", new_movie_review_path(@movie) %>
	        </div>
	      </div>
	      <div class="col-md-7 col-md-offset-1">
	        <h1 class="review_title"><%= @movie.title %></h1>
	        <p><%= @movie.description %></p>

	        <% if @reviews.blank? %>
	          <h3>No reviews just yet, would you like to add the first!</h3>
	          <%= link_to "Write Review", new_movie_review_path(@movie), class: "btn btn-danger" %>
	        <% else %>
	          <% @reviews.each do |review| %>
	            <div class="reviews">
	              <div class="star-rating" data-score= <%= review.rating %> ></div>
	              <p><%= review.comment %></p>
	            </div>
	          <% end %>
	        <% end %>
	      </div>
	    </div>
	  </div>
	</div>

	<%= link_to 'Edit', edit_movie_path(@movie) %> |
	<%= link_to 'Back', movies_path %>

	<script>
	    $('.star-rating').raty({
	      path: '/assets/',
	      readOnly: true,
	      score: function() {
	            return $(this).attr('data-score');
	    }
	  });
	</script>
```

![image](https://github.com/TimingJL/movie_review/blob/master/pic/star.jpeg)


Instead of having our users manually type in on a one to five their score. We want them to be able to just select theme stars they want.        
To do that, let's go to our `app/views/reviews/_form.html.erb`         
we're gonna replace:
```html

  <div class="field">
    <%= f.label :rating %>
    <%= f.number_field :rating %>
  </div>
```
to

```html

  <div class="field">
    <div id="star-rating"></div>
  </div>
```

And we need to add another script file.
```js

	<script>
	  $('#star-rating').raty({
	    path: '/assets/',
	    scoreName: 'review[rating]'
	  });
	</script>
```
So this is grabbing the star rating give heading to the path, and the score name is allowing us to take what's in this `div` and save it as the review rating.
![image](https://github.com/TimingJL/movie_review/blob/master/pic/new_review_star.jpeg)

One last thing I wnat to do is I want to add a average review for this movie based on all the reivews.      
To do that, lets' go into our controller.    
In `app/controllers/movies_controller.rb`  
```ruby
  def show
    @reviews = Review.where(movie_id: @movie.id).order("created_at DESC")

    if @reviews.blank?
      @avg_review = 0
    else
      @avg_review = @reviews.average(:rating).round(2)
    end
  end
```

Next, we want to show the average review under the picture.        
In `app/views/movies/show.html.erb`
```html

	<div class="panel panel-default">
	  <div class="panel-body">
	    <div class="row">
	      <div class="col-md-4">
	        <%= image_tag @movie.image.url(:medium) %>
	        <div class="star-rating" data-score= <%= @avg_review %> ></div>
	        <em><%= "#{@reviews.length} reviews" %></em>
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
	          <%= link_to "Write a Review", new_movie_review_path(@movie) %>
	        </div>
	      </div>
	      <div class="col-md-7 col-md-offset-1">
	        <h1 class="review_title"><%= @movie.title %></h1>
	        <p><%= @movie.description %></p>

	        <% if @reviews.blank? %>
	          <h3>No reviews just yet, would you like to add the first!</h3>
	          <%= link_to "Write Review", new_movie_review_path(@movie), class: "btn btn-danger" %>
	        <% else %>
	          <% @reviews.each do |review| %>
	            <div class="reviews">
	              <div class="star-rating" data-score= <%= review.rating %> ></div>
	              <p><%= review.comment %></p>
	            </div>
	          <% end %>
	        <% end %>
	      </div>
	    </div>
	  </div>
	</div>

	<%= link_to 'Edit', edit_movie_path(@movie) %> |
	<%= link_to 'Back', movies_path %>

	<script>
	    $('.star-rating').raty({
	      path: '/assets/',
	      readOnly: true,
	      score: function() {
	            return $(this).attr('data-score');
	    }
	  });
	</script>
```
![image](https://github.com/TimingJL/movie_review/blob/master/pic/avg_review.jpeg)




So the last and final thing we want to do for this application is add the ability to search.     
We're going to use a gem called `searchkick`. You'll see intelligent search make easy.      
https://github.com/ankane/searchkick      

### How To Install and Configure Elasticsearch on Ubuntu 16.04
https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-elasticsearch-on-ubuntu-16-04       

After installing and loading Elasticsearch, You go to `http://localhost:9200/`, it should print out:
![image](https://github.com/TimingJL/movie_review/blob/master/pic/load_elasticsearch.jpeg)
That will confirm that is installed correctly.


Then we need to add the line `searchkick` to our movie's model.       
In `app/models/movie.rb`
```ruby
class Movie < ApplicationRecord
	searchkick
	belongs_to :user
	has_many :reviews

	has_attached_file :image, styles: { medium: "400x600#" }, default_url: "/images/:style/missing.png"
  	validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/
end
```

Next, we need to load `reindex` all of the movies from our database.
```console
$ rake searchkick:reindex CLASS=Movie
```

Next, we need to add a route for our search.          
In `config/routes.rb`
```ruby
Rails.application.routes.draw do  
  devise_for :users

  resources :movies do
  	collection do
  		get 'search'
  	end
  	resources :reviews, except: [:show, :index]
  end

  root 'movies#index'
end
```

The next thing we need to do is convert our static search form to embedded Ruby.
In `app/views/layouts/_header.html.erb`
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
	      <%= form_tag search_movies_path, method: :get, class: "navbar-form navbar-right", role: "search" do %>
	        <p>
	          <%= text_field_tag :search, params[:search], class: "form-control" %>
	          <%= submit_tag "Search", name: nil, class: "btn btn-default" %>
	        </p>
	      <% end %>
	    </div><!-- /.navbar-collapse -->
	  </div><!-- /.container-fluid -->
	</nav>
```

Now, we need to add a search method within our controller.       
In `app/controllers/movies_controller.rb`
```ruby
  def search
    if params[:search].present?
      @movies = Movie.search(params[:search])
    else
      @movies = Movie.all
    end
  end
```
So if the search form is legt blank, the application would just display all of the movies in our database.

The final step is creating a view for our search form. So under `app/views/movies/`, let's create a new file named `search.html.erb`.          
In `app/views/movies/search.html.erb`
```html

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

Note: Isolation Problems(Result window is too large)
```
  Movie Search (49.2ms)  curl http://localhost:9200/movies_development/_search?pretty -d '{"query":{"dis_max":{"queries":[{"match":{"_all":{"query":"Hulk","operator":"and","boost":10,"analyzer":"searchkick_search"}}},{"match":{"_all":{"query":"Hulk","operator":"and","boost":10,"analyzer":"searchkick_search2"}}},{"match":{"_all":{"query":"Hulk","operator":"and","boost":1,"fuzziness":1,"max_expansions":3,"analyzer":"searchkick_search"}}},{"match":{"_all":{"query":"Hulk","operator":"and","boost":1,"fuzziness":1,"max_expansions":3,"analyzer":"searchkick_search2"}}}]}},"size":100000,"from":0,"fields":[]}'
Elasticsearch::Transport::Transport::Errors::InternalServerError: [500] {"error":{"root_cause":[{"type":"query_phase_execution_exception","reason":"Result window is too large, from + size must be less than or equal to: [10000] but was [100000]. See the scroll api for a more efficient way to request large data sets. This limit can be set by changing the [index.max_result_window] index level parameter."}],"type":"search_phase_execution_exception","reason":"all shards failed","phase":"query","grouped":true,"failed_shards":[{"shard":0,"index":"movies_development_20160803223651347","node":"45PhBgMFQfW1xhnMcSQ7xw","reason":{"type":"query_phase_execution_exception","reason":"Result window is too large, from + size must be less than or equal to: [10000] but was [100000]. See the scroll api for a more efficient way to request large data sets. This limit can be set by changing the [index.max_result_window] index level parameter."}}]},"status":500}
```

Solution:         
```console
$ sudo vim /etc/elasticsearch/elasticsearch.yml
```
And add `index.max_result_window: 500000` at the bottom.     
Then restart the elasticsearch service.
```console
$ sudo systemctl restart elasticsearch
```


To be continued...