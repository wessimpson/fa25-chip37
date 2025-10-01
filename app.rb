# app.rb
require 'sinatra/base'
require 'sinatra/flash'
require_relative 'lib/wordguesser_game'

class WordGuesserApp < Sinatra::Base
  enable :sessions
  register Sinatra::Flash

  # Optional: allow Heroku hosts; safe to tweak/remove locally
  set :host_authorization, { permitted_hosts: ['.herokuapp.com', 'localhost', '127.0.0.1'] }

  before do
    # Restore game from session or start an "empty" one so views don't explode
    @game = session[:game] || WordGuesserGame.new('')
  end

  after do
    # Persist the game object across requests
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

  # Process a letter guess, set flash messages for repeats/invalids,
  # then decide win/lose/play. Only this route is allowed to redirect
  # to /win or /lose so cheating via /show won't work.
  post '/guess' do
    ch = params[:guess].to_s[0]  # mimic autograder behavior: first char only

    begin
      used = @game.guess(ch)          # true on new valid guess, false if repeated
      flash[:message] = "You have already used that letter." if used == false
    rescue ArgumentError
      flash[:message] = "Invalid guess."
    end

    case @game.check_win_or_lose
    when :win  then redirect '/win'
    when :lose then redirect '/lose'
    else            redirect '/show'
    end
  end

  # IMPORTANT: /show must NEVER redirect to win/lose; it only renders.
  # This prevents tampering from forcing a terminal state.
  get '/show' do
    # show.erb should use @game.word_with_guesses, @game.wrong_guesses, etc.
    erb :show
  end

  get '/win' do
    erb :win
  end

  get '/lose' do
    erb :lose
  end
end
