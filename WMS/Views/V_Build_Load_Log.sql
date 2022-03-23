SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_Build_Load_Log]
AS
SELECT
    Step5      AS [BatchNo],
    TimeIn     AS [StartTime],
    TIMEOUT    AS [EndTime],
    TotalTime,
    Step4      AS [StorerKey],
    Col1       AS [LoadKey],
    Col2       AS [UserName],
    Col3       AS [ParameterCode],
    Col4       AS [TotalOrders],
    Col5       AS [TotalOpenQty]
FROM   TraceInfo  AS ti WITH (NOLOCK)
WHERE  ti.TraceName = 'isp_Build_Loadplan'

GO
GRANT DELETE ON  [dbo].[V_Build_Load_Log] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_Build_Load_Log] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_Build_Load_Log] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_Build_Load_Log] TO [NSQL]
GO
