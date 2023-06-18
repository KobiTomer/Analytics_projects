
/*
working on different SQL skills
*/

CREATE DATABASE SleepingAlone;

/*
I created an ID column in the CSV file, 
and I separated the reasons into another sheet [reasons], 
in order to have 2 tables for SQL, 
then saved as Excel and loaded to the SQL database
*/



/*
changing names to columns, they are too long to work with
To rename a column in a table, 'old_name' must be in the form of table.column
*/

sp_rename 'sleeping_alone.[When both you and your partner are at home, how often do you sle]', 'SeparateSleep', 'COLUMN';

sp_rename 'sleeping_alone.[Which of the following best describes your current relationship ]', 'Status', 'COLUMN';

sp_rename 'sleeping_alone.[When you''re not sleeping in the same bed as your partner, where ]', 'Second_place', 'COLUMN';

sp_rename 'sleeping_alone.[When you''re not sleeping in the same bed, where does your partne]', 'partner_place', 'COLUMN';

sp_rename 'sleeping_alone.[When was the first time you slept in separate beds?]', 'First_separated', 'COLUMN';

sp_rename 'sleeping_alone.[To what extent do you agree with the following statement: "we sl]', 'Sleep_better?', 'COLUMN';

sp_rename 'sleeping_alone.[To what extent do you agree with the following statement:ë_"our ]', 'Sex_improved?', 'COLUMN';

sp_rename 'sleeping_alone.[Which of the following best describes your current occupation?]', 'occupation', 'COLUMN';

********

sp_rename 'reasons.[One of us snores]', 'Snoring', 'COLUMN';

sp_rename 'reasons.[One of us makes frequent bathroom trips in the night]', 'Frequent bathroom trips', 'COLUMN';

sp_rename 'reasons.[One of us is sick]', 'Sickness', 'COLUMN';

sp_rename 'reasons.[We are no longer physically intimate]', 'no longer intimate', 'COLUMN';
sp_rename 'reasons.[We have different temperature preferences for the room]', 'different temperature preferences', 'COLUMN';

sp_rename 'reasons.[We''ve had an argument or fight]', 'Argument or fight', 'COLUMN';

sp_rename 'reasons.[One of us needs to sleep with a child]', 'Children', 'COLUMN';


-- display Statuses count
Select Status, Count(Status) as StatusCount
From sleeping_alone
Group by Status
Order by StatusCount desc

--Display percentages of Statuses count, change 1 and 5 to selection
SELECT FORMAT(((1)*1.0/(5)*1.0),'P2') as name


SELECT FORMAT(((Select Count(Status)
From sleeping_alone
where Status='Married')*1.0/(Select Count(Status)
From sleeping_alone)*1.0),'P2') as Married
,FORMAT(((Select Count(Status)
From sleeping_alone
where Status='Single, but cohabiting with a significant other')*1.0/(Select Count(Status)
From sleeping_alone)*1.0),'P2') as 'Single, but cohabiting with a significant other'
,FORMAT(((Select Count(Status)
From sleeping_alone
where Status='In a domestic partnership or civil union')*1.0/(Select Count(Status)
From sleeping_alone)*1.0),'P2') as 'In a domestic partnership or civil union'
,FORMAT(((Select Count(Status)
From sleeping_alone
where Status='Divorced')*1.0/(Select Count(Status)
From sleeping_alone)*1.0),'P2') as Divorced
,FORMAT(((Select Count(Status)
From sleeping_alone
where Status='Separated')*1.0/(Select Count(Status)
From sleeping_alone)*1.0),'P2') as Separated
,FORMAT(((Select Count(Status)
From sleeping_alone
where Status='Widowed')*1.0/(Select Count(Status)
From sleeping_alone)*1.0),'P2') as Widowed

/*
Create View Married_Couples_p
show period, Status_Stage with names, 
and the percentage number of Married couples using period column, 
*/


Create view Married_Couples_p AS
Select period, 
CASE
    WHEN period = 'Less than 1 year' THEN 'JustMarried'
	WHEN period = '1-5 years' THEN 'StillNew'
	WHEN period = '6-10 years' THEN 'Advanced'
	WHEN period = '11-15 years' THEN 'StickTogether'
	WHEN period = '16-20 years' THEN 'OldCouple'
	WHEN period = 'More than 20 years' THEN 'UnSpepartable'
    ELSE 'Unknown'
END 
AS Statuses_Stage
, 

FORMAT(((Count(period))*1.0/(Select Count(period)
From sleeping_alone
where Status= 'Married' and period is not null)*1.0),'P2')  AS NumberOfCouples
From sleeping_alone
where Status= 'Married' and period is not null
Group by Status, period

-- use the view and order it by case made number to correct the order by the length of the relationship

Select *
From Married_Couples_p
order by 
(CASE
    WHEN period = 'Less than 1 year' THEN 1
	WHEN period = '1-5 years' THEN 2
	WHEN period = '6-10 years' THEN 3
	WHEN period = '11-15 years' THEN 4
	WHEN period = '16-20 years' THEN 5
	WHEN period = 'More than 20 years' THEN 6
    ELSE 0
END)



-- create a view of Married_SleepSeparate, state percentage of how frequent they Sleep Separate, and then order by frequency

Create view Married_SleepSeparate AS
Select SeparateSleep, 
FORMAT(((Count(SeparateSleep))*1.0/(Select Count(SeparateSleep)
From sleeping_alone
where Status= 'Married' and period is not null
)*1.0),'P2')  AS MarriedCouplesSleepSeparate
From sleeping_alone
where Status= 'Married' and period is not null
Group by SeparateSleep


Select *
From Married_SleepSeparate
order by 
(CASE
    WHEN SeparateSleep = 'Every night' THEN 1
	WHEN SeparateSleep = 'A few times per week' THEN 2
	WHEN SeparateSleep = 'A few times per month' THEN 3
	WHEN SeparateSleep = 'Once a month or less' THEN 4
	WHEN SeparateSleep = 'Once a year or less' THEN 5
    ELSE 6
END)


--View of percentage of married people who sleep apart at some point for various reasons

Create view Married_SleepSeparate_reasons AS
SELECT FORMAT(((Select count(Snoring) 
From reasons r full join sleeping_alone sa ON r.ID=sa.ID
where sa.Status='Married' and Snoring is not null
Group by Snoring)*1.0/(Select Count(SeparateSleep)
From sleeping_alone
where Status='Married'
and SeparateSleep <> 'never')*1.0),'P2') as Snoring
,
FORMAT(((Select count([Frequent bathroom trips])
From reasons r full join sleeping_alone sa ON r.ID=sa.ID
where sa.Status='Married' and [Frequent bathroom trips] is not null
Group by [Frequent bathroom trips])*1.0/(Select Count(SeparateSleep)            
From sleeping_alone                                      
where Status='Married'
and SeparateSleep <> 'never')*1.0),'P2') as Frequent_bathroom_trips
,
FORMAT(((Select count(Sickness) 
From reasons r full join sleeping_alone sa ON r.ID=sa.ID
where sa.Status='Married' and Sickness is not null
Group by Sickness)*1.0/(Select Count(SeparateSleep)         
From sleeping_alone                                       
where Status='Married'
and SeparateSleep <> 'never')*1.0),'P2') as Sickness  
,
FORMAT(((Select count([no longer intimate]) 
From reasons r full join sleeping_alone sa ON r.ID=sa.ID
where sa.Status='Married' and [no longer intimate] is not null
Group by [no longer intimate])*1.0/(Select Count(SeparateSleep)       
From sleeping_alone                                       
where Status='Married'
and SeparateSleep <> 'never')*1.0),'P2') as no_longer_intimate   
,
FORMAT(((Select count([different temperature preferences]) 
From reasons r full join sleeping_alone sa ON r.ID=sa.ID
where sa.Status='Married' and [different temperature preferences] is not null
Group by [different temperature preferences])*1.0/(Select Count(SeparateSleep)         
From sleeping_alone                                      
where Status='Married'
and SeparateSleep <> 'never')*1.0),'P2') as different_temperature_preferences     
,
FORMAT(((Select count([Argument or fight]) 
From reasons r full join sleeping_alone sa ON r.ID=sa.ID
where sa.Status='Married' and [Argument or fight] is not null     
Group by [Argument or fight])*1.0/(Select Count(SeparateSleep)        
From sleeping_alone                                      
where Status='Married'
and SeparateSleep <> 'never')*1.0),'P2') as Argument_or_fight               
,
FORMAT(((Select count([Not enough space]) 
From reasons r full join sleeping_alone sa ON r.ID=sa.ID
where sa.Status='Married' and [Not enough space] is not null
Group by [Not enough space])*1.0/(Select Count(SeparateSleep)         
From sleeping_alone                                      
where Status='Married'
and SeparateSleep <> 'never')*1.0),'P2') as Not_enough_space  
,
FORMAT(((Select count([Do not want to share the covers]) 
From reasons r full join sleeping_alone sa ON r.ID=sa.ID
where sa.Status='Married' and [Do not want to share the covers] is not null
Group by [Do not want to share the covers])*1.0/(Select Count(SeparateSleep)       
From sleeping_alone                                      
where Status='Married'
and SeparateSleep <> 'never')*1.0),'P2') as Do_not_want_to_share_the_covers      
,
FORMAT(((Select count(Children) 
From reasons r full join sleeping_alone sa ON r.ID=sa.ID
where sa.Status='Married' and Children is not null
Group by Children)*1.0/(Select Count(SeparateSleep)   
From sleeping_alone                                      
where Status='Married'
and SeparateSleep <> 'never')*1.0),'P2') as Children       
,
FORMAT(((Select count([Night working/very different sleeping times]) 
From reasons r full join sleeping_alone sa ON r.ID=sa.ID
where sa.Status='Married' and [Night working/very different sleeping times] is not null
Group by [Night working/very different sleeping times])*1.0/(Select Count(SeparateSleep)       
From sleeping_alone                                      
where Status='Married'
and SeparateSleep <> 'never')*1.0),'P2') as Night_working_very_different_sleeping_times


-- create a view of Married_Sex_improved, state the percentage of Married couples that Sleep Separately and if their sex improved by that
Create View Married_Sex_improved AS
SELECT [Sex_improved?],
FORMAT(((count([Sex_improved?]))*1.0/(Select count([Sex_improved?])
From sleeping_alone
Where [Sex_improved?] is not Null and Status='Married' and SeparateSleep <> 'never')*1.0),'P2') as Married_Sex_improved
From sleeping_alone
Where [Sex_improved?] is not Null and Status='Married' and SeparateSleep <> 'never'
Group by [Sex_improved?]



/*
Views summary

Married_Couples_p
Married_SleepSeparate
Married_SleepSeparate_reasons
Married_Sex_improved

*/


