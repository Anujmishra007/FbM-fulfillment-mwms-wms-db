CREATE TABLE [BI].[IMLAgg]
(
[PromoID] [smallint] NOT NULL,
[Batch] [int] NOT NULL,
[DATETIME] [smalldatetime] NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifyDate] [datetime] NOT NULL CONSTRAINT [DF_IMLAgg_ModifyDate] DEFAULT (getdate()),
[num_CALLS_SWebServiceLog_IN] [bigint] NOT NULL,
[num_CALLS_SWebServiceLog_OUT] [bigint] NOT NULL,
[num_IML_IN_File] [int] NULL,
[num_IML_OUT_File] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [BI].[IMLAgg] ADD CONSTRAINT [PK_IMLAgg] PRIMARY KEY CLUSTERED ([StorerKey]) WITH (FILLFACTOR=80, PAD_INDEX=ON) ON [PRIMARY]
GO
