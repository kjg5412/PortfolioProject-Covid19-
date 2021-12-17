select * from death
where continent is null
order by 3,4

select * from vaccinations
order by 3,4

-- Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
from death
where continent is not null
order by 1,2


-- Looking at Total cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths,
round((total_deaths/total_cases),5)*100 as DeathPercentage
from death
Where location like '%korea%' and continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Show what percentage of population got Covid-19
Select Location, date, total_cases, population,
round((total_cases/population), 5)*100 as PopulationInfectedPopulation
from death
Where continent is not null


-- Looking at Countries with Highest Infection Rate compared to Population
Select Location,
max(round((total_cases/population), 5)*100) as HighestInfectionRateCountry
from death
Where continent is not null
Group by Location
order by 2 desc
-- other way to solve this question
Select Location, Population, max(total_cases) as HighestInfectionCount,
max(round((total_cases/population), 5)*100) as PopulationInfectedPercent
from death
Where continent is not null
Group by location, population
order by PopulationInfectedPercent desc


-- Showing Countries with Highest Death Count per Population
-- Here is the issue with data type which is total_deaths column
-- need to convert it to integer
Select Location, 
max(cast(total_deaths as int)) as TotalDeathCount
From death
Where continent is not null
group by location
order by TotalDeathCount desc


-- LET'S break things down by continent
Select continent, 
max(cast(total_deaths as int)) as TotalDeathCount
From death
Where continent is not null
group by continent
order by TotalDeathCount desc


-- Showing Countries with Highest Death Rate per population
Select Location, Population, 
max(cast(total_deaths as int)) as TotalDeathCount,
max(round((total_deaths/population), 5)*100) as TotalDeathRate
from death
Where continent is not null
Group by location, population
order by TotalDeathRate desc


-- Showing continents with the highest death count per population
select continent,
max(cast(total_deaths as int)) as TotalDeathCount
from death
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global number of case, death by date
select 
sum(cast(new_deaths as int)) as TotalDeaths,
sum(new_cases) as TotalCases,
round(sum(cast(new_deaths as int))/sum(new_cases)*100,2) as DeathRate
from death
where continent is not null
--group by date
order by 1,2


-- Join
-- Looking at Total Population vs Vaccinations
select d.continent, d.location, d.date, d.population,
v.new_vaccinations from [PortfolioProject_4(Covid_updated)].. death d
join [PortfolioProject_4(Covid_updated)]..vaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null
order by 1,2,3

select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as bigint)) over (partition by d.location Order by d.location, d.Date) as PeopleVaccinated
from [PortfolioProject_4(Covid_updated)].. death d
join [PortfolioProject_4(Covid_updated)]..vaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null
order by 2,3

-- Use CTE(Common Table Expression)
with sample1 as (
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as bigint)) over (partition by d.location Order by d.location, d.Date) as PeopleVaccinated
from [PortfolioProject_4(Covid_updated)].. death d
join [PortfolioProject_4(Covid_updated)]..vaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null)

select *,
Round((PeopleVaccinated/population)*100, 2)
from sample1


-- Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as bigint)) over (partition by d.location Order by d.location, d.Date) as PeopleVaccinated
from [PortfolioProject_4(Covid_updated)].. death d
join [PortfolioProject_4(Covid_updated)]..vaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null

select *,
round((PeopleVaccinated/Population)*100, 4)
from #PercentPopulationVaccinated


Create View view1 as
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as bigint)) over (partition by d.location Order by d.location, d.Date) as PeopleVaccinated
from [PortfolioProject_4(Covid_updated)].. death d
join [PortfolioProject_4(Covid_updated)]..vaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null

select * from view1