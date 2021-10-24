


SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3, 
         4;

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
-From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country





SELECT Location, 
       date, 
       total_cases, 
       total_deaths, 
       (total_deaths / total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
--and continent is not null 
ORDER BY 1, 
         2;





--Looking at total cases vs. Population
--Shows what percetage of population got Covid



SELECT Location, 
       date, 
       total_cases, 
       total_deaths, 
       (total_deaths / population) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
      AND continent IS NOT NULL
ORDER BY 1, 
         2;





-- Countries with Highest Infection Rate compared to Population

SELECT Location, 
       Population, 
       MAX(total_cases) AS HighestInfectionCount, 
       MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
GROUP BY Location, 
         Population
ORDER BY PercentPopulationInfected DESC;







-- Countries with Highest Death Count per Population
-- CAST total_deaths from nvarchar too int.



SELECT Location, 
       MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;




-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population



SELECT continent, 
       MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;





--Lets break things down by continent
-- Gives a representation of breakdown of contintents




SELECT location, 
       MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;





-- GLOBAL NUMBERS
-- date is breakdown per day



SELECT SUM(new_cases) AS total_cases, 
       SUM(CAST(new_deaths AS INT)) AS total_deaths, 
       SUM(CAST(new_deaths AS INT)) / SUM(New_Cases) * 100 AS DeathPercentage
--Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent IS NOT NULL 
--Group By date
ORDER BY 1, 
         2;




-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
--CONVERT(int, column) same as CAST(column AS int)




SELECT dea.continent, 
       dea.location, 
       dea.date, 
       dea.population, 
       vac.people_fully_vaccinated, 
       SUM(CONVERT(INT, people_fully_vaccinated)) OVER(PARTITION BY dea.Location
ORDER BY dea.location, 
         dea.Date) AS CumalativeVaccinated
-- (CumalativeVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
     JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location
                                                     AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 
         3;

-



-- Using CTE to perform Calculation on Partition By in previous query



WITH PopvsVac(Continent, 
              Location, 
              Date, 
              Population, 
              New_Vaccinations, 
              CumalativeVaccinated)
     AS (SELECT dea.continent, 
                dea.location, 
                dea.date, 
                dea.population, 
                vac.new_vaccinations, 
                SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.Location
         ORDER BY dea.location, 
                  dea.Date) AS CumalativeVaccinated
         --, (CumalativeVaccinated/population)*100
         FROM PortfolioProject..CovidDeaths dea
              JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location
                                                              AND dea.date = vac.date
         WHERE dea.continent IS NOT NULL 
         --order by 2,3
         )
     SELECT PopvsVac.Continent, 
            PopvsVac.Location, 
            PopvsVac.[Date], 
            PopvsVac.Population, 
            PopvsVac.New_Vaccinations, 
            PopvsVac.CumalativeVaccinated, 
            (CumalativeVaccinated / Population) * 100 AS Percent_CumalativeVaccinated
     FROM PopvsVac;





-- Using Temp Table to perform Calculation on Partition By in previous query





.DROP TABLE IF EXISTS #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated
(Continent            NVARCHAR(255), 
 Location             NVARCHAR(255), 
 Date                 DATETIME, 
 Population           NUMERIC, 
 New_vaccinations     NUMERIC, 
 CumalativeVaccinated NUMERIC
);
INSERT INTO #PercentPopulationVaccinated
       SELECT dea.continent, 
              dea.location, 
              dea.date, 
              dea.population, 
              vac.new_vaccinations, 
              SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.Location
       ORDER BY dea.location, 
                dea.Date) AS CumalativeVaccinated
       --, (CumalativeVaccinated/population)*100
       FROM PortfolioProject..CovidDeaths dea
            JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location
                                                            AND dea.date = vac.date;
--where dea.continent is not null 
--order by 2,3



SELECT *, 
       (CumalativeVaccinated / Population) * 100
FROM #PercentPopulationVaccinated;

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated
AS
     SELECT dea.continent, 
            dea.location, 
            dea.date, 
            dea.population, 
            vac.new_vaccinations, 
            SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.Location
     ORDER BY dea.location, 
              dea.Date) AS CumalativeVaccinated
     --, (CumalativeVaccinated/population)*100
     FROM PortfolioProject..CovidDeaths dea
          JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location
                                                          AND dea.date = vac.date
     WHERE dea.continent IS NOT NULL;
SELECT *
FROM PercentPopulationVaccinated
	where lOCATION ='united states'





