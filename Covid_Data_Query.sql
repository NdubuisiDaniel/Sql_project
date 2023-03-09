/*
Covid 19 Data Exploration 
Using functions like -Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
--View full dataset excluding rows with Null in  continient column
Select *
From CovidDeaths
Where continent is not null 
order by 3,4

-- Select relevant columns
Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null
order by Location, date

 -- Calculating Total Cases vs Total Deaths
 -- Here I calculated the % death for each country and ordered by location first and then by Percentage death Descending.
 Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeaths
 From CovidDeaths
 Where continent is not null
 order by Location, 5 Desc

 -- Calculating Total Cases vs Total Deaths in USA 
 Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeaths
 From CovidDeaths
 Where continent is not null
and Location like '%states%'
 order by Location, 5 Desc
 
 -- Calculating Total Cases vs Population
 Select Location, date, total_cases, population, (total_cases/population)*100 as Percentageinfected
 From CovidDeaths
 Where continent is not null
 order by Location, 5 Desc

 --Locate country with the  Highest Infection Rate compared to Population
 Select Location,population, MAX(total_cases) as HighestInfected, MAX((total_cases/population))*100 as Percentageinfected
 From CovidDeaths
 Where continent is not null
 Group by Location, population
 Order by 3 DESC,4 
 

 ---- Countries with Highest Death Count per Population
 Select Location,population, MAX(Cast(total_deaths as int)) as HighestDeaths, MAX((total_deaths/population))*100 as PercentageDeaths
 From CovidDeaths
 Where continent is not null
 Group by Location, population
 Order by 3 DESC,4 

 -- Showing continents with the highest death count per population
 Select continent, MAX(Cast(total_deaths as int)) as HighestDeaths, MAX((total_deaths/population))*100 as PercentageDeaths
 From CovidDeaths
 Where continent is not null
 Group by continent
 Order by 2 Desc

 -- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
 Select cd.continent, cd.Location, cd.date, cd.population, cv.new_vaccinations,
 SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
 From CovidDeaths cd
 JOIN CovidVaccinations cv
 ON cd.Location =cv.Location and
    cd.date = cv.date
Where cd.continent is not null
Order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select cd.continent, cd.location,cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths cd
Join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths cd
Join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cd.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths cd
Join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 