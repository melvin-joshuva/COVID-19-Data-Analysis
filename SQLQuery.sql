SELECT *FROM PortfolioP_Project.dbo.CovidDeaths$
ORDER BY 3,4

--SELECT *FROM PortfolioP_Project.dbo.CovidVaccinations$
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioP_Project.dbo.CovidDeaths$
ORDER BY 1,2

--FINDING TOTAL CASES AND TOTAL DEATHS
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS Total_deaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioP_Project.dbo.CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2


--DEATH RATE BASED ON THE COUNTRY
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioP_Project.dbo.CovidDeaths$
WHERE LOCATION LIKE '%states'
ORDER BY 1,2

--TOTAL CASE VS POPULATION
SELECT Location, date, total_cases, population, (total_cases/population) *100 AS CovidPerecentage
FROM PortfolioP_Project.dbo.CovidDeaths$
WHERE LOCATION LIKE '%states'
ORDER BY 1,2

--COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT location, population, MAX(total_cases) AS HighInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected 
FROM PortfolioP_Project.dbo.CovidDeaths$
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--WITH DATE
SELECT location, population, date, MAX(total_cases) AS HighInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected 
FROM PortfolioP_Project.dbo.CovidDeaths$
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC

--PEOPLE DIED IN PARTICULAR COUNTRY
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioP_Project.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--PEOPLE DIED IN EACH CONTINENT
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount2
FROM PortfolioP_Project.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount2 DESC
	
-- SUM OF NEW CASES IN EACH DATE
SELECT date, SUM(new_cases) 
FROM PortfolioP_Project.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- SUM OF NEW CASES AND NEW DEATHS IN EACH DATE
SELECT date, SUM(new_cases) AS TotalNewCases, SUM(CAST(new_deaths AS INT)) AS TotalDeath1, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioP_Project.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- TOTAL NEW CASES AND DEATH
SELECT SUM(new_cases) AS TotalNewCases, SUM(CAST(new_deaths AS INT)) AS TotalDeath1, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioP_Project.dbo.CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

--JOINING BOTH TABLES
SELECT *
FROM PortfolioP_Project.dbo.CovidDeaths$ dea
JOIN PortfolioP_Project.dbo.CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date

--POPULATION VS VACCINATIONS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioP_Project.dbo.CovidDeaths$ dea
JOIN PortfolioP_Project.dbo.CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--TOTAL NUMBER OF PEOPLE VACCINATED IN PARTICULAR LOCATION

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM PortfolioP_Project.dbo.CovidDeaths$ dea
JOIN PortfolioP_Project.dbo.CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--CTE FOR CALCULATING THE AVERAGE PEOPLE VACCINATED IN EACH COUNTRY

WITH popVvas(Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM PortfolioP_Project.dbo.CovidDeaths$ dea
JOIN PortfolioP_Project.dbo.CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM popVvas

--TEMP TABLE 

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM PortfolioP_Project.dbo.CovidDeaths$ dea
JOIN PortfolioP_Project.dbo.CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population) *100
FROM #PercentPopulationVaccinated


--VIEW 
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM PortfolioP_Project.dbo.CovidDeaths$ dea
JOIN PortfolioP_Project.dbo.CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *FROM PercentPopulationVaccinated
