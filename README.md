<h1>Coronavirus (COVID-19) Analytical Project</h1>

<h2>Description</h2>
In this project, I utilized Microsoft SQL Server to develop a perform a data analytics exercise on understanding the depth behind <b>Coronavirus (COVID-19) Deaths</b>. Leveraging the data & resourceful insights retrieved from renowned sources, I have interpreted and examined the data in the most efficient manner possible. Afterwards, I have taken out the most crucial insights out of my SQL analysis and expressed them using <b>Tableau</b>.
</br>

## Steps
 1. Data Preprocessing : Removing empty records, editing textual errors and altering datatypes, for eg: nvarchar to float.
 2. Querying and Exploring data using SQL on Microsoft SQL Server.
 3. Exporting data in the form of summarized tables using <b>Microsoft Excel</b> and visualizing it using <b>Tableau Public Software</b>.

## Technologies Used

- <b>Microsoft SQL Server</b> 
- <b>Microsoft Excel</b>
- <b>Tableau</b>

## Skills 
 <b>Data Mining & Preprocessing | Database Creation & Querying | Data Visualization | Critical Thinking</b> 

## Dataset 
The COVID-19 dataset is available [HERE](https://ourworldindata.org/covid-deaths).</br>It contains information about countries: Cases, Deaths, Vaccinations,  Demographics...etc 
|Columns  | details  |
|--|--|
|iso_code  | Country id  |
|Date |date of reported numbers |
| Location |Country  |
| new_cases |number of new cases  |
| Population |number of inhabitant per country    |
| new_vaccination|daily number of vaccinations   |
| new_deaths|daily number of death cases  |

## SQL Queries 
All queries [HERE](https://github.com/KAnurag27/COVID-PortfolioProject/blob/main/COVID%20Portfolio%20Project.sql)<br></br>
Below is the glimpse of a few SQL queries: 
<br></br>Total Cases vs Total deaths
```sql
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
```
Total cases vs Population
```sql
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

```

Top 10 countries having the highest number of covid cases

```sql
SELECT 
    Location, 
	population,
	max(total_cases) as HighestInfectionCount,
	max(cast(total_cases as FLOAT)/nullif(population,0))*100 as PercentPopulationInfected
FROM 
    ProjectPortfolio..CovidDeaths2
Group by location,population
order by PercentPopulationInfected desc

```
Countries with highest death count per population 
```sql
SELECT 
    Location, 
	max(cast(total_deaths as int)) as TotalDeathCount
FROM ProjectPortfolio..CovidDeaths2   
where continent is not null
Group by location
order by TotalDeathCount desc
```
Total Population vs Vaccinations

```sql

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
	,sum(convert(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from ProjectPortfolio..CovidVaccinations vac
join ProjectPortfolio..CovidDeaths2 dea
	on dea.location=vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location = 'India'
order by 2,3
```
## Dashboard Report 
Have a look at the complete [TABLEAU](https://public.tableau.com/views/CovidDashboard_16905681686080/Dashboard1?:language=en-US&:display_count=n&:origin=viz_share_link) report to observe the insights and trends derived from the analysis.
<br></br>![Dashboard](https://github.com/KAnurag27/COVID-PortfolioProject/blob/main/Tableau%20Dashboard%20-%20COVID%20Project.png)
