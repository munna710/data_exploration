/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

-- SELECT * FROM project.coviddeaths2;
load data infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\CovidDeaths2.csv'
into table project.coviddeaths2
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows
;
Select *
From Project.coviddeaths2
Where continent is not null 
order by 3,4;
-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From Project.coviddeaths2
Where continent is not null 
order by 1,2;
-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Project.Coviddeaths2
Where location like '%states%'
and continent is not null 
order by 1,2;
-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From Project.Coviddeaths2
Where location like '%ndia%'
order by 1,2;

-- states

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From Project.CovidDeaths2
Where location like '%states%'
order by 1,2;
-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Project.CovidDeaths2
-- Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc;

-- Countries with Highest Death Count per Population

Select Location, MAX(Total_deaths) as TotalDeathCount
From Project.CovidDeaths2
-- Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc;
-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as float)) as TotalDeathCount
From Project.CovidDeaths2
-- Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc;
-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as float)) as TotalDeathCount
From Project.CovidDeaths2
-- Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc;
-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(New_Cases)*100 as DeathPercentage
From Project.CovidDeaths2
-- Where location like '%states%'
where continent is not null 
-- Group By date
order by 1,2;

-- import covidvaccination2.csv

load data infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Covidvaccination2.csv'
into table project.covidvaccination2
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows
;

-- join
select * 
from project.coviddeaths2 dea
join project.covidvaccination2 vac
on dea.location=vac.location
and dea.date=vac.date ;
-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(number,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From Project.CovidDeaths2 dea
Join Project.CovidVaccination2 vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;
-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths2 dea
Join Project..CovidVaccination2 vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;
-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths2 dea
Join Project..CovidVaccination2 vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3;

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated;
-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths2 dea
Join Project..CovidVaccination2 vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null ;