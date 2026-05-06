--Operation Type: SCE_DL_CT358_GVTEvent
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
    'SCE_DL_CT358_GVTEvent',
    'GVT',
    'EUR',
    'GBL',
    'apfbmpgvtsql01',
    'GVTRACK',
    '/sceapi/EUR/GVT/GenericRequest/SCE_DL_Generic_GVTRACK',
    '/sceapi/EUR/GVT/GenericRequest/SCE_DLColumnMap_Inq')

INSERT INTO [dbo].[SCE_DLModule] ([WebApiConfigID],[STG_TBLName],[POST_TBLName])
VALUES (@InsertedId,'[dbo].[EXL_TEMP_WS_STG_STG]','[dbo].[EXL_TEMP_WS_STG]')

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
    3685,
    @InsertedId,
    1,
    N'WS_STG_RULES_100001',
    10,
    N'isp_SCE_DL_GENERIC_WS_STG_RULES_100001_10',
    N'1',
    N'Perform columns checking',
    NULL,
    NULL,
    NULL,
    NULL),
    (
    3686,
    @InsertedId,
    2,
    N'WS_STG_RULES_200001',
    10,
    N'isp_SCE_DL_GENERIC_WS_STG_RULES_200001_10',
    N'1',
    N'Perform Insert into WS_STG table.',
    NULL,
    NULL,
    NULL,
    NULL)
SET IDENTITY_INSERT [dbo].[SCE_DLSubRuleDict_Hdr] OFF

SET IDENTITY_INSERT [dbo].[SCE_DLSubRuleDict_Det] ON
INSERT [dbo].[SCE_DLSubRuleDict_Det] ([SeqNo], [SRDictID], [Lbl_InParm], [Typ_InParm], [Att_InParm], [Val_InParm], [Seq_InParm])
VALUES
    (6827, 3685, N'Validate SERVICE_TYPE', N'NVARCHAR(60)', N'1', N'1', 1),
    (6828, 3685, N'Validate MBL', N'NVARCHAR(60)', N'1', N'1', 2)
SET IDENTITY_INSERT [dbo].[SCE_DLSubRuleDict_Det] OFF
