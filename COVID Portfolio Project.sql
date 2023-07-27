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
