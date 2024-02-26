SELECT *
FROM coviddeaths

---Looking at death percentage

SELECT location, date, total_cases, total_deaths,(CAST(total_deaths AS FLOAT) / NULLIF(CAST(total_cases AS FLOAT), 0)) * 100 AS DeathPercentage
FROM coviddeaths
WHERE location like '%states%'
order by 1,2 


---Looking at total Cases vs. population 
-- show what percentage of population got covid
SELECT 
    location, 
    date, 
    total_cases, 
    population, 
    (CAST(total_cases AS FLOAT) / NULLIF(CAST(population AS FLOAT), 0)) * 100 AS CasesPercentage
FROM coviddeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2;

---What country has the highest infection rate based on the population

SELECT 
    location, 
    population, 
	MAX (total_cases)as HighestInfectionCount, 
    MAX (CAST(total_cases AS FLOAT) / NULLIF(CAST(population AS FLOAT), 0)) * 100 AS PercentPopulationInfected
FROM coviddeaths
GROUP BY Location, Population 
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per population 

SELECT 
    location, 
	MAX (cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..Coviddeaths
GROUP BY Location
ORDER BY TotalDeathCount DESC

---LET'S BREAK THINGS DOWN BY LOCATION

SELECT 
    location, 
	MAX (cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..Coviddeaths
WHERE total_deaths is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

---GLOBAL NUMBER 


SELECT 
    date,
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS INT)) AS total_deaths,
    SUM(CAST(new_deaths AS FLOAT)) / NULLIF(SUM(CAST(new_cases AS FLOAT)), 0) * 100 AS DeathPercentage
FROM 
    PortfolioProject..Coviddeaths
GROUP BY 
    date 
ORDER BY 
    date;

----Looking at population vs vaccinations----

Select vac.continent, dea.location, dea.date,dea.population

From PortfolioProject..Coviddeaths dea
Join PortfolioProject..Covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where vac.continent is not null
order by 1,2,3

----CTE-----
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac

Create Table #PercentagePopulationVaccinated 
(
continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null

--Creating View to store data for later visualizations

Create View PercentagePopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3 

Select *
From PercentagePopulationVaccinated