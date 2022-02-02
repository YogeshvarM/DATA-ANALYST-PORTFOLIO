/* SQL DATA EXPLORATION*/

/* Using Covid Data from "Ourworldindata" site */

/* After Importing Excel Workbook from local drive into MYsql using "ExcelMysql" application. 
   Yes, we can do import thing in Mysql itself but we need to convert them into .csv format.Also if you import .csv file then you need to specify the datatypes for each features.
   Deleting the empty rows and selecting the tables that got imported.
*/ I 
create database SQLDataExploration;
use SQLDataExploration;
select * from deaths_sheet1;
select * from vaccination_sheet1;

DELETE FROM deaths_sheet1 WHERE iso_code= '';
DELETE FROM vaccination_sheet1 WHERE iso_code= '';

/* Lets explore SQL more with this dataset*/

/*Settling Things by using Order by operation. 3,4 specifying the columns. 
 */
select * from deaths_sheet1
order by 3,4;

/*Setting up the required features*/
Select Location,Date,Continent,Population,Total_cases,new_Cases,Total_deaths,new_deaths from deaths_sheet1;

-- Total Cases vs Total Deaths in India
Select Location,Date,Continent,Population,Total_cases,Total_deaths,(Total_Deaths/Total_cases)*100 as DeathPercentage from deaths_sheet1
where (total_deaths is not null and total_cases is not null) and location='India'   /*TO  get accurate result im using where condition to avoid NULL values*/
order by 1,2;

-- Total Cases vs Population in India 
Select Location,Date,Continent,Population,Total_cases,(Total_cases/Population)*100 as PopulationAffectedInPercentage from deaths_sheet1
where (total_deaths is not null and total_cases is not null) and location='India'    /*TO  get accurate result im using where condition to avoid NULL values*/
order by 1,2;

-- Countries with Highest Infection Rate compared to Population
Select Location,Date,Continent,Max(total_cases) as HighestInfectedCases,MAX((Total_cases/Population)*100) as HigehstINfectionRateWithPopulation
from deaths_sheet1
where Continent !='' and total_deaths is not null and total_cases is not null
group by location
order by HigehstINfectionRateWithPopulation desc;


-- Countries with Highest Death Count per Population
Select Location,Date,Continent,Max(total_deaths) as HighestDeathCount,MAX((Total_deaths/Population)*100) as HighestDeathPerPopulation
from deaths_sheet1
where Continent !='' and total_deaths is not null and total_cases is not null /*and Location ='India'*/
group by location
order by HighestDeathPerPopulation desc;

-- Showing contintents with the highest death count per population
Select Location,Date,Continent,Max(total_deaths) as HighestDeathCount,MAX((Total_deaths/Population)*100) as HighestDeathPerPopulation
from deaths_sheet1
where Continent='' and total_deaths is not null and total_cases is not null /*and Location ='India'*/
group by location
order by HighestDeathPerPopulation desc;


-- Death Percentage
Select Location,SUM(new_cases) as total_case , sum(new_deaths) as total_Death,(sum(new_deaths)/SUM(new_cases))*100 as DeathPercentage -- (total_death/total_case)*100 as DeathPercentage "We cant execute this to execute the aggregrated columns we can use cte or temp table
from deaths_sheet1
where continent!='' and total_deaths is not null and total_cases is not null
group by location
order by DeathPercentage desc;

/* Using CTE to perform above query*/
With DeathvsCase (Continent,Location,total_Case,total_death)
as
(
Select Continent,Location,SUM(new_cases) as total_case , sum(new_deaths) as total_Death
from deaths_sheet1
where continent!='' and total_deaths is not null and total_cases is not null
group by location
)
Select *,(total_death/total_case)*100 as Death_Percentage
from DeathvsCase
order by Death_Percentage desc;

/* Using Temp Table */
Create temporary table Temp_Table(
Continent varchar(100),
Location varchar(100),
Total_case bigint,
total_Death bigint
);

Insert into Temp_Table
Select Continent,Location,SUM(new_cases) as total_case , sum(new_deaths) as total_Death
from deaths_sheet1
where continent!='' and total_deaths is not null and total_cases is not null
group by location;

Select *,(total_death/total_case)*100 as Death_Percentage
from Temp_Table
order by Death_Percentage desc;

-- Joining Two Tables
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From deaths_sheet1 as dea
Join vaccination_sheet1 as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;

#To perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From deaths_sheet1 as dea
Join vaccination_sheet1 as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 as Vaccinated_Percentage
From PopvsVac
Order by Vaccinated_Percentage desc;

