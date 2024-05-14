
---------------------SELECTIONNER LES COLONNES QUI NOUS INTERESSE----------------------------------------
 SELECT location, date,new_cases, total_cases, total_deaths,population
 FROM CovidDeaths
 order by 1,2

 ------------------porcentage de Meutre par jour si vous contractez le covid dans votre pays--------------------------------------------
 
 SELECT location, date,total_cases, total_deaths,(total_deaths/total_cases)*100  AS Pourcentage_de_mort --Le taux de meurtre de la covid 19 aux etats unis par jour
 FROM CovidDeaths
 WHERE location LIKE '%state%' 
 order by 3 desc

------------------Nombre total de cas par rapport a la population par jour----------------------------------------
 SELECT location, date,total_cases, population,(total_cases/population)*100  AS Pourcentage_infecté --Pourcentage de la population infecté par jour
 FROM CovidDeaths
 WHERE location LIKE '%state%' 
 order by 1,2

 -------------Pays(population) ayant le taux d'infections le plus elevé -------------------------------------------------
 SELECT location, population, Max(total_cases) as cas_le_plus_elevé, MAX((total_cases/population)*100)  AS PoucentagePop
 FROM CovidDeaths
 group by location, population
 order by PoucentagePop desc

------------------Pays(population) ayant le taux de mortalite le plus elevé --------------------------------------------

SELECT location,population,Max(CONVERT (int,total_deaths)) as motalité, (Max(CONVERT (int,total_deaths))/population)*100 as taux_Mortalité
FROM CovidDeaths
where continent is not null --and location LIKE '%ivoire%'
group by location, population
order by 4desc

------------------Pays ayant enregistrer le plus de mort --------------------------------------------

 SELECT location,Max(cast(total_deaths as int)) as Nbre_Mort_Total--Max((total_deaths/population)*100)  AS Pourcentage_de_mortalité --Le taux de meurtre de la covid 19 aux etats unis par jour
 FROM CovidDeaths
 WHERE continent IS NOT NULL
 group by location
 order by Nbre_Mort_Total DESC


------------------Continent avec le Nbre de mort le plus elevé--------------------------------------------

SELECT continent, Max(cast(total_deaths as int)) as Mortalité--, (Max(cast(total_deaths as int))/population)*100 as taux_de_mortalité
FROM CovidDeaths
WHERE continent IS NOT NULL
group by continent
order by Mortalité DESC


------------------Continent avec le taux de mortalité le plus elevé par rapport a la population continentale--------------------------------------------

 SELECT continent,(Sum(cast(total_deaths as int))/ Sum(population))*100 as taux_mortalité--, (Max(cast(total_deaths as int))/population)*100 as taux_de_mortalité
 FROM CovidDeaths
 WHERE continent IS NOT NULL
 group by continent
 order by taux_mortalité DESC

 ------------------------------Chiffres Mondiaux----------------------------------------------------------

 SELECT date, SUM(new_cases) as Nouveaux_cas, SUM(cast(new_deaths as int)) as Nvelle_Mortalité, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as taux_de_mortalité
 FROM CovidDeaths
 WHERE continent IS NOT NULL
 group by date
 order by taux_de_mortalité desc

 SELECT location,population, SUM(new_cases) as cas_Mondiaux, SUM(cast(new_deaths as int)) as Mortalité_Mondial, (SUM(cast(new_deaths as int))/population)*100 as taux_de_mortalité_Mondial,(SUM(new_cases)/population)*100 as contamination_Mondial
 FROM CovidDeaths
 WHERE location LIKE '%world%'
 group by location,population


 --------------jointure entre les deux tables(combien de personnes on ete vaccinees dans le monde)----------------------------------------------------------
 
 --VACCINATION PAR JOUR

 SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
 FROM CovidDeaths as cd
 JOIN CovidVaccinations as cv
	ON cd.location = cv.location
	and cd.date = cv.date
Where  cd.continent IS NOT NULL
order by 1,2


 SELECT cd.location, SUM(CONVERT(int,cv.new_vaccinations)) as total_vaccination
 FROM CovidDeaths as cd
 JOIN CovidVaccinations as cv
	ON cd.location = cv.location
	and cd.date = cv.date
Where  cd.continent IS NOT NULL and cd.location LIKE '%ivoire%'
group by cd.location
order by total_vaccination desc

WITH CTE_VccMonde (continent, Vacciné) AS
 (SELECT cd.continent, SUM(CONVERT(int,cv.new_vaccinations)) as Vaccinés
 FROM CovidDeaths as cd
 JOIN CovidVaccinations as cv
	ON cd.location = cv.location
	and cd.date = cv.date
Where  cd.continent IS NOT NULL and cv.new_vaccinations is not null
group by cd.continent
)

SELECT Sum(Vacciné) as Nombre_Vacciné_Mondial
FROM CTE_VccMonde


SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(int,cv.new_vaccinations)) OVER (PARTITION BY cd.location order by cd.location, cd.date) as total_vaccination
FROM CovidDeaths as cd
 JOIN CovidVaccinations as cv
	ON cd.location = cv.location
	and cd.date = cv.date
Where  cd.continent IS NOT NULL and cd.location LIKE '%ivoire%' and cv.new_vaccinations IS NOT NULL
order by 2,3 

------------------------------COMMON TABLE EXPRESSION----------------------------------------------------

WITH CTE_Vacc (continent, location, date, population, new_vaccinations, total_vaccination) AS 

(SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(int,cv.new_vaccinations)) OVER (PARTITION BY cd.location order by cd.location, cd.date) as total_vaccination
FROM CovidDeaths as cd
 JOIN CovidVaccinations as cv
	ON cd.location = cv.location
	and cd.date = cv.date
Where  cd.continent IS NOT NULL and cv.new_vaccinations IS NOT NULL
)--order by 2,3) 

SELECT *, (total_vaccination/population)*100 AS taux_de_vaccination_par_jour
FROM CTE_Vacc


------------------------------TEMP TABLE-----------------------------------------------------------------

--DROP  TABLE IF EXISTS #temp_vacc
--CREATE TABLE #temp_vacc 
--(Continents varchar(100),
--total_Vacc int
--)

--INSERT INTO #temp_vacc
-- SELECT cd.continent,SUM(cast(cv.new_vaccinations as int)) as Pers_Vacc
-- FROM CovidDeaths as cd
-- JOIN CovidVaccinations as cv
--	ON cd.location = cv.location
--	and cd.date = cv.date
--Where  cd.continent IS NOT NULL --and cd.location LIKE '%ivoire%'
--group by cd.continent

--SELECT SUM(total_Vacc) as Total_vaccin
--FROM #temp_vacc



----------------------------------------CREATION DES VUES POUR LA VISUALISATION-------------------------------------------------

--CREATE VIEW taux_de_vaccination_par_jour AS

--WITH CTE_Vacc (continent, location, date, population, new_vaccinations, total_vaccination) AS 

--(SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(int,cv.new_vaccinations)) OVER (PARTITION BY cd.location order by cd.location, cd.date) as total_vaccination
--FROM CovidDeaths as cd
-- JOIN CovidVaccinations as cv
--	ON cd.location = cv.location
--	and cd.date = cv.date
--Where  cd.continent IS NOT NULL and cv.new_vaccinations IS NOT NULL
--)

--SELECT *, (total_vaccination/population)*100 AS taux_de_vaccination_par_jour
--FROM CTE_Vacc


--SELECT *
--FROM taux_de_vaccination_par_jour
