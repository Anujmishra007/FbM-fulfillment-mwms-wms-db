CREATE OR ALTER VIEW [BI].[V_LoadPlanLaneDetail]
AS
SELECT  *  FROM dbo.LoadPlanLaneDetail WITH (nolock)
GO

GRANT SELECT ON [BI].[V_LoadPlanLaneDetail] TO [JReportRole]
GO 


--EXEC AS login = 'JReportUserIDN'
--REVERT;
--SELECT suser_name()

--SELECT TOP 10 * FROM BI.V_LoadPlanDetail