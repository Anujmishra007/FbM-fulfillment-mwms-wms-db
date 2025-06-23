SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'CCSerialNoLog')
BEGIN
   CREATE TABLE [dbo].[CCSerialNoLog] (
   	[CountSerialKey] [bigint] IDENTITY(1,1) NOT NULL,
   	[CCKey] [nvarchar](10) NOT NULL,
   	[CCDetailKey] [nvarchar](10) NOT NULL,
   	[CCSheetNo] [nvarchar](10) NOT NULL,
      [Facility] [nvarchar](5) NOT NULL,
      [StorerKey] [nvarchar](15) NOT NULL,
      [SerialNo] [nvarchar](30) NOT NULL,
      [SKU] [nvarchar](20) NOT NULL,
      [Qty] [int] NULL CONSTRAINT [DF_CCSerialNoLog]  DEFAULT ((0)),
      [Lot] [nvarchar](10) NOT NULL,
      [Loc] [nvarchar](10) NOT NULL,
      [ID] [nvarchar](18) NOT NULL,
      [Status] [nvarchar](10) NULL CONSTRAINT [DF_CCSerialNoLog_Status]  DEFAULT ('0'),
   	[AddDate] [datetime] NULL CONSTRAINT [DF_CCSerialNoLog_AddDate]  DEFAULT (getdate()),
   	[AddWho] [nvarchar](18) NULL CONSTRAINT [DF_CCSerialNoLog_AddWho]  DEFAULT (suser_sname()),
   	[EditDate] [datetime] NULL CONSTRAINT [DF_CCSerialNoLog_EditDate]  DEFAULT (getdate()),
   	[EditWho] [nvarchar](18) NULL CONSTRAINT [DF_CCSerialNoLog_EditWho]  DEFAULT (suser_sname()),
   	[ArchiveCop] [nvarchar](1) NULL,
   	[TrafficCop] [nvarchar](1) NULL,
    CONSTRAINT [PK_CCSerialNoLog] PRIMARY KEY CLUSTERED 
   (
   	[CountSerialKey] ASC
   )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
   ) ON [PRIMARY]
   --GO

   GRANT SELECT, UPDATE, DELETE, INSERT ON [dbo].[CCSerialNoLog] TO NSQL
   --GO

   --EXEC sp_addextendedproperty 
   --@name = N'MS_Description', @value = N'Unique row ref', 
   --@level0type = N'Schema', @level0name = dbo, 
   --@level1type = N'Table',  @level1name = CCSerialNoLog, 
   --@level2type = N'Column', @level2name = [CountSerialKey]
   
--GO   
END
ELSE
BEGIN
   --UWP-28817 start
   -- Drop the existing default constraint
   ALTER TABLE dbo.CCSerialNoLog DROP CONSTRAINT DF_CCSerialNoLog_Status;
   ALTER TABLE dbo.CCSerialNoLog ADD CONSTRAINT DF_CCSerialNoLog_Status DEFAULT '0' FOR Status;
   --UWP-28817 end

END


