/*
Covid 19 Data Exploration 
Skills applied: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
SELECT*
FROM PortfolioProjects..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Select Data that will be needed

SELECT Location, date, total_cases, new_cases,total_deaths, population
FROM PortfolioProjects..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Looking at the total cases versus total deaths
-- The likelood of dying if you contract COVID in your country based on daily total COVID Cases And deaths
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths$
--WHERE location LIKE '%State%'
WHERE continent IS NOT NULL
ORDER BY DeathPercentage DESC

-- The likelood of dying if you contract COVID in your country based total COVID New Cases And deaths
SELECT location, SUM(new_cases) AS TotalNewCases, SUM(CAST(new_deaths AS INT)) AS TotalNewDeaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths$
-- WHERE location LIKE '%%'
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY DeathPercentage DESC

-- Looking at Total Cases Vs Population
-- Shows the daily percentage of infected individual per population
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentInfectedPopulation
FROM PortfolioProjects..CovidDeaths$
--WHERE location LIKE '%Kingdom%'
ORDER BY 1, 2


-- Looking at the countries with Highest Infection Rate compared to population

SELECT location, population, date, MAX(total_cases) AS HighestInfectioncount, MAX((total_cases/population))*100 AS PercentInfectedPopulation 
FROM PortfolioProjects..CovidDeaths$
--WHERE location LiKE '%Italy%'
WHERE continent IS NOT NULL
GROUP BY location, population, date
ORDER BY PercentInfectedPopulation Desc

SELECT location, population, MAX(total_cases) AS HighestInfectioncount, MAX((total_cases/population))*100 AS PercentInfectedPopulation 
FROM PortfolioProjects..CovidDeaths$
--WHERE location LiKE '%Italy%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentInfectedPopulation Desc

-- Countries with Highest Death Count per population

SELECT location, MAX(CAST(Total_deaths AS INT)) AS HighestDeathCount
FROM PortfolioProjects..CovidDeaths$
-- WHERE location LIKE '%%'
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY HighestDeathCount DESC

-- Total COVID Death across Locations (Countries)

SELECT location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths$
WHERE continent IS NOT NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Total COVID Deaths across Continent

SELECT location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths$
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International', 'High income','Upper middle income','Lower middle income','Low income')
GROUP BY location
ORDER BY TotalDeathCount DESC

--- Showing continent with highest death count per population

SELECT continent, MAX(CAST(Total_deaths AS INT)) AS HighestDeathCount
FROM PortfolioProjects..CovidDeaths$
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY HighestDeathCount DESC


-- GLOBAL NUMBERS COVID CASES AND DEATHS

SELECT SUM(new_cases) AS TotalNewCases, SUM(CAST(new_deaths AS INT)) AS TotalNewDeaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths$
-- WHERE location LIKE '%%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2 

--1. Daily number COVID Cases AND Deaths

SELECT date, SUM(new_cases) AS TotalNewCases, SUM(CAST(new_deaths AS INT)) AS TotalNewDeaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DailyDeathPercentage
FROM PortfolioProjects..CovidDeaths$
-- WHERE location LIKE '%%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Looking at Total population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
-- this newly created column RollingPeopleVaccinated cant be  for the next statemnt/we can create CTE or temp table
FROM PortfolioProjects..CovidDeaths$ AS dea
JOIN PortfolioProjects..CovidVaccinations$ AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE to perform Calculation on Partition By in previous query involving newly created column RollingPeopleVaccinated 

WITH PopVsVac(Continent,Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
AS -- number of columns in the CTE need to match the number of column in the statement below
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
-- this newly created column RollingPeopleVaccinated cant be  for the next statemnt/we can create CTE or temp table
FROM PortfolioProjects..CovidDeaths$ AS dea
JOIN PortfolioProjects..CovidVaccinations$ AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3
)
SELECT*, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
FROM PopVsVac


-- Using Temp Table to perform Calculation on Partition By in previous query involving newly created column RollingPeopleVaccinated 

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
-- this newly created column RollingPeopleVaccinated cant be  for the next statemnt/we can create CTE or temp table
FROM PortfolioProjects..CovidDeaths$ AS dea
JOIN PortfolioProjects..CovidVaccinations$ AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT*, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualization

--1. View vaccinated population per country in each continent

CREATE VIEW PopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
-- this newly created column RollingPeopleVaccinated cant be  for the next statemnt/we can create CTE or temp table
FROM PortfolioProjects..CovidDeaths$ AS dea
JOIN PortfolioProjects..CovidVaccinations$ AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

-- 2. View countries COVID deaths
CREATE VIEW CountriesDeathCount AS
SELECT location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths$
WHERE continent IS NOT NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
--ORDER BY TotalDeathCount DESC

--3.View Global COVID Numbers (New cases, deaths and mortality rate)

CREATE VIEW CovidGlobalNumbers AS 
SELECT SUM(new_cases) AS TotalNewCases, SUM(CAST(new_deaths AS INT)) AS TotalNewDeaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths$
-- WHERE location LIKE '%%'
WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY 1,2 

--4. View COVID Infection rate by country
CREATE VIEW CountriesInfectionNumbers AS
SELECT location, population, MAX(total_cases) AS HighestInfectioncount, MAX((total_cases/population))*100 AS PercentInfectedPopulation 
FROM PortfolioProjects..CovidDeaths$
--WHERE location LiKE '%Italy%'
WHERE continent IS NOT NULL
GROUP BY location, population
--ORDER BY PercentInfectedPopulation Desc

--5. View COVID deathcount per Continent

CREATE VIEW ContinentDeathCount AS
SELECT continent, MAX(CAST(Total_deaths AS INT)) AS HighestDeathCount
FROM PortfolioProjects..CovidDeaths$
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL 
GROUP BY continent
--ORDER BY HighestDeathCount DESC