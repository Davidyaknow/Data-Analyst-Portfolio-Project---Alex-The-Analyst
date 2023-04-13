select * from [Portfolio Project]..CovidDeaths$
order by 3,4

select * from [Portfolio Project]..CovidVaccinations$
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths$
order by 1,2

-- Total Cases vs Total Deaths -- 

SELECT LOCATION, DATE, TOTAL_CASES, TOTAL_DEATHS, (CONVERT(FLOAT,TOTAL_DEATHS) / CONVERT(FLOAT,TOTAL_CASES))*100 AS DEATHPERCENTAGE
FROM [Portfolio Project]..CovidDeaths$
ORDER BY 1,2



SELECT LOCATION, DATE, TOTAL_CASES, TOTAL_DEATHS, (CONVERT(FLOAT,TOTAL_DEATHS) / CONVERT(FLOAT,TOTAL_CASES))*100 AS DEATHPERCENTAGE
FROM [Portfolio Project]..CovidDeaths$
WHERE LOCATION LIKE '%STATES%'
ORDER BY 1,2

-- TOTAL CASES VS POPULATION

SELECT LOCATION, DATE, TOTAL_CASES, POPULATION, (CONVERT(FLOAT,TOTAL_CASES) / CONVERT(FLOAT,POPULATION))*100 AS POPULATIONPERCENTAGE
FROM [Portfolio Project]..CovidDeaths$
WHERE LOCATION LIKE '%STATES%'
ORDER BY 1,2

-- COUNTRIES WITH THE HIGHEST INFECTION RATES COMPARED TO POPULATION

SELECT LOCATION, MAX(TOTAL_CASES) AS HIGHEST_INFECTION_RATE, POPULATION, (CONVERT(FLOAT,MAX(TOTAL_CASES)) / CONVERT(FLOAT,POPULATION))*100 AS POPULATIONPERCENTAGEINFECTED
FROM [Portfolio Project]..CovidDeaths$
GROUP BY LOCATION, POPULATION
ORDER BY POPULATIONPERCENTAGEINFECTED DESC

-- COUNTRIES WITH THE HIGHEST MORTALITY RATE

SELECT LOCATION, CONVERT(FLOAT, MAX(total_deaths)) AS HIGHEST_MORTALITY_RATE
FROM [Portfolio Project]..CovidDeaths$
GROUP BY LOCATION
ORDER BY HIGHEST_MORTALITY_RATE DESC


SELECT LOCATION, CONVERT(FLOAT, MAX(total_deaths)) AS HIGHEST_MORTALITY_RATE
FROM [Portfolio Project]..CovidDeaths$
WHERE CONTINENT IS NULL
GROUP BY LOCATION
ORDER BY HIGHEST_MORTALITY_RATE DESC

-- HIGHEST MORTALITY RATE BY CONTINENT
SELECT CONTINENT, CONVERT(FLOAT, MAX(total_deaths)) AS HIGHEST_MORTALITY_RATE
FROM [Portfolio Project]..CovidDeaths$
WHERE CONTINENT IS NOT NULL
GROUP BY CONTINENT
ORDER BY HIGHEST_MORTALITY_RATE DESC

-- GLOBAL NUMBERS

SELECT DATE, TOTAL_CASES, TOTAL_DEATHS, (CONVERT(FLOAT,TOTAL_DEATHS)/CONVERT(FLOAT,TOTAL_CASES)) * 100 AS DEATHPERCENTAGE
FROM [Portfolio Project]..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

-- NEW CASES

SELECT DATE, SUM(NEW_CASES)
FROM [Portfolio Project]..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY DATE
ORDER BY 1,2


-- NEW CASES AND DEATHS

SELECT DATE, SUM(NEW_CASES) AS NEW_CASES, CONVERT(FLOAT, SUM(NEW_DEATHS)) AS [NEW DEATHS]
FROM [Portfolio Project]..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY DATE
ORDER BY 1,2

-- COMBINING THE 2 DATABASES

select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
from [Portfolio Project]..CovidDeaths$ death
join [Portfolio Project]..CovidVaccinations$ vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null
order by 2,3

-- ROLLING COUNT USING PARTITION BY

select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, SUM(CONVERT(FLOAT,vaccine.new_vaccinations)) 
OVER (PARTITION BY DEATH.LOCATION ORDER BY DEATH.LOCATION, DEATH.DATE) AS [ROLLING VACCINATION COUNT]
from [Portfolio Project]..CovidDeaths$ death
join [Portfolio Project]..CovidVaccinations$ vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null
order by 2,3

-- USING CTE TO FIND % OF POPULATION VACCINATED

WITH POPVSVAC (CONTINENT, LOCATION, DATE, POPULATION, NEW_VACCINATIONS, ROLLINGVACCINATIONCOUNT)
AS
(
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, SUM(CONVERT(FLOAT,vaccine.new_vaccinations)) 
OVER (PARTITION BY DEATH.LOCATION ORDER BY DEATH.LOCATION, DEATH.DATE) AS [ROLLING VACCINATION COUNT]
from [Portfolio Project]..CovidDeaths$ death
join [Portfolio Project]..CovidVaccinations$ vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null

--order by 2,3
)
SELECT *, (ROLLINGVACCINATIONCOUNT/POPULATION)*100 AS [PERCENTAGEVACCINATED]
FROM POPVSVAC

-- TEMP TABLE

DROP TABLE IF EXISTS #PERCENTPOPULATIONVACCINATED
CREATE TABLE #PERCENTPOPULATIONVACCINATED
(
Continent nvarchar(255),
Location nvarchar (255),
Date Datetime,
Population Numeric,
New_Vaccination Numeric,
RollingPeopleVaccinated Numeric
)

INSERT INTO #PERCENTPOPULATIONVACCINATED

select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, SUM(CONVERT(FLOAT,vaccine.new_vaccinations)) 
OVER (PARTITION BY DEATH.LOCATION ORDER BY DEATH.LOCATION, DEATH.DATE) AS [ROLLING VACCINATION COUNT]
from [Portfolio Project]..CovidDeaths$ death
join [Portfolio Project]..CovidVaccinations$ vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null

SELECT *, ([RollingPeopleVaccinated]/POPULATION)*100 AS [PERCENTAGEVACCINATED]

FROM #PERCENTPOPULATIONVACCINATED;

-- CREATING VIEWS FOR FUTURE DATA VISUALIZATIONS

SELECT CONTINENT, MAX(CONVERT(FLOAT,TOTAL_DEATHS)) AS [TOTAL DEATH COUNT]
FROM [Portfolio Project]..CovidDeaths$
WHERE CONTINENT IS NOT NULL
GROUP BY continent 
ORDER BY [TOTAL DEATH COUNT] DESC;

CREATE VIEW PERCENTPOUPLATIONVACCINATED AS
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, SUM(CONVERT(FLOAT,vaccine.new_vaccinations)) 
OVER (PARTITION BY DEATH.LOCATION ORDER BY DEATH.LOCATION, DEATH.DATE) AS [ROLLING VACCINATION COUNT]
from [Portfolio Project]..CovidDeaths$ death
join [Portfolio Project]..CovidVaccinations$ vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null


SELECT *
FROM PERCENTPOUPLATIONVACCINATED