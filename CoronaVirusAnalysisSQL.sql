Select * 
from [Portfolio Project]..CovidDeaths
where continent is not NULL
order by 3,4;

--Select * 
--from [Portfolio Project]..CovidVaccinations
--order by 3,4;

--Select the data we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths
where continent is not NULL
order by 1,2;

--2. Lets first analyze total cases vs total deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths 
where location like '%India%' and continent is not NULL
order by location, date;
--We get the likelyhood of dying if someone contracts corona virus in India by the above code


--3. Total Cases vs Population
Select location, date, population, total_cases, (total_cases/population)*100 as InfectedPopulationPercentage
from [Portfolio Project]..CovidDeaths 
where location like '%India%' and continent is not NULL
order by location, date;
--This shows what percentage of population in India contracted Covid


--4. Looking at Countries with Highest Infection Percentage
Select location, population, MAX(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as InfectedPopulationPercentage
from [Portfolio Project]..CovidDeaths
where continent is not NULL
group by location, population
order by InfectedPopulationPercentage DESC;


--5. Looking at Countries with Highest Death Count per Population
Select location, population, MAX(cast(total_deaths as int)) as TotalDeathCount, max((cast(total_deaths as INT)/population)*100) as DeathPercentage
from [Portfolio Project]..CovidDeaths
where continent is not NULL
group by location, population
order by TotalDeathCount DESC;

--6. Lets break things down by the continents.
--   a. Showing the continents with highest death counts;
Select continent, MAX(cast(total_deaths as INT)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
where continent is not NULL
group by continent
order by TotalDeathCount DESC;


Select continent,  max(total_cases) as TotalCases, max(cast(total_deaths as INT)) as TotalDeaths, max(cast(total_deaths as INT))/max(total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths 
where continent is not NULL
group by continent
order by DeathPercentage;


Select continent, max(population), max(total_cases) as TotalCases, max(total_cases/population)*100 as InfectionPercentage
from [Portfolio Project]..CovidDeaths 
where continent is not NULL
group by continent
order by 2;


Select continent, max(population) as Totalpopulation, max(cast(total_deaths as INT)) as TotalDeath, max(cast(total_deaths as INT)/population)*100 as Death_vs_PopulationPercentage
from [Portfolio Project]..CovidDeaths 
where continent is not NULL
group by continent
order by Death_vs_PopulationPercentage;



--7. GLOBAL NUMBERS
--a. Analysis per day
select date, SUM(new_cases) as new_cases_agg, Sum(cast(new_deaths as INT)) as new_deaths_agg, sum(cast(new_deaths as INT))/sum(new_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where continent is not null
group by date
order by 1,2;

--Total cases
select SUM(new_cases) as new_cases_agg, Sum(cast(new_deaths as INT)) as new_deaths_agg, sum(cast(new_deaths as INT))/sum(new_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where continent is not null;



----------------------------------------------------------------------------

--VACCINATION TABLE 
Select dea.continent, dea.location, dea.date, population, vacc.new_vaccinations 
from [Portfolio Project]..CovidVaccinations dea
Join [Portfolio Project]..CovidDeaths vacc
On dea.location = vacc.location and dea.date = vacc.date
order by 1,2,3;


--1. Looking at Total population vs new Vaccinations per day
Select dea.continent, dea.location, dea.date, population, vacc.new_vaccinations 
from [Portfolio Project]..CovidVaccinations dea
Join [Portfolio Project]..CovidDeaths vacc
On dea.location = vacc.location and dea.date = vacc.date
where dea.continent is not null
order by 2,3;

--Select dea.continent, dea.location, dea.date, Max(population) as TotalPopulation, sum(cast(vacc.new_vaccinations as Int)) as NewVaccinationsPerDay  
--from [Portfolio Project]..CovidVaccinations dea
--Join [Portfolio Project]..CovidDeaths vacc
--On dea.location = vacc.location and dea.date = vacc.date
--where dea.continent is not null
--group by dea.date, dea.continent, dea.location
--order by 2,3;

Select dea.continent, dea.location, dea.date, population, vacc.new_vaccinations, 
sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
from [Portfolio Project]..CovidVaccinations dea
Join [Portfolio Project]..CovidDeaths vacc
On dea.location = vacc.location and dea.date = vacc.date
where dea.continent is not null
order by 2,3;

--USE CTE
With PopvsVacc (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as(
Select dea.continent, dea.location, dea.date, population, vacc.new_vaccinations, 
sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidVaccinations dea
Join [Portfolio Project]..CovidDeaths vacc
On dea.location = vacc.location and dea.date = vacc.date
where dea.continent is not null)
Select *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
from PopvsVacc
order by 2,3;


--TEMP TABLE


CREATE TABLE PercentagePopulationVaccinated(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date datetime,
Population numeric,
new_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
);

Insert Into PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, population, vacc.new_vaccinations, 
sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidVaccinations dea
Join [Portfolio Project]..CovidDeaths vacc
On dea.location = vacc.location and dea.date = vacc.date
where dea.continent is not null;


Select *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
from PercentagePopulationVaccinated
order by 2,3;

DROP TABLE if exists PercentagePopulationVaccinated;



--Creating view to store data for later visualtions
Create view PercentagePolpulationVaccinated as
Select dea.continent, dea.location, dea.date, population, vacc.new_vaccinations, 
sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidVaccinations dea
Join [Portfolio Project]..CovidDeaths vacc
On dea.location = vacc.location and dea.date = vacc.date
where dea.continent is not null;

Select * from PercentagePolpulationVaccinated;