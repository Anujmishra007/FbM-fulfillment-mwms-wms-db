CREATE TABLE [dbo].[idsStkTrfDoc]
(
[STDNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TruckNo] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DriverName] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Finalized] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DestCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WHSEID] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TrxType] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReasonCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_idsStkTrfDoc_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_idsStkTrfDoc_AddWho] DEFAULT (suser_sname()),
[SourceID] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[idsStkTrfDoc] ADD CONSTRAINT [PK_idsStkTrfDoc] PRIMARY KEY CLUSTERED ([STDNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[idsStkTrfDoc] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[idsStkTrfDoc] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[idsStkTrfDoc] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[idsStkTrfDoc] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'idsStkTrfDoc', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'idsStkTrfDoc', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying destination.', 'SCHEMA', N'dbo', 'TABLE', N'idsStkTrfDoc', 'COLUMN', N'DestCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Full name of delivery truck driver.', 'SCHEMA', N'dbo', 'TABLE', N'idsStkTrfDoc', 'COLUMN', N'DriverName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'idsStkTrfDoc', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Reason.', 'SCHEMA', N'dbo', 'TABLE', N'idsStkTrfDoc', 'COLUMN', N'ReasonCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Source.', 'SCHEMA', N'dbo', 'TABLE', N'idsStkTrfDoc', 'COLUMN', N'SourceID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'idsStkTrfDoc', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number plate of delivery truck.', 'SCHEMA', N'dbo', 'TABLE', N'idsStkTrfDoc', 'COLUMN', N'TruckNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Warehouse.', 'SCHEMA', N'dbo', 'TABLE', N'idsStkTrfDoc', 'COLUMN', N'WHSEID'
GO
