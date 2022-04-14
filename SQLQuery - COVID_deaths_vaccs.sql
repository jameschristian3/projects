--Data from ourworldindata.org

SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER by 3,4;

SELECT * 
FROM PortfolioProject..CovidVaccinations
ORDER by 3,4;

--Test 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Order by 1,2;

-- Total cases v total deaths, can show likelihood of death if contracted COVID

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
FROM PortfolioProject..CovidDeaths
WHERE location like '%States%' and continent is not null
Order By 1,2;


--Total cases v Population, can show percentage of population that has had COVID

SELECT Location, date, total_cases, population, (total_cases/population)*100 as InfectedPercent
FROM PortfolioProject..CovidDeaths
WHERE location like '%States%'
Order by 1,2;

--What countries has the highest Infection Rates?

SELECT Location, population, MAX(total_cases) as populationInfected, MAX((total_cases/population))*100 as InfectedPercent
FROM PortfolioProject..CovidDeaths
Group by location, population
Order by 4 desc;


--What countries have the highest Death Count?

SELECT Location, MAX(cast(Total_deaths as INT)) as TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group by location
Order by TotalDeaths desc;

--What continents?

SELECT continent, MAX(cast(Total_deaths as INT)) as TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group by continent
Order by TotalDeaths desc;

--Additional areas/Demographics?

SELECT Location, MAX(cast(Total_deaths as INT)) as TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent is null
Group by location
Order by TotalDeaths desc;

--New Cases per day in US?

SELECT date, SUM(new_cases) as NewCases
FROM PortfolioProject..CovidDeaths
WHERE location like '%States%'
Group by date
Order by 1,2;

-- New cases Worldwide with death percentage?

SELECT date, SUM(new_cases) as NewCases, SUM(cast(new_deaths as int)) as NewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercent 
FROM PortfolioProject..CovidDeaths
--WHERE location like '%States%'
WHERE continent is not null
Group by date
Order by 1,2;

--Global Population v Vaccination.  Rolling count of people vaccintated by country and date

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccCount
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null AND vac.new_vaccinations is not null
Order by 1,2,3;

--To use RollingVacCount to display percentage of population that is vaccinated by date 
--Use CTE/WITH command

WITH PopVac (Continent, location, date, population, new_vaccinations, RollingVaccCount)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccCount
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null AND vac.new_vaccinations is not null
)
SELECT *, (RollingVaccCount/population)*100 as PopulationVaccPercent
FROM PopVac;