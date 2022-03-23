SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_SKUConfig] AS
   SELECT [StorerKey]
      ,[SKU]
      ,[ConfigType]
      ,[Data]
      ,[Addwho]
      ,[AddDate]
      ,[EditWho]
      ,[EditDate]
      ,[userdefine01]
      ,[userdefine02]
      ,[userdefine03]
      ,[userdefine04]
      ,[userdefine05]
      ,[userdefine06]
      ,[userdefine07]
      ,[userdefine08]
      ,[userdefine09]
      ,[userdefine10]
      ,[userdefine11]
      ,[userdefine12]
      ,[userdefine13]
      ,[userdefine14]
      ,[userdefine15]
      ,[notes]
   FROM dbo.SKUConfig (nolock)
GO
GRANT DELETE ON  [dbo].[V_SKUConfig] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_SKUConfig] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_SKUConfig] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_SKUConfig] TO [NSQL]
GO
