  
if not exists ( SELECT 1 FROM sys.sequences WHERE name = 'TrackBatchNo' )

BEGIN
CREATE SEQUENCE dbo.TrackBatchNo 
 AS [BIGINT]
 START WITH 1
 INCREMENT BY 1
 MINVALUE 0
 MAXVALUE 9999989999
 CYCLE
 CACHE 50
GO

grant Update on dbo.TrackBatchNo  to NSQL
END