Select*
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
order by 3,4

--Select*
--From PortfolioProject.dbo.CovidVaccinations
--order by 3,4

--select data that we are going to be using--

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
order by 1,2

--Looking at the total cases vs total deaths--
--Shows how likely you are able to die if you get Covid by Country--
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2


--Look at total cases vs population--
--Shows what percent of population has Covid--

Select Location, date, population, total_cases,(total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
order by 1,2


-- Look at Country with Highest Infection Rates compared to their population--

Select Location, population, Max(total_cases) as HighestInfectionCount,     Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
group by Location, population
order by PercentPopulationInfected desc


--Show Counties with Highest Death County by Population--


Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
group by Location
order by TotalDeathCount desc


-- BREAK DOWN BY CONTINENT--


--Show continent with highest Death Count-- 

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS--

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , SUM(cast(new_deaths as int))/SUM(NEW_CASES)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2



--Total Population vs Vaccinations--


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST( vac.new_vaccinations as int)) OVER (Partition by dea.Location)
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations  vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--or--

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations  vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- USE CTE

with PopvsVac(Continent, Location, Date, Population, New_Vaccinations,  RollingPeopleVaccinated)
As
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations  vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)

Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--Temp Table

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

Insert Into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations  vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




--create View to store data for Visualization--

Create View PercentagePopulationVaccination as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations  vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select*
From PercentagePopulationVaccination
