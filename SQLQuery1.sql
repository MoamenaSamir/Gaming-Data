
--1)Extract `P_ID`, `Dev_ID`, `PName`, and `Difficulty_level` of all players at Level 0.

SELECT
       Ld.P_ID,
	   Dev_ID,
	   PName,
	   Difficulty,
	   Level
FROM
       Ld JOIN Pd ON (Ld.P_ID = Pd.P_ID)
WHERE 
       Level = 0;



--2)Find `Level1_code` wise average `Kill_Count` where `lives_earned` is 2, and at least 3 stages are crossed.

SELECT 
       L1_code, 
	   AVG(Kill_Count) AS Avg_Kill_Count
FROM 
       Ld JOIN Pd ON Ld.P_ID = Pd.P_ID
WHERE 
       lives_earned = 2
GROUP BY 
       L1_code
HAVING 
       COUNT (Stages_crossed) >= 3;



--3)Find the total number of stages crossed at each difficulty level for Level 2 with players using `zm_series` devices. Arrange the result in decreasing order of the total number of stages crossed.

SELECT 
       Difficulty, 
	   SUM(Stages_crossed) AS Total_Stages_Crossed
FROM 
       Ld
WHERE 
       Level = 2 AND Dev_ID LIKE 'zm%'
GROUP BY 
       Difficulty
ORDER BY  
       Total_Stages_Crossed DESC;



--4)Extract `P_ID` and the total number of unique dates for those players who have played games on multiple days.

SELECT 
       P_ID, 
	   COUNT(DISTINCT Start_Datetime) AS Total_Unique_Dates
FROM 
       Ld
GROUP BY 
       P_ID
HAVING
       COUNT(DISTINCT Start_Datetime) > 1;



--5)Find `P_ID` and levelwise sum of `kill_counts` where `kill_count` is greater than the average kill count for Medium difficulty.

SELECT 
       P_ID, 
	   Level, 
	   SUM(Kill_Count) AS Total_Kills
FROM 
       Ld
WHERE 
       Difficulty = 'Medium' AND 
	   kill_count > (SELECT AVG(kill_count) FROM Ld WHERE Difficulty = 'Medium')
GROUP BY 
       P_ID, 
	   Level;



--6)Find `Level` and its corresponding `Level_code`wise sum of lives earned, excluding Level 0. Arrange in ascending order of level.

SELECT 
       Level, 
	   L1_Code, 
	   SUM(Lives_Earned) AS TotalLivesEarned
FROM 
       Ld JOIN Pd ON (Ld.P_ID = Pd.P_ID)
WHERE 
       Level = 1
GROUP BY 
       Level, 
	   L1_Code
ORDER BY 
       Level ASC;
--
SELECT 
       Level, 
	   L2_Code, 
	   SUM(Lives_Earned) AS TotalLivesEarned
FROM 
       Ld JOIN Pd ON (Ld.P_ID = Pd.P_ID)
WHERE 
       Level = 2
GROUP BY 
       Level, 
	   L2_Code
ORDER BY 
       Level ASC;



--7)Find the top 3 scores based on each `Dev_ID` and rank them in increasing order using `Row_Number`. Display the difficulty as well.

SELECT
       TOP (3) Score,
	   Dev_ID,
	   Difficulty,
	   ROW_NUMBER() OVER (PARTITION BY Dev_ID ORDER BY Score) AS RowNumber
FROM
       Ld;



--8)Find the `first_login` datetime for each device ID.

SELECT
       Dev_ID,
	   MIN(Start_Datetime) AS First_Login
FROM
       Ld
GROUP BY
       Ld.Dev_ID;



--9)Find the top 5 scores based on each difficulty level and rank them in increasing order using `Rank`. Display `Dev_ID` as well.

SELECT
       TOP (5) Score,
	   Difficulty,
	   Dev_ID,
       RANK() OVER (PARTITION BY Difficulty ORDER BY Score) AS Rank
FROM
       Ld;



--10)Find the device ID that is first logged in (based on `start_datetime`) for each player (`P_ID`). Output should contain player ID, device ID, and first login datetime.

SELECT
       P_ID,
	   Dev_ID,
	   MIN(Start_Datetime) AS First_longin_datetime
FROM
       Ld
GROUP BY 
       Dev_ID,
	   P_ID;



--11)For each player and date, determine how many `kill_counts` were played by the player so far.
--a) Using window functions
--b) Without window functions

SELECT
      P_ID,
	  CAST(Start_Datetime AS date) AS Date,
	  SUM(Kill_Count) OVER(PARTITION BY P_ID ORDER BY Start_Datetime) AS Total_Kill_Count --Using window functions
FROM
       Ld;
--------------------------------
SELECT
      P_ID,
	  CAST(Start_Datetime AS date) AS Date,
	  SUM(Kill_Count) AS Total_Kill_Count
FROM
       Ld
GROUP BY 
       P_ID,
	   Start_Datetime
ORDER BY
       P_ID, Start_Datetime;



--12)Find the cumulative sum of stages crossed over `start_datetime` for each `P_ID`, excluding the most recent `start_datetime`.

SELECT
       P_ID,
	   Start_Datetime,
       SUM(Stages_crossed) OVER(PARTITION BY P_ID ORDER BY Start_Datetime ASC) AS Cumulative_Sum
FROM
       Ld;



--13)Extract the top 3 highest sums of scores for each `Dev_ID` and the corresponding `P_ID`.

SELECT
       TOP 3 SUM(Score) AS TOP_3,
	   P_ID,
	   Dev_ID
FROM 
       Ld
GROUP BY 
       P_ID,
	   Dev_ID
ORDER BY 
       SUM(Score) DESC;



--14)Find players who scored more than 50% of the average score, scored by the sum of scores for each `P_ID`.

SELECT
       P_ID,
       AVG(Score) AS Avg_Score
FROM
       Ld
GROUP BY
       P_ID
HAVING
       MIN(Score) > 0.5 * AVG(Score);
----
SELECT
      P_ID,
      SUM(Score) AS Total_Score
FROM
      Ld
GROUP BY
      P_ID
ORDER BY
      Total_Score;



--15)Create a stored procedure to find the top `n` `headshots_count` based on each `Dev_ID` and rank them in increasing order using `Row_Number`. Display the difficulty as well.

CREATE PROCEDURE dbo.spLd_GetTopHS 
                @n INT 
AS 
BEGIN
SELECT
      Dev_ID,
      headshots_count,
      difficulty,
     ROW_NUMBER() OVER (PARTITION BY Dev_ID ORDER BY headshots_count) AS Rank
FROM
     Ld
ORDER BY
  Dev_ID, 
  Rank
OFFSET
  0 ROWS
FETCH NEXT
  @n ROWS ONLY;
END

-------------
EXEC	[dbo].[spLd_GetTopHS] @n = 4;



--16)Create a function to return sum of Score for a given player_id.

CREATE FUNCTION dbo.GetTotalScore
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
SELECT dbo.GetTotalScore (644);
