CREATE TABLE [dbo].[DEL_RefKeyLookup]
(
[PickDetailkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Pickslipno] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Loadkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[DeleteWho] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeleteDate] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DEL_RefKeyLookup] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[DEL_RefKeyLookup] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[DEL_RefKeyLookup] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[DEL_RefKeyLookup] TO [NSQL]
GO
