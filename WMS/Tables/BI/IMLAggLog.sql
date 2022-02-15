CREATE TABLE [BI].[IMLAggLog]
(
[PromoID] [smallint] NOT NULL,
[Batch] [int] NOT NULL,
[DATETIME] [smalldatetime] NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifyDate] [datetime] NOT NULL,
[num_CALLS_SWebServiceLog_IN] [bigint] NOT NULL,
[num_CALLS_SWebServiceLog_OUT] [bigint] NOT NULL,
[num_IML_IN_File] [int] NULL,
[num_IML_OUT_File] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [BI].[IMLAggLog] ADD CONSTRAINT [PK_IMLAggLog] PRIMARY KEY CLUSTERED ([PromoID] DESC, [Batch] DESC, [StorerKey]) WITH (FILLFACTOR=80, PAD_INDEX=ON) ON [PRIMARY]
GO
ALTER TABLE [BI].[IMLAggLog] ADD CONSTRAINT [FK_IMLAggLog_eComPromo] FOREIGN KEY ([PromoID]) REFERENCES [BI].[eComPromo] ([PromoID])
GO
