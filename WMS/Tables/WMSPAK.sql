CREATE TABLE [dbo].[WMSPAK]
(
[PACKKEY] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PACKDESCR] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PACKUOM1] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CASECNT] [decimal] (8, 0) NOT NULL,
[ISWHQTY1] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[REPLENISHUOM1] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[REPLENISHZONE1] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CARTONIZEUOM1] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LENGTHUOM1] [decimal] (8, 2) NOT NULL,
[WIDTHUOM1] [decimal] (8, 2) NOT NULL,
[HEIGHTUOM1] [decimal] (8, 2) NOT NULL,
[CUBEUOM1] [decimal] (8, 2) NOT NULL,
[PACKUOM2] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[INNERPACK] [decimal] (8, 0) NOT NULL,
[ISWHQTY2] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[REPLENISHUOM2] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[REPLENISHZONE2] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CARTONIZEUOM2] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LENGTHUOM2] [decimal] (8, 2) NOT NULL,
[WIDTHUOM2] [decimal] (8, 2) NOT NULL,
[HEIGHTUOM2] [decimal] (8, 2) NOT NULL,
[CUBEUOM2] [decimal] (8, 2) NOT NULL,
[PACKUOM3] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QTY] [decimal] (8, 0) NOT NULL,
[ISWHQTY3] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[REPLENISHUOM3] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[REPLENISHZONE3] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CARTONIZEUOM3] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LENGTHUOM3] [decimal] (8, 2) NOT NULL,
[WIDTHUOM3] [decimal] (8, 2) NOT NULL,
[HEIGHTUOM3] [decimal] (8, 2) NOT NULL,
[CUBEUOM3] [decimal] (8, 2) NOT NULL,
[PACKUOM4] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PALLET] [decimal] (8, 0) NOT NULL,
[ISWHQTY4] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[REPLENISHUOM4] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[REPLENISHZONE4] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CARTONIZEUOM4] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LENGTHUOM4] [decimal] (8, 2) NOT NULL,
[WIDTHUOM4] [decimal] (8, 2) NOT NULL,
[HEIGHTUOM4] [decimal] (8, 2) NOT NULL,
[CUBEUOM4] [decimal] (8, 2) NOT NULL,
[PALLETWOODLENGTH] [decimal] (8, 2) NOT NULL,
[PALLETWOODWIDTH] [decimal] (8, 2) NOT NULL,
[PALLETWOODHEIGHT] [decimal] (8, 2) NOT NULL,
[PALLETTI] [decimal] (4, 0) NOT NULL,
[PALLETHI] [decimal] (4, 0) NOT NULL,
[PACKUOM5] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CUBE] [decimal] (8, 2) NOT NULL,
[ISWHQTY5] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PACKUOM6] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GROSSWGT] [decimal] (8, 2) NOT NULL,
[ISWHQTY6] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PACKUOM7] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NETWGT] [decimal] (8, 2) NOT NULL,
[ISWHQTY7] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PACKUOM8] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OTHERUNIT1] [decimal] (8, 0) NOT NULL,
[ISWHQTY8] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[REPLENISHUOM8] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[REPLENISHZONE8] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CARTONIZEUOM8] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LENGTHUOM8] [decimal] (8, 2) NOT NULL,
[WIDTHUOM8] [decimal] (8, 2) NOT NULL,
[HEIGHTUOM8] [decimal] (8, 2) NOT NULL,
[PACKUOM9] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OTHERUNIT2] [decimal] (8, 0) NOT NULL,
[ISWHQTY9] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[REPLENISHUOM9] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[REPLENISHZONE9] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CARTONIZEUOM9] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LENGTHUOM9] [decimal] (8, 2) NOT NULL,
[WIDTHUOM9] [decimal] (8, 2) NOT NULL,
[HEIGHTUOM9] [decimal] (8, 2) NOT NULL,
[ADDDATE] [decimal] (8, 0) NOT NULL,
[ADDWHO] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EDITDATE] [decimal] (8, 0) NOT NULL,
[EDITWHO] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TRAFFICCOP] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ARCHIVECOP] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TIMESTAMP] [nvarchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WMSPAK] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[WMSPAK] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[WMSPAK] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[WMSPAK] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WMSPAK', 'COLUMN', N'ADDDATE'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'WMSPAK', 'COLUMN', N'ADDWHO'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'WMSPAK', 'COLUMN', N'EDITDATE'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'WMSPAK', 'COLUMN', N'EDITWHO'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pick method to use when picking inner packs in the zone.', 'SCHEMA', N'dbo', 'TABLE', N'WMSPAK', 'COLUMN', N'INNERPACK'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the Pack.', 'SCHEMA', N'dbo', 'TABLE', N'WMSPAK', 'COLUMN', N'PACKDESCR'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the Pack code.', 'SCHEMA', N'dbo', 'TABLE', N'WMSPAK', 'COLUMN', N'PACKKEY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated.', 'SCHEMA', N'dbo', 'TABLE', N'WMSPAK', 'COLUMN', N'QTY'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'WMSPAK', 'COLUMN', N'TRAFFICCOP'
GO
