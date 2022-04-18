select *
from BA_Porfolio_Project_1..CovidDeaths
order by 3,4


----select location, date, total_cases, new_cases, total_deaths, population
----from BA_Porfolio_Project_1..CovidDeaths
----order by 1,2




select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from BA_Porfolio_Project_1..CovidDeaths
order by 1,2

--trying to add constraint which is too late
--alter table BA_Porfolio_Project_1..CovidDeaths add constraint df_a default NULL for new_deaths

update BA_Porfolio_Project_1..CovidDeaths 
set  total_cases = NULL
where total_cases = 0

update BA_Porfolio_Project_1..CovidDeaths 
set  new_cases = NULL
where new_cases = 0

update BA_Porfolio_Project_1..CovidDeaths 
set  population = NULL
where population  = 0;


--fix data
--Because of importing from csv format, all the type have been changed to varchar. After modify, all the default value is gone, so I have to change some value for farther calculation.


--looking at total cases vs total death
--shows likehood of data from specific country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from BA_Porfolio_Project_1..CovidDeaths 
where location like '%zealand%'
order by 1,2


--looking at total cases vs population
--shows whhat percentage of population got covid

select location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
from BA_Porfolio_Project_1..CovidDeaths 
--where location like '%zealand%'
order by 1,2

--Looking at Country with Highest infection Rate

select location, Max(total_cases) as MaxInfectionCount, population, Max(total_cases/population)*100 as MaxPercentage
from BA_Porfolio_Project_1..CovidDeaths 
--where location like '%zealand%'
group by location, population
order by MaxPercentage desc


--Showing Countries with Highest Death Count per Population
update BA_Porfolio_Project_1..CovidDeaths 
set  continent = NULL
where continent =''
--change default value cross type

select location, Max(total_deaths) as TotalDeathCount
from BA_Porfolio_Project_1..CovidDeaths 
--World should not be as a country
--where location not in ('world','upper middle income','high income', 'europe', 'north america', 'asia' , 'lower middle income', 'south america','european union', 'africa')
where continent is not null
group by location
order by TotalDeathCount desc


--Let's break things down by continet

select continent, Max(total_deaths) as TotalDeathCount
from BA_Porfolio_Project_1..CovidDeaths 
where continent is not null
group by continent
order by TotalDeathCount desc


--Let's break things down by income class

select location as income_class, Max(total_deaths) as TotalDeathCount
from BA_Porfolio_Project_1..CovidDeaths 
where location like '%income%'
group by location
order by TotalDeathCount desc

--Global Numbers

select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,(sum(cast(new_deaths as float))/sum(cast(new_cases as float)))*100 as DeathPercentage
from BA_Porfolio_Project_1..CovidDeaths 
-- where location like '%zealand%'
where continent is not null
group by date
order by 1,2

-- for total number cross time

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,(sum(cast(new_deaths as float))/sum(cast(new_cases as float)))*100 as DeathPercentage
from BA_Porfolio_Project_1..CovidDeaths 
-- where location like '%zealand%'
where continent is not null
--group by date
order by 1,2

--Looking at total population vs vaccination

--Use ECT

with PopvsVac (Continent, Location, Date, Population, New_vaccination, RollingPeopleVaccinated)
as(select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as float)) over (Partition by dea.location 
	order by dea.location, dea.date) as RollingPeopleVaccinated 
--convert(int, name)
from BA_Porfolio_Project_1..CovidVaccinations vac
join BA_Porfolio_Project_1..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null)


select *, (RollingPeopleVaccinated/Population)*100 as VaccinationRate

from PopvsVac



--Temp Table


drop table if exists ##percentPopulationVaccinated

Create Table ##percentPopulationVaccinated(
Continent varchar(50),
location varchar(50),
Date datetime,
Population bigint,
New_vaccinations varchar(50),
RollingPeopleVaccinated float

)

insert into ##percentPopulationVaccinated

select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as float)) over (Partition by dea.location 
	order by dea.location, dea.date) as RollingPeopleVaccinated 
--convert(int, name)
from BA_Porfolio_Project_1..CovidVaccinations vac
join BA_Porfolio_Project_1..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


select *, (RollingPeopleVaccinated/Population)*100 as VaccinationRate
from ##percentPopulationVaccinated



--Creat view to store data for later visualization
use BA_Porfolio_Project_1

drop view if exists PercentPopulationVaccinated

create view PercentPopulationVaccinated
as(select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as float)) over (Partition by dea.location 
	order by dea.location, dea.date) as RollingPeopleVaccinated 
--convert(int, name)
from BA_Porfolio_Project_1..CovidVaccinations vac
join BA_Porfolio_Project_1..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null)




select *, (RollingPeopleVaccinated/Population)*100 as VaccinationRate
from PercentPopulationVaccinated


