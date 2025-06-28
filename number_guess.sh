#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read username

# Check if user exists
user_exists=$($PSQL "SELECT username FROM users WHERE username='$username'")

if [[ -z $user_exists ]]
then
  # New user
  echo "Welcome, $username! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username) VALUES('$username')" > /dev/null
else
  # Existing user
  games_played=$($PSQL "SELECT games_played FROM users WHERE username='$username'")
  best_game=$($PSQL "SELECT best_game FROM users WHERE username='$username'")
  echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
fi

# Generate random number
secret_number=$(( RANDOM % 1000 + 1 ))
guess_count=0

echo "Guess the secret number between 1 and 1000:"

while true
do
  read guess
  ((guess_count++))
  
  # Check if input is integer
  if [[ ! $guess =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  if [[ $guess -eq $secret_number ]]
  then
    echo "You guessed it in $guess_count tries. The secret number was $secret_number. Nice job!"
    
    # Update user stats
    current_best=$($PSQL "SELECT best_game FROM users WHERE username='$username'")
    if [[ -z $current_best ]] || [[ $guess_count -lt $current_best ]]
    then
      $PSQL "UPDATE users SET best_game=$guess_count WHERE username='$username'" > /dev/null
    fi
    $PSQL "UPDATE users SET games_played=games_played+1 WHERE username='$username'" > /dev/null
    break
  elif [[ $guess -gt $secret_number ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
done
