-- load data
-- TRUNCATE TABLE landing_ProjectBudgets;
-- TRUNCATE TABLE landing_TimeEntries;


-- run this in psql
-- \copy landing_ProjectBudgets (ProjectID, ProjectName, Budget, Contingency, ApprovedContingency) FROM 'C:/Users/sina_/OneDrive/Documents/001 - Ideations and One Shots/Projects/Workday Analysis/Mock data generator/project_budgets.csv' DELIMITER ',' CSV HEADER

-- \copy landing_TimeEntries (ProjectID, ProjectName, Date, EmployeeName, Bucket, HoursWorked, WorkerComments) FROM 'C:/Users/sina_/OneDrive/Documents/001 - Ideations and One Shots/Projects/Workday Analysis/Mock data generator/time_entries.csv' DELIMITER ',' CSV HEADER



-- Update contingencies
WITH actual_billed_contingency AS (
    SELECT 
        te.projectid,
        CAST(SUM(CASE WHEN LOWER(workercomments) LIKE '%contingency%' THEN hoursworked ELSE 0 END) * 175 AS Money) AS billed_hours_with_contingency
    FROM landing_timeentries te
    GROUP BY te.projectid
)
    
UPDATE landing_projectbudgets pb
SET 
    contingency = (
        SELECT billed_hours_with_contingency * 1.15 
        FROM actual_billed_contingency abd 
            WHERE abd.projectid = pb.projectid),
    approvedcontingency = (
        SELECT billed_hours_with_contingency * 1.10 
        FROM actual_billed_contingency abd 
            WHERE abd.projectid = pb.projectid);



WITH actual_billed_contingency AS (
SELECT 
    te.projectname, 
    te.projectid,
    budget,
    CAST (SUM(CASE WHEN LOWER(workercomments) LIKE '%contingency%' THEN hoursworked ELSE 0 END) * 175 AS Money) AS billed_hours_with_contingency
FROM landing_timeentries te
LEFT JOIN landing_projectbudgets pb
    ON te.projectid = pb.projectid
GROUP BY te.projectname, 
    te.projectid,
    budget
    )
SELECT abd.projectid, 
    abd.budget, 
    billed_hours_with_contingency,
    contingency, 
    approvedcontingency
FROM landing_projectbudgets abd
RIGHT JOIN actual_billed_contingency pb
    ON abd.projectid = pb.projectid;
   