CREATE TABLE [dbo].[pbcattbl]
(
[pbt_tnam] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbt_tid] [int] NULL,
[pbt_ownr] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbd_fhgt] [smallint] NULL,
[pbd_fwgt] [smallint] NULL,
[pbd_fitl] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbd_funl] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbd_fchr] [smallint] NULL,
[pbd_fptc] [smallint] NULL,
[pbd_ffce] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbh_fhgt] [smallint] NULL,
[pbh_fwgt] [smallint] NULL,
[pbh_fitl] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbh_funl] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbh_fchr] [smallint] NULL,
[pbh_fptc] [smallint] NULL,
[pbh_ffce] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbl_fhgt] [smallint] NULL,
[pbl_fwgt] [smallint] NULL,
[pbl_fitl] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbl_funl] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbl_fchr] [smallint] NULL,
[pbl_fptc] [smallint] NULL,
[pbl_ffce] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbt_cmnt] [nvarchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pbcattbl_idx] ON [dbo].[pbcattbl] ([pbt_tnam], [pbt_ownr]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[pbcattbl] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[pbcattbl] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[pbcattbl] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[pbcattbl] TO [NSQL]
GO
