/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/




Select*
From CovidVaccinations$
Where Continent is null
order by 3,4

--Select*
--From CovidDeaths$
--Where Continent is null
--order by 3,4

-- Select data that we are going to use

Select location, date,total_cases,new_cases,total_deaths,population
From CovidDeaths$
Where Continent is null
order by 1,2

--Total cases Vs Total Deaths
-- This shows the likelihood of dying if you contract covid in your Country

Select location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths$
Where location like '%uganda%'
order by 1,2


--Looking at the Total_cases Vs Population
--Shows what Percentage of population has got Covid


Select location, date,total_cases,population, (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths$
--Where location like '%uganda%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select location, Population, MAX(total_cases)as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths$
--Where location like '%uganda%'
Group by Location, Population
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population


Select Location,  MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths$
--Where location like '%uganda%'
Where Continent is null
Group by Location
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing the Continents with the Highest Death Count


Select Continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths$
--Where Location like '%uganda%'
Where Continent is not null
Group by Continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS


Select Date,SUM(New_Cases)as New_Cases, SUM(cast(New_Deaths as int)) as New_Deaths,SUM(cast(New_Deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths$
--Where location like '%uganda%'
Where Continent is not null
Group by date
order by 1,2


Select SUM(New_Cases) as Total_Cases, SUM(cast(New_Deaths as int)) as Total_Deaths,SUM(cast(New_Deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths$
--Where location like '%uganda%'
Where Continent is not null
--Group by date
order by 1,2


-- Looking at Total Population Vs Total Vaccination

Select *
From CovidVaccinations$

Select *
From CovidVaccinations$ Vac
Join CovidDeaths$  Dea
   On Dea.Location = Vac.Location
   and Dea.Date = Vac.Date

Select Dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.new_vaccinations
,SUM(cast (Vac.new_vaccinations as int)) OVER (Partition by dea.location Order by Dea.Location, Dea.Date) as RollingPeopleVaccinated
From CovidVaccinations$ Vac
Join CovidDeaths$  Dea
   On Dea.Location = Vac.Location
   and Dea.Date = Vac.Date
Where Dea.Continent is not null
order by 2,3


--USE CTE
With PopVsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select Dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.new_vaccinations
,SUM(cast (Vac.new_vaccinations as int)) OVER (Partition by dea.location Order by Dea.Location, Dea.Date) as RollingPeopleVaccinated
From CovidVaccinations$ Vac
Join CovidDeaths$  Dea
   On Dea.Location = Vac.Location
   and Dea.Date = Vac.Date
Where Dea.Continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac




--TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select Dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.new_vaccinations
,SUM(cast (Vac.new_vaccinations as int)) OVER (Partition by dea.location Order by Dea.Location, Dea.Date) as RollingPeopleVaccinated
From CovidVaccinations$ Vac
Join CovidDeaths$  Dea
   On Dea.Location = Vac.Location
   and Dea.Date = Vac.Date
Where Dea.Continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select Dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.new_vaccinations
,SUM(cast (Vac.new_vaccinations as int)) OVER (Partition by dea.location Order by Dea.Location, Dea.Date) as RollingPeopleVaccinated
From CovidVaccinations$ Vac
Join CovidDeaths$  Dea
   On Dea.Location = Vac.Location
   and Dea.Date = Vac.Date
Where Dea.Continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating View to store data for later Visualizations

Create View PercentPopulationVaccinated as 
Select Dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.new_vaccinations
,SUM(cast (Vac.new_vaccinations as int)) OVER (Partition by dea.location Order by Dea.Location, Dea.Date) as RollingPeopleVaccinated
From CovidVaccinations$ Vac
Join CovidDeaths$  Dea
   On Dea.Location = Vac.Location
   and Dea.Date = Vac.Date
Where Dea.Continent is not null
--order by 2,3


Select*
From PercentPopulationVaccinated


