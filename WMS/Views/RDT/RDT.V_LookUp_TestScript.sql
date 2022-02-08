SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
  
  
CREATE VIEW [RDT].[V_LookUp_TestScript]
AS    
SELECT Description AS [Text] ,
       Code AS [Value] FROM dbo.Codelkup WITH (NOLOCK)
WHERE Listname = 'ASNSTATUS'
  

GO
GRANT DELETE ON  [RDT].[V_LookUp_TestScript] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[V_LookUp_TestScript] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[V_LookUp_TestScript] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[V_LookUp_TestScript] TO [NSQL]
GO
