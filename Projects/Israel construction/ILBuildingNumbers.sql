/*
working on different SQL skills
*/

CREATE DATABASE ILBuildingNumbers;

/*
loading the numbers to the SQL database

In order to decrease the population number from the previous number I joined the table to itself.
I put that into CTE in order to make the first calculation, and put that into a view,
in order to make new calculations.
then finally created a last view with the results. 
*/

create view houses2 as
With houses2CTE AS (
Select h.Year, h.Starts, h.Ends, Round(h.Population_percent,0,1) AS Pop_percent_n, 
cast(Round(((h.Population_percent-h1.Population_percent)*100),0,1) as int) AS PopAdd
From houses h JOIN houses h1
ON h.Year=h1.Year+1)
Select *, Round(cast((PopAdd/3.25) as int),0,1) AS Household
From houses2CTE


Create view houses3 as
Select *,Round(((Starts*0.98)-Household),0,1) AS StartGap,
Round(((Ends*0.98)-Household),0,1) AS EndsGap
From houses2


Select *
From houses3


-- Last View houses3
