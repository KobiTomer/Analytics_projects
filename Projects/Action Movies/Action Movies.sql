/*
working on different SQL skills
Database data cleaning
*/

CREATE DATABASE Movies;

/* 
Change the CSV to Excel and load it to the SQL
change the names of the table
clean the file for smooth use
*/

EXEC sp_rename 'dbo.action_series$', 'Action';



Select *,
CAST((Substring(Runtime,1, CHARINDEX('m',Runtime)-1)) AS int) as runtime_n
From Action
where [Gross Revenue] is not null and Runtime is not null

המרתי את זמני הסרט למספר. 
צריך שלא יהיו סרטים כפולים לפי שם הסרט




/*
I create a view called C_Action [Clean]
and at that code, I use CTE to give row numbers to each unique line with Partition By. 
If it's not unique, and it's duplicate, it will get a number bigger than 1. 
So I pick only lines equal to 1.

At the same time, I change the runtime column to Int and show numbers only.
In the end, I clean lines with Null.
*/


Create view C_Action AS
With RowNumCTE AS (
Select *, CAST((Substring(Runtime,1, CHARINDEX('m',Runtime)-1)) AS int) as runtime_n,
	Row_Number() Over(
	Partition By Title, 
				 [IMDb ID], 
				 [Release Year], 
				 Genre,  
				 Rating, 
				 Runtime, 
				 Certificate, 
				 [Number of Votes], 
				 [Gross Revenue]
				 Order By 
				 Title
				 ) row_id
From Movies.dbo.Action
)
Select Title, [IMDb ID], [Release Year], Genre, Cast, Synopsis, Rating, runtime_n, Certificate, [Number of Votes], [Gross Revenue]
From RowNumCTE
Where row_id=1 and [Gross Revenue] is not null and Runtime is not null and [Release Year] is not null




צריך להמיר את הרווח למספר

PARSENAME
גוזרת מקטע טקסט עד לסימן נקודה, ומתחילה לגזור מצד ימין
replace
בהחלפה מחפש את הפסיק, מחליף את הפסיק בסימן נקודה

With ColumnCTE AS (
Select
[Gross Revenue], 
PARSENAME(replace([Gross Revenue],',','.'),3) as X,
PARSENAME(replace([Gross Revenue],',','.'),2) as Y,
PARSENAME(replace([Gross Revenue],',','.'),1) as Z
From C_Action)


Select *
From ColumnCTE
where Y is null

/*
To change the income column from text to number, 
first I made the revenue column without commas 
(I put dots instead, and connected the 3 new columns to one), 
it's still text. 
I put it to View Gross_Revenue_Table
*/

Create view Gross_Revenue_Table AS
With ColumnCTE AS (
Select Title,
[Gross Revenue], 
PARSENAME(replace([Gross Revenue],',','.'),3) as X,
PARSENAME(replace([Gross Revenue],',','.'),2) as Y,
PARSENAME(replace([Gross Revenue],',','.'),1) as Z
From C_Action)

Select title, [Gross Revenue], 
(CASE
    when Y is null THEN z
	 when X is null and Y is not null THEN (y+z)
    ELSE (X+Y+Z)
END)
AS Gross_Revenue_n
From ColumnCTE

/*
I merged both tables using join and created a new view C_Action_n 
as the entire table is clean and the Gross Revenue column is a BigInt type number 
on which calculations can be made with big numbers
*/

create view C_Action_n AS
Select ca.Title, [IMDb ID], [Release Year], Genre, Cast, Synopsis, Rating, runtime_n, Certificate, [Number of Votes], 
cast(Gross_Revenue_n as bigint) as Gross_Revenue_n
From C_Action ca
join Gross_Revenue_Table grt ON ca.[Gross Revenue]=grt.[Gross Revenue]
where grt.Title=ca.Title






