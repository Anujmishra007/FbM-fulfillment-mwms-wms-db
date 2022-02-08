CREATE TABLE [RDT].[rdtPrinterGroup]
(
[PrinterID] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PrinterGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DefaultPrinter] [int] NOT NULL CONSTRAINT [DF_rdtPrinterGroup_DefaultPrinter] DEFAULT ((0)),
[Description] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPrinterGroup_Description] DEFAULT (''),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtPrinterGroup_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPrinterGroup_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtPrinterGroup_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPrinterGroup_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [RDT].[rdtPrinterGroup] ADD CONSTRAINT [PK_rdtPrinterGroup] PRIMARY KEY CLUSTERED ([PrinterGroup], [PrinterID]) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtPrinterGroup] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtPrinterGroup] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtPrinterGroup] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtPrinterGroup] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Printer group (not to confuse with rdt.rdtPrinter.PrinterGroup, which is use by RDTSpooler)', 'SCHEMA', N'RDT', 'TABLE', N'rdtPrinterGroup', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'The default printer in a printer group (1=Default)', 'SCHEMA', N'RDT', 'TABLE', N'rdtPrinterGroup', 'COLUMN', N'DefaultPrinter'
GO
