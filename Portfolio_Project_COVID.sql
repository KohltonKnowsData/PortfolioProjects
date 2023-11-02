/* COVID 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT * 
FROM PortfolioCOVID..CovidDeaths
WHERE continent is not NULL
ORDER by 3,4

--Select data that we are going to be starting with

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioCOVID..CovidDeaths
ORDER by 1,2

-- Looking at Total Cases vs Total Deaths
--Likelihood of dying after contracting COVID

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM PortfolioCOVID..CovidDeaths
WHERE location like '%states%'
ORDER by 1,2

--Looking at total cases vs Population
--What percentage of the population contracted covid 

SELECT Location, date, total_cases, population, (total_cases/population)*100 as Infected_Percentage
FROM PortfolioCOVID..CovidDeaths
WHERE location like '%states%'
ORDER by 1,2

-- Looking at countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population))*100 AS Infected_Percentage 
FROM PortfolioCOVID..CovidDeaths
--WHERE location like '%states%'
GROUP by Location, population
ORDER by Infected_Percentage desc

--Showing countries with the highest death count per population

SELECT Location, MAX(cast(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioCOVID..CovidDeaths
WHERE continent is not null
GROUP by Location
ORDER by TotalDeathCount desc

--Breakdown of death count by Continent 

SELECT location, MAX(cast(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioCOVID..CovidDeaths
WHERE continent is null
GROUP by location
ORDER by TotalDeathCount desc

-- Global numbers

SELECT date, SUM(new_cases) as Cases, SUM(Cast(new_deaths as int)) as Deaths, SUM(Cast(new_deaths as int))/Sum(new_cases) * 100 AS Death_Percentage
FROM PortfolioCOVID..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER by 1,2


-- Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(CAST(vac.new_vaccinations as int)) over (Partition by dea.location Order BY dea.location, dea.Date) AS Total_Vaccinations,
Total_Vaccinations
From PortfolioCOVID..CovidDeaths dea
Join PortfolioCOVID..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date 
where dea.continent is not null
ORDER BY 2,3

--USING CTE
WITH PopVsVac (Continent, Location, Date, Population, new_vaccinations, Total_Vaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(CAST(vac.new_vaccinations as int)) over (Partition by dea.location Order BY dea.location, dea.Date) AS Total_Vaccinations
From PortfolioCOVID..CovidDeaths dea
Join PortfolioCOVID..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date 
where dea.continent is not null
--ORDER BY 2,3
)
Select *, (Total_Vaccinations/Population)*100 as Percent_Vaccinated
From PopVsVac

-- Using TEMP Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Total_Vaccinations numeric
)


Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(CAST(vac.new_vaccinations as int)) over (Partition by dea.location Order BY dea.location, dea.Date) AS Total_Vaccinations
From PortfolioCOVID..CovidDeaths dea
Join PortfolioCOVID..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date 
where dea.continent is not null
--ORDER BY 2,3

Select *, (Total_Vaccinations/Population)*100 as Percent_Vaccinated
From #PercentPopulationVaccinated

--View for later data visualization

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(CAST(vac.new_vaccinations as int)) over (Partition by dea.location Order BY dea.location, dea.Date) AS Total_Vaccinations
From PortfolioCOVID..CovidDeaths dea
Join PortfolioCOVID..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date 
where dea.continent is not null

Create View PercentDeathByCovid as
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population))*100 AS Infected_Percentage 
FROM PortfolioCOVID..CovidDeaths
--WHERE location like '%states%'
GROUP by Location, population

Select * from PercentDeathByCovid