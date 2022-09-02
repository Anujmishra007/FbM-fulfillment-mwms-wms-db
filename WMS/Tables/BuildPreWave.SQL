CREATE TABLE dbo.BUILDPREWAVE
      (  [RowID]                    INT            NOT NULL IDENTITY(1,1) 
      ,	 [BuildParmKey]             NVARCHAR(10)   NOT NULL CONSTRAINT [DF_BUILDPREWAVE_BuildParmKey]          DEFAULT('') 
      ,  [Status]                   NVARCHAR(10)   NOT NULL CONSTRAINT [DF_BUILDPREWAVE_Status]                DEFAULT('0')
      ,  [NoOfOrders]               INT            NOT NULL CONSTRAINT [DF_BUILDPREWAVE_NoOfOrders]            DEFAULT(0)       
      ,  [Column01]                 NVARCHAR(100)  NULL     CONSTRAINT [DF_BUILDPREWAVE_Column01]              DEFAULT('')
      ,  [Column02]                 NVARCHAR(100)  NULL     CONSTRAINT [DF_BUILDPREWAVE_Column02]              DEFAULT('')
      ,  [Column03]                 NVARCHAR(100)  NULL     CONSTRAINT [DF_BUILDPREWAVE_Column03]              DEFAULT('')
      ,  [Column04]                 NVARCHAR(100)  NULL     CONSTRAINT [DF_BUILDPREWAVE_Column04]              DEFAULT('')
      ,  [Column05]                 NVARCHAR(100)  NULL     CONSTRAINT [DF_BUILDPREWAVE_Column05]              DEFAULT('')
      ,  [AddWho]                   NVARCHAR(18)   NOT NULL CONSTRAINT [DF_BUILDPREWAVE_AddWho]                DEFAULT(suser_sname())
      ,  [AddDate]                  DATETIME       NOT NULL CONSTRAINT [DF_BUILDPREWAVE_AddDate]               DEFAULT(getdate())
      ,  [EditWho]                  NVARCHAR(18)   NOT NULL CONSTRAINT [DF_BUILDPREWAVE_EditWho]               DEFAULT(suser_sname())
      ,  [EditDate]                 DATETIME       NOT NULL CONSTRAINT [DF_BUILDPREWAVE_EditDate]              DEFAULT(getdate())
      ,  [TrafficCop]               NCHAR(1)       NULL
      ,  [ArchiveCop]               NCHAR(1)       NULL
      CONSTRAINT [PK_BUILDPREWAVE] PRIMARY KEY CLUSTERED 
(
[BuildParmKey], [RowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON [dbo].[BUILDPREWAVE] TO nSQL 
GO                                                                                 

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Build Parameter Detail' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPREWAVE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Row Unique #' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPREWAVE', @level2type=N'COLUMN',@level2name=N'RowID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Build Parameter key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPREWAVE', @level2type=N'COLUMN',@level2name=N'BuildParmKey'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Record Status: 0,1,9' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPREWAVE', @level2type=N'COLUMN',@level2name=N'Status'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'No Of Orders' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPREWAVE', @level2type=N'COLUMN',@level2name=N'NoOfOrders'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Column Value 01' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPREWAVE', @level2type=N'COLUMN',@level2name=N'Column01'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Column Value 02' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPREWAVE', @level2type=N'COLUMN',@level2name=N'Column02'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Column Value 03' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPREWAVE', @level2type=N'COLUMN',@level2name=N'Column03'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Column Value 04' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPREWAVE', @level2type=N'COLUMN',@level2name=N'Column04'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Column Value 05' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPREWAVE', @level2type=N'COLUMN',@level2name=N'Column05'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The username/login ID added the information.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPREWAVE', @level2type=N'COLUMN',@level2name=N'AddWho'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The date in which the load is created' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPREWAVE', @level2type=N'COLUMN',@level2name=N'AddDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The username/login ID edited/modified/updated the information.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPREWAVE', @level2type=N'COLUMN',@level2name=N'EditWho'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date of the information edited/modified/updated. (System date)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPREWAVE', @level2type=N'COLUMN',@level2name=N'EditDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPREWAVE', @level2type=N'COLUMN',@level2name=N'TrafficCop'
GO

