
ALTER TABLE vct
RENAME COLUMN `K/D` TO kill_death;

ALTER TABLE vct
RENAME COLUMN `HS %` TO hs_percentage;

ALTER TABLE vct
RENAME COLUMN `Rounds Played` TO rounds_played;

ALTER TABLE vct
RENAME COLUMN `Rounds Win` TO rounds_won;

ALTER TABLE vct
RENAME COLUMN `Rounds Lose` TO rounds_lost;

CREATE TABLE vct2
LIKE vct;

INSERT vct2
SELECT *
FROM vct;

SELECT *
FROM vct2;

-- corrects spelling of South Korea
UPDATE vct2
SET Nationality = 'South Korea'
WHERE Nationality = 'South Corea';

-- check for dupliate players
SELECT player, COUNT(*) c
FROM vct2
GROUP BY player
HAVING c>1;

SELECT DISTINCT Nationality
FROM vct2;

SELECT *
FROM vct2
WHERE Nationality = 'International';

SELECT team, Nationality
FROM vct2;


SELECT team, player, AVG(kill_death) as average_kd
FROM vct2
GROUP BY team, player;

-- create CTE for average team kd
WITH avg_team_kd
AS
(
SELECT team, AVG(kill_death) as average_kd
FROM vct2
GROUP BY team
)
SELECT team, 
ROUND(average_kd, 2) as average_kd_2
FROM avg_team_kd
ORDER BY average_kd_2 DESC;

-- teams that have an average kd greater than 1
WITH avg_team_kd
AS
(
SELECT team, AVG(kill_death) as average_kd
FROM vct2
GROUP BY team
)
SELECT team, ROUND(average_kd, 2) as average_kd_2
FROM avg_team_kd
WHERE ROUND(average_kd, 2) > 1;

-- teams that have an average kd less than 1
WITH avg_team_kd
AS
(
SELECT team, AVG(kill_death) as average_kd
FROM vct2
GROUP BY team
)
SELECT team, ROUND(average_kd, 2) as average_kd_2
FROM avg_team_kd
WHERE ROUND(average_kd, 2) < 1;

SELECT player, team, kill_death
FROM vct2;

-- total player and team count
Select COUNT(player) AS total_player_count, COUNT(DISTINCT team) AS num_of_teams,
ROUND(COUNT(player)/COUNT(DISTINCT team), 0) AS players_per_team
FROM vct2;


SELECT DISTINCT(Nationality)
FROM vct2;

-- highest kd by role
SELECT MAX(kill_death), role
FROM vct2
GROUP BY role
ORDER BY role;

-- total kills per region
SELECT DISTINCT(Nationality), SUM(`Kill`) AS total_kills_by_region
FROM vct2
WHERE Nationality IS NOT NULL
GROUP BY Nationality
ORDER BY Nationality;


-- total amount of kills and death
SELECT SUM(`kill`) AS total_kills, SUM(`death`) AS total_deaths
FROM vct2;
    
SELECT *
FROM vct2;

DELETE 
FROM vct2
WHERE player IS NULL;

UPDATE vct2
SET KAST = (KAST/100);

UPDATE vct
SET KAST = TRIM(TRAILING '%' FROM KAST);

SELECT *
FROM vct2 t1
JOIN updated_prize_table t2 ON t1.player = t2.player;

-- updates prize money from updated_prize_money table into vct2
UPDATE vct2 t1 JOIN updated_prize_table t2 ON t1.player = t2.player
SET t1.updated_prize = t2.prize_money
WHERE t1.player = t2.player;

-- total money the winners of the event won
SELECT team, `rank`, SUM(updated_prize) AS money_won
FROM vct2
GROUP BY team, `rank`
HAVING `rank` = 1;

-- prize money won per team
SELECT team, SUM(updated_prize) AS prize_per_team
FROM vct2
GROUP BY team;

-- prize money won per team with rolling prize total
WITH rolling_total_prize AS
(
SELECT team, SUM(updated_prize) AS prize_per_team
FROM vct2
GROUP BY team
)
SELECT team, prize_per_team, SUM(prize_per_team) OVER(ORDER BY team) AS rolling_prize_total
FROM rolling_total_prize
ORDER BY rolling_prize_total;


-- MVP of the event
SELECT player, team, MAX(KAST) AS KAST
FROM vct2
GROUP BY team, player
ORDER BY MAX(KAST) desc
LIMIT 1;

SELECT player, kill_death, `role`,
CASE
WHEN kill_death > 1  THEN 'positive'
WHEN kill_death < 1  THEN 'negative'
ELSE 'neutral'
END AS kill_death_summary
FROM vct2
ORDER BY kill_death_summary desc;



