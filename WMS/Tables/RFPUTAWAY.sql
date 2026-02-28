SET ANSI_NULLS OFF

SET QUOTED_IDENTIFIER OFF


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RFPUTAWAY]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RFPUTAWAY]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SuggestedLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ptcid] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[qty] [int] NOT NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_RFPutaway_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RFPutaway_AddWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CaseID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rfPutaway_CaseID] DEFAULT (''),
[FromID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rfPutaway_FromID] DEFAULT (''),
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[TaskDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RFPutaway_TaskDetailKey] DEFAULT (''),
[Func] [int] NOT NULL CONSTRAINT [DF_RFPutaway_Func] DEFAULT ((0)),
[PABookingKey] [int] NOT NULL CONSTRAINT [DF_RFPutaway_PABookingKey] DEFAULT ((0)),
[QTYPrinted] [int] NOT NULL CONSTRAINT [DF_RFPutaway_QTYPrinted] DEFAULT ((0))
) ON [PRIMARY]

GRANT DELETE ON  [dbo].[RFPUTAWAY] TO [NSQL]

GRANT INSERT ON  [dbo].[RFPUTAWAY] TO [NSQL]

GRANT SELECT ON  [dbo].[RFPUTAWAY] TO [NSQL]

GRANT UPDATE ON  [dbo].[RFPUTAWAY] TO [NSQL]


ALTER TABLE [dbo].[RFPUTAWAY] ADD CONSTRAINT [PK_RFPutaway] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=90) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_RFPutaway_01] ON [dbo].[RFPUTAWAY] ([ptcid], [Sku], [SuggestedLoc]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_RFPutaway_SKUFROMLOC] ON [dbo].[RFPUTAWAY] ([Sku], [FromLoc]) ON [PRIMARY]

EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'RFPUTAWAY', 'COLUMN', N'AddDate'

EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information. ', 'SCHEMA', N'dbo', 'TABLE', N'RFPUTAWAY', 'COLUMN', N'AddWho'

EXEC sp_addextendedproperty N'MS_Description', 'Current location for the Commodity to be moved.', 'SCHEMA', N'dbo', 'TABLE', N'RFPUTAWAY', 'COLUMN', N'FromLoc'

EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'RFPUTAWAY', 'COLUMN', N'Id'

EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric values associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'RFPUTAWAY', 'COLUMN', N'Lot'

EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated.', 'SCHEMA', N'dbo', 'TABLE', N'RFPUTAWAY', 'COLUMN', N'qty'

EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'RFPUTAWAY', 'COLUMN', N'Sku'

EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'RFPUTAWAY', 'COLUMN', N'StorerKey'

EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'RFPUTAWAY', 'COLUMN', N'TrafficCop'

END 

ELSE 
BEGIN
--ALTER COLUMN

		IF EXISTS( SELECT 1 
				FROM SYS.columns WHERE NAME ='FromID' AND Object_ID = Object_ID('[dbo].[RFPUTAWAY]') AND  max_length <> 40)
		BEGIN
		ALTER TABLE [dbo].[RFPUTAWAY]
		ALTER COLUMN [FromID] [nvarchar] (20) NOT NULL;
		END
END