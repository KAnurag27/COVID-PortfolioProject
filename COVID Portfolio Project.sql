-- Looking at Total Cases vs Total deaths
-- Shows likelihood of dying if you contract covid in your own

SELECT 
    Location, 
    date, 
    total_deaths, 
    total_cases,
    CAST(total_deaths AS FLOAT) / NULLIF(total_cases, 0)*100 AS DeathPercentage
FROM 
    ProjectPortfolio..CovidDeaths2
WHERE 
    location = 'India'
ORDER by 1,2

-- Looking at Total cases vs Population	
-- Shows how many people from population got vaccinated

SELECT 
    Location, 
    date, 
    Population,
	total_vaccinations,
	CAST(total_vaccinations AS FLOAT) / NULLIF(population, 0)*100 AS VaccinationPercentage
FROM 
    ProjectPortfolio..CovidVaccinations
WHERE 
    location = 'India'
ORDER by 1,2

-- Looking at top 10 countries having the highest number of covid cases

SELECT 
    Location, 
	population,
	max(total_cases) as HighestInfectionCount,
	max(cast(total_cases as FLOAT)/nullif(population,0))*100 as PercentPopulationInfected
FROM 
    ProjectPortfolio..CovidDeaths2
Group by location,population
order by PercentPopulationInfected desc

--Showing Countries with highest death count per population 

SELECT 
    Location, 
	max(cast(total_deaths as int)) as TotalDeathCount
FROM ProjectPortfolio..CovidDeaths2   
where continent is not null
Group by location
order by TotalDeathCount desc

-- Grouping data by Continent

SELECT 
    continent, 
	max(cast(total_deaths as int)) as TotalDeathCount
FROM ProjectPortfolio..CovidDeaths2   
where continent is not null
Group by continent
order by TotalDeathCount desc

--Showing continents with the highest death count per population

SELECT 
    continent, 
	max(cast(total_deaths as int)) as TotalDeathCount
FROM ProjectPortfolio..CovidDeaths2   
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers

SELECT  
    date,  
    sum(new_cases) as TotalCases,
	sum(new_deaths)as TotalDeaths,
    sum(new_deaths) / sum(nullif(new_cases,0))*100 AS DeathPercentage
FROM 
    ProjectPortfolio..CovidDeaths2
WHERE continent is not null
group by date
ORDER by 1,2

--Global Numbers (Overall Stats)

SELECT  
--    date,  
    sum(new_cases) as TotalCases,
	sum(new_deaths)as TotalDeaths,
    sum(new_deaths) / sum(new_cases)*100 AS DeathPercentage
FROM 
    ProjectPortfolio..CovidDeaths2
WHERE continent is not null
--group by date
ORDER by 1,2

--Looking at Total Population vs Vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
	,sum(convert(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from ProjectPortfolio..CovidVaccinations vac
join ProjectPortfolio..CovidDeaths2 dea
	on dea.location=vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location = 'India'
order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations,ROllingPeopleVaccinated)
as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
	,sum(convert(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from ProjectPortfolio..CovidVaccinations vac
join ProjectPortfolio..CovidDeaths2 dea
	on dea.location=vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac



-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
	,sum(convert(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from ProjectPortfolio..CovidVaccinations vac
join ProjectPortfolio..CovidDeaths2 dea
	on dea.location=vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
	,sum(convert(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from ProjectPortfolio..CovidVaccinations vac
join ProjectPortfolio..CovidDeaths2 dea
	on dea.location=vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select *
from PercentPopulationVaccinated



------------------------------------------------------------------------------------


/*

Queries used for Tableau Project

*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths2
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths2
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From ProjectPortfolio..CovidDeaths2
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From ProjectPortfolio..CovidDeaths2
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc












-- Queries I originally had, but excluded some because it created too long of video
-- Here only in case you want to check them out


-- 1.

Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3




-- 2.
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 3.

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc



-- 4.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc



-- 5.

--Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where continent is not null 
--order by 1,2

-- took the above query and added population
Select Location, date, population, total_cases, total_deaths
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
order by 1,2


-- 6. 


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac


-- 7. 

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc




