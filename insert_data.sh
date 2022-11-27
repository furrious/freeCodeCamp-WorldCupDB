#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
$($PSQL "CREATE TABLE teams (
team_id SERIAL PRIMARY KEY NOT NULL, 
name VARCHAR NOT NULL UNIQUE
)")

$($PSQL "CREATE TABLE games (
game_id SERIAL PRIMARY KEY NOT NULL,
year INT NOT NULL,
round VARCHAR NOT NULL,
winner_id SERIAL NOT NULL REFERENCES teams (team_id),
opponent_id SERIAL NOT NULL REFERENCES teams (team_id),
winner_goals INT NOT NULL,
opponent_goals INT NOT NULL
)")

cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do

# Populate 'teams' table with team names from 'winner' column into 'teams' table
	if [[ $WINNER != "winner" ]]
	then
	# Get team_id
		TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
	
	# If not found
		if [[ -z $TEAM_ID ]]
		then
			INSERT_NAME_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER')")
			if [[ $INSERT_NAME_RESULT == "INSERT 0 1" ]]
			then
				echo Inserted into teams: $WINNER
			fi
		fi
	fi

# Populate 'teams' table with remaining team names from 'opponent' column
	if [[ $OPPONENT != "opponent" ]]
	then
	# Get team_id
		TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
		
	# If not found
		if [[ -z $TEAM_ID ]]
		then
			INSERT_NAME_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')")
			if [[ $INSERT_NAME_RESULT == "INSERT 0 1" ]]
			then
				echo Inserted into teams: $OPPONENT
			fi
		fi
	fi	
done

cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
# Populate 'games' table with year, round, winner_id, opponent_id, winner goals, opponent goals
	if [[ $YEAR != "year" ]]
	then

	# Find winner_id
		WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
		
	# Find opponent_id
		OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")		

	# Insert data
		INSERT_GAMES_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
		if [[ $INSERT_GAMES_RESULT == "INSERT 0 1" ]]
		then
			echo Inserted into games: $YEAR, $ROUND, $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS
		fi
	fi

done