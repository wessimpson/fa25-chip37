# app.rb
require 'sinatra/base'
require 'sinatra/flash'
require_relative 'lib/wordguesser_game'

class WordGuesserApp < Sinatra::Base
  enable :sessions
  register Sinatra::Flash

  # Allow Heroku host; you can loosen/tighten as you wish
  set :host_authorization, { permitted_hosts: ['.herokuapp.com', 'localhost', '127.0.0.1'] }

  before do
    @game = session[:game] || WordGuesserGame.new('')
  end

  after do
    session[:game] = @game
  end

  get '/' do
    redirect '/new'
  end

  get '/new' do
    erb :new
  end

  post '/create' do
    # NOTE: don't change next line - it's needed by autograder!
    word = params[:word] || WordGuesserGame.get_random_word
    # NOTE: don't change previous line - it's needed by autograder!

    @game = WordGuesserGame.new(word)
    redirect '/show'
  end

  # If a guess is repeated, flash[:message] = "You have already used that letter."
  # If a guess is invalid,  flash[:message] = "Invalid guess."
  post '/guess' do
    ch = params[:guess].to_s[0]   # mirror autograder behavior

    begin
      valid = @game.guess(ch)
      flash[:message] = "You have already used that letter." if valid == false
    rescue ArgumentError
      flash[:message] = "Invalid guess."
    end

    redirect '/show'
  end

  # Decide where to go after a guess
  get '/show' do
    case @game.check_win_or_lose
    when :win  then redirect '/win'
    when :lose then redirect '/lose'
    else
      # The show.erb template uses @game.word_with_guesses and @game.wrong_guesses
      erb :show
    end
  end

  get '/win' do
    erb :win
  end

  get '/lose' do
    erb :lose
  end
end
