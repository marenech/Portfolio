/*

Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT * 
FROM PortfolioProject..CovidDeaths1
WHERE continent is NOT NULL
ORDER BY 3,4


-- Select Data we are going to start with   

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths1
WHERE continent is NOT NULL 
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths * 1.0/total_cases)*100.0 AS DeathPercentage
FROM PortfolioProject..CovidDeaths1
WHERE location like '%states%'
WHERE continent is NOT NULL 
ORDER BY 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, population, total_cases, (total_cases * 1.0/population)*100.0 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths1
-- WHERE location like '%states%'
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases * 1.0/population))*100.0 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths1
-- WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths1
-- WHERE location like '%states%'
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths1
-- WHERE location like '%states%'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths * 1.0)/SUM(new_cases)*100.0 AS DeathPercentage
FROM PortfolioProject..CovidDeaths1
-- WHERE location like '%states%'
WHERE continent is NOT NULL 
GROUP BY date 
ORDER BY 1,2

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths * 1.0)/SUM(new_cases)*100.0 AS DeathPercentage
FROM PortfolioProject..CovidDeaths1
-- WHERE location like '%states%'
WHERE continent is NOT NULL 
-- GROUP BY date 
ORDER BY 1,2


-- Total Population vs Vaccinations
-- Shows percentage of Population that has received at least one Covid vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100.0
FROM PortfolioProject..CovidDeaths1 dea 
JOIN PortfolioProject..CovidVaccinations1 vac
    ON dea.location = vac.location 
    AND dea.date = vac.date 
WHERE dea.continent is NOT NULL 
ORDER BY 2,3


-- Using CTE to perform calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100.0
FROM PortfolioProject..CovidDeaths1 dea 
JOIN PortfolioProject..CovidVaccinations1 vac
    ON dea.location = vac.location 
    AND dea.date = vac.date 
WHERE dea.continent is NOT NULL 
--ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated * 1.0 /Population)*100.0
FROM PopvsVac


-- Using Temp Table to perform calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100.0
FROM PortfolioProject..CovidDeaths1 dea 
JOIN PortfolioProject..CovidVaccinations1 vac
    ON dea.location = vac.location 
    AND dea.date = vac.date 
--WHERE dea.continent is NOT NULL 
--ORDER BY 2,3

SELECT * , (RollingPeopleVaccinated * 1.0 /Population)*100.0
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100.0
FROM PortfolioProject..CovidDeaths1 dea 
JOIN PortfolioProject..CovidVaccinations1 vac
    ON dea.location = vac.location 
    AND dea.date = vac.date 
WHERE dea.continent is NOT NULL 

