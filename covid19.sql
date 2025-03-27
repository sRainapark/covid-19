SELECT *
FROM covid_deaths
ORDER BY 3,4;

-- SELECT *
-- FROM covid_vaccinations
-- ORDER BY 3,4

-- select data to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY location, date;

-- look at total_cases vs total_deaths in the U.S.
-- show percent of people who died from having covid
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS percent_death
FROM covid_deaths
WHERE location LIKE '%States%'
ORDER BY location, date;

-- look at total_cases vs population. Show what percent of the population got covid
SELECT location, date, population, total_cases,(total_cases/population) * 100 AS percent_infected
FROM covid_deaths
ORDER BY location, date;

-- look at countries with highest infection rate overall compared to their population
SELECT location, population, MAX(total_cases) AS max_total_case, MAX((total_cases/population)) * 100 AS percent_infected
FROM covid_deaths
GROUP BY population, location
ORDER BY percent_infected DESC;

-- show countries with highest mortality overall
SELECT location, MAX(COALESCE(CAST(total_deaths AS FLOAT),0)) AS max_total_death
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY  location
ORDER BY max_total_death DESC;

-- highest mortality by continent
SELECT location, MAX(COALESCE(CAST(total_deaths AS FLOAT),0)) AS max_total_death
FROM covid_deaths
WHERE continent IS NULL
GROUP BY  location
ORDER BY max_total_death DESC;

-- CTE total population and vaccination
WITH pv (continent, location, date, population, new_vaccinations, rolling_vaccinated) AS 
(SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_vaccinated
FROM covid_deaths d
JOIN covid_vaccinations v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
)
SELECT *, rolling_vaccinated * 100 / population AS percent_vaccinated
FROM pv
;

DROP TABLE IF EXISTS percent_pop_vaccinated;
CREATE TABLE percent_pop_vaccinated
(
    continent  VARCHAR(255),
    location VARCHAR(255),
    date TIMESTAMP,
    population FLOAT,
    new_vaccinations FLOAT,
    rolling_vaccinated FLOAT
);
INSERT INTO percent_pop_vaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_vaccinated
FROM covid_deaths d
JOIN covid_vaccinations v
ON d.location = v.location AND d.date = v.date
;

SELECT *, rolling_vaccinated * 100 / population AS percent_vaccinated
FROM percent_pop_vaccinated
;

-- create view for later visualizations
CREATE VIEW percent_population_vaccinated AS 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_vaccinated
FROM covid_deaths d
JOIN covid_vaccinations v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL;

SELECT * FROM percent_population_vaccinated;

