require 'open-uri'
require 'json'

class WordsController < ApplicationController

  def game
    @start_time = Time.now
    @grid = ("A".."Z").to_a.sample(9)
  end

  def score
    @grid = JSON.parse(params[:grid])
    @attempt = params[:attempt]
    @end_time = Time.now.to_i
    @start_time = Time.parse(params[:start_time]).to_i
    @time_taken = @end_time - @start_time
    included?(@attempt, @grid)
    compute_score(@attempt, @time_taken)
    run_game(@attempt, @grid, @start_time, @end_time)
    score_and_message(@attempt, @grid, @time_taken)
  end

  private

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }

    score_and_message = score_and_message(attempt, grid, result[:time])
    result[:score] = score_and_message.first
    result[:message] = score_and_message.last

    result
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        @display = [score, "well done"]
      else
        @display = [0, "not an english word"]
      end
    else
      @display = [0, "not in the grid"]
    end
  end

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    return json['found']
  end




end
