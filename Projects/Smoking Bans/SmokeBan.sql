
CREATE DATABASE SmokeBan;

/*
Loads the Excel file with the data.
I get a lot of duplicate rows, probably Excel was inflated like that.
The Row_Number() command numbers a row according to conditions, that's how you see how many duplicates there are.

create view which shows only a single line and not identical double lines.
*/

Create view SmokersDis AS 
With RowIdCTE AS (
Select *,
	Row_Number() Over(
	Partition By id,
				 smoker,
				 ban, 
				 age, 
				 education, 
				 afam, 
				 hispanic, 
				 gender
				 Order By 
				 id
				 ) row_id
From SmokeBan.dbo.SmokeBan
)
Select *
From RowIdCTE
Where row_id=1
--order by id


Select *
From SmokersDis
order by id

/*
You are left with 10,000 rows and you can work with it with the help of:
SmokersDis


To find the median age of men or women, you need to make separate tables for the calculation, because there is no direct function for the median.

First make a separate View for women and a separate one for men.

*/
Create view SmokersDisF AS 
With RowIdFCTE AS (
Select *,
	Row_Number() over (order by age) row_idF
From SmokersDis
where Gender='Female'
)
Select *
From RowIdFCTE



Create view SmokersDisM AS 
With RowIdMCTE AS (
Select *,
	Row_Number() over (order by age) row_idM
From SmokersDis
where Gender='Male'
)
Select *
From RowIdMCTE

/*
Now doing the median calculations separately, first for women and then for men. The difference in the M/F signal
It actually takes the maximum age from the upper 50% of the age when the table is arranged by ascending serial number (it's actually the lower half. You take the last number as you move to the second half),
Add to this the minimum age from the upper 50% of the age when the table is arranged according to descending serial number (this is actually the upper half. Take the last number as you move to the first half),
That is, you take the two numbers that are right in the middle, add them together, then divide by 2.
*/

SELECT ( (SELECT MAX(age)
          FROM   (SELECT TOP 50 PERCENT age  
                  FROM SmokersDisF ORDER BY row_idF) AS BOTTOM_HALF)
         + (SELECT MIN(age)
            FROM   (SELECT TOP 50 PERCENT age
                    FROM SmokersDisF ORDER BY row_idF DESC) AS TOPHALF) ) / 2 AS MEDIAN_F


SELECT ( (SELECT MAX(age)
          FROM   (SELECT TOP 50 PERCENT age  
                  FROM SmokersDisM ORDER BY row_idM) AS BOTTOM_HALF)
         + (SELECT MIN(age)
            FROM   (SELECT TOP 50 PERCENT age
                    FROM SmokersDisM ORDER BY row_idM DESC) AS TOPHALF) ) / 2 AS MEDIAN_M


--Display percentages with the format where the number next to p determines how many numbers after the decimal point it's going to show
SELECT FORMAT((1.0/5.0),'P3') as [ThreeDecimalsPercentage]


--Creates View of MEDIAN_Smokers_race: 
--median age of smokers, median of black, Hispanic, white smokers

Create view MEDIAN_Smokers_race AS
SELECT 
( (SELECT MAX(age)
          FROM   (SELECT TOP 50 PERCENT age  
                  FROM SmokersDis Where smoker='yes' ORDER BY row_id) AS BOTTOM_HALF)
         + (SELECT MIN(age)
            FROM   (SELECT TOP 50 PERCENT age
                    FROM SmokersDis Where smoker='yes' ORDER BY row_id DESC) AS TOPHALF) ) / 2 AS MEDIAN_Smokers,

( (SELECT MAX(age)
          FROM   (SELECT TOP 50 PERCENT age  
                  FROM SmokersDis Where smoker='yes' and afam='yes' ORDER BY row_id) AS BOTTOM_HALF)
         + (SELECT MIN(age)
            FROM   (SELECT TOP 50 PERCENT age
                    FROM SmokersDis Where smoker='yes' and afam='yes' ORDER BY row_id DESC) AS TOPHALF) ) / 2 AS MEDIAN_B_Smokers,

( (SELECT MAX(age)
          FROM   (SELECT TOP 50 PERCENT age  
                  FROM SmokersDis Where smoker='yes' and hispanic='yes' ORDER BY row_id) AS BOTTOM_HALF)
         + (SELECT MIN(age)
            FROM   (SELECT TOP 50 PERCENT age
                    FROM SmokersDis Where smoker='yes' and hispanic='yes' ORDER BY row_id DESC) AS TOPHALF) ) / 2 AS MEDIAN_H_Smokers,

( (SELECT MAX(age)
          FROM   (SELECT TOP 50 PERCENT age  
                  FROM SmokersDis Where smoker='yes' and hispanic='no' and afam='no' ORDER BY row_id) AS BOTTOM_HALF)
         + (SELECT MIN(age)
            FROM   (SELECT TOP 50 PERCENT age
                    FROM SmokersDis Where smoker='yes' and hispanic='no' and afam='no' ORDER BY row_id DESC) AS TOPHALF) ) / 2 AS MEDIAN_W_Smokers


--Making a View of MEDIAN_Smokers_race_gender:
--Median age of smokers, median of black, Hispanic, white smokers by male and female sex

Create view MEDIAN_Smokers_race_gender AS
SELECT 
( (SELECT MAX(age)
          FROM   (SELECT TOP 50 PERCENT age  
                  FROM SmokersDis Where smoker='yes' and gender='Male' ORDER BY row_id) AS BOTTOM_HALF)
         + (SELECT MIN(age)
            FROM   (SELECT TOP 50 PERCENT age
                    FROM SmokersDis Where smoker='yes' and gender='Male' ORDER BY row_id DESC) AS TOPHALF) ) / 2 AS MEDIAN_MSmokers,

					( (SELECT MAX(age)
          FROM   (SELECT TOP 50 PERCENT age  
                  FROM SmokersDis Where smoker='yes' and gender='Female' ORDER BY row_id) AS BOTTOM_HALF)
         + (SELECT MIN(age)
            FROM   (SELECT TOP 50 PERCENT age
                    FROM SmokersDis Where smoker='yes' and gender='Female' ORDER BY row_id DESC) AS TOPHALF) ) / 2 AS MEDIAN_FSmokers,

( (SELECT MAX(age)
          FROM   (SELECT TOP 50 PERCENT age  
                  FROM SmokersDis Where smoker='yes' and afam='yes' and gender='Male' ORDER BY row_id) AS BOTTOM_HALF)
         + (SELECT MIN(age)
            FROM   (SELECT TOP 50 PERCENT age
                    FROM SmokersDis Where smoker='yes' and afam='yes' and gender='Male' ORDER BY row_id DESC) AS TOPHALF) ) / 2 AS MEDIAN_B_MSmokers,

					( (SELECT MAX(age)
          FROM   (SELECT TOP 50 PERCENT age  
                  FROM SmokersDis Where smoker='yes' and afam='yes' and gender='Female' ORDER BY row_id) AS BOTTOM_HALF)
         + (SELECT MIN(age)
            FROM   (SELECT TOP 50 PERCENT age
                    FROM SmokersDis Where smoker='yes' and afam='yes' and gender='Female' ORDER BY row_id DESC) AS TOPHALF) ) / 2 AS MEDIAN_B_FSmokers,

( (SELECT MAX(age)
          FROM   (SELECT TOP 50 PERCENT age  
                  FROM SmokersDis Where smoker='yes' and hispanic='yes' and gender='Male' ORDER BY row_id) AS BOTTOM_HALF)
         + (SELECT MIN(age)
            FROM   (SELECT TOP 50 PERCENT age
                    FROM SmokersDis Where smoker='yes' and hispanic='yes'and gender='Male' ORDER BY row_id DESC) AS TOPHALF) ) / 2 AS MEDIAN_H_MSmokers,

( (SELECT MAX(age)
          FROM   (SELECT TOP 50 PERCENT age  
                  FROM SmokersDis Where smoker='yes' and hispanic='yes' and gender='Female' ORDER BY row_id) AS BOTTOM_HALF)
         + (SELECT MIN(age)
            FROM   (SELECT TOP 50 PERCENT age
                    FROM SmokersDis Where smoker='yes' and hispanic='yes'and gender='Female' ORDER BY row_id DESC) AS TOPHALF) ) / 2 AS MEDIAN_H_FSmokers,

( (SELECT MAX(age)
          FROM   (SELECT TOP 50 PERCENT age  
                  FROM SmokersDis Where smoker='yes' and hispanic='no' and afam='no' and gender='Male' ORDER BY row_id) AS BOTTOM_HALF)
         + (SELECT MIN(age)
            FROM   (SELECT TOP 50 PERCENT age
                    FROM SmokersDis Where smoker='yes' and hispanic='no' and afam='no' and gender='Male' ORDER BY row_id DESC) AS TOPHALF) ) / 2 AS MEDIAN_W_MSmokers,

( (SELECT MAX(age)
          FROM   (SELECT TOP 50 PERCENT age  
                  FROM SmokersDis Where smoker='yes' and hispanic='no' and afam='no' and gender='Female' ORDER BY row_id) AS BOTTOM_HALF)
         + (SELECT MIN(age)
            FROM   (SELECT TOP 50 PERCENT age
                    FROM SmokersDis Where smoker='yes' and hispanic='no' and afam='no' and gender='Female' ORDER BY row_id DESC) AS TOPHALF) ) / 2 AS MEDIAN_W_FSmokers

--Doing a View of MEDIAN_NotSmokers_race_gender:
--Median age of non-smokers, median black, Hispanic, white non-smokers by male and female sex

Create view MEDIAN_NotSmokers_race_gender AS
SELECT 
( (SELECT MAX(age)
          FROM   (SELECT TOP 50 PERCENT age  
                  FROM SmokersDis Where smoker='no' and gender='Male' ORDER BY row_id) AS BOTTOM_HALF)
         + (SELECT MIN(age)
            FROM   (SELECT TOP 50 PERCENT age
                    FROM SmokersDis Where smoker='no' and gender='Male' ORDER BY row_id DESC) AS TOPHALF) ) / 2 AS MEDIAN_MNotSmokers,

					( (SELECT MAX(age)
          FROM   (SELECT TOP 50 PERCENT age  
                  FROM SmokersDis Where smoker='no' and gender='Female' ORDER BY row_id) AS BOTTOM_HALF)
         + (SELECT MIN(age)
            FROM   (SELECT TOP 50 PERCENT age
                    FROM SmokersDis Where smoker='no' and gender='Female' ORDER BY row_id DESC) AS TOPHALF) ) / 2 AS MEDIAN_FNotSmokers,

( (SELECT MAX(age)
          FROM   (SELECT TOP 50 PERCENT age  
                  FROM SmokersDis Where smoker='no' and afam='yes' and gender='Male' ORDER BY row_id) AS BOTTOM_HALF)
         + (SELECT MIN(age)
            FROM   (SELECT TOP 50 PERCENT age
                    FROM SmokersDis Where smoker='no' and afam='yes' and gender='Male' ORDER BY row_id DESC) AS TOPHALF) ) / 2 AS MEDIAN_B_MNotSmokers,

					( (SELECT MAX(age)
          FROM   (SELECT TOP 50 PERCENT age  
                  FROM SmokersDis Where smoker='no' and afam='yes' and gender='Female' ORDER BY row_id) AS BOTTOM_HALF)
         + (SELECT MIN(age)
            FROM   (SELECT TOP 50 PERCENT age
                    FROM SmokersDis Where smoker='no' and afam='yes' and gender='Female' ORDER BY row_id DESC) AS TOPHALF) ) / 2 AS MEDIAN_B_FNotSmokers,

( (SELECT MAX(age)
          FROM   (SELECT TOP 50 PERCENT age  
                  FROM SmokersDis Where smoker='no' and hispanic='yes' and gender='Male' ORDER BY row_id) AS BOTTOM_HALF)
         + (SELECT MIN(age)
            FROM   (SELECT TOP 50 PERCENT age
                    FROM SmokersDis Where smoker='no' and hispanic='yes'and gender='Male' ORDER BY row_id DESC) AS TOPHALF) ) / 2 AS MEDIAN_H_MNotSmokers,

( (SELECT MAX(age)
          FROM   (SELECT TOP 50 PERCENT age  
                  FROM SmokersDis Where smoker='no' and hispanic='yes' and gender='Female' ORDER BY row_id) AS BOTTOM_HALF)
         + (SELECT MIN(age)
            FROM   (SELECT TOP 50 PERCENT age
                    FROM SmokersDis Where smoker='no' and hispanic='yes'and gender='Female' ORDER BY row_id DESC) AS TOPHALF) ) / 2 AS MEDIAN_H_FNotSmokers,

( (SELECT MAX(age)
          FROM   (SELECT TOP 50 PERCENT age  
                  FROM SmokersDis Where smoker='no' and hispanic='no' and afam='no' and gender='Male' ORDER BY row_id) AS BOTTOM_HALF)
         + (SELECT MIN(age)
            FROM   (SELECT TOP 50 PERCENT age
                    FROM SmokersDis Where smoker='no' and hispanic='no' and afam='no' and gender='Male' ORDER BY row_id DESC) AS TOPHALF) ) / 2 AS MEDIAN_W_MNotSmokers,

( (SELECT MAX(age)
          FROM   (SELECT TOP 50 PERCENT age  
                  FROM SmokersDis Where smoker='no' and hispanic='no' and afam='no' and gender='Female' ORDER BY row_id) AS BOTTOM_HALF)
         + (SELECT MIN(age)
            FROM   (SELECT TOP 50 PERCENT age
                    FROM SmokersDis Where smoker='no' and hispanic='no' and afam='no' and gender='Female' ORDER BY row_id DESC) AS TOPHALF) ) / 2 AS MEDIAN_W_FNotSmokers

/*
Making a View of F_M_AfterBan:
A woman does not smoke after a boycott - percent
A woman smokes after a boycott - percent
A man does not smoke after a boycott - percent
A man smokes after a boycott - percent
*/

Create view F_M_AfterBan AS
Select FORMAT(
(Select(
Select Count(id)
From SmokersDisF
Where ban='yes' and smoker='no'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisF
Where ban='yes' 
group by ban
)*1.0),'P2')
AS WomenNotSmoksAfterBan,
FORMAT(
(Select(
Select Count(id)
From SmokersDisF
Where ban='yes' and smoker='yes'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisF
Where ban='yes' 
group by ban
)*1.0),'P2')
AS WomenSmoksAfterBan,

FORMAT(
(Select(
Select Count(id)
From SmokersDisM
Where ban='yes' and smoker='no'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisM
Where ban='yes' 
group by ban
)*1.0),'P2')
AS MenNotSmoksAfterBan,

FORMAT(
(Select(
Select Count(id)
From SmokersDisM
Where ban='yes' and smoker='yes'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisM
Where ban='yes' 
group by ban
)*1.0),'P2')
AS MenSmoksAfterBan

/*
Making a View of F_M_NoBan:
A woman does not smoke without a boycott - percent
A woman smokes without a boycott - percent
A man does not smoke without a boycott - percent
A man smokes without a boycott - percent
*/

Create view F_M_NoBan AS
Select FORMAT(
(Select(
Select Count(id)
From SmokersDisF
Where ban='no' and smoker='no'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisF
Where ban='no' 
group by ban
)*1.0),'P2')
AS WomenNotSmoksNoBan,
FORMAT(
(Select(
Select Count(id)
From SmokersDisF
Where ban='no' and smoker='yes'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisF
Where ban='no' 
group by ban
)*1.0),'P2')
AS WomenSmoksNoBan,

FORMAT(
(Select(
Select Count(id)
From SmokersDisM
Where ban='no' and smoker='no'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisM
Where ban='no' 
group by ban
)*1.0),'P2')
AS MenNotSmoksNoBan,

FORMAT(
(Select(
Select Count(id)
From SmokersDisM
Where ban='no' and smoker='yes'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisM
Where ban='no' 
group by ban
)*1.0),'P2')
AS MenSmoksNoBan

/*
Making a View of B_F_M_AfterBan:
A black woman does not smoke after a boycott - percent
A black woman smokes after a boycott - percent
A black man does not smoke after a boycott - percent
A black man smokes after a boycott - percent
*/

Create view B_F_M_AfterBan AS
Select FORMAT(
(Select(
Select Count(id)
From SmokersDisF
Where ban='yes' and smoker='no' and afam='yes'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisF
Where ban='yes' and afam='yes'
group by ban
)*1.0),'P2')
AS BWomenNotSmoksAfterBan,

FORMAT(
(Select(
Select Count(id)
From SmokersDisF
Where ban='yes' and smoker='yes' and afam='yes'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisF
Where ban='yes' and afam='yes'
group by ban
)*1.0),'P2')
AS BWomenSmoksAfterBan,

FORMAT(
(Select(
Select Count(id)
From SmokersDisM
Where ban='yes' and smoker='no' and afam='yes'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisM
Where ban='yes' and afam='yes'
group by ban
)*1.0),'P2')
AS BMenNotSmoksAfterBan,

FORMAT(
(Select(
Select Count(id)
From SmokersDisM
Where ban='yes' and smoker='yes' and afam='yes'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisM
Where ban='yes' and afam='yes'
group by ban
)*1.0),'P2')
AS BMenSmoksAfterBan

/*
Making a View of B_F_M_NoBan:
A black woman does not smoke without a boycott - percent
A black woman smokes without a boycott - percent
A black man does not smoke without a boycott - percent
A black man smokes without a boycott - percent
*/

Create view B_F_M_NoBan AS
Select FORMAT(
(Select(
Select Count(id)
From SmokersDisF
Where ban='no' and smoker='no' and afam='yes'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisF
Where ban='no' and afam='yes'
group by ban
)*1.0),'P2')
AS BWomenNotSmoksNoBan,

FORMAT(
(Select(
Select Count(id)
From SmokersDisF
Where ban='no' and smoker='yes' and afam='yes'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisF
Where ban='no' and afam='yes'
group by ban
)*1.0),'P2')
AS BWomenSmoksNoBan,

FORMAT(
(Select(
Select Count(id)
From SmokersDisM
Where ban='no' and smoker='no' and afam='yes'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisM
Where ban='no' and afam='yes'
group by ban
)*1.0),'P2')
AS BMenNotSmoksNoBan,

FORMAT(
(Select(
Select Count(id)
From SmokersDisM
Where ban='no' and smoker='yes' and afam='yes'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisM
Where ban='no' and afam='yes'
group by ban
)*1.0),'P2')
AS BMenSmoksNoBan



--Smokers by education level, and counting people by education level


Select education, Count(smoker)AS SmokeNum
From SmokersDis
Where smoker='yes'
Group by education
Order by SmokeNum


Select education, Count(smoker)AS SmokeNum
From SmokersDis
Group by education
Order by SmokeNum

/*
Making View of SmokeByEducation:
The proportion of smokers by level of education
hs dropped out, hs, some college, college, master
*/

Create view SmokeByEducation AS
SELECT FORMAT((
(Select(
Select Count(smoker)
From SmokersDis
Where education='hs drop out' and smoker='yes' 
Group by education
)*1.0)
/
(Select(
Select Count(smoker)
From SmokersDis
Where education='hs drop out'
Group by education
)*1.0)
),'P2') As HsDropOutSmokes,

FORMAT((
(Select(
Select Count(smoker)
From SmokersDis
Where education='hs' and smoker='yes' 
Group by education
)*1.0)
/
(Select(
Select Count(smoker)
From SmokersDis
Where education='hs'
Group by education
)*1.0)
),'P2') As HsSmokes,

FORMAT((
(Select(
Select Count(smoker)
From SmokersDis
Where education='some college' and smoker='yes' 
Group by education
)*1.0)
/
(Select(
Select Count(smoker)
From SmokersDis
Where education='some college'
Group by education
)*1.0)
),'P2') As SomeCollegeSmokes,

FORMAT((
(Select(
Select Count(smoker)
From SmokersDis
Where education='college' and smoker='yes' 
Group by education
)*1.0)
/
(Select(
Select Count(smoker)
From SmokersDis
Where education='college'
Group by education
)*1.0)
),'P2') As CollegeSmokes,

FORMAT((
(Select(
Select Count(smoker)
From SmokersDis
Where education='master' and smoker='yes' 
Group by education
)*1.0)
/
(Select(
Select Count(smoker)
From SmokersDis
Where education='master'
Group by education
)*1.0)
),'P2') As MasterSmokes

/*
Making a View of H_F_M_AfterBan:
A Hispanic woman does not smoke after a boycott - percent
A Hispanic woman smokes after a boycott - percent
A Hispanic man does not smoke after a boycott - percent
A Hispanic man smokes after a boycott - percent
*/

Create view H_F_M_AfterBan AS
Select FORMAT(
(Select(
Select Count(id)
From SmokersDisF
Where ban='yes' and smoker='no' and hispanic='yes'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisF
Where ban='yes' and hispanic='yes'
group by ban
)*1.0),'P2')
AS HWomenNotSmoksAfterBan,

FORMAT(
(Select(
Select Count(id)
From SmokersDisF
Where ban='yes' and smoker='yes' and hispanic='yes'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisF
Where ban='yes' and hispanic='yes'
group by ban
)*1.0),'P2')
AS HWomenSmoksAfterBan,

FORMAT(
(Select(
Select Count(id)
From SmokersDisM
Where ban='yes' and smoker='no' and hispanic='yes'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisM
Where ban='yes' and hispanic='yes'
group by ban
)*1.0),'P2')
AS HMenNotSmoksAfterBan,

FORMAT(
(Select(
Select Count(id)
From SmokersDisM
Where ban='yes' and smoker='yes' and hispanic='yes'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisM
Where ban='yes' and hispanic='yes'
group by ban
)*1.0),'P2')
AS HMenSmoksAfterBan

/*
Making a View of H_F_M_NoBan:
A Hispanic woman does not smoke without a boycott - percentages
A Hispanic woman smokes without a boycott - percent
A Hispanic man does not smoke without a boycott - percent
A Hispanic man smokes without a boycott - percent
*/

Create view H_F_M_NoBan AS
Select FORMAT(
(Select(
Select Count(id)
From SmokersDisF
Where ban='no' and smoker='no' and hispanic='yes'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisF
Where ban='no' and hispanic='yes'
group by ban
)*1.0),'P2')
AS HWomenNotSmoksNoBan,

FORMAT(
(Select(
Select Count(id)
From SmokersDisF
Where ban='no' and smoker='yes' and hispanic='yes'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisF
Where ban='no' and hispanic='yes'
group by ban
)*1.0),'P2')
AS HWomenSmoksNoBan,

FORMAT(
(Select(
Select Count(id)
From SmokersDisM
Where ban='no' and smoker='no' and hispanic='yes'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisM
Where ban='no' and hispanic='yes'
group by ban
)*1.0),'P2')
AS HMenNotSmoksNoBan,

FORMAT(
(Select(
Select Count(id)
From SmokersDisM
Where ban='no' and smoker='yes' and hispanic='yes'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisM
Where ban='no' and hispanic='yes'
group by ban
)*1.0),'P2')
AS HMenSmoksNoBan

/*
Making a View of W_F_M_AfterBan:
A white woman does not smoke after a boycott - percent
A white woman smokes after a boycott - percent
A white man does not smoke after a boycott - percent
A white man smokes after a boycott - percent
*/

Create view W_F_M_AfterBan AS
Select FORMAT(
(Select(
Select Count(id)
From SmokersDisF
Where ban='yes' and smoker='no' and hispanic='no' and afam='no'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisF
Where ban='yes' and hispanic='no' and afam='no'
group by ban
)*1.0),'P2')
AS WWomenNotSmoksAfterBan,

FORMAT(
(Select(
Select Count(id)
From SmokersDisF
Where ban='yes' and smoker='yes' and hispanic='no' and afam='no'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisF
Where ban='yes' and hispanic='no' and afam='no'
group by ban
)*1.0),'P2')
AS WWomenSmoksAfterBan,

FORMAT(
(Select(
Select Count(id)
From SmokersDisM
Where ban='yes' and smoker='no' and hispanic='no' and afam='no'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisM
Where ban='yes' and hispanic='no' and afam='no'
group by ban
)*1.0),'P2')
AS WMenNotSmoksAfterBan,

FORMAT(
(Select(
Select Count(id)
From SmokersDisM
Where ban='yes' and smoker='yes' and hispanic='no' and afam='no'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisM
Where ban='yes' and hispanic='no' and afam='no'
group by ban
)*1.0),'P2')
AS WMenSmoksAfterBan

/*
Making a View of W_F_M_NoBan:
A white woman does not smoke without a boycott - percent
A white woman smokes without a boycott - percent
A white man does not smoke without a boycott - percent
A white man smokes without a boycott - percent
*/

Create view W_F_M_NoBan AS
Select FORMAT(
(Select(
Select Count(id)
From SmokersDisF
Where ban='no' and smoker='no' and hispanic='no' and afam='no'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisF
Where ban='no' and hispanic='no' and afam='no'
group by ban
)*1.0),'P2')
AS WWomenNotSmoksNoBan,

FORMAT(
(Select(
Select Count(id)
From SmokersDisF
Where ban='no' and smoker='yes' and hispanic='no' and afam='no'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisF
Where ban='no' and hispanic='no' and afam='no'
group by ban
)*1.0),'P2')
AS WWomenSmoksNoBan,

FORMAT(
(Select(
Select Count(id)
From SmokersDisM
Where ban='no' and smoker='no' and hispanic='no' and afam='no'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisM
Where ban='no' and hispanic='no' and afam='no'
group by ban
)*1.0),'P2')
AS WMenNotSmoksNoBan,

FORMAT(
(Select(
Select Count(id)
From SmokersDisM
Where ban='no' and smoker='yes' and hispanic='no' and afam='no'
)*1.0)
/
(
Select(
Select Count(id)
From SmokersDisM
Where ban='no' and hispanic='no' and afam='no'
group by ban
)*1.0),'P2')
AS WMenSmoksNoBan

/*
Views summary

SmokersDis
SmokersDisF
SmokersDisM
MEDIAN_Smokers_race
MEDIAN_Smokers_race_gender
MEDIAN_NotSmokers_race_gender
F_M_AfterBan
F_M_NoBan
B_F_M_AfterBan
B_F_M_NoBan
SmokeByEducation
H_F_M_AfterBan
H_F_M_NoBan
W_F_M_AfterBan
W_F_M_NoBan

*/





