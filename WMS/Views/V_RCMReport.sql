SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_RCMReport]
AS
SELECT [ComputerName]
, [StorerKey]
, [ReportType]
, [PB_Datawindow]
, [Rpt_Printer]
, [AddWho]
, [AddDate]
, [EditWho]
, [EditDate]
,ExtendParmName1
,ExtendParmName2
,ExtendParmName3
,ExtendParmName4
,ExtendParmName5
,ExtendParmDefault1
,ExtendParmDefault2
,ExtendParmDefault3
,ExtendParmDefault4
,ExtendParmDefault5
,AutoPrint
FROM dbo.[RCMReport] (NOLOCK)

GO
GRANT DELETE ON  [dbo].[V_RCMReport] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_RCMReport] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_RCMReport] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_RCMReport] TO [NSQL]
GO
