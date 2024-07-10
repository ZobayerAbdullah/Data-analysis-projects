/*-------------- Covid 19 data exploration------------ */

--Dataset link : https://ourworldindata.org/covid-deaths


 Select * 
 From covidDeaths
Where continent is not null
Order by 3,4


--select important data that we need to use

Select location,date,continent,total_cases,total_deaths
From covidDeaths
Where continent is not null
order by 1,2

--total cases vs total deaths
--shows death percentage in my country
Select location,date,continent,total_cases,total_deaths,(cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From covidDeaths
where location = 'Bangladesh'
order by date

-- Shows what percentage of population infected with Covid in my country


Select location,date,population,total_cases,(cast(total_cases as float)/cast(population as float))*100 as PercentPopulationInfected
From covidDeaths
where location = 'Bangladesh'
order by date

--countries with highest infection rate compared to population

Select location,population,MAX(total_cases) as HighestInfectionCount ,MAX((cast(total_cases as float)/cast(population as float))*100) as HighestInfectionRate
From covidDeaths
Group by location,population
order by 4 desc

--countries with highest death counts per population
Select location,population,MAX(total_deaths) as HighestDeathCount
From covidDeaths
where continent is not null
Group by location,population
order by 3 desc

--BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From covidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--GLOBAL STATEMENT
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From covidDeaths
where continent is not null 
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select cd.continent,cd.location,cd.date,cd.total_cases,cv.new_vaccinations,cd.population,
Sum(CONVERT(bigint,cv.new_vaccinations)) over(Partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated

From covidDeaths cd
Join covidVaccinated cv
on cd.date = cv.date
and cd.location = cv.location
where cd.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac(Continent,Location,Date,TotalCases,Vaccinations,Populations,RollingPeopleVaccinated)
as (
Select cd.continent,cd.location,cd.date,cd.total_cases,cv.new_vaccinations,cd.population,
Sum(CONVERT(bigint,cv.new_vaccinations)) over(Partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated

From covidDeaths cd
Join covidVaccinated cv
on cd.date = cv.date
and cd.location = cv.location
where cd.continent is not null

)
Select *,(RollingPeopleVaccinated/Populations)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

Drop Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeapleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
Sum(CONVERT(bigint,cv.new_vaccinations)) over(Partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated

From covidDeaths cd
Join covidVaccinated cv
on cd.date = cv.date
and cd.location = cv.location

Select *,(RollingPeapleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinatedView as
Select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
Sum(CONVERT(bigint,cv.new_vaccinations)) over(Partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated

From covidDeaths cd
Join covidVaccinated cv
on cd.date = cv.date
and cd.location = cv.location






