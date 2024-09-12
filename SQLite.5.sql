SELECT * from FlightDelays;

--Compare Scheduled vs. Actual Departure Times
SELECT FL_NUM, ORIGIN, DEST, FL_DATE,
       CRS_DEP_TIME AS scheduled_dep_time,
       DEP_TIME AS actual_dep_time,
       (DEP_TIME - CRS_DEP_TIME) AS delay_minutes
FROM FlightDelays
WHERE (DEP_TIME - CRS_DEP_TIME) > 0
ORDER BY delay_minutes DESC;

-- Top 10 Routes with the Most Delays
SELECT origin, dest, COUNT(*) as total_flights,
       AVG(DEP_TIME - CRS_DEP_TIME) as avg_delay
from FlightDelays
where (DEP_TIME - CRS_DEP_TIME) > 0
GROUP by origin, dest
ORDER by avg_delay DESC
LIMIT 10;

-- Flight Delay Trends by Day of the Week
SELECT day_week, AVG (dep_time - crs_dep_time) as avg_delay
from FlightDelays
GROUP by day_week
ORDER by avg_delay desc;

--Compare Delays by Carrier
SELECT CARRIER, COUNT(*) AS total_flights,
       AVG(DEP_TIME - CRS_DEP_TIME) AS avg_delay
FROM FlightDelays
GROUP BY CARRIER
ORDER BY avg_delay DESC;

--Carrier On-Time Performance Over Time
SELECT carrier, fl_date,
AVG(CASE WHEN (dep_time - crs_dep_time) <= 0 then 1 ELSE 0 END) * 100 as on_time_percentage
from FlightDelays
GROUP by carrier, fl_date
ORDER by fl_date;

--Best and Worst Performing Airlines
SELECT CARRIER, COUNT(*) AS total_flights,
       SUM(CASE WHEN DEP_TIME - CRS_DEP_TIME <= 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS on_time_percentage
FROM FlightDelays
GROUP BY CARRIER
ORDER BY on_time_percentage DESC;

--Analyze the Impact of Weather on Delays
SELECT weather, avg(dep_time - crs_dep_time) as avg_delay, count(*) as total_flights
from FlightDelays
where weather is not NULL
group by weather
ORDER by avg_delay desc;

--Worst Weather Conditions for Flight Delays
SELECT weather, count (*) as delay_count
from FlightDelays
where dep_time - crs_dep_time > 0 and weather is not NULL
GROUP by weather
order by delay_count desc;

--Correlation Between Flight Distance and Delays
SELECT distance, avg(dep_time - crs_dep_time) as avg_delay
from FlightDelays
where (dep_time - crs_dep_time) > 0
GROUP by distance
order by distance desc;

-- Long-Distance vs. Short-Distance Delays
with distance_group as (
  SELECT case
             when distance < 500 then 'Short'
             when distance BETWEEN 500 and 1500 then 'Medium'
             ELSE 'Long'
        end as distance_category, dep_time - crs_dep_time as delay
  from FlightDelays
)
SELECT distance_category, avg(delay) as avg_delay
from distance_group
where delay > 0
group by distance_category
order by avg_delay desc;

SELECT DISTINCT flight_status
from FlightDelays;

--Delayed Flights vs. On-Time Flights
SELECT 'delayed' AS flight_status, COUNT(*) AS count_flt
FROM FlightDelays
WHERE "flight_status" = 'delayed'
UNION ALL
SELECT 'ontime' AS flight_status, COUNT(*)
FROM FlightDelays
WHERE "flight_status" = 'ontime';

--Impact of Flight Status on Delays
SELECT flight_status, AVG(DEP_TIME - CRS_DEP_TIME) AS avg_delay
FROM FlightDelays
WHERE DEP_TIME IS NOT NULL
GROUP BY flight_status
ORDER BY avg_delay DESC;

--Identify Flights with Repeated Delays by Tail Number
SELECT TAIL_NUM, COUNT(*) AS delay_count, AVG(DEP_TIME - CRS_DEP_TIME) AS avg_delay
FROM FlightDelays
WHERE (DEP_TIME - CRS_DEP_TIME) > 0
GROUP BY TAIL_NUM
HAVING COUNT(*) > 3
ORDER BY avg_delay DESC;

--Frequent Delays by Specific Aircraft (Tail Number)
SELECT TAIL_NUM, AVG(DEP_TIME - CRS_DEP_TIME) AS avg_delay, COUNT(*) AS total_flights
FROM FlightDelays
WHERE (DEP_TIME - CRS_DEP_TIME) > 0
GROUP BY TAIL_NUM
ORDER BY avg_delay DESC
LIMIT 10;

--Flight Delays by Day of the Month
SELECT DAY_OF_MONTH, AVG(DEP_TIME - CRS_DEP_TIME) AS avg_delay
FROM FlightDelays
GROUP BY DAY_OF_MONTH
ORDER BY avg_delay DESC;

--Most Delayed Day of the Week
SELECT DAY_WEEK, AVG(DEP_TIME - CRS_DEP_TIME) AS avg_delay
FROM FlightDelays
GROUP BY DAY_WEEK
ORDER BY avg_delay DESC;

-- Top 5 most popular flight routes
SELECT origin, dest, count(*) as flight_count
from FlightDelays
GROUP by origin, dest
ORDER by flight_count
LIMIT 5;

--Seasonal Flight Delays (By Month)
SELECT 
    CASE SUBSTR(FL_DATE, 1, INSTR(FL_DATE, '/') - 1)
        WHEN '1' THEN 'January'
        WHEN '2' THEN 'February'
        WHEN '3' THEN 'March'
        WHEN '4' THEN 'April'
        WHEN '5' THEN 'May'
        WHEN '6' THEN 'June'
        WHEN '7' THEN 'July'
        WHEN '8' THEN 'August'
        WHEN '9' THEN 'September'
        WHEN '10' THEN 'October'
        WHEN '11' THEN 'November'
        WHEN '12' THEN 'December'
    END AS month_name,
    AVG(DEP_TIME - CRS_DEP_TIME) AS avg_delay
FROM FlightDelays
WHERE DEP_TIME IS NOT NULL
GROUP BY month_name
ORDER BY SUBSTR(FL_DATE, 1, INSTR(FL_DATE, '/') - 1);