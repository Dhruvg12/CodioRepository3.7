require 'sinatra/base'
require 'sinatra/flash'
require_relative 'lib/wordguesser_game'

class WordGuesserApp < Sinatra::Base
  enable :sessions
  register Sinatra::Flash

  set :host_authorization, { permitted_hosts: [] }  

  before do
    @game = session[:game] || WordGuesserGame.new('')
  end

  after do
    session[:game] = @game
  end

  # These two routes are good examples of Sinatra syntax
  # to help you with the rest of the assignment
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

# Use existing methods in WordGuesserGame to process a guess.
# If a guess is repeated, set flash[:message] = "You have already used that letter."
# If a guess is invalid,  set flash[:message] = "Invalid guess."
post '/guess' do
  @game = session[:game]
  halt 400, "No game" unless @game

  letter = params[:guess].to_s[0] # first character or nil->""
  begin
    used = !@game.guess(letter)   # guess returns false if already guessed
    if used
      flash[:message] = "You have already used that letter."
      flash[:notice]  = flash[:message] # keep if your view still checks :notice
    end
  rescue ArgumentError
    flash[:message] = "Invalid guess."
    flash[:notice]  = flash[:message]
  end

  redirect '/show'
end

# Every time a guess is made, we end up here.
# Decide if the player won/lost/keep playing.
get '/show' do
  @game = session[:game]
  halt 400, "No game" unless @game

  case @game.check_win_or_lose
  when :win  then redirect '/win'
  when :lose then redirect '/lose'
  else
    erb :show
  end
end

get '/win' do
  @game = session[:game]
  halt 400, "No game" unless @game
  erb :win
end

get '/lose' do
  @game = session[:game]
  halt 400, "No game" unless @game
  erb :lose
end

end
