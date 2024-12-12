
IF NOT EXISTS (SELECT *
               FROM sys.tables
               WHERE name = 'ID'
                 AND type = 'U')
BEGIN
	
	CREATE TABLE [dbo].[ID]
   (
   [Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ID_Id] DEFAULT (' '),
   [Qty] [int] NOT NULL CONSTRAINT [DF_ID_Qty] DEFAULT ((0)),
   [Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ID_Status] DEFAULT ('OK'),
   [Packkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ID_Packkey] DEFAULT ('STD'),
   [PutAwayTI] [int] NOT NULL CONSTRAINT [DF_ID_PutAwayTi] DEFAULT ((0)),
   [PutAwayHI] [int] NOT NULL CONSTRAINT [DF_ID_PutAwayHi] DEFAULT ((0)),
   [TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
   [ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
   [EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ID_EditWho] DEFAULT (suser_sname()),
   [EditDate] [datetime] NOT NULL CONSTRAINT [DF_ID_EditDate] DEFAULT (getdate()),
   [PalletFlag] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ID_PalletFlag] DEFAULT (''),
   [TaskStatus] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ID_TaskStatus] DEFAULT (''),
   [VirtualLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ID_VirtualLoc] DEFAULT (''),
   [PalletFlag2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ID_PalletFlag2] DEFAULT (''),
   [Channel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ID_Channel] DEFAULT (''),
   [Channel_ID] [bigint] NULL CONSTRAINT [DF_ID_Channel_ID] DEFAULT ((0)),
   [InitialWeight] [float] NULL CONSTRAINT [DF_ID_InitialWeight] DEFAULT ((0)),
   [PalletType] [nvarchar] (10) NOT NULL CONSTRAINT [DF_ID_PalletType] DEFAULT ('')
   ) ON [PRIMARY]


   ALTER TABLE [dbo].[ID] ADD CONSTRAINT [PKID] PRIMARY KEY CLUSTERED ([Id]) WITH (FILLFACTOR=90) ON [PRIMARY]

   GRANT SELECT ON  [dbo].[ID] TO [JReportRole]

   GRANT DELETE ON  [dbo].[ID] TO [NSQL]

   GRANT INSERT ON  [dbo].[ID] TO [NSQL]

   GRANT SELECT ON  [dbo].[ID] TO [NSQL]

   GRANT UPDATE ON  [dbo].[ID] TO [NSQL]

   EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'ID', 'COLUMN', N'EditDate'

   EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'ID', 'COLUMN', N'EditWho'

   EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'ID', 'COLUMN', N'Id'

   EXEC sp_addextendedproperty N'MS_Description', 'Initial Weight', 'SCHEMA', N'dbo', 'TABLE', N'ID', 'COLUMN', N'InitialWeight'

   EXEC sp_addextendedproperty N'MS_Description', 'Name of the Pack code.', 'SCHEMA', N'dbo', 'TABLE', N'ID', 'COLUMN', N'Packkey'

   EXEC sp_addextendedproperty N'MS_Description', 'Also known as quantity on hand, in stock, store quantity. Quantity on hand describes the actual physical inventory in the possession of the business. When inventory is received or produced, it is added to quantity on hand, when inventory is sold or consumed, it is removed from quantity on hand.', 'SCHEMA', N'dbo', 'TABLE', N'ID', 'COLUMN', N'Qty'

   EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'ID', 'COLUMN', N'TrafficCop'

   EXEC sp_addextendedproperty N'MS_Description', 'Pallet Type' , 'SCHEMA', N'dbo', 'TABLE', N'ID', 'COLUMN',N'PalletType'

END
ELSE
BEGIN
	IF NOT EXISTS (SELECT *
                       FROM sys.columns
                       WHERE Name = 'PalletType'
                         AND Object_ID = Object_ID('ID'))
            BEGIN
                ALTER TABLE ID
                    ADD PalletType NVARCHAR(10) NOT NULL CONSTRAINT [DF_ID_PalletType] DEFAULT ('');
                EXEC sp_addextendedproperty N'MS_Description', 'Pallet Type', 'SCHEMA', N'dbo', 'TABLE',
                     N'ID', 'COLUMN', N'PalletType'
            END

      IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'UserDefine01'  AND Object_ID = Object_ID('ID'))
      BEGIN
         ALTER TABLE ID ADD UserDefine01 NVARCHAR(30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ID_UserDefine01] DEFAULT (' ');
         EXEC sp_addextendedproperty N'MS_Description', 'UserDefine01', 'SCHEMA', N'dbo', 'TABLE',
              N'ID', 'COLUMN', N'UserDefine01'
      END

      IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'UserDefine02'  AND Object_ID = Object_ID('ID'))
      BEGIN
         ALTER TABLE ID ADD UserDefine02 NVARCHAR(30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ID_UserDefine02] DEFAULT (' ');
         EXEC sp_addextendedproperty N'MS_Description', 'UserDefine02', 'SCHEMA', N'dbo', 'TABLE',
              N'ID', 'COLUMN', N'UserDefine02'
      END

      IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'UserDefine03'  AND Object_ID = Object_ID('ID'))
      BEGIN
         ALTER TABLE ID ADD UserDefine03 NVARCHAR(30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ID_UserDefine03] DEFAULT (' ');
         EXEC sp_addextendedproperty N'MS_Description', 'UserDefine03', 'SCHEMA', N'dbo', 'TABLE',
              N'ID', 'COLUMN', N'UserDefine03'
      END

      IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'UserDefine04'  AND Object_ID = Object_ID('ID'))
      BEGIN
         ALTER TABLE ID ADD UserDefine04 NVARCHAR(30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ID_UserDefine04] DEFAULT (' ');
         EXEC sp_addextendedproperty N'MS_Description', 'UserDefine04', 'SCHEMA', N'dbo', 'TABLE',
              N'ID', 'COLUMN', N'UserDefine04'
      END

      IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'UserDefine05'  AND Object_ID = Object_ID('ID'))
      BEGIN
         ALTER TABLE ID ADD UserDefine05 NVARCHAR(30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ID_UserDefine05] DEFAULT (' ');
         EXEC sp_addextendedproperty N'MS_Description', 'UserDefine05', 'SCHEMA', N'dbo', 'TABLE',
              N'ID', 'COLUMN', N'UserDefine05'
      END

      IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'UserDefine06'  AND Object_ID = Object_ID('ID'))
      BEGIN
         ALTER TABLE ID ADD [UserDefine06] [datetime] NULL;
         EXEC sp_addextendedproperty N'MS_Description', 'UserDefine06', 'SCHEMA', N'dbo', 'TABLE',
              N'ID', 'COLUMN', N'UserDefine06'
      END

      IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'UserDefine07'  AND Object_ID = Object_ID('ID'))
      BEGIN
         ALTER TABLE ID ADD [UserDefine07] [datetime] NULL;
         EXEC sp_addextendedproperty N'MS_Description', 'UserDefine07', 'SCHEMA', N'dbo', 'TABLE',
              N'ID', 'COLUMN', N'UserDefine07'
      END

      IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'UserDefine08'  AND Object_ID = Object_ID('ID'))
      BEGIN
         ALTER TABLE ID ADD UserDefine08 NVARCHAR(30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ID_UserDefine08] DEFAULT (' ');
         EXEC sp_addextendedproperty N'MS_Description', 'UserDefine08', 'SCHEMA', N'dbo', 'TABLE',
              N'ID', 'COLUMN', N'UserDefine08'
      END

      IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'UserDefine09'  AND Object_ID = Object_ID('ID'))
      BEGIN
         ALTER TABLE ID ADD UserDefine09 NVARCHAR(30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ID_UserDefine09] DEFAULT (' ');
         EXEC sp_addextendedproperty N'MS_Description', 'UserDefine09', 'SCHEMA', N'dbo', 'TABLE',
              N'ID', 'COLUMN', N'UserDefine09'
      END

      IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = 'UserDefine10'  AND Object_ID = Object_ID('ID'))
      BEGIN
         ALTER TABLE ID ADD UserDefine10 NVARCHAR(30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ID_UserDefine10] DEFAULT (' ');
         EXEC sp_addextendedproperty N'MS_Description', 'UserDefine10', 'SCHEMA', N'dbo', 'TABLE',
              N'ID', 'COLUMN', N'UserDefine10'
      END


END
	


