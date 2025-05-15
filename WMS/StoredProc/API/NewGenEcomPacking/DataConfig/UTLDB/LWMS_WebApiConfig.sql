INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'SCE_ConvertCountryCode', 'GTAPPS', 'dbo', 'isp_SCE_ConvertCountryCode', 'Y', 'N', 'Convert SCE 3-char country code to 2-char', 1
WHERE NOT EXISTS ( SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'SCE_ConvertCountryCode' )

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_UpdateUserPF', 'GTAPPS', 'dbo', 'isp_ECOMP_UpdateUserProfile', 'Y', 'N', 'Update NewGen ECOMPacking''s User Profile', 1
WHERE NOT EXISTS ( SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_UpdateUserPF' )

INSERT INTO dbo.LWMS_WebApiConfig (OperationType, TargetDB, TargetSchema, WSPostingSP01, SPTJSON, SPTXML, [Descr], ResponseOriContent)
SELECT 'ECOMP_GetUserPF', 'GTAPPS', 'dbo', 'isp_ECOMP_GetUserProfile', 'Y', 'N', 'Get NewGen ECOMPacking''s User Profile', 1
WHERE NOT EXISTS ( SELECT 1 FROM dbo.LWMS_WebApiConfig (NOLOCK) WHERE OperationType = 'ECOMP_GetUserPF' )



