SELECT *
FROM PortfolioProject..covidDeaths
Where continent is not null
Order By 3,4

--SELECT *
--FROM PortfolioProject..covidVaccinations
--Order By 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covidDeaths
Where continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (Convert(float,total_deaths)/nullif(convert(float, total_cases), 0))*100 as DeathPercentage
FROM PortfolioProject..covidDeaths
Where location like '%states%'
and continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Population
--Shows what percentage of population got Covid

SELECT location, date, total_cases, population, (Convert(float,total_cases)/nullif(convert(float, population), 0))*100 as DeathPercentage
FROM PortfolioProject..covidDeaths
Where location like '%states%'
ORDER BY 1,2


--Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, (Convert(float,Max(total_cases))/nullif(convert(float, population), 0))*100 as PerecentPopulationInfected
FROM PortfolioProject..covidDeaths
GROUP BY location, population
ORDER BY PerecentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent is null and location NOT LIKE '%income%'
GROUP BY location
ORDER BY TotalDeathCount desc

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount desc

--Showing continents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount desc



-- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(New_deaths)/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject..covidDeaths
-- Where location like '%states%'
WHERE continent is not null and new_cases <> 0
--Group By date
ORDER BY 1,2


--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
Order by 2,3


-- USE CTE

With PopvsVac (Conitinent, Location, Data, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated





--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3
