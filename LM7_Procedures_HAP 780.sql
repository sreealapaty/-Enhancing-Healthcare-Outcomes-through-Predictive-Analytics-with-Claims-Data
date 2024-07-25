use Test_claims

-- Create Elixhauser comorbidity indicators for each patient
SELECT c.patient_id
,max(case when [diagnosis] = 'ELIX1' then 1 else 0 end) as 	ELIX1
,max(case when [diagnosis] = 'ELIX10' then 1 else 0 end) as 	ELIX10
,max(case when [diagnosis] = 'ELIX11' then 1 else 0 end) as 	ELIX11
,max(case when [diagnosis] = 'ELIX12' then 1 else 0 end) as 	ELIX12
,max(case when [diagnosis] = 'ELIX13' then 1 else 0 end) as 	ELIX13
,max(case when [diagnosis] = 'ELIX14' then 1 else 0 end) as 	ELIX14
,max(case when [diagnosis] = 'ELIX15' then 1 else 0 end) as 	ELIX15
,max(case when [diagnosis] = 'ELIX16' then 1 else 0 end) as 	ELIX16
,max(case when [diagnosis] = 'ELIX17' then 1 else 0 end) as 	ELIX17
,max(case when [diagnosis] = 'ELIX18' then 1 else 0 end) as 	ELIX18
,max(case when [diagnosis] = 'ELIX19' then 1 else 0 end) as 	ELIX19
,max(case when [diagnosis] = 'ELIX2' then 1 else 0 end) as 	ELIX2
,max(case when [diagnosis] = 'ELIX20' then 1 else 0 end) as 	ELIX20
,max(case when [diagnosis] = 'ELIX21' then 1 else 0 end) as 	ELIX21
,max(case when [diagnosis] = 'ELIX22' then 1 else 0 end) as 	ELIX22
,max(case when [diagnosis] = 'ELIX23' then 1 else 0 end) as 	ELIX23
,max(case when [diagnosis] = 'ELIX24' then 1 else 0 end) as 	ELIX24
,max(case when [diagnosis] = 'ELIX25' then 1 else 0 end) as 	ELIX25
,max(case when [diagnosis] = 'ELIX26' then 1 else 0 end) as 	ELIX26
,max(case when [diagnosis] = 'ELIX27' then 1 else 0 end) as 	ELIX27
,max(case when [diagnosis] = 'ELIX28' then 1 else 0 end) as 	ELIX28
,max(case when [diagnosis] = 'ELIX29' then 1 else 0 end) as 	ELIX29
,max(case when [diagnosis] = 'ELIX3' then 1 else 0 end) as 	ELIX3
,max(case when [diagnosis] = 'ELIX4' then 1 else 0 end) as 	ELIX4
,max(case when [diagnosis] = 'ELIX5' then 1 else 0 end) as 	ELIX5
,max(case when [diagnosis] = 'ELIX6' then 1 else 0 end) as 	ELIX6
,max(case when [diagnosis] = 'ELIX7' then 1 else 0 end) as 	ELIX7
,max(case when [diagnosis] = 'ELIX8' then 1 else 0 end) as 	ELIX8
,max(case when [diagnosis] = 'ELIX9' then 1 else 0 end) as 	ELIX9
INTO #ELIX
FROM dbo.diagnoses d
JOIN dbo.claims c ON d.claim_id = c.claim_id
GROUP BY c.patient_id -----(145929 rows affected)

---Step 2:-- Aggregate procedure information by patient and format hcpcs_grp
SELECT c.patient_id, 
REPLACE(p.hcpcs_grp, '-', '') AS hcpcs_grp,
COUNT(p.hcpcs) AS procedure_count 
INTO #PROCEDURES
FROM dbo.[procedures] p
JOIN dbo.claims c ON p.claim_id = c.claim_id
GROUP BY c.patient_id, REPLACE(p.hcpcs_grp, '-', '') ---(810997 rows affected)

select * from #PROCEDURES

---Step 3: -- Define high utilizers based on claim counts in year 'Y2'
SELECT patient_id, 
COUNT(*) AS CLAIMS, 
CASE WHEN COUNT(*) >= 100 THEN 1 ELSE 0 END AS highUtilizer 
INTO #HIGH_UTILIZERS
FROM dbo.claims
WHERE year = 'Y2'
GROUP BY patient_id  ---(114663 rows effected)

select * from #HIGH_UTILIZERS

---Step 4: -- Combine all data into a final dataset
SELECT e.patient_id,
e.ELIX1, e.ELIX2, e.ELIX3, e.ELIX4, e.ELIX5, e.ELIX6, e.ELIX7, e.ELIX8, e.ELIX9, e.ELIX10,
e.ELIX11, e.ELIX12, e.ELIX13, e.ELIX14, e.ELIX15, e.ELIX16, e.ELIX17, e.ELIX18, e.ELIX19, e.ELIX20,
e.ELIX21, e.ELIX22, e.ELIX23, e.ELIX24, e.ELIX25, e.ELIX26, e.ELIX27, e.ELIX28, e.ELIX29,
p.hcpcs_grp, p.procedure_count,
h.highUtilizer
INTO dbo.procedures_classification_final
FROM #ELIX e
LEFT JOIN #PROCEDURES p ON e.patient_id = p.patient_id
LEFT JOIN #HIGH_UTILIZERS h ON e.patient_id = h.patient_id

select * from dbo.procedures_classification_final

-- Select the top 100,000 rows from the final classification data
SELECT TOP 100000
patient_id,
ELIX1, ELIX2, ELIX3, ELIX4, ELIX5, ELIX6, ELIX7, ELIX8, ELIX9, ELIX10,
ELIX11, ELIX12, ELIX13, ELIX14, ELIX15, ELIX16, ELIX17, ELIX18, ELIX19, ELIX20,
ELIX21, ELIX22, ELIX23, ELIX24, ELIX25, ELIX26, ELIX27, ELIX28, ELIX29,
hcpcs_grp,procedure_count,highUtilizer
INTO dbo.final_classification_data_subset
FROM [dbo].[procedures_classification_final]
ORDER BY patient_id

select * from dbo.final_classification_data_subset