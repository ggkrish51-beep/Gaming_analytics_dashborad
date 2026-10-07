-- GAMING ANALYTICS | SQL portfolio queries | MySQL 8+
Drop database gaming_analytics;
create database gaming_analytics;
USE gaming_analytics;

-- 1. Table row counts
SELECT 'DimGame' table_name, COUNT(*) total_rows FROM DimGame UNION ALL
SELECT 'DimPlatform', COUNT(*) FROM DimPlatform UNION ALL SELECT 'DimRegion', COUNT(*) FROM DimRegion UNION ALL
SELECT 'DimDate', COUNT(*) FROM DimDate UNION ALL SELECT 'FactPerformance', COUNT(*) FROM FactPerformance UNION ALL
SELECT 'FactReviews', COUNT(*) FROM FactReviews;

-- 2. KPI overview (aligns with Power BI)
SELECT ROUND(SUM(Revenue_USD_M),2) AS total_revenue_usd_m,
       SUM(Downloads) AS total_downloads, SUM(Active_Users) AS total_active_users,
       COUNT(DISTINCT Game_Key) AS games_covered
FROM FactPerformance;

-- 3. Revenue and downloads by game
SELECT g.Game_Name, g.Genre, ROUND(SUM(f.Revenue_USD_M),2) revenue_usd_m,
       SUM(f.Downloads) downloads, SUM(f.Active_Users) active_users
FROM FactPerformance f JOIN DimGame g ON f.Game_Key=g.Game_Key
GROUP BY g.Game_Key,g.Game_Name,g.Genre ORDER BY revenue_usd_m DESC;

-- 4. Revenue by platform
SELECT p.Platform, ROUND(SUM(f.Revenue_USD_M),2) revenue_usd_m,
       SUM(f.Downloads) downloads
FROM FactPerformance f JOIN DimPlatform p ON f.Platform_ID=p.Platform_ID
GROUP BY p.Platform_ID,p.Platform ORDER BY revenue_usd_m DESC;

-- 5. Revenue by genre
SELECT g.Genre, ROUND(SUM(f.Revenue_USD_M),2) revenue_usd_m
FROM FactPerformance f JOIN DimGame g ON f.Game_Key=g.Game_Key
GROUP BY g.Genre ORDER BY revenue_usd_m DESC;

-- 6. Revenue by region
SELECT r.Region, ROUND(SUM(f.Revenue_USD_M),2) revenue_usd_m,
       SUM(f.Downloads) downloads
FROM FactPerformance f JOIN DimRegion r ON f.Region_ID=r.Region_ID
GROUP BY r.Region_ID,r.Region ORDER BY revenue_usd_m DESC;

-- 7. Monthly revenue trend
SELECT d.`Date`, d.`Year`, d.Month_Name, d.Quarter,
       ROUND(SUM(f.Revenue_USD_M),2) revenue_usd_m
FROM FactPerformance f JOIN DimDate d ON f.Date_ID=d.Date_ID
GROUP BY d.Date_ID,d.`Date`,d.`Year`,d.Month_No,d.Month_Name,d.Quarter
ORDER BY d.`Date`;

-- 8. Year-over-year revenue growth
WITH yearly AS (
 SELECT d.`Year`, SUM(f.Revenue_USD_M) revenue
 FROM FactPerformance f JOIN DimDate d ON f.Date_ID=d.Date_ID
 GROUP BY d.`Year`
)
SELECT `Year`, ROUND(revenue,2) revenue_usd_m,
       ROUND(LAG(revenue) OVER (ORDER BY `Year`),2) previous_year_revenue,
       ROUND(100*(revenue-LAG(revenue) OVER (ORDER BY `Year`)) /
             NULLIF(LAG(revenue) OVER (ORDER BY `Year`),0),2) yoy_growth_pct
FROM yearly ORDER BY `Year`;

-- 9. Average review score and total reviews by game
SELECT g.Game_Name, g.Genre, ROUND(AVG(r.Review_Score),2) avg_review_score,
       SUM(r.Review_Count) total_reviews
FROM FactReviews r JOIN DimGame g ON r.Game_Key=g.Game_Key
GROUP BY g.Game_Key,g.Game_Name,g.Genre ORDER BY total_reviews DESC;

-- 10. Review sentiment distribution
SELECT Sentiment, SUM(Review_Count) review_count,
       ROUND(100*SUM(Review_Count)/(SELECT SUM(Review_Count) FROM FactReviews),2) pct_reviews
FROM FactReviews GROUP BY Sentiment ORDER BY review_count DESC;

-- 11. Review score trend by year
SELECT d.`Year`, ROUND(AVG(r.Review_Score),2) avg_review_score,
       SUM(r.Review_Count) total_reviews
FROM FactReviews r JOIN DimDate d ON r.Date_ID=d.Date_ID
GROUP BY d.`Year` ORDER BY d.`Year`;

-- 12. Platform x genre performance
SELECT p.Platform,g.Genre,ROUND(SUM(f.Revenue_USD_M),2) revenue_usd_m,
       SUM(f.Downloads) downloads
FROM FactPerformance f JOIN DimPlatform p ON f.Platform_ID=p.Platform_ID
JOIN DimGame g ON f.Game_Key=g.Game_Key
GROUP BY p.Platform,g.Genre ORDER BY revenue_usd_m DESC;

-- 13. Revenue vs downloads (one row per game)
SELECT g.Game_Name,SUM(f.Downloads) downloads,
       ROUND(SUM(f.Revenue_USD_M),2) revenue_usd_m
FROM FactPerformance f JOIN DimGame g ON f.Game_Key=g.Game_Key
GROUP BY g.Game_Key,g.Game_Name ORDER BY downloads DESC;

-- 14. Data quality: duplicate primary keys (each query should return no rows)
SELECT Game_Key,COUNT(*) FROM DimGame GROUP BY Game_Key HAVING COUNT(*)>1;
SELECT Performance_ID,COUNT(*) FROM FactPerformance GROUP BY Performance_ID HAVING COUNT(*)>1;

-- 15. Data quality: orphan fact rows (each count should be zero)
SELECT COUNT(*) performance_missing_game FROM FactPerformance f LEFT JOIN DimGame g ON f.Game_Key=g.Game_Key WHERE g.Game_Key IS NULL;
SELECT COUNT(*) review_missing_game FROM FactReviews f LEFT JOIN DimGame g ON f.Game_Key=g.Game_Key WHERE g.Game_Key IS NULL;

-- 16. Create Power BI-friendly game summary view
CREATE OR REPLACE VIEW vw_game_performance AS
SELECT g.Game_Key,g.Game_Name,g.Genre,g.Release_Year,
       ROUND(SUM(f.Revenue_USD_M),2) revenue_usd_m,SUM(f.Downloads) downloads,
       SUM(f.Active_Users) active_users
FROM DimGame g LEFT JOIN FactPerformance f ON g.Game_Key=f.Game_Key
GROUP BY g.Game_Key,g.Game_Name,g.Genre,g.Release_Year;
SELECT * FROM vw_game_performance ORDER BY revenue_usd_m DESC;
