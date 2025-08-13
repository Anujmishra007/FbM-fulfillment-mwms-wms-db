IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BUILDPARMPREWAVE]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[BUILDPARMPREWAVE]
      (  [BuildParmKey]             NVARCHAR(10)   NOT NULL CONSTRAINT [DF_BUILDPARMPREWAVE_BuildParmKey]            DEFAULT('')       
      ,  [BuildParmPreWaveLineNo]   NVARCHAR(5)    NOT NULL CONSTRAINT [DF_BUILDPARMPREWAVE_BuildParmPreWaveLineNo]  DEFAULT('')       
      ,  [Description]              NVARCHAR(60)   NOT NULL CONSTRAINT [DF_BUILDPARMPREWAVE_Description]             DEFAULT('')
      ,  [Type]                     NVARCHAR(10)   NOT NULL CONSTRAINT [DF_BUILDPARMPREWAVE_Type]                    DEFAULT('')
      ,  [FieldName]                NVARCHAR(100)  NULL     CONSTRAINT [DF_BUILDPARMPREWAVE_FieldName]               DEFAULT('')
      ,  [FieldLabel]               NVARCHAR(50)   NULL     CONSTRAINT [DF_BUILDPARMPREWAVE_FieldLabel]              DEFAULT('')
      ,  [OrAnd]                    NVARCHAR(10)   NULL     CONSTRAINT [DF_BUILDPARMPREWAVE_OrAnd]                   DEFAULT('')
      ,  [Operator]                 NVARCHAR(60)   NULL     CONSTRAINT [DF_BUILDPARMPREWAVE_Operator]                DEFAULT('')
      ,  [Value]                    NVARCHAR(4000) NULL     CONSTRAINT [DF_BUILDPARMPREWAVE_Value]                   DEFAULT('')
      ,  [UDF01]                    NVARCHAR(60)   NULL     CONSTRAINT [DF_BUILDPARMPREWAVE_UDF01]                   DEFAULT('')
      ,  [UDF02]                    NVARCHAR(60)   NULL     CONSTRAINT [DF_BUILDPARMPREWAVE_UDF02]                   DEFAULT('')
      ,  [UDF03]                    NVARCHAR(60)   NULL     CONSTRAINT [DF_BUILDPARMPREWAVE_UDF03]                   DEFAULT('')
      ,  [UDF04]                    NVARCHAR(60)   NULL     CONSTRAINT [DF_BUILDPARMPREWAVE_UDF04]                   DEFAULT('')
      ,  [UDF05]                    NVARCHAR(60)   NULL     CONSTRAINT [DF_BUILDPARMPREWAVE_UDF05]                   DEFAULT('')
      ,  [AddWho]                   NVARCHAR(128)   NOT NULL CONSTRAINT [DF_BUILDPARMPREWAVE_AddWho]                  DEFAULT(suser_sname())
      ,  [AddDate]                  DATETIME       NOT NULL CONSTRAINT [DF_BUILDPARMPREWAVE_AddDate]                 DEFAULT(getdate())
      ,  [EditWho]                  NVARCHAR(128)   NOT NULL CONSTRAINT [DF_BUILDPARMPREWAVE_EditWho]                 DEFAULT(suser_sname())
      ,  [EditDate]                 DATETIME       NOT NULL CONSTRAINT [DF_BUILDPARMPREWAVE_EditDate]                DEFAULT(getdate())
      ,  [TrafficCop]               NCHAR(1)       NULL
      ,  [ArchiveCop]               NCHAR(1)       NULL
      CONSTRAINT [PK_BUILDPARMPREWAVE] PRIMARY KEY CLUSTERED 
(
[BuildParmKey], [BuildParmPreWaveLineNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GRANT SELECT, INSERT, UPDATE, DELETE ON [dbo].[BUILDPARMPREWAVE] TO nSQL                                                                            

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Build Parameter Detail' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPARMPREWAVE'

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Build Parameter key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPARMPREWAVE', @level2type=N'COLUMN',@level2name=N'BuildParmKey'

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Build Parameter Pre Wave Line #' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPARMPREWAVE', @level2type=N'COLUMN',@level2name=N'BuildParmPreWaveLineNo'

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Criteria Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPARMPREWAVE', @level2type=N'COLUMN',@level2name=N'Description'

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPARMPREWAVE', @level2type=N'COLUMN',@level2name=N'Type'

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Column Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPARMPREWAVE', @level2type=N'COLUMN',@level2name=N'FieldName'

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Column Label' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPARMPREWAVE', @level2type=N'COLUMN',@level2name=N'FieldLabel'

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Or And' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPARMPREWAVE', @level2type=N'COLUMN',@level2name=N'OrAnd'

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Operator' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPARMPREWAVE', @level2type=N'COLUMN',@level2name=N'Operator'

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Value' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPARMPREWAVE', @level2type=N'COLUMN',@level2name=N'Value'

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Define Field 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPARMPREWAVE', @level2type=N'COLUMN',@level2name=N'UDF01'

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Define Field 2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPARMPREWAVE', @level2type=N'COLUMN',@level2name=N'UDF02'

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Define Field 3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPARMPREWAVE', @level2type=N'COLUMN',@level2name=N'UDF03'

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Define Field 4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPARMPREWAVE', @level2type=N'COLUMN',@level2name=N'UDF04'

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Define Field 5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPARMPREWAVE', @level2type=N'COLUMN',@level2name=N'UDF05'

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The username/login ID added the information.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPARMPREWAVE', @level2type=N'COLUMN',@level2name=N'AddWho'

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The date in which the load is created' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPARMPREWAVE', @level2type=N'COLUMN',@level2name=N'AddDate'

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The username/login ID edited/modified/updated the information.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPARMPREWAVE', @level2type=N'COLUMN',@level2name=N'EditWho'

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date of the information edited/modified/updated. (System date)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPARMPREWAVE', @level2type=N'COLUMN',@level2name=N'EditDate'

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BUILDPARMPREWAVE', @level2type=N'COLUMN',@level2name=N'TrafficCop'


END

ELSE 
BEGIN


--ALTER COLUMN

		IF EXISTS( SELECT 1 
				FROM SYS.columns WHERE NAME ='AddWho' AND Object_ID = Object_ID('[dbo].[BUILDPARMPREWAVE]') AND  max_length <> 256)
		BEGIN
		ALTER TABLE [dbo].[BUILDPARMPREWAVE]
		ALTER COLUMN [AddWho] NVARCHAR(128) NOT NULL;

		END


		IF EXISTS( SELECT 1 
				FROM SYS.columns WHERE NAME ='EditWho' AND Object_ID = Object_ID('[dbo].[BUILDPARMPREWAVE]') AND  max_length <> 256)
		BEGIN
		ALTER TABLE [dbo].[BUILDPARMPREWAVE]
		ALTER COLUMN [EditWho] NVARCHAR(128) NOT NULL;

		END
END




