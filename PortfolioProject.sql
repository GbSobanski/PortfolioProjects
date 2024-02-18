select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--Select the data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total cases vs Total deaths
-- Shows the likelihood of dying if you contract Covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location = 'Brazil'
--and continent is not null
order by 1,2

-- Looking at Total cases vs Population
-- Shows what percentage of population got covid
Select Location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at countries with Highest Infection rate compared to population

Select Location, max(total_cases) as HighestInfectionCount, population, MAX((total_cases/population)*100) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
Group by Location, population
order by PercentPopulationInfected desc


-- Showing the countries with the highest deathcount per population

Select Location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc



--Let's break things down by continent


--Showing the continent with the highest death count per population

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global numbers


Select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location = 'Brazil'
Where continent is not null
order by 1,2


--Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
Order by 2,3


--Use CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population*100)
From PopvsVac


--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
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
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
--Where dea.continent is not null
Order by 2,3

Select *, (RollingPeopleVaccinated/Population*100)
From #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--Order by 2,3


Select *
From PercentPopulationVaccinated