CREATE TABLE covid_deaths AS
    SELECT
        C3 AS date,
        C2 AS location,
        C1 AS continent,
        C5 AS new_cases,
        C4 AS total_cases,
        C8 AS new_deaths,
        C7 AS total_deaths,
        C62 AS population
    FROM covid_data_raw;

CREATE TABLE covid_vax AS
    SELECT
        C3 AS date,
        C2 AS location,
        C1 AS continent,
        C5 AS new_cases,
        C4 AS total_cases,
        C38 AS new_vaccinated,
        C35 AS vaccinated,
        C37 AS boosted,
        C35 AS total_vaccinated,
        C62 AS population
    FROM covid_data_raw;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY 1, 2;

-- Looking at Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS mortality
FROM covid_deaths
ORDER BY 1, 2;

SELECT location, date, total_cases, population, (total_cases/population)*100 as contraction
FROM covid_deaths
WHERE location like '%states%'
ORDER BY 1, 2;

-- Looking at countries with high infection rates compared to population

SELECT location, population, MAX(total_cases) AS most_infected, (total_cases/population)*100 AS contraction
FROM covid_deaths
GROUP BY population, location
ORDER BY contraction desc;

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) AS Total_Death_Count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count desc;

-- Breaking down by continent

SELECT location, MAX(cast(total_deaths as int)) AS Total_Death_Count
FROM covid_deaths
WHERE continent IS NULL AND location NOT LIKE '%income%'
GROUP BY location
ORDER BY Total_Death_Count desc;

-- Finding global numbers (pretending World row doesn't exist)

SELECT date, SUM(new_cases), SUM(cast(new_deaths as int)),
       (SUM(new_deaths)/SUM(new_cases))*100 AS death_percent
FROM covid_deaths
GROUP BY date
ORDER BY 1, 2;

--Join Deaths with Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinated,
       SUM(vax.new_vaccinated) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
        AS total_vaxed-- Makes sure it only sums per locations
FROM covid_deaths dea
JOIN covid_vax vax
    ON dea.location = vax.location
    AND dea.date = vax.date
WHERE dea.location LIKE '%states%'
ORDER BY 2, 3;

-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinated, total_vaxed)
    AS (Select dea.continent,
               dea.location,
               dea.date,
               dea.population,
               vax.new_vaccinated,
               SUM(vax.new_vaccinated) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
                   AS total_vaxed-- Makes sure it only sums per locations
        FROM covid_deaths dea
                 JOIN covid_vax vax
                      ON dea.location = vax.location
                          AND dea.date = vax.date
        WHERE dea.location LIKE '%states%')

-- TEMP Table
CREATE TABLE PercentPopulationVaccinated -- specify columns
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_vaccinations numeric,
    Total_vaxxed numeric
)
INSERT INTO PercentPopulationVaccinated
Select dea.continent,
               dea.location,
               dea.date,
               dea.population,
               vax.new_vaccinated,
               SUM(vax.new_vaccinated) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
                   AS total_vaxed-- Makes sure it only sums per locations
        FROM covid_deaths dea
                 JOIN covid_vax vax
                      ON dea.location = vax.location
                          AND dea.date = vax.date
        WHERE dea.location LIKE '%states%'

SELECT *, (Total_vaxxed/Population)*100
FROM PercentPopulationVaccinated

-- Creating View to store data for later visualizations
-- Creates permanent table from query without having to extract

CREATE VIEW PercentPopulationVaccinated AS
    Select dea.continent,
               dea.location,
               dea.date,
               dea.population,
               vax.new_vaccinated,
               SUM(vax.new_vaccinated) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
                   AS total_vaxed-- Makes sure it only sums per locations
        FROM covid_deaths dea
                 JOIN covid_vax vax
                      ON dea.location = vax.location
                          AND dea.date = vax.date
        WHERE dea.location LIKE '%states%'