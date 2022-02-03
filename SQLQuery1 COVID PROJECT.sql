SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2


-- Looking at total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


--Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
Group By Location, population
order by PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population
-- Needed to add continent condition to filter out continents

SELECT Location, MAX(cast(Total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group By Location
order by TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Had to adjust to location for  more accurate, but not clean data
-- Showing continents with the highest death count per population


SELECT continent, MAX(cast(Total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group By continent
order by TotalDeathCount DESC



-- GLOBAL NUMBERS


SELECT SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as bigint)) as TotalNewDeaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2


-- Looking at Total Population vs Vaccinations
-- Used Convert instead of Cast to demonstrate knolwedge

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as RollingPercent
From PopvsVac



-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 as RollingPercent
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3



Select*
From PercentPopulationVaccinated

-- In This project used: Join, SUM, convert, cast, order by, group by, where, 
-- CTE, Temp Table, Drop Table, Create View, Partition by