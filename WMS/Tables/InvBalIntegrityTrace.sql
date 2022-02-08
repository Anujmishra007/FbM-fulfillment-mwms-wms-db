CREATE TABLE [dbo].[InvBalIntegrityTrace]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[CheckType] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LOT] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_InvBalIntegrityTrace_LOT] DEFAULT (''),
[LOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_InvBalIntegrityTrace_LOC] DEFAULT (''),
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_InvBalIntegrityTrace_ID] DEFAULT (''),
[A_Qty] [int] NOT NULL CONSTRAINT [DF_InvBalIntegrityTrace_A_Qty] DEFAULT ((0)),
[A_QtyAllocated] [int] NOT NULL CONSTRAINT [DF_InvBalIntegrityTrace_A_QtyAllocated] DEFAULT ((0)),
[A_QtyPicked] [int] NOT NULL CONSTRAINT [DF_InvBalIntegrityTrace_A_QtyPicked] DEFAULT ((0)),
[B_Qty] [int] NOT NULL CONSTRAINT [DF_InvBalIntegrityTrace_B_Qty] DEFAULT ((0)),
[B_QtyAllocated] [int] NOT NULL CONSTRAINT [DF_InvBalIntegrityTrace_B_QtyAllocated] DEFAULT ((0)),
[B_QtyPicked] [int] NOT NULL CONSTRAINT [DF_InvBalIntegrityTrace_B_QtyPicked] DEFAULT ((0)),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_InvBalIntegrityTrace_AddDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InvBalIntegrityTrace] ADD CONSTRAINT [PK_InvBalIntegrityTrace] PRIMARY KEY CLUSTERED ([RowID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[InvBalIntegrityTrace] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[InvBalIntegrityTrace] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[InvBalIntegrityTrace] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[InvBalIntegrityTrace] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'InvBalIntegrityTrace', 'COLUMN', N'AddDate'
GO
