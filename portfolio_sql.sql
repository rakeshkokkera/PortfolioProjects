select * 
from Portfolio_Project..CovidDeaths
where continent is not null
order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Project..CovidVaccination
order by 1,2

-- Looking at Total cases Vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases,
  CAST(total_deaths AS DECIMAL) / CAST(total_cases AS DECIMAL) * 100 AS DeathPercentage
FROM Portfolio_Project..CovidVaccination
where location like 'indi%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

SELECT Location, date, total_cases, population, (total_cases/population) * 100 AS covidpercentage
FROM Portfolio_Project..CovidVaccination
where location = 'india'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compated to population

Select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as percentpopulationinfected
FROM Portfolio_Project..CovidVaccination
--where location = 'india'
group by location, population
order by percentpopulationinfected desc

-- Showing Countries with Highest Death Count per population

select location, max(cast(Total_deaths as int)) as TotalDeathCount
from Portfolio_Project..CovidVaccination
--where location = 'india'
where continent is not null
group by location
order by TotalDeathCount desc

-- Showing Total death count by continent

select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from Portfolio_Project..CovidVaccination
--where location = 'india'
where continent is not null
group by continent
order by TotalDeathCount desc

-- Showing Total death count by Asia continent, and all locations in that continent

select continent,location, max(cast(Total_deaths as int)) as TotalDeathCount
from Portfolio_Project..CovidVaccination
where continent = 'Asia'
group by continent, location
order by TotalDeathCount desc

-- Global numbers

Select sum(new_cases) as total_Cases, sum(cast(new_deaths as int)) total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Portfolio_Project..CovidVaccination
--where location= ' india'
where continent is not null
--group by date
order by 1,2

-- looking at total population vs vaccinations

select vac.continent, vac.location, vac.date, vac.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (Partition by vac.Location order by vac.location, vac.date)as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
from Portfolio_Project..CovidVaccination vac
join Portfolio_Project..CovidDeaths dea
on vac.location = dea.location
and vac.date = vac.date
where vac.continent is not null
order by 2,3

-- use CTE

with PopvsVac(Continent, Location, date, population,New_vacination, RollingPeopleVaccinated)
as 
(
select vac.continent, vac.location, vac.date, vac.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (Partition by vac.Location order by vac.location, vac.date)as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
from Portfolio_Project..CovidVaccination vac
join Portfolio_Project..CovidDeaths dea
on vac.location = dea.location
and vac.date = vac.date
where vac.continent is not null
--order by 2,3
)
select * ,(RollingPeopleVaccinated/population)*100
from PopvsVac

-- Temp Table

drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select vac.continent, vac.location, vac.date, vac.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (Partition by vac.Location order by vac.location, vac.date)as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
from Portfolio_Project..CovidVaccination vac
join Portfolio_Project..CovidDeaths dea
on vac.location = dea.location
and vac.date = vac.date
--where vac.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
select vac.continent, vac.location, vac.date, vac.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (Partition by vac.Location order by vac.location, vac.date)as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
from Portfolio_Project..CovidVaccination vac
join Portfolio_Project..CovidDeaths dea
on vac.location = dea.location
and vac.date = vac.date
where vac.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated