#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

echo "Enter your username:"
read USERNAME

USER=$($PSQL "SELECT best_game, games_played FROM users WHERE username = '$USERNAME';")
#if user does not exist
if [[ -z $USER ]]
then
  #add user to database
  ADD_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
else
  echo "$USER" | while read BEST BAR PLAYED
  do
    echo -e "Welcome back, $USERNAME! You have played $PLAYED games, and your best game took $BEST guesses."
  done
fi

SECRET_NUMBER=$(($RANDOM % 1000 + 1))

echo -e "Guess the secret number between 1 and 1000:"
read GUESS
NUMBER_OF_GUESSES=1
while [[ $GUESS -ne $SECRET_NUMBER ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  else
    echo "It's lower than that, guess again:"
  fi
  read GUESS
  ((NUMBER_OF_GUESSES++))
done

echo "$USER" | while read BEST BAR PLAYED
do
  UPDATE_GAMES_PLAYED_RESULT=$($PSQL "UPDATE users SET games_played = ($PLAYED + 1) WHERE username = '$USERNAME';")
  if [[ -z $BEST || $BEST -gt $NUMBER_OF_GUESSES ]]
  then
    UPDATE_BEST_RESULT=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME';")
  fi
done

echo -e "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
