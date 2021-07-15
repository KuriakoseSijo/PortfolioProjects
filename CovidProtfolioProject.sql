-------
SELECT location_, date, total_cases, total_deaths, (total_deaths::float/total_cases::float)*100 as DeathPercentage
FROM CovidDeaths
WHERE location_ like '%States%'
order by 1;

----

Select *
FROM coviddeaths
WHERE continent is not null
ORDER BY 3,4;

----


Select *
FROM coviddeaths
WHERE continent is not null
ORDER BY 3,4;
-- Looking at Total Cases vs. Total Deaths

SELECT location_, date, total_cases, total_deaths, (total_deaths::float/total_cases::float)*100 as DeathPercentage
FROM CovidDeaths
WHERE location_ like '%States%'
order by 1;

--- Looking at Total Cases vs. Population
-- Shows what percentage of population got Covid
SELECT location_, date, total_cases, population, (total_cases::float/population ::float)*100 as PercentPopulationInfected
FROM CovidDeaths
WHERE location_ like '%States%' 
order by 1;

--- Looking at Countries with Highest infection Rate compared to population
SELECT location_, population,MAX(total_cases)as HigestInfectionCount,  MAX(total_cases::float/population ::float*100) as PercentPopulationInfected
FROM CovidDeaths
WHERE continent is not null
GROUP by location_, population
order by PercentPopulationInfected desc;
-- setting null to zero



-- Showing the Countries with Highest Death Count per Population
SELECT location_, MAX(total_deaths)as TotalDeaths 
FROM CovidDeaths
WHERE continent is not null
GROUP by location_
order by location_ desc;


-- ****LET'S BREAK THINGS DOWN BY CONTINENT ******

-- Showing the contintens with the higest death count
SELECT continent, MAX(total_deaths) as TotalDeaths 
FROM CovidDeaths
WHERE continent is not null
GROUP by continent
ORDER by continent desc;


-- GLOBAL NUMBERS

SELECT SUM(new_cases::INT), SUM(new_deaths:: INT), ROUND((SUM(new_deaths::float)/SUM(new_cases::float))*100) as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER by 1,2



-- Looking at Total populations vs Vaccinations
SELECT dea.continent, dea.location_, dea.date::DATE, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations::int) OVER (Partition by dea.location_ ORDER BY dea.location_, dea.date) as RollingPeopleVaccinated,

FROM CovidDeaths dea
JOIN CovidVaccinations vac
on dea.location_= vac.location_
and dea.date = vac.date
WHERE dea.continent is not null
ORDER by 2,3;


-- USE CTE 
WITH PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location_, dea.date::DATE, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations::int) OVER (Partition by dea.location_ ORDER BY dea.location_, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/poplulation::int)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
on dea.location_= vac.location_
and dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (RollingPeopleVaccinated/population::float)*100 as percentageOfVac
	FROM PopvsVac


--TEMP TABLE
-- DROP TABLE IF exists PercentPopulationVaccinated

CREATE TABLE PercentPopulationVaccinated
(
	Continet varchar(255),
	Location_ varchar(255),
	Date date,
	Population numeric, 
	New_vaccinations numeric, 
	RollingPeopleVaccinated numeric
);
INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location_, dea.date::DATE, dea.population::numeric, vac.new_vaccinations::numeric, 
SUM(vac.new_vaccinations::int) OVER (Partition by dea.location_ ORDER BY dea.location_, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/poplulation::int)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
on dea.location_= vac.location_
and dea.date = vac.date
WHERE dea.continent is not null


SELECT *, (RollingPeopleVaccinated/population::float)*100 as percentageOfVac
	FROM PercentPopulationVaccinated
	
-- Creating view to store data for later visualization
create view PercentPopulationVaccinated1 as
SELECT dea.continent, dea.location_, dea.date::DATE, dea.population::numeric, vac.new_vaccinations::numeric, 
SUM(vac.new_vaccinations::int) OVER (Partition by dea.location_ ORDER BY dea.location_, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/poplulation::int)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
on dea.location_= vac.location_
and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT * 
FROM PercentPopulationVaccinated1
