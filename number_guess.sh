#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_EXISTS=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM users INNER JOIN games USING(user_id) WHERE username='$USERNAME'")
BEST_GAME=$($PSQL "SELECT MIN(number_guesses) FROM users INNER JOIN games USING(user_id) WHERE username='$USERNAME'")

if [[ -z $USER_EXISTS ]]
then
  NEW_USER=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')") > /dev/null
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESS=0
echo -n "Guess the secret number between 1 and 1000:"

while true
do
  read PLAYER_INPUT
  if [[ ! $PLAYER_INPUT =~ ^[0-9]+$ ]]
  then
    echo -n "That is not an integer, guess again:"
  elif [[ $PLAYER_INPUT -gt $SECRET_NUMBER ]]
  then
    echo -n "It's lower than that, guess again:"
  elif [[ $PLAYER_INPUT -lt $SECRET_NUMBER ]]
  then
    echo -n "It's higher than that, guess again:"
  else
    GUESS=$(( GUESS + 1 ))
    break
  fi
done

echo "You guessed it in $GUESS tries. The secret number was $SECRET_NUMBER. Nice job!"

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
SAVE_GAME=$($PSQL "INSERT INTO games(user_id, number_generated, number_guesses) VALUES ($USER_ID, $SECRET_NUMBER, $GUESS)") > /dev/null