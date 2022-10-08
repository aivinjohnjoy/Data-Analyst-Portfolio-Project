select * 
from CovidDeath
order by 3,4

select * 
--from CovidVaccinations
--order by 3,4


select location,date, total_cases, new_cases, total_deaths, population
from CovidDeath
order by 1,2


--looking at total cases vs total deaths
--(total_deaths/total_cases)*100 as DeathPercentage
select location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from CovidDeath
where total_cases != 0 and total_deaths != 0
order by 1,2

Alter table [dbo].[CovidDeath]
Alter column [total_cases] float

Alter table [dbo].[CovidDeath]
Alter column [total_deaths] float

Alter table [dbo].[CovidDeath]
Alter column[population]float


select location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeath
order by 1,2


UPDATE [dbo].[CovidDeath]
SET [total_deaths]= NULL
WHERE [total_deaths]= 0;

UPDATE [dbo].[CovidDeath]
SET [total_cases]= NULL
WHERE [total_cases] = 0;

UPDATE [dbo].[CovidDeath]
SET [population]= NULL
WHERE [population] = 0;


--Total cases vs Total deaths
-- likelyhood of dying in India

select location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from CovidDeath
where location = 'India'
order by 1,2


-- Total cases vs Population
-- Percentage of population got infected

SELECT location, date, total_cases, population, (total_cases/population)*100 AS Percentage_of_Infection
FROM CovidDeath
WHERE location='India'
ORDER BY 1,2



--Countries with high infection rates


Select location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidDeath
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


select * 
from [dbo].[CovidDeath]
where location ='High income'

update [dbo].[CovidDeath]
set [continent]= null
where [continent] = ' '

-- Countries with highest death per population

Select location, MAX(total_deaths) as TotalDeathCount
From [dbo].[CovidDeath]
where continent is not null
--where location='India'
Group by location
order by TotalDeathCount desc

-- NUmber of Death by continent

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM [dbo].[CovidDeath]
--WHERE continent IS NULL
WHERE continent IS null AND location != 'High income' AND location !='Upper middle income'AND location != 'Lower middle income'AND location != 'Low income'
GROUP BY location
ORDER BY TotalDeathCount desc


--Global Numbers

Select SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(cast(new_cases as float))*100 as DeathPercentage
From [dbo].[CovidDeath]
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



--total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from [dbo].[CovidDeath] dea
join [dbo].[CovidVaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--AND dea.location = 'India'
order by 2,3


update [dbo].[CovidVaccinations]
set [new_vaccinations] = null
where [new_vaccinations] = ' '

alter table [dbo].[CovidVaccinations]
alter column [new_vaccinations] float

alter table [dbo].[CovidDeath]
alter column [date] date


-- total vaccination per location
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)  as sum_vaccination
from [dbo].[CovidDeath] dea
join [dbo].[CovidVaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--AND dea.location = 'India'
order by 2,3



-- percentage of vaccination against population
-- CTE


with pop_vac (Continent, Location, Date, Population, New_Vaccinations, sum_vaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)  as sum_vaccination
from [dbo].[CovidDeath] dea
join [dbo].[CovidVaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--AND dea.location = 'India'
--order by 2,3
)
select *, (sum_vaccination/population)*100 as percentage
from pop_vac
where location = 'India'


--Using TEMP Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population float,
New_vaccinations float,
sum_vaccination float
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as sum_vaccination
--, (RollingPeopleVaccinated/population)*100
From [dbo].[CovidDeath] dea
Join [dbo].[CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (sum_vaccination/Population)*100 as percentage
From #PercentPopulationVaccinated


--Creating View

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as sum_vaccination
--, (RollingPeopleVaccinated/population)*100
From [dbo].[CovidDeath] dea
Join [dbo].[CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date