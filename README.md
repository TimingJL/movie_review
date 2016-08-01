# Learning by Doing 

![Ubuntu version](https://img.shields.io/badge/Ubuntu-16.04%20LTS-orange.svg)
![Rails version](https://img.shields.io/badge/Rails-v5.0.0-blue.svg)
![Ruby version](https://img.shields.io/badge/Ruby-v2.3.1p112-red.svg)

Mackenzie Child's video really inspired me. So I decided to follow all of his rails video tutorial to learn how to build a web app. Through the video, I would try to build the web app by my self and record the courses step by step in text to facilitate the review.


# Project 5: How To Build A Movie Review App With Rails

This week I built a movie rating and review application. We have a bunch of different movies and each movie has multiple review which is rated on a one to five star scale. And then another cool feature is we have the ability to search. The cool thing about this search gem that we are using is it's able to distinguish between correct spelling and misspelled or pluralization and all that. And obviouly we have the ability to sign-up/sign-in, and only sign-in users have the ability to write review.

https://mackenziechild.me/12-in-12/5/  



### Highlights of this course
1. Users
2. Reviews
3. Ratings
4. Search
5. HAML
6. Bootstrap


# Create The App
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