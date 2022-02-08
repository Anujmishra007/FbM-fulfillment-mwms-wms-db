CREATE TABLE [dbo].[rdsMenu]
(
[MenuID] [int] NOT NULL,
[SeqNo] [int] NOT NULL CONSTRAINT [DF_rdsMenu_SeqNo] DEFAULT ((0)),
[Type] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsMenu_Descr] DEFAULT (''),
[ObjectName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsMenu_ObjectName] DEFAULT (''),
[BitMap] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdsMenu_BitMap] DEFAULT (''),
[PrevMenuID] [int] NOT NULL CONSTRAINT [DF_rdsMenu_PrevMenuID] DEFAULT ((0)),
[NextMenuID] [int] NOT NULL CONSTRAINT [DF_rdsMenu_NextMenuID] DEFAULT ((0)),
[Visible] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsMenu_Visible] DEFAULT ('Y'),
[Enable] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdsMenu_Enable] DEFAULT ('Y')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[rdsMenu] ADD CONSTRAINT [PK_rdsMenu] PRIMARY KEY CLUSTERED ([MenuID], [SeqNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[rdsMenu] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[rdsMenu] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[rdsMenu] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[rdsMenu] TO [NSQL]
GO
