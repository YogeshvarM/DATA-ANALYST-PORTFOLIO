use sqldataexploration;

-- Query for Tableau  

Select SUM(new_cases) as total_cases, SUM(new_deaths ) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From deaths_sheet1
where continent!=''
order by 1,2;

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe
Select location, SUM(new_deaths) as TotalDeathCount
From deaths_sheet1
Where continent=''
and location not in ('World', 'European Union', 'International','Upper middle income','High income','Lower Middle income','Low income')
Group by location
order by TotalDeathCount desc;

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From deaths_sheet1
Group by Location, Population
order by PercentPopulationInfected desc;

/*Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From deaths_sheet1
Group by Location, Population, date
order by PercentPopulationInfected desc;
*/
