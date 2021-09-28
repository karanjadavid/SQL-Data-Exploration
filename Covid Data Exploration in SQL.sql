--View the table. 
SELECT *
FROM CovidData..CovidDeaths;

SELECT *
FROM CovidData..CovidVaccinations;

--Select the useful data.
SELECT location, date, total_cases, new_cases,total_deaths, population
FROM CovidData..CovidDeaths
ORDER BY 1,2;


--Percent of people who have died after contacting covid in Kenya.
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM CovidData..CovidDeaths
WHERE location = 'Kenya'
ORDER BY 1,2;

--What percent of Kenyans have contacted covid?
SELECT location, date, icu_patients, total_cases, (icu_patients/total_cases)*100 AS icu_percent
FROM CovidData..CovidDeaths
WHERE location = 'Kenya'
ORDER BY 1,2;

--What percent of Kenyans have been hospitalized in ICU due to covid?
SELECT location, date, population, total_cases, (total_cases/population)*100 AS covid_case_percent
FROM CovidData..CovidDeaths
WHERE location = 'Kenya'
ORDER BY 1,2;


--how many Kenyans have been fully vaccinated in Kenya so far?
SELECT location, MAX(people_fully_vaccinated) AS TotalPeopleVaccinated
FROM CovidData..CovidVaccinations
WHERE location = 'Kenya'
GROUP BY location;

---what percent of Kenyans have been fully vaccinated in Kenya so far?
SELECT vac.location, MAX(people_fully_vaccinated) AS TotalPeopleVaccinated, dea.population, 
(MAX(people_fully_vaccinated)/dea.population)*100 AS percentoffullyvaccinatedkenyans
FROM CovidData..CovidVaccinations vac
JOIN CovidData..CovidDeaths dea
ON vac.date = dea.date
AND vac.location = dea.location
WHERE vac.location = 'Kenya'
GROUP BY vac.location, dea.population;

--how many new tests were carried out in the month of August 2021 in Kenya?
SELECT location, date, new_tests
FROM CovidData..CovidVaccinations
WHERE  date BETWEEN '2021-08-01 00:00:00:000' AND '2021-08-31 00:00:00:000' AND
location = 'Kenya'
ORDER BY date;



-- Which nations have the highest infection rates compared to population?
SELECT location, population, MAX(total_cases) AS highestinfectionrate, MAX(total_cases/population)* 100 AS covid_case_percent 
FROM CovidData..CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC;

--Which nations have the highest death rates
SELECT location, population, MAX(total_deaths) AS highestdeathrate, MAX(total_deaths/population)* 100 AS covid_deaths_percent 
FROM CovidData..CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC;

--which nations have the highest death counts
--convert total_deaths data type to int using CAST
SELECT location, MAX(CAST(total_deaths AS int)) AS Totaldeathcount
FROM CovidData..CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY Totaldeathcount DESC;


--which continents have the highest death counts
--convert total_deaths data type to int using CAST
SELECT location, MAX(CAST(total_deaths AS int)) AS Totaldeathcount
FROM CovidData..CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY Totaldeathcount DESC;


--Total new deaths per day percentage
SELECT date, SUM(new_cases) AS totalnewcases, SUM(CAST(new_deaths AS int)) AS totalnewdeaths,
SUM(CAST(new_deaths AS int))/SUM(new_cases) AS totalnewdeathspercentage
FROM CovidData..CovidDeaths
WHERE continent is NOT NULL
GROUP BY date
ORDER BY date;





--Joining the two tables in the database
SELECT*
FROM CovidData..CovidDeaths dea
JOIN CovidData..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date




--total vaccination VS total population
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidData..CovidDeaths dea
JOIN CovidData..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;



--total vaccination VS total population
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION by dea.location) AS
totalcountryvaccinations
FROM CovidData..CovidDeaths dea
JOIN CovidData..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;



--total vaccination VS total population
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.location,
dea.date) AS rollingtotalcountryvaccinations
FROM CovidData..CovidDeaths dea
JOIN CovidData..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;





--Use CTE
WITH popvsVac (continent, location, date, population, new_vaccinations, rollingtotalcountryvaccinations) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.location,
dea.date) AS rollingtotalcountryvaccinations
FROM CovidData..CovidDeaths dea
JOIN CovidData..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *,(rollingtotalcountryvaccinations/population)*100
FROM popvsVac






--Temp table
DROP TABLE IF EXISTS percentpopulationvaccinated
CREATE TABLE percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingtotalcountryvaccinations numeric
);
INSERT INTO percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.location,
dea.date) AS rollingtotalcountryvaccinations
FROM CovidData..CovidDeaths dea
JOIN CovidData..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *,(rollingtotalcountryvaccinations/population)*100
FROM percentpopulationvaccinated





