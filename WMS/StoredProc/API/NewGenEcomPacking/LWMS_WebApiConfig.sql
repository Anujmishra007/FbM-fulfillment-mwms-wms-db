DECLARE @c_TargetDB NVARCHAR(15) = DB_NAME()

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_SCANSKU', @c_TargetDB, 'API', 'isp_ECOMP_API_ScanSKU', 'Y', 'N', 'PAC-4 Single Pack SKU Scanning', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_SCANSKU'
)

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_SCANSERIALNO', @c_TargetDB, 'API', 'isp_ECOMP_API_ScanSerialNumber', 'Y', 'N', 'PAC-4 Serial Number Scanning', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_SCANSERIALNO'
)

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_GETPACKTASK', @c_TargetDB, 'API', 'isp_ECOMP_API_GetPackTask', 'Y', 'N', 'PAC-4 Single Pack Get Pack Tasks', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_GETPACKTASK'
)

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_SEARCHORDER', @c_TargetDB, 'API', 'isp_ECOMP_API_SearchPackOrder', 'Y', 'N', 'PAC-4 Search For Orders/ Update Pack HD/DT', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_SEARCHORDER'
)

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_PACKQRF_SCANQRCODE', @c_TargetDB, 'API', 'isp_ECOMP_API_PackQRF_ScanQRCode', 'Y', 'N', 'PAC-4 Pack QRF Screen - Scan QR Code & Validation', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_PACKQRF_SCANQRCODE'
)

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_REDO', @c_TargetDB, 'API', 'isp_ECOMP_API_Redo', 'Y', 'N', 'PAC-4 Redo', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_REDO'
)

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_UNDO', @c_TargetDB, 'API', 'isp_ECOMP_API_Undo', 'Y', 'N', 'PAC-4 Undo Pack Confirm', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_UNDO'
)

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_PACKCONFIRM', @c_TargetDB, 'API', 'isp_ECOMP_API_PackConfirm', 'Y', 'N', 'PAC-4 PackConfirm', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_PACKCONFIRM'
)

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_CONVERTCARTONTYPE', @c_TargetDB, 'API', 'isp_ECOMP_API_ConvertCartonType', 'Y', 'N', 'PAC-4 Convert Carton Type', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_CONVERTCARTONTYPE'
)

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_GETORDERS_S', @c_TargetDB, 'API', 'isp_ECOMP_API_GetOrderList_S', 'Y', 'N', 'PAC-4 Get Pending Orders', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_GETORDERS_S'
)

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_SCANCTNLBL_S', @c_TargetDB, 'API', 'isp_ECOMP_API_ScanCartonLabelNo', 'Y', 'N', 'PAC-4 Scan Carton Label No - Single', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_SCANCTNLBL_S'
)

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_GETVAS', @c_TargetDB, 'API', 'isp_ECOMP_API_GetVasActivity', 'Y', 'N', 'PAC-4 Get VAS Activity', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_GETVAS'
)

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_UPDATEVAS', @c_TargetDB, 'API', 'isp_ECOMP_API_UpdateVasActivity', 'Y', 'N', 'PAC-4 Update VAS Activity', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_UPDATEVAS'
)

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_AUTOPRINT', @c_TargetDB, 'API', 'isp_ECOMP_API_Auto_Print', 'Y', 'N', 'PAC-65 Auto Print Packing Report', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_AUTOPRINT'
)

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_PRINT', @c_TargetDB, 'API', 'isp_ECOMP_API_Report_Print', 'Y', 'N', 'PAC-65 Print Packing Report', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_PRINT'
)

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_GETREPORTPARAM', @c_TargetDB, 'API', 'isp_ECOMP_API_GetReportParam', 'Y', 'N', 'PAC-65 Get Print Packing Report Info', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_GETREPORTPARAM'
)

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_GETREPORTS', @c_TargetDB, 'API', 'isp_ECOMP_API_GetReports', 'Y', 'N', 'PAC-65 Get Print Report List', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_GETREPORTS'
)

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_ASSIGNORDER_M', @c_TargetDB, 'API', 'isp_ECOMP_API_AssignOrder_M', 'Y', 'N', 'PAC-7 Update PackHeader with OrderKey selection From UI (Multi)', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_ASSIGNORDER_M'
)

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_CLOSECARTON_M', @c_TargetDB, 'API', 'isp_ECOMP_API_CloseCarton_M', 'Y', 'N', 'PAC-7 Close Carton (Multi)', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_CLOSECARTON_M'
)

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_SCANSKU_M', @c_TargetDB, 'API', 'isp_ECOMP_API_ScanSKU_M', 'Y', 'N', 'PAC-7 Scan SKU (Multi)', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_SCANSKU_M'
)

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_SCANLOTTABLE_M', @c_TargetDB, 'API', 'isp_ECOMP_API_ScanLottable_M', 'Y', 'N', 'PAC-7 Scan Lottable (Multi)', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_SCANLOTTABLE_M'
)

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_SCANSERIALNUMBER_M', @c_TargetDB, 'API', 'isp_ECOMP_API_ScanSerialNumber_M', 'Y', 'N', 'PAC-7 Scan Serial Number (Multi)', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_SCANSERIALNUMBER_M'
)

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_CLOSECTNPRINT_M', @c_TargetDB, 'API', 'isp_ECOMP_API_CloseCartonPrint_M', 'Y', 'N', 'PAC-7 Close Carton Printing (Multi)', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_CLOSECTNPRINT_M'
)

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_SCANLOTTABLE_S', @c_TargetDB, 'API', 'isp_ECOMP_API_ScanLottable_S', 'Y', 'N', 'PAC-142 Scan Lottable (SINGLE)', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_SCANLOTTABLE_S'
)

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_GETSYSSUGCTNTYPE', @c_TargetDB, 'API', 'isp_ECOMP_API_GetSuggestedCartonType', 'Y', 'N', 'PAC-363 Get System Suggested Carton Type', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_GETSYSSUGCTNTYPE'
)

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_GEN_CCTVFILENAME', @c_TargetDB, 'API', 'isp_ECOMP_API_GENCCTVFileName', 'Y', 'N', 'PAC-354 Generate CCTV FileName', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_GEN_CCTVFILENAME'
)

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_VALIDATE_CTNTYPE', @c_TargetDB, 'API', 'isp_ECOMP_API_ValidateCartonType', 'Y', 'N', 'PAC-320 Validate carton type input by user', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_VALIDATE_CTNTYPE'
)

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_GETDUSTBAGLIST', @c_TargetDB, 'API', 'isp_ECOMP_API_GetDustBagList', 'Y', 'N', 'FCR-9149 Check and retreive Dustbag required for order', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_GETDUSTBAGLIST'
)

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_VALIDATE_CTNTYPE_CUST', @c_TargetDB, 'API', 'isp_ECOMP_API_ValidateCartonType_Cust', 'Y', 'N', 'FCR-9928 China - Maersk WMS v0 - VF CORPORATION - CartonType Validation', 1
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_VALIDATE_CTNTYPE_CUST'
)