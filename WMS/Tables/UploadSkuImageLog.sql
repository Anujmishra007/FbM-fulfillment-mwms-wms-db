SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UploadSkuImageLog](
	[RowRef]        BIGINT IDENTITY(1,1) NOT NULL,
	[Storerkey]     NVARCHAR(15) NULL,
  [Sku]           NVARCHAR(20) NULL,
  [ImagePath]     NVARCHAR(250) NULL,
  [ImageFolder]   NVARCHAR(100) NULL,
  [ImageFile]     NVARCHAR(100) NULL,
  [MainImageFlag] NVARCHAR(5) NULL CONSTRAINT [DF_UploadSkuImageLog_MainImageFlag]  DEFAULT ('Y'),  
  [LogDate]       DATETIME NULL CONSTRAINT [DF_UploadSkuImageLog_LogDate]  DEFAULT (GETDATE())
CONSTRAINT [PK_UploadSkuImageLog] PRIMARY KEY CLUSTERED 
( 
	[RowRef] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

GRANT SELECT ON  [dbo].[UploadSkuImageLog] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[UploadSkuImageLog] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[UploadSkuImageLog] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[UploadSkuImageLog] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[UploadSkuImageLog] TO [NSQL]
GO	
EXEC sp_ADDextendedproperty MS_Description,'Upload sku image log',
'Schema',[dbo], 'Table',[UploadSkuImageLog]
GO	
EXEC sp_ADDextendedproperty MS_Description,'Storer',
'Schema',[dbo], 'Table',[UploadSkuImageLog], 'Column',[Storerkey]
GO	
EXEC sp_ADDextendedproperty MS_Description,'Commodity',
'Schema',[dbo], 'Table',[UploadSkuImageLog], 'Column',[Sku]
GO	
EXEC sp_ADDextendedproperty MS_Description,'Image Path',
'Schema',[dbo], 'Table',[UploadSkuImageLog], 'Column',[ImagePath]
GO	
EXEC sp_ADDextendedproperty MS_Description,'Image folder',
'Schema',[dbo], 'Table',[UploadSkuImageLog], 'Column',[ImageFolder]
GO	
EXEC sp_ADDextendedproperty MS_Description,'Image file name',
'Schema',[dbo], 'Table',[UploadSkuImageLog], 'Column',[ImageFile]
GO	
EXEC sp_ADDextendedproperty MS_Description,'Main Image of the sku flag',
'Schema',[dbo], 'Table',[UploadSkuImageLog], 'Column',[MainImageFlag]
GO	
EXEC sp_ADDextendedproperty MS_Description,'Image upload date',
'Schema',[dbo], 'Table',[UploadSkuImageLog], 'Column',[LogDate]
GO	
