Select * 
From PortfolioProject..covid_death$
where continent is not null
order by 3,4


--Select * 
--From PortfolioProject..covid_vaccinations$
--order by 3,4


--selecting data that we are using 


Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..covid_death$
where continent is not null
order by 1,2


-- Total cases vs Total Deaths

-- shows the likelihood of dying of covid in India

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..covid_death$
where location like '%india%'

order by 1,2


-- Looking at Total cases vs Population

-- shows percentage of population that got covid

Select location,date,total_deaths,population,total_cases,(total_cases/population)*100 as InfectPercentage
From PortfolioProject..covid_death$
where location like '%india%'
order by 1,2



-- What country has highest Infection rate vs Population

Select location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as InfectedPopulationPercentage
From PortfolioProject..covid_death$
where continent is not null
Group by location,population
order by InfectedPopulationPercentage desc



-- Countries with highest death count per population

Select location,MAX(cast(total_deaths as int)) as Total_Death_count
From PortfolioProject..covid_death$
where continent is not null
Group by location
order by Total_Death_count desc



-- lETS BREAK  THINGS DOWN BY CONTINENT




-- Showing the continent with highest death count

Select continent,MAX(cast(total_deaths as int)) as Total_Death_count
From PortfolioProject..covid_death$
where continent is not null
Group by continent
order by Total_Death_count desc




-- Global Numbers

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage  --total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..covid_death$
-- where location like '%india%'
where continent is not null
--Group By date
order by 1,2











-- ----------------------------------------------------------------------------------------

-- Looking at Total Population vs Vaccinations

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 as 
From PortfolioProject..covid_death$ as dea
Join PortfolioProject..covid_vaccinations$ as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- USE CTE

with PopvsVac(Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 as 
From PortfolioProject..covid_death$ as dea
Join PortfolioProject..covid_vaccinations$ as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as RollingPercentage
From PopvsVac










-- TEMP TABLE

DROP Table if exists #percentPopulationVaccinated
Create Table #percentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
newVaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #percentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 as 
From PortfolioProject..covid_death$ as dea
Join PortfolioProject..covid_vaccinations$ as vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as RollingPercentage
From #percentPopulationVaccinated













-- Creating View to store data for visualisation

Create View percentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 as 
From PortfolioProject..covid_death$ as dea
Join PortfolioProject..covid_vaccinations$ as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select * 
From percentPopulationVaccinated