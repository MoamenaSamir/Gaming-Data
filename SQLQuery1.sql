/*Create a database and import tables into it*/
CREATE DATABASE Gaming_Analysis;

/*Modify the data and delete the extra column*/
USE Gaming_Analysis
ALTER TABLE Pd DROP COLUMN Column1;
ALTER TABLE Pd ADD CONSTRAINT P_ID PRIMARY KEY(P_ID);
ALTER TABLE Pd ALTER COLUMN L1_Status VARCHAR(30);
ALTER TABLE Pd ALTER COLUMN L2_Status VARCHAR(30);
ALTER TABLE Ld DROP COLUMN Column1;


/*1) Extract P_ID, Dev_ID, PName and Difficulty_level of all players at level 0*/
USE Gaming_Analysis

SELECT
      Ld.P_ID,
	  Ld.Dev_ID,
	  Pd.PName,
	  Ld.Difficulty
FROM
      Ld INNER JOIN Pd ON (Ld.P_ID = Pd.P_ID)
WHERE
	  Level = 0;
	  
/*2)Find Level1_code wise Avg_Kill_Count where lives_earned is 2 and at least 3 stages are crossed*/
USE Gaming_Analysis
SELECT
      Pd.L1_Code,
	  AVG(Kill_Count) AS avg_kill_count
FROM
      Ld INNER JOIN Pd ON (Ld.P_ID = Pd.P_ID)
WHERE
      Lives_Earned = 2 AND
	  Stages_crossed >= 3
GROUP BY
      L1_Code;

/*3)Find the total number of stages crossed at each diffuculty level where for Level2 with players use zm_series devices. Arrange the result in decsreasing order of total number of stages crossed*/
USE Gaming_Analysis
SELECT
      SUM(Stages_crossed) AS total_stages_crossed,
	  Difficulty
FROM
     Ld
WHERE
     Level = 2 AND
	 Dev_ID like 'zm%'
GROUP BY 
     Difficulty
ORDER BY 
     total_stages_crossed DESC;

/*4)Extract P_ID and the total number of unique dates for those players who have played games on multiple days*/
USE Gaming_Analysis
SELECT
      P_ID,
	  COUNT(DISTINCT Start_datetime) AS unique_dates
FROM
     Ld
GROUP BY 
     P_ID
HAVING
     COUNT(DISTINCT Start_datetime) > 1;

/*5)Find P_ID and level wise sum of kill_counts where kill_count is greater than avg kill count for the Medium difficulty*/
USE Gaming_Analysis
SELECT
      P_ID,
	  Level,
	  SUM(Kill_Count) AS total_kill_count
FROM
      Ld
WHERE
      Kill_Count > (SELECT AVG(Kill_Count) FROM Ld WHERE Difficulty = 'Medium')
GROUP BY 
      P_ID,
	  Level;

/*6)Find Level and its corresponding Level code wise sum of lives earned excluding level 0. Arrange in asecending order of level*/
USE Gaming_Analysis
SELECT
      Level,
	  COALESCE (L1_Code, L2_Code) AS Level_code,
	  SUM(Lives_Earned) AS total_lives_earned
FROM
      Ld INNER JOIN Pd ON (Ld.P_ID = Pd.P_ID)

WHERE
      Level <> 0 
GROUP BY
      Level,
	  L1_Code,
	  L2_Code
ORDER BY 
      Level ASC;

/*7)Find Top 3 score based on each dev_id and Rank them in increasing order using Row_Number. Display difficulty as well*/
USE Gaming_Analysis
SELECT
      TOP 3 (Score),
	  Dev_ID,
	  ROW_NUMBER() OVER(PARTITION BY Dev_ID ORDER BY Score) AS rownumber,
	  Difficulty
FROM
      Ld
GROUP BY 
      Dev_ID,
	  Score,
	  Difficulty;

/*8)Find first_login datetime for each device id*/
USE Gaming_Analysis
SELECT
      MIN(Start_datetime) AS first_login_datetime,
	  Dev_ID
FROM
      Ld
GROUP BY 
      Dev_ID;

/*9)Find Top 5 score based on each difficulty level and Rank them in increasing order using Rank. Display dev_id as well*/
USE Gaming_Analysis
SELECT
      TOP 5 (Score),
	  Difficulty,
	  Dev_ID,
	  RANK() OVER(PARTITION BY Dev_id ORDER BY Score) AS 'Rank'
FROM
      Ld;

/*10)Find the device ID that is first logged in(based on start_datetime) for each player(p_id). Output should contain player id, device id and first login datetime*/
USE Gaming_Analysis
SELECT
      P_ID,
	  Dev_ID,
	  MIN(Start_datetime) AS first_login_datetime
FROM
      Ld
GROUP BY
      P_ID,
	  Dev_ID;

/*11)For each player and date, how many kill_count played so far by the player. That is, the total number of games played by the player until that date.*/
-- a) window function--
USE Gaming_Analysis
SELECT
      P_ID,
	  CAST(Start_datetime AS date) AS 'Date',
	  SUM(Kill_Count) OVER(PARTITION BY P_ID ORDER BY Start_datetime) AS total_kill_count
FROM
      Ld;

-- b) without window function.
USE Gaming_Analysis
SELECT 
      P_ID, 
	  CAST(Start_datetime AS date) AS 'Date', 
	  (SELECT SUM(Kill_Count) FROM Ld ld2 WHERE ld2.P_ID = Ld.P_ID AND ld2.Start_datetime <= Ld.Start_datetime) AS total_kill_count 
FROM 
      Ld;

/*12)Find the cumulative sum of an stages crossed over a start_datetime for each player id but exclude the most recent start_datetime*/

USE Gaming_Analysis
SELECT
       P_ID,
	   Start_Datetime,
       SUM(Stages_crossed) OVER(PARTITION BY P_ID ORDER BY Start_Datetime ASC) AS cumulative_sum_of_stages_crossed
FROM
       Ld;

/*13)Extract the top 3 highest sums of scores for each `Dev_ID` and the corresponding `P_ID`*/
USE Gaming_Analysis
SELECT
       TOP 3 SUM(Score) AS highest_scores,
	   P_ID,
	   Dev_ID
FROM 
       Ld
GROUP BY 
       P_ID,
	   Dev_ID
ORDER BY 
       SUM(Score) DESC;

/*14)Find players who scored more than 50% of the average score, scored by the sum of scores for each `P_ID`*/
USE Gaming_Analysis
SELECT 
      P_ID,
      SUM(Score) AS total_scores
FROM
      Ld
GROUP BY 
      P_ID
HAVING
      SUM(Score) > 0.5*(SELECT AVG(Score) FROM Ld);

/*15)Create a stored procedure to find the top `n` `headshots_count` based on each `Dev_ID`and rank them in increasing order using `Row_Number`. Display the difficulty as well*/
CREATE PROCEDURE top_n_headshots_count 
                @n INT 
AS 
BEGIN
SELECT
      Dev_ID,
      headshots_count,
      difficulty,
      ROW_NUMBER() OVER (PARTITION BY Dev_ID ORDER BY headshots_count) AS Row_Number
FROM
     Ld
ORDER BY
  Dev_ID, 
  Row_Number
OFFSET
  0 ROWS
FETCH NEXT
  @n ROWS ONLY;
END

EXEC	[dbo].[top_n_headshots_count] @n = 4;

/*16)Create a function to return sum of Score for a given player_id*/
CREATE FUNCTION Total_Score
(
    @player_id AS INT
)
RETURNS INT
AS
BEGIN
    DECLARE @total_score AS INT;

    SELECT @total_score = SUM(Score)
    FROM Ld
    WHERE P_ID = @player_id;

    RETURN @total_score;
END;

SELECT dbo.Total_Score (644) AS Total_Score;
