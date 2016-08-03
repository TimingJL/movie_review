class AddMovieIdToReviews < ActiveRecord::Migration[5.0]
  def change
    add_column :reviews, :movie_id, :integer
  end
end
