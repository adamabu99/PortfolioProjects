--All columns for covid vaccination

SELECT *
FROM [Portfolio Project]..covid_vacinnations
ORDER BY 3, 4

-- All columns for covid deaths

SELECT *
FROM [Portfolio Project]..covid_deaths
ORDER BY 3, 4

--Selecting a few columns 

SELECT date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..covid_deaths
ORDER BY 1, 2

--Looking at Total Cases vs Total Deaths
-- Shows likehood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
FROM [Portfolio Project]..covid_deaths
WHERE location like '%igeri%'
ORDER BY 1, 2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid


SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM [Portfolio Project]..covid_deaths
WHERE location like '%igeri%'
ORDER BY 1, 2

-- Looking at Countries with highest infection rate compared to population


SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))* 100 as PercentPopulationInfected
FROM [Portfolio Project]..covid_deaths
GROUP BY location, population
ORDER BY 4 DESC

--Showing then countries with Highest Death Count per Population


SELECT location, MAX(cast (total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT 
-- Showing the continents with the highest death count per population

SELECT continent, MAX(cast (total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..covid_deaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS


SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage
FROM [Portfolio Project]..covid_deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2


--Joining the two tables into 1
-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM [Portfolio Project]..covid_deaths dea
JOIN [Portfolio Project]..covid_vacinnations vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent is not null
ORDER BY 2, 3
-- Since you cannot divide RollingPeopleVaccinated with Population because you just created the column RollingPeopleVaccinated
-- You have to create a CTE or Temptable to solve this problem

--USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vacinnation, RollingPeopleVaccinated)
--The number of columns in the CTE has to be the same
AS
(
SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations, dea.population, SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM [Portfolio Project]..covid_deaths dea
JOIN [Portfolio Project]..covid_vacinnations vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent is not null
--ORDER BY 2, 3
)

SELECT *, (RollingPeopleVaccinated/Population * 100)
FROM PopvsVac

--TEMP TABLE

DROP TABLE if exists #PercenPercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations, dea.population, SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM [Portfolio Project]..covid_deaths dea
JOIN [Portfolio Project]..covid_vacinnations vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent is not null
--ORDER BY 2, 3


SELECT *, (RollingPeopleVaccinated/Population * 100)
FROM #PercentPopulationVaccinated

--If you want to alter the table for example removing the where clause

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations, dea.population, SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM [Portfolio Project]..covid_deaths dea
JOIN [Portfolio Project]..covid_vacinnations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population * 100)
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualisation

Create VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM [Portfolio Project]..covid_deaths dea
JOIN [Portfolio Project]..covid_vacinnations vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent is not null

Create VIEW HighestInfectionRate as
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))* 100 as PercentPopulationInfected
FROM [Portfolio Project]..covid_deaths
GROUP BY location, population

