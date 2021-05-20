/*Covid 19 Data Exploration as of May 11 2021
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types */

 SELECT 
		 *
 FROM 
		 PortfolioProjectDataExpl..CovidDeaths
 WHERE 
		 continent is Not Null
 ORDER BY
		 3,4

 --Selecting the Data we're going to use.

 SELECT
		 Location,
		 date, 
		 total_cases, 
		 new_cases,
		 total_deaths,
		 population
 FROM 
		 PortfolioProjectDataExpl..CovidDeaths 
 WHERE
		 continent is Not Null
ORDER BY 
		 1,2

					/*Total Cases vs. Total Deaths*/  
 --Shows history of likelihood of dying "DeatRate" per country if you contract covid 
 
 SELECT 
		 Location,
		 date, 
		 total_cases, 
		 total_deaths, 
		 (total_deaths/total_cases)*100 as DeathRate
 FROM 
		 PortfolioProjectDataExpl..CovidDeaths 
 WHERE
		 continent is not null
 Order By 
		 1,2


--Shows history of likelihood of dying if you contract covid in Philippines specifically

 SELECT 
		Location,
		date, 
		total_cases, 
		total_deaths, 
		(total_deaths/total_cases)*100 as DeathRate
 FROM 
		PortfolioProjectDataExpl..CovidDeaths 
 WHERE
		location = 'Philippines' --(using exact word)
		and continent is not null 
 ORDER By
		1,2

					/* Total Cases vs. Global or Philippine Population*/ 
 -- Shows history percentage of population that got infected with Covid "InfectionRate"

SELECT
		 Location,
		 date, 
		 population, 
		 total_cases, 
		 (total_cases/population)*100 as InfectionRate
 FROM 
		 PortfolioProjectDataExpl..CovidDeaths 
/* WHERE
		 location LIKE 'Phil%'  --(using wild card)*/
 ORDER BY
		 1,2

 -- Looking at Countries with Highest Infection Rate compared to Population
 -- Ph currently around # 112 as of May 11 2021
SELECT
		 Location, 
		 population, 
		 MAX(total_cases) AS HighestInfectionCount, 
		 MAX((total_cases/population))*100 as PercentPopulationInfected
 FROM 
		 PortfolioProjectDataExpl..CovidDeaths 
 WHERE
		 continent is not null
GROUP BY
		 Location, 
		 Population
 ORDER BY
		 PercentPopulationInfected Desc

-- Countries with Highest Death Count per Population

Select 
		Location, 
		MAX(cast(Total_deaths as int)) as TotalDeathCount
From 
		PortfolioProjectDataExpl..CovidDeaths
Where 
		/*location='philippines'and*/ 
		continent is not null 
Group By 
		Location
Order By
		TotalDeathCount desc


-- Countries with Highest Death Count per Population : BY Continent

Select 
		location, 
		MAX(cast(Total_deaths as int)) as TotalDeathCount
From 
		PortfolioProjectDataExpl..CovidDeaths
Where 
		/*location='philippines'and*/ 
		continent is null 
Group By 
		location
Order By
		TotalDeathCount desc

		-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per continent: For Visualization

SELECT 
		continent, 
		MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM
		PortfolioProjectDataExpl..CovidDeaths
WHERE
		/*location='philippines'and*/ 
		continent is not null 
GROUP BY
		continent
ORDER BY 
		TotalDeathCount desc


--Global Numbers

 SELECT
		 /*date*/
		 SUM(new_cases) as total_cases, 
		 SUM(cast(new_deaths as int)) as total_deaths,
		 SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
 FROM 
		 PortfolioProjectDataExpl..CovidDeaths 
 WHERE
		 /*location='philippines'and*/ 
		continent is not null 
 /*GROUP BY
		date*/
 Order By 
		 1,2

		/*Exploring table #2 CovidVaccinations
Total Population vs Vaccinations or "Rolling Count"
Shows Percentage of Population that has recieved at least one Covid Vaccine Dose */

SELECT 
		 deaths.continent, 
		 deaths.location, 
		 deaths.date, 
		 deaths.population, 
		 vaccs.new_vaccinations,
		 SUM(CONVERT(int,vaccs.new_vaccinations)) 
			OVER 
				(PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as RollingTotalVaccinatedCount
 FROM 
		 PortfolioProjectDataExpl..CovidDeaths deaths
 Join    
		 PortfolioProjectDataExpl..CovidVaccinations vaccs
	ON
		deaths.location = vaccs.location
	AND
		deaths.date = vaccs.date
 WHERE
--deaths.location = 'Philippines' and
		deaths.continent is not null
 ORDER BY
		2,3

		--Performing Calculation on Partition By in previous query:
--Using CTE

WITH 
		PopvsVac 
	(
		continent, 
		location, 
		date, 
		population, 
		new_vaccinations, 
		RollingTotalVaccinatedCount)
	AS
	(
SELECT 
		 deaths.continent, 
		 deaths.location, 
		 deaths.date, 
		 deaths.population, 
		 vaccs.new_vaccinations,
		 SUM(CONVERT(int,vaccs.new_vaccinations)) 
			OVER 
				(PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as RollingTotalVaccinatedCount
 FROM 
		 PortfolioProjectDataExpl..CovidDeaths deaths
 Join    
		 PortfolioProjectDataExpl..CovidVaccinations vaccs
	ON
		deaths.location = vaccs.location
	AND
		deaths.date = vaccs.date
 WHERE
		deaths.continent is not null
	)
 SELECT
		 *, (RollingTotalVaccinatedCount/population)*100 AS PopVaccPercentage
 FROM
		 PopvsVac

--USING TEMP TABLE

DROP TABLE IF EXISTS
		#PopulationVaccinatedPercentage
CREATE TABLE
		#PopulationVaccinatedPercentage
	(
		Continent nvarchar(255),
		Location nvarchar(255),
		Date datetime,
		Population int,
		New_Vaccinations numeric,
		RollingTotalVaccinatedCount numeric,
	)
INSERT INTO
		#PopulationVaccinatedPercentage
SELECT 
		 deaths.continent, 
		 deaths.location, 
		 deaths.date, 
		 deaths.population, 
		 vaccs.new_vaccinations,
		 SUM(CONVERT(int,vaccs.new_vaccinations)) 
			OVER 
				(PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as RollingTotalVaccinatedCount
 FROM 
		 PortfolioProjectDataExpl..CovidDeaths deaths
 Join    
		 PortfolioProjectDataExpl..CovidVaccinations vaccs
	ON
		deaths.location = vaccs.location
	AND
		deaths.date = vaccs.date
 WHERE
		deaths.continent is not null
 ORDER BY
		 2,3 

 SELECT
		 *, (RollingTotalVaccinatedCount/population)*100 AS PopVaccPercentage
 FROM
		 #PopulationVaccinatedPercentage

-- Creating View to store data for later visualizations

CREATE VIEW
		 PopulationVaccinatedPercentage 
	AS
SELECT 
		 deaths.continent, 
		 deaths.location, 
		 deaths.date, 
		 deaths.population, 
		 vaccs.new_vaccinations,
		 SUM(CONVERT(int,vaccs.new_vaccinations)) 
			OVER 
				(PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as RollingTotalVaccinatedCount
 FROM 
		 PortfolioProjectDataExpl..CovidDeaths deaths
 Join    
		 PortfolioProjectDataExpl..CovidVaccinations vaccs
	ON
		deaths.location = vaccs.location
	AND
		deaths.date = vaccs.date
 WHERE
		deaths.continent is not null

SELECT 
		* 
FROM
		PopulationVaccinatedPercentage