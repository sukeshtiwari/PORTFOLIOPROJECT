SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccination
ORDER BY 3,4

SELECT location, date, total_cases, New_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- looking at Total Cases vs Total Deaths
-- shows likelihood of daying if you contract covid in your country
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%india%'
ORDER BY 1,2

-- looking at TOtale cases vs Population
-- shows what percentage of population got covid

SELECT location, date, population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%india%'
ORDER BY 1,2

-- looking at countrys with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%india%'
GROUP BY location, population  
ORDER BY PercentPopulationInfected DESC 

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeathcCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%india%'
WHERE continent IS NOT NULL
GROUP BY location  
ORDER BY TotalDeathcCount DESC 

-- LET'S BREAK DOWN THINGS BY CONTINENT



-- Showing Contintents With the Highest Death Count per Population

SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathcCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%india%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathcCount DESC 

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
Group By date
order by 1,2

-- looking at TOtal Popluation vs Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) over(Partition by dea.location order BY dea.location, dea.date) as RollingPeopleVaccinated
,--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
   ON  dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
   order by 2,3

   -- USE CTE

   With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, New_Vaccinations
, SUM(CONVERT(int,vac.New_Vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.New_vaccinations
, SUM(CONVERT(int,vac.New_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.New_vaccinations
, SUM(CONVERT(int,vac.New_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

 





