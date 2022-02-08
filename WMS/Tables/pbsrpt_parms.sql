CREATE TABLE [dbo].[pbsrpt_parms]
(
[rpt_id] [nvarchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[parm_no] [tinyint] NOT NULL,
[parm_datatype] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[parm_label] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[parm_default] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[style] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[name] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[display] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[data] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[attributes] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[visible] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pbsrpt_parms] ADD CONSTRAINT [rpt_parms_id_ndx] PRIMARY KEY CLUSTERED ([rpt_id], [parm_no]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[pbsrpt_parms] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[pbsrpt_parms] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[pbsrpt_parms] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[pbsrpt_parms] TO [NSQL]
GO
