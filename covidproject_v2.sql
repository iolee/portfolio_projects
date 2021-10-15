
--SELECT *
--FROM portfolio_projects..covid_vaccinations
--ORDER BY 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolio_projects..covid_deaths
ORDER BY 1,2

--Looking at Total cases VS Total deaths
--Show likelihood of dying if contract covid in your country
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS death_percentage
FROM portfolio_projects..covid_deaths
WHERE continent is not null AND location like 'canada'
ORDER BY 1,2

--Looking at total cases vs population
--Shows what percentage of population got covid
SELECT location, date, total_cases, population,(total_cases/population)*100 AS infection_percentage
FROM portfolio_projects..covid_deaths
WHERE continent is not null AND location like 'canada'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT location,  population, MAX(total_cases) AS highest_infection_count, MAX( total_cases/population)*100 as highest_infection_percentage
FROM portfolio_projects..covid_deaths
WHERE continent is not null
GROUP BY location, population
ORDER BY 4 DESC

--Look countries with highest deaths count per popluation
SELECT location,MAX(CAST (total_deaths AS INT)) AS total_death_count
FROM portfolio_projects..covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY 2 DESC

--Break things down by continent
SELECT location,MAX(CAST (total_deaths AS INT)) AS total_death_count
FROM portfolio_projects..covid_deaths
WHERE continent is null
GROUP BY location
ORDER BY 2 DESC

--Continents with the highest death count per population
SELECT continent,MAX(CAST (total_deaths AS INT)) AS highest_death_count
FROM portfolio_projects..covid_deaths
WHERE continent is not null
GROUP BY continent
ORDER BY 2 DESC

--Global #
SELECT  SUM (new_cases) AS total_cases, SUM( CAST (new_deaths AS INT)) AS total_deaths
FROM  portfolio_projects..covid_deaths
WHERE continent is not null


--Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY 
	dea.location, dea.date) AS rolling_people_vaccinated
	
FROM portfolio_projects..covid_deaths dea
JOIN portfolio_projects..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Use CTE
WITH POPVSVAC (continent, location, date, population, new_vaccinations,rolling_people_vaccinated)
AS(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY 
	dea.location, dea.date) AS rolling_people_vaccinated
FROM portfolio_projects..covid_deaths dea
JOIN portfolio_projects..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

)
SELECT *, (rolling_people_vaccinated/population)*100
FROM POPVSVAC

--Temp table
DROP TABLE IF EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(
continent NVARCHAR (255),
location NVARCHAR (255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY 
	dea.location, dea.date) AS rolling_people_vaccinated
FROM portfolio_projects..covid_deaths dea
JOIN portfolio_projects..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (rolling_people_vaccinated/population)*100
FROM #percent_population_vaccinated

--Create view to store data for later visualization
CREATE VIEW highest_infection_percentage AS
SELECT location,  population, MAX(total_cases) AS highest_infection_count, MAX( total_cases/population)*100 as highest_infection_percentage
FROM portfolio_projects..covid_deaths
WHERE continent is not null
GROUP BY location, population


SELECT *
FROM highest_infection_percentage