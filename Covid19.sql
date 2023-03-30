SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccination$
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Total Cases Vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Philippines'
ORDER BY 1,2


--Total Cases vs Population

SELECT Location, date, population, total_cases,(total_cases/population)*100 AS CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Afghanistan'
ORDER BY 1,2

--Countries with Highest Infection Rate Compared to Population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 AS CasePercentage
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY 4 DESC

--Countries with Highest Death Count per Population
SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY Location
ORDER BY TotalDeathCount Desc

--By Continent


--Showing the continent with the highest death count per population
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount Desc



--Global numbers 

--Per Day
SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP By  date
ORDER BY 1,2

--Around the World 
SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--Another Dataset contatining Covid Vaccinations
SELECT *
FROM PortfolioProject..CovidVaccination


-- Joining the two tables by location and date
SELECT *
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccination vacc
	ON death.location = vacc.location
	AND death.date = vacc.date


-- Total Population vs Vaccinations
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(Cast(vacc.new_vaccinations as int)) OVER (PARTITION BY death.location ORDER BY death.location,
death.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccination vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(Cast(vacc.new_vaccinations as int)) OVER (PARTITION BY death.location ORDER BY death.location,
death.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccination vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE death.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(Cast(vacc.new_vaccinations as int)) OVER (PARTITION BY death.location ORDER BY death.location,
death.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccination vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
--WHERE death.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualization
USE PortfolioProject
GO
Create View PercentPopulationVaccinated as 
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(Cast(vacc.new_vaccinations as int)) OVER (PARTITION BY death.location ORDER BY death.location,
death.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccination vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE death.continent IS NOT NULL


SELECT *
FROM PercentPopulationVaccinated