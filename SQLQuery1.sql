select *
from [Portfolio SQL Project1]..[covid-death]
where continent is not null
order by 3,4


--select *
--from [Portfolio SQL Project1]..[covid-vaccinate]
--order by 3,4

select location, date, total_cases, new_cases, total_deaths,population
from [Portfolio SQL Project1]..[covid-death]
order by 1,2

-- Looking at total cases vs total deaths
-- shows likehood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio SQL Project1]..[covid-death]
where location like '%states%'
order by 1,2


-- looking at total cases vs population
-- shows what percentage of population got covid
select location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
from [Portfolio SQL Project1]..[covid-death]
-- where location like '%states%'
order by 1,2


-- looking at country with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from [Portfolio SQL Project1]..[covid-death]
-- where location like '%states%'
group by Location, Population
order by PercentPopulationInfected desc

--showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeatheCount
from [Portfolio SQL Project1]..[covid-death]
-- where location like '%states%'
where continent is not null
group by Location
order by TotalDeatheCount desc

-- break things down by continent
select continent, max(cast(total_deaths as int)) as TotalDeatheCount
from [Portfolio SQL Project1]..[covid-death]
-- where location like '%states%'
where continent is not null
group by continent
order by TotalDeatheCount desc

--showing continent with the highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeatheCount
from [Portfolio SQL Project1]..[covid-death]
-- where location like '%states%'
where continent is not null
group by continent
order by TotalDeatheCount desc

--global numbers
select SUM(new_cases)as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
from [Portfolio SQL Project1]..[covid-death]
--where location like '%states%'
where continent is not null
--group by date
order by 1,2



-- looking at total population vs vaccinations
select *
from [Portfolio SQL Project1]..[covid-death] dea
join [Portfolio SQL Project1]..[covid-vaccinate] vac
	on dea.location = vac.location and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio SQL Project1]..[covid-death] dea
join [Portfolio SQL Project1]..[covid-vaccinate] vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- use CTE
with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio SQL Project1]..[covid-death] dea
join [Portfolio SQL Project1]..[covid-vaccinate] vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--temp table
drop table if exists #PercentPopulationVaccinnated
create table #PercentPopulationVaccinnated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinnated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio SQL Project1]..[covid-death] dea
join [Portfolio SQL Project1]..[covid-vaccinate] vac
	on dea.location = vac.location and dea.date = vac.date
-- where dea.continent is not null
-- order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinnated 


--create view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinnated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio SQL Project1]..[covid-death] dea
join [Portfolio SQL Project1]..[covid-vaccinate] vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
-- order by 2,3


select *
from PercentPopulationVaccinnated