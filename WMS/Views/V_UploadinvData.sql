SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [dbo].[V_UploadinvData]   
AS   
SELECT [Storerkey]  
, [ExternOrderkey]  
, [Invoice_Number]  
, [Invoice_Date]  
, [Invoice_Amount]  
, [Status]  
, [Remarks]  
FROM [UploadinvData] (NOLOCK)   
GO
GRANT DELETE ON  [dbo].[V_UploadinvData] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_UploadinvData] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_UploadinvData] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_UploadinvData] TO [NSQL]
GO
