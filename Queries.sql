------------------Query Crete View
CREATE VIEW View_Countries_Last_Cases AS
SELECT ps.*,
	cov.weekly_count as qtd_cases_last_week,
    	cov.rate_14_day
FROM countries ps 
LEFT JOIN (
SELECT country,
weekly_count,
rate_14_day
FROM covid_data
WHERE year_week = '2023-40'
AND indicator = 'cases') cov 
ON ps.country = cov.country


------------------Question 1
SELECT country,
	indicator,
	year_week,
	weekly_count, 
	population,
	weekly_count/(population*0.00001) as rate	
FROM covid_data
WHERE year_week = '2020-31' AND indicator = 'cases'
AND country <> 'EU/EEA (total)'
ORDER BY weekly_count/(population*0.00001) DESC
LIMIT 1;

------------------Question 2
SELECT	country,
	indicator,
	year_week,
	weekly_count, 
	population,
	weekly_count/(population*0.00001) as rate	
FROM covid_data
WHERE year_week = '2020-31' AND indicator = 'cases'
AND country <> 'EU/EEA (total)'
ORDER BY weekly_count/(population*0.00001)
LIMIT 10;

------------------Question 3
--Adjust of country name
UPDATE countries
SET country = REPLACE(country, 'Czech Republic ', 'Czechia');

-- Top 20 richest countries -> 10 high number of cases
	SELECT * FROM 
(SELECT cov.country,
MAX(cov.cumulative_count) as total_cases,
ps.gdp	
FROM covid_data cov
LEFT JOIN countries ps
ON RTRIM(cov.country) = RTRIM(ps.country)
WHERE cov.indicator = 'cases'
AND cov.country <> 'EU/EEA (total)'
GROUP BY cov.country, ps.gdp
ORDER BY ps.gdp DESC
LIMIT 20) n
ORDER BY n.total_cases DESC;


------------------Question 4
--Considering that 31/07/2020 is the 31 week of the year
WITH question_4 as (
SELECT cov.country,
	ps.country,
	RTRIM(ps.region) as region,
	ps.population,
	ps.population/1000000 as pop_per_million,
	ps.area,
	cov.weekly_count	
FROM covid_data cov
LEFT JOIN countries ps
ON RTRIM(cov.country) = RTRIM(ps.country)
WHERE cov.indicator = 'cases'
AND cov.year_week = '2020-31'
AND cov.country <> 'EU/EEA (total)')

SELECT region,
	SUM(weekly_count)/SUM(pop_per_million) AS cases_per_million,
	SUM(population)/SUM(area) AS pop_density
FROM question_4
GROUP BY region;



------------------Question 5

--Validating table question_4
SELECT country, count(*) as count
FROM question_4
GROUP BY country
HAVING count(*) > 1;


--Each year has 52 weeks. The database has data from 2020,2021,2022 and 2023 -> so 197 weeks analized
SELECT country,
indicator,
count(*) as count
FROM covid_data
GROUP BY country, indicator
HAVING count(*) <> 197

------------------Enrich the information
--CREATE VIEW CASES AND TEST:
CREATE VIEW View_Cases_Testing AS
SELECT cov.country,
cov.population,
cov.indicator,
cov.year_week,
cov.rate_14_day,
cov.cumulative_count,
test.new_cases,
test.tests_done,
test.testing_rate,
test.positivity_rate
FROM covid_data cov
LEFT JOIN test_covid test
ON cov.country = test.country 
AND cov.year_week=test.year_week
WHERE indicator = 'cases';

--THEN QUERY:
SELECT country,
population, 
sum(new_cases) as total_cases,
sum(tests_done) as total_tests,
sum(testing_rate) as testing_rate,
sum(new_cases)/population*0.000001 as cases_rate,
sum(positivity_rate) as positivity_rate
FROM view_cases_testing
WHERE country <> 'EU/EEA (total)'
GROUP BY country, population
--ORDER BY sum(new_cases)/population*0.000001 DESC
ORDER BY sum(testing_rate) DESC

