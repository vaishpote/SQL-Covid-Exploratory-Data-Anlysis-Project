/*
Covid 19 Data Exploration

Skills used: Join , CTE's , Window Function , Aggregate Functions, Creating views, Converting Data Types

*/


SELECT * FROM covid.coviddeaths;

SELECT count(*) FROM covid.coviddeaths;


SELECT * FROM covid.covidvaccinations;

SELECT count(*) FROM covid.covidvaccinations;


select * from covid.coviddeaths
where continent is not null
order by 3,4;


--- Select Data that we are going to be starting with

select Location , date, total_cases , total_deaths, population
From covid.coviddeaths
where continent is not null
order by 1,2;


--- Total Cases vs Total Deaths
--- Shows likelihood of dying if you contract covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From covid.coviddeaths
where location like '%state%'
and continent is not null
order by 1,2;



--- Total Cases vs Population
--- Shows what percentage of population infected with Covid

select Location , date , Population , total_cases,(total_cases/population)*100 as PercentPopulationInfected
From covid.coviddeaths
where location like '%states%'
order by 1,2;



--- Countries with Highest Infection Rate compared to Population

Select Location , Population , Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as percentPopulationInfected
From covid.coviddeaths
where location like '%states%'
Group by Location, Population
order by percentPopulationInfected desc;



--- Countries with Highest Death Count per Population

select Location , count(Total_deaths) as TotalDeathCount
from covid.coviddeaths
where location like '%states%'
group by Location
order by TotalDeathCount desc;



--- BREAKING THINGS DOWN BY CONTINENT

--- Showing continents with the highest death count per population

select continent, count(Total_deaths) as TotalDeathCount
from covid.coviddeaths
where continent is not null
group by continent
order by TotalDeathCount desc
limit 1;


-- Total Population vs Vaccinations
-- Shows Sum of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date ) as RollingPeopleVaccinated
From covid.CovidDeaths dea
Join covid.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by RollingPeopleVaccinated desc
limit 1;



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From covid.CovidDeaths dea
Join covid.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by RollingPeopleVaccinated desc 
)
Select *, (RollingPeopleVaccinated/Population)*100 as percentage
From PopvsVac;







