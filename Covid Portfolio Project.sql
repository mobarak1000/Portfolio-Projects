
Select * From PortfolioProject..CovidDeaths
Order By 3,4


Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order By 1,2


--Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Order By 1,2



--Total Cases vs Population

Select location, date, total_cases, population, (total_cases/population)*100 as TotalCasesPercentage
From PortfolioProject..CovidDeaths
Where location = 'Egypt'
Order By 1,2

--Top 10 Countries with highest infection rate compared to population
Select location, population, Max(total_cases), Max((total_cases/population))*100 as TotalCasesPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group By location, population 
Order BY TotalCasesPercentage Desc 
OFFSET 0 ROWS
FETCH NEXT 10 ROWS ONLY


--Countries with highest infection rate compared to population
Select location, population, Max(total_cases) as HighestInfectionRate, Max((total_cases/population))*100 as TotalCasesPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group By location, population 
Order BY TotalCasesPercentage Desc


--Countries with the highest death count and percentage 
Select location, population, Max(total_deaths) as HighestDeathRate, Max((total_deaths/population))*100 as DeathPercentagePerCountry
From PortfolioProject..CovidDeaths
Where continent is not null
Group By location, population 
Order BY DeathPercentagePerCountry Desc
-----------------------------------

Select location, Max(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By location
Order BY TotalDeathCount Desc
 

--Continent with the highest death count
Select location, Max(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where location in('Europe','Africa','North America','South America','Asia','Oceania','World')
Group By location
Order BY TotalDeathCount Desc
--------------------------------

Select continent, Max(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By continent
Order BY TotalDeathCount Desc


--Global Numbers
Select date, SUM(new_cases) as CasesPerDay, SUM(new_deaths) as DeathsPerDay
From PortfolioProject..CovidDeaths
Where continent is not null
Group By date
Order By 1,2
---------------

Select SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 1,2
----------------

--Total Population vs Total Vaccinations
Select rip.continent, rip.location, rip.date, rip.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) over(partition by rip.location order by rip.location, rip.date) as IncreaseOfVaccination
From PortfolioProject..CovidDeaths rip
Join PortfolioProject..CovidVaccinations vac
ON rip.location = vac.location
and rip.date = vac.date
Where rip.continent is not null
Order By 2,3



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, IncreaseOfVaccination)
as
(
Select rip.continent, rip.location, rip.date, rip.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by rip.Location Order by rip.location, rip.Date) as IncreaseOfVaccination
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths rip
Join PortfolioProject..CovidVaccinations vac
	On rip.location = vac.location
	and rip.date = vac.date
where rip.continent is not null 
--order by 2,3
)
Select *, (IncreaseOfVaccination/Population)*100 as IncreaseOfVaccinationPercentage
From PopvsVac




---creating views for later visualizations

create view RateOfVaccination as
Select rip.continent, rip.location, rip.date, rip.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) over(partition by rip.location order by rip.location, rip.date) as IncreaseOfVaccination
From PortfolioProject..CovidDeaths rip
Join PortfolioProject..CovidVaccinations vac
ON rip.location = vac.location
and rip.date = vac.date
Where rip.continent is not null;
--Order By 2,3



create view GlobalNumbers as
Select date, SUM(new_cases) as CasesPerDay, SUM(new_deaths) as DeathsPerDay
From PortfolioProject..CovidDeaths
Where continent is not null
Group By date;




create view DeathCountPerContinent as
Select location, Max(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where location in('Europe','Africa','North America','South America','Asia','Oceania','World')
Group By location
--Order BY TotalDeathCount Desc




create view DeatCountPerCountry as
Select location, population, Max(total_deaths) as HighestDeathRate, Max((total_deaths/population))*100 as DeathPercentagePerCountry
From PortfolioProject..CovidDeaths
Where continent is not null
Group By location, population 
--Order BY DeathPercentagePerCountry Desc




create view InfectionRatePerCountry as 
Select location, population, Max(total_cases) as HighestInfectionRate, Max((total_cases/population))*100 as TotalCasesPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group By location, population 
--Order BY TotalCasesPercentage Desc

