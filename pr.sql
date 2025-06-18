-- Table: daily_activity

CREATE TABLE daily_activity_clean (
    Id BIGINT,
    ActivityDate DATE,
    TotalSteps INT,
    TotalDistance FLOAT,
    TrackerDistance FLOAT,
    LoggedActivitiesDistance FLOAT,
    VeryActiveDistance FLOAT,
    ModeratelyActiveDistance FLOAT,
    LightActiveDistance FLOAT,
    SedentaryActiveDistance FLOAT,
    VeryActiveMinutes INT,
    FairlyActiveMinutes INT,
    LightlyActiveMinutes INT,
    SedentaryMinutes INT,
    Calories INT
);

-- Table: sleep_data
CREATE TABLE sleep_data_clean (
    Id BIGINT,
    SleepDay DATE,
    TotalSleepRecords INT,
    TotalMinutesAsleep INT,
    TotalTimeInBed INT
);


INSERT INTO daily_activity_clean (
    Id,
    ActivityDate,
    TotalSteps,
    TotalDistance,
    TrackerDistance,
    LoggedActivitiesDistance,
    VeryActiveDistance,
    ModeratelyActiveDistance,
    LightActiveDistance,
    SedentaryActiveDistance,
    VeryActiveMinutes,
    FairlyActiveMinutes,
    LightlyActiveMinutes,
    SedentaryMinutes,
    Calories
)
SELECT 
    field1,
    field2,
    field3,
    field4,
    field5,
    field6,
    field7,
    field8,
    field9,
    field10,
    field11,
    field12,
    field13,
    field14,
    field15
FROM daily_activity;


INSERT INTO sleep_data_clean(
    Id,
    SleepDay,
    TotalSleepRecords,
    TotalMinutesAsleep,
    TotalTimeInBed 
)
SELECT 
    field1,
    field2,
    field3,
    field4,
    field5
FROM sleep_data;

DROP TABLE daily_activity;

ALTER TABLE daily_activity_clean RENAME TO daily_activity;


DROP TABLE sleep_data;

ALTER TABLE sleep_data_clean RENAME TO sleep_data;




-- View sample data
SELECT * FROM daily_activity LIMIT 10;
SELECT * FROM sleep_data LIMIT 10;

-- Count unique users
SELECT COUNT(DISTINCT Id) AS unique_users
FROM daily_activity;

-- Null or zero checks
SELECT COUNT(*) AS zero_step_days
FROM daily_activity
WHERE TotalSteps = 0;

SELECT COUNT(*) AS zero_sleep_days
FROM sleep_data
WHERE TotalMinutesAsleep = 0;

-- Data Cleaning
DELETE FROM daily_activity
WHERE TotalSteps = 0;

DELETE FROM sleep_data
WHERE TotalMinutesAsleep = 0;

-- Feature Engineering: Add weekday (SQLite)
SELECT 
    ActivityDate, 
    strftime('%w', ActivityDate) AS weekday_number,
    CASE strftime('%w', ActivityDate)
        WHEN '0' THEN 'Sunday'
        WHEN '1' THEN 'Monday'
        WHEN '2' THEN 'Tuesday'
        WHEN '3' THEN 'Wednesday'
        WHEN '4' THEN 'Thursday'
        WHEN '5' THEN 'Friday'
        WHEN '6' THEN 'Saturday'
    END AS weekday_name,
    TotalSteps
FROM daily_activity;

-- Join daily_activity and sleep_data
SELECT 
    a.Id,
    a.ActivityDate,
    a.TotalSteps,
    a.Calories,
    a.VeryActiveMinutes,
    s.TotalMinutesAsleep,
    s.TotalTimeInBed
FROM daily_activity a
JOIN sleep_data s
  ON a.Id = s.Id AND a.ActivityDate = s.SleepDay;

-- Summary statistics
SELECT 
    Id,
    ROUND(AVG(TotalSteps), 2) AS avg_steps,
    ROUND(AVG(Calories), 2) AS avg_calories
FROM daily_activity
GROUP BY Id;

SELECT 
    Id,
    ROUND(AVG(TotalMinutesAsleep), 2) AS avg_sleep
FROM sleep_data
GROUP BY Id;

-- Average steps per weekday
SELECT 
    CASE strftime('%w', ActivityDate)
        WHEN '0' THEN 'Sunday'
        WHEN '1' THEN 'Monday'
        WHEN '2' THEN 'Tuesday'
        WHEN '3' THEN 'Wednesday'
        WHEN '4' THEN 'Thursday'
        WHEN '5' THEN 'Friday'
        WHEN '6' THEN 'Saturday'
    END AS weekday_name,
    ROUND(AVG(TotalSteps), 2) AS avg_steps
FROM daily_activity
GROUP BY weekday_name;

-- Identify high-activity users
SELECT 
    Id,
    SUM(VeryActiveMinutes) AS total_active_minutes,
    ROUND(AVG(Calories), 2) AS avg_calories
FROM daily_activity
GROUP BY Id
ORDER BY total_active_minutes DESC
LIMIT 5;

SELECT Id, TotalSteps, Calories
FROM daily_activity
LIMIT 20;
