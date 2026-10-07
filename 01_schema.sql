-- GAMING ANALYTICS | MySQL 8+
CREATE DATABASE IF NOT EXISTS gaming_analytics;
USE gaming_analytics;

DROP TABLE IF EXISTS FactReviews;
DROP TABLE IF EXISTS FactPerformance;
DROP TABLE IF EXISTS DimDate;
DROP TABLE IF EXISTS DimRegion;
DROP TABLE IF EXISTS DimPlatform;
DROP TABLE IF EXISTS DimGame;

CREATE TABLE DimGame (
  Game_Key INT PRIMARY KEY,
  Game_Name VARCHAR(120) NOT NULL,
  Genre VARCHAR(80) NOT NULL,
  Release_Year SMALLINT
);
CREATE TABLE DimPlatform (
  Platform_ID VARCHAR(10) PRIMARY KEY,
  Platform VARCHAR(40) NOT NULL
);
CREATE TABLE DimRegion (
  Region_ID VARCHAR(10) PRIMARY KEY,
  Region VARCHAR(80) NOT NULL
);
CREATE TABLE DimDate (
  Date_ID INT PRIMARY KEY,
  `Date` DATE NOT NULL,
  `Year` SMALLINT NOT NULL,
  Month_No TINYINT NOT NULL,
  Month_Name VARCHAR(20) NOT NULL,
  Quarter VARCHAR(2) NOT NULL
);
CREATE TABLE FactPerformance (
  Performance_ID INT PRIMARY KEY,
  Game_Key INT NOT NULL,
  Platform_ID VARCHAR(10) NOT NULL,
  Region_ID VARCHAR(10) NOT NULL,
  Date_ID INT NOT NULL,
  `Year` SMALLINT NOT NULL,
  Revenue_USD_M DECIMAL(12,2) NOT NULL DEFAULT 0,
  Downloads BIGINT NOT NULL DEFAULT 0,
  Active_Users BIGINT NOT NULL DEFAULT 0);
  
CREATE TABLE FactReviews (
  Review_ID INT PRIMARY KEY,
  Game_Key INT NOT NULL,
  Platform_ID VARCHAR(10) NOT NULL,
  Date_ID INT NOT NULL,
  Review_Score DECIMAL(3,2) NOT NULL,
  Review_Count INT NOT NULL DEFAULT 0,
  Sentiment VARCHAR(20) NOT NULL
);


# 1 Total Revenue — KPI
USE gaming_analytics;

SELECT 
    ROUND(SUM(Revenue_USD_M), 2) AS Total_Revenue_Million_USD
FROM FactPerformance;

# 2 Total Downloads — KPI
SELECT 
    SUM(Downloads) AS Total_Downloads
FROM FactPerformance;

# 3 Total Games — KPI
SELECT 
    COUNT(*) AS Total_Games
FROM DimGame;

# 4 Total Active Users — KPI
SELECT 
    SUM(Active_Users) AS Total_Active_Users
FROM FactPerformance;

# 5 Total Revenue by Genre 
SELECT 
    g.Genre,
    ROUND(SUM(f.Revenue_USD_M), 2) AS Total_Revenue
FROM FactPerformance f
JOIN DimGame g 
    ON f.Game_Key = g.Game_Key
GROUP BY g.Genre
ORDER BY Total_Revenue DESC;

 # 6 Total Downloads by Platform 
 SELECT 
    p.Platform,
    SUM(f.Downloads) AS Total_Downloads
FROM FactPerformance f
JOIN DimPlatform p
    ON f.Platform_ID = p.Platform_ID
GROUP BY p.Platform
ORDER BY Total_Downloads DESC;

# 7 Revenue by Game 
SELECT 
    g.Game_Name,
    ROUND(SUM(f.Revenue_USD_M), 2) AS Total_Revenue
FROM FactPerformance f
JOIN DimGame g
    ON f.Game_Key = g.Game_Key
GROUP BY g.Game_Key, g.Game_Name
ORDER BY Total_Revenue DESC
LIMIT 6;

# 8 Total Revenue by Year 
SELECT 
    f.Year,
    ROUND(SUM(f.Revenue_USD_M), 2) AS Total_Revenue
FROM FactPerformance f
GROUP BY f.Year
ORDER BY f.Year;

 # 9 Total Downloads by Game 
 SELECT 
    g.Game_Name,
    SUM(f.Downloads) AS Total_Downloads
FROM FactPerformance f
JOIN DimGame g
    ON f.Game_Key = g.Game_Key
GROUP BY g.Game_Key, g.Game_Name
ORDER BY Total_Downloads DESC
LIMIT 6; 

#10 Total Revenue by Platform
SELECT 
    p.Platform,
    ROUND(SUM(f.Revenue_USD_M), 2) AS Total_Revenue
FROM FactPerformance f
JOIN DimPlatform p
    ON f.Platform_ID = p.Platform_ID
GROUP BY p.Platform_ID, p.Platform
ORDER BY Total_Revenue DESC;

# 11 Total Revenue by Region
SELECT 
    r.Region,
    ROUND(SUM(f.Revenue_USD_M), 2) AS Total_Revenue
FROM FactPerformance f
JOIN DimRegion r
    ON f.Region_ID = r.Region_ID
GROUP BY r.Region_ID, r.Region
ORDER BY Total_Revenue DESC;

# 12 Revenue vs Downloads 
SELECT 
    g.Game_Name,
    SUM(f.Downloads) AS Total_Downloads,
    ROUND(SUM(f.Revenue_USD_M), 2) AS Total_Revenue
FROM FactPerformance f
JOIN DimGame g
    ON f.Game_Key = g.Game_Key
GROUP BY g.Game_Key, g.Game_Name
ORDER BY Total_Downloads;

# 13 Average Review Score — KPI 
SELECT 
    ROUND(AVG(Review_Score), 2) AS Average_Review_Score
FROM FactReviews;

# 14 Total Revenue — KPI
SELECT 
    ROUND(SUM(Revenue_USD_M), 2) AS Total_Revenue
FROM FactPerformance;

# 15 Total Revenue by Sentiment — Donut Chart 

SELECT
    r.Sentiment,
    ROUND(SUM(f.Revenue_USD_M), 2) AS Total_Revenue
FROM
(
    SELECT DISTINCT
        Game_Key,
        Platform_ID,
        Date_ID,
        Sentiment
    FROM FactReviews
) r
JOIN FactPerformance f
    ON r.Game_Key = f.Game_Key
    AND r.Platform_ID = f.Platform_ID
    AND r.Date_ID = f.Date_ID
GROUP BY r.Sentiment
ORDER BY Total_Revenue DESC;

# 16 Average Review Score by Year 
SELECT
    d.Year,
    ROUND(AVG(r.Review_Score), 2) AS Average_Review_Score
FROM FactReviews r
JOIN DimDate d
    ON r.Date_ID = d.Date_ID
GROUP BY d.Year
ORDER BY d.Year;

# 17 Total Reviews by Game 
SELECT
    g.Game_Name,
    SUM(r.Review_Count) AS Total_Reviews
FROM FactReviews r
JOIN DimGame g
    ON r.Game_Key = g.Game_Key
GROUP BY g.Game_Key, g.Game_Name
ORDER BY Total_Reviews DESC;  

# 18 Game_Name — Slicer 
SELECT
    Game_Key,
    Game_Name
FROM DimGame
ORDER BY Game_Name;