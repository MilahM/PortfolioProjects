Select *
From PortfolioProject.dbo.CovidDeaths
Order by 3,4

--Select *
--From PortfolioProject.dbo.CovidVaccinations
--Order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
Order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract Covid in your Country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location like '%states%'
Order by 1,2


--Looking at the Total Cases vs Population
--Shows what percentage of population got Covid
Select Location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject.dbo.CovidDeaths
Where location like '%states%'
Order by 1,2


--Looking at Countries w/ the highest infection rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject.dbo.CovidDeaths
Group by location, population
Order by PercentagePopulationInfected desc


--Showing Countries w/ Highest Death Count per Population
--Used cast on total_deaths because data type was nvarchar and we wanted to see actual numbers
--Where continent is not null was added because there's issue w/ data where a country will be listed as a country and a continent
Select Location,  MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc


--Breaking things down by Continent
--Likely more accurate because it accts for all of NA, SA, etc
Select location,  MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount desc

--Used for purposes of the project
Select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc


--Showing the Continents w/ the Highest Death Counts

Select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc


--Global Numbers

Select  date, Sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by date
Order by 1,2

Select  Sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Order by 1,2


--Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =vac.date
Where dea.continent is not null
Order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =vac.date
Where dea.continent is not null
Order by 2,3


--Using a CTE

With PopvsVac (COntinent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac



--Using a Temp Table


Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =vac.date
--Where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =vac.date
Where dea.continent is not null