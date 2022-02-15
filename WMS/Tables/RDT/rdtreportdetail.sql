CREATE TABLE [RDT].[rdtreportdetail]
(
[storerkey] [nvarchar] (20) NULL,
[reporttype] [nvarchar] (20) NULL,
[processtype] [nvarchar] (20) NULL,
[SUBPlatform] [nvarchar] (20) NULL,
[printtemplate] [nvarchar] (max) NULL,
[printtemplatesp] [nvarchar] (20) NULL,
[function_id] [int] NULL
) ON [PRIMARY]
GO
