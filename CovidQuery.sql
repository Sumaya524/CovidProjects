select *
from [Covid Dataset]..[Covid Deaths]
WHERE continent is not null
order by 3,4


-- Covid Deaths Table Exploration
-- LET'S EXPLORE total cases, new cases, total deaths,location, population

select location, date, total_cases, new_cases, total_deaths, population
from [Covid Dataset]..[Covid Deaths]
where continent is not null
order by 1,2

-- let's explore Total Cases vs Total Death, percentageDeathRate -- which indicates the likelihood of dying when diagonosed with covid daily

select location, date, total_cases,  total_deaths,(total_deaths/total_cases) *100 as PercentageDeathRate
from [Covid Dataset]..[Covid Deaths]
where location like '%states%'
order by 1,2


 
-- Total Cases Vs Population
-- Shows what percentage of population infected with Covid

Select location, date, population, total_cases, (total_cases/population) * 100 as PercentagePolutaionInfected
from [Covid Dataset]..[Covid Deaths]
-- where location like '%states%'
order by 1,2


-- Countries with Higest total cases Infection Rate compared to Population

select location, population, MAX(total_cases) as HigestInfectionCount , MAX (total_cases/population) * 100 as PercentagePolutaionInfected
from [Covid Dataset]..[Covid Deaths]
-- where location like '%states%'
GROUP BY location, population
order by PercentagePolutaionInfected desc


-- Countries with Higest total Death Count per population

select location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
from [Covid Dataset]..[Covid Deaths]
-- where location like '%states%'
WHERE continent is NOT NULL
GROUP BY location
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continentw with higest TotalDeathCount

select continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
from [Covid Dataset]..[Covid Deaths]
-- where location like '%states%'
WHERE continent is NOT NULL
GROUP BY continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths , SUM(CAST(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
from [Covid Dataset]..[Covid Deaths]
-- where location like '%states%'
where continent is not null
-- GROUP BY date
order by 1,2



-- Total Population Vs Total Vaccination
-- Showing percentage of population that has received at least one covid vaccine

select dea.continent, dea.location, dea.date,dea.population, vacci.new_vaccinations,
SUM(CAST(vacci.new_vaccinations AS bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from [Covid Dataset]..[Covid Deaths] as dea
join [Covid Dataset]..[Covid Vaccinations] as vacci ON
dea.location=vacci.location
and dea.date=vacci.date
where dea.continent is not null
order by 2,3


-- Using CTE(Common_table_Expression)


With PopvsVac(continent,location,date, population, new_vaccinations,RollingPeopleVaccinated) AS

(
select dea.continent, dea.location, dea.date,dea.population, vacci.new_vaccinations,
SUM(CAST(vacci.new_vaccinations AS bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from [Covid Dataset]..[Covid Deaths] as dea
join [Covid Dataset]..[Covid Vaccinations] as vacci ON
dea.location=vacci.location
and dea.date=vacci.date
where dea.continent is not null
-- order by 2,3
)
select * , (RollingPeopleVaccinated/population)*100
from PopvsVac



-- Creating TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeoplevaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date,dea.population, vacci.new_vaccinations,
SUM(CAST(vacci.new_vaccinations AS bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from [Covid Dataset]..[Covid Deaths] as dea
join [Covid Dataset]..[Covid Vaccinations] as vacci ON
dea.location=vacci.location
and dea.date=vacci.date
-- where dea.continent is not null
-- order by 2,3

select * , (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for later visualization

CREATE VIEW  PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date,dea.population, vacci.new_vaccinations,
SUM(CAST(vacci.new_vaccinations AS bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from [Covid Dataset]..[Covid Deaths] as dea
join [Covid Dataset]..[Covid Vaccinations] as vacci ON
dea.location=vacci.location
and dea.date=vacci.date
where dea.continent is not null


SELECT *
from PercentPopulationVaccinated






