--Operation Type: SCE_DL_CT624_ORDDET
DECLARE @InsertedId INT = 0;

INSERT INTO [dbo].[SCE_DLWebApiConfig] (
    [OperationType],
    [Application],
    [Environment],
    [Country],
    [TgtServer],
    [TgtDatabase],
    [URL],
    [ColumnMapURL])
OUTPUT inserted.WebApiConfigID INTO @InsertedId
VALUES (
    'SCE_DL_CT624_ORDDET',
    'GVT',
    'EUR',
    'GBL',
    'apfbmpgvtsql01',
    'GVTRACK',
    '/sceapi/EUR/GVT/GenericRequest/SCE_DL_Generic_GVTRACK',
    '/sceapi/EUR/GVT/GenericRequest/SCE_DLColumnMap_Inq')

INSERT INTO [dbo].[SCE_DLModule] ([WebApiConfigID],[STG_TBLName],[POST_TBLName])
VALUES (@InsertedId,'[dbo].[SCE_DL_ORDDET_STG]','[dbo].[SCE_DL_ORDDET]')

SET IDENTITY_INSERT [dbo].[SCE_DLSubRuleDict_Hdr] ON
INSERT [dbo].[SCE_DLSubRuleDict_Hdr] (
    [SRDictID],
    [WebApiConfigID],
    [Flag],
    [Code],
    [Step],
    [SubRuleSP],
    [IsActive],
    [Descr],
    [Notes],
    [Pre_Flag],
    [Pre_Code],
    [Pre_Step])
VALUES (
    3690,
    @InsertedId,
    1,
    N'ORDDET_RULES_100001',
    10,
    N'isp_SCE_DL_GENERIC_ORDDET_RULES_100001_10',
    N'1',
    N'Perform default value checking ',
    NULL,
    NULL,
    NULL,
    NULL),
    (
    3691,
    @InsertedId,
    2,
    N'ORDDET_RULES_200001',
    10,
    N'isp_SCE_DL_GENERIC_ORDDET_RULES_200001_10',
    N'1',
    N'Perform Insert/Update into GV_Order, GV_Order_Move and GV_Order_Detail table.',
    NULL,
    NULL,
    NULL,
    NULL)
SET IDENTITY_INSERT [dbo].[SCE_DLSubRuleDict_Hdr] OFF

SET IDENTITY_INSERT [dbo].[SCE_DLSubRuleDict_Det] ON
INSERT [dbo].[SCE_DLSubRuleDict_Det] ([SeqNo], [SRDictID], [Lbl_InParm], [Typ_InParm], [Att_InParm], [Val_InParm], [Seq_InParm])
VALUES (6834, 3690, N'ClientID', N'NVARCHAR(60)', N'1', N'LOGITECH', 1)
SET IDENTITY_INSERT [dbo].[SCE_DLSubRuleDict_Det] OFF
