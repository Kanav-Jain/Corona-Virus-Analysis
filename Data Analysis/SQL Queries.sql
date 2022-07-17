-- Queries for Data Visualization in Tableau

--1. Global Data
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(New_Cases))*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
where continent is not null 
order by 1,2;

--2. Global Data by each Continent
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3. Percentage Population Infected in each Location
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc;


-- 4. Percentage Population Infected by each day
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc
