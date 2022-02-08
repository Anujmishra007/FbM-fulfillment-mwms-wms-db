IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[V_Backend_Allocate_Parm_Header]')) 
   DROP VIEW [dbo].[V_Backend_Allocate_Parm_Header]
GO
CREATE VIEW [dbo].[V_Backend_Allocate_Parm_Header]
AS  
SELECT SC.StorerKey, 
       SC.Facility, 
       sValue           AS [BL_ParamGroup], 
       CL.LISTNAME      AS [BL_ParameterCode], 
       CL.[DESCRIPTION] AS [BL_ParmDesc], 
       ISNULL(CL.UDF01, '') AS [BL_Priority], 
       ISNULL(CL.UDF02, '') AS [BL_AllocStrategy], 
       ISNULL(Cl.UDF03,'0') AS [BL_ActiveFlag], 
       ISNULL(Cl.UDF04,'0') AS [BL_BuildType], 
       ISNULL(Cl.UDF05, '5000') AS [BL_BatchSize]
FROM   StorerConfig  AS SC WITH (NOLOCK)
       JOIN CODELIST AS CL WITH (NOLOCK) ON  CL.ListGroup = SC.SValue
WHERE  SC.ConfigKey = 'BuildLoadParm' 
AND Cl.UDF04 = 'BACKENDALLOC'
GO

GRANT SELECT ON V_Backend_Allocate_Parm_Header to NSQL
GO



