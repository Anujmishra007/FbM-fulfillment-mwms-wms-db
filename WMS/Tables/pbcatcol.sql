CREATE TABLE [dbo].[pbcatcol]
(
[pbc_tnam] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_tid] [int] NULL,
[pbc_ownr] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_cnam] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_cid] [smallint] NULL,
[pbc_labl] [nvarchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_lpos] [smallint] NULL,
[pbc_hdr] [nvarchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_hpos] [smallint] NULL,
[pbc_jtfy] [smallint] NULL,
[pbc_mask] [nvarchar] (31) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_case] [smallint] NULL,
[pbc_hght] [smallint] NULL,
[pbc_wdth] [smallint] NULL,
[pbc_ptrn] [nvarchar] (31) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_bmap] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_init] [nvarchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_cmnt] [nvarchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_edit] [nvarchar] (31) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_tag] [nvarchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pbcatcol_idx] ON [dbo].[pbcatcol] ([pbc_tnam], [pbc_ownr], [pbc_cnam]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[pbcatcol] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[pbcatcol] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[pbcatcol] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[pbcatcol] TO [NSQL]
GO
