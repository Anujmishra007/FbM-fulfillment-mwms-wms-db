--Operation Type: SCE_DL_CT341_SHPCONT
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
    'SCE_DL_CT341_SHPCONT',
    'GVT',
    'EUR',
    'GBL',
    'apfbmpgvtsql01',
    'GVTRACK',
    '/sceapi/EUR/GVT/GenericRequest/SCE_DL_Generic_GVTRACK',
    '/sceapi/EUR/GVT/GenericRequest/SCE_DLColumnMap_Inq')

INSERT INTO [dbo].[SCE_DLModule] ([WebApiConfigID],[STG_TBLName],[POST_TBLName])
VALUES (@InsertedId,'[dbo].[SCE_DL_SHPCONT_STG]','[dbo].[SCE_DL_SHPCONT]')

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
    3687,
    @InsertedId,
    1,
    N'SHPCONT_RULES_100001',
    10,
    N'isp_SCE_DL_GENERIC_SHPCONT_RULES_100001_10',
    N'1',
    N'Perform default value checking ',
    NULL,
    NULL,
    NULL,
    NULL),
    (
    3688,
    @InsertedId,
    1, N'SHPCONT_RULES_100002',
    10,
    N'isp_SCE_DL_GENERIC_SHPCONT_RULES_100002_10',
    N'1',
    N'Perform HBL value checking',
    NULL,
    NULL,
    NULL,
    NULL),
    (
    3689,
    @InsertedId,
    2,
    N'SHPCONT_RULES_200001',
    10,
    N'isp_SCE_DL_GENERIC_SHPCONT_RULES_200001_10',
    N'1',
    N'Perform Insert/Update into GV_Shipment, GV_Shipment_Move and GV_Container table.',
    NULL,
    NULL,
    NULL,
    NULL)
SET IDENTITY_INSERT [dbo].[SCE_DLSubRuleDict_Hdr] OFF

SET IDENTITY_INSERT [dbo].[SCE_DLSubRuleDict_Det] ON
INSERT [dbo].[SCE_DLSubRuleDict_Det] ([SeqNo], [SRDictID], [Lbl_InParm], [Typ_InParm], [Att_InParm], [Val_InParm], [Seq_InParm])
VALUES
    (6829, 3687, N'ClientID', N'NVARCHAR(60)', N'1', N'LOGITECH', 1),
    (6830, 3687, N'Doc Status', N'NVARCHAR(60)', N'1', N'NEW', 2),
    (6831, 3687, N'Shp Move Status', N'NVARCHAR(60)', N'1', N'New', 3),
    (6832, 3688, N'ActiveFlag', N'NVARCHAR(60)', N'1', N'1', 1),
    (6833, 3689, N'ASN or HBL', N'NVARCHAR(60)', N'2', N'2', 1)
SET IDENTITY_INSERT [dbo].[SCE_DLSubRuleDict_Det] OFF
