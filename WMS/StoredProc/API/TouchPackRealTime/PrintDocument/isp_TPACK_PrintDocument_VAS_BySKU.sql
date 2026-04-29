SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_PrintDocument_VAS_BySKU                            */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Get Repoorts INFO by VAS Code when SKU Scan                  */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-12-24   1.0  YLI237     UWP-45422                                        */
/* 2026-02-25   2.0  GCH225     UWP-49257 Enhancement.                           */
/* 2026-04-01   2.1  GCH225     FCR-12063 VasCustPref New Logic                  */
/*********************************************************************************/


CREATE OR ALTER PROC [API].[isp_TPACK_PrintDocument_VAS_BySKU] (
     @cWODType             NVARCHAR(30)   = ''
   , @cStorerKey           NVARCHAR(15)   = ''
   , @cFacility            NVARCHAR(5)    = ''
   , @cOrderKey            NVARCHAR(10)   = ''
   , @cPickSlipNo          NVARCHAR(10)   = ''
   , @nCartonNo            INT            = 0
   , @cSKU                 NVARCHAR(50)   = ''
   , @cUDF01_WK            NVARCHAR(60)   = ''
   , @cUDF04_WK            NVARCHAR(60)   = ''
   , @bPrintLabelFlag      BIT            = 0
   , @bPrintPaperFlag      BIT            = 0
   , @cLangCode            NVARCHAR(3)    = ''
   , @b_Success            INT            = 0   OUTPUT  
   , @n_ErrNo              INT            = 0   OUTPUT
   , @c_ErrMsg             NVARCHAR(250)  = ''  OUTPUT
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @n_Continue     INT           = 1  
         , @n_StartCnt     INT           = @@TRANCOUNT  

   DECLARE @cModuleID      NVARCHAR(30)  = 'TPPACK'
         , @cUDF01_Pref    NVARCHAR(60)  = ''
         , @cUDF02_Pref    NVARCHAR(60)  = ''
         , @cUDF04_Pref    NVARCHAR(60)  = ''
         , @cCode2_Pref    NVARCHAR(30)  = ''
         , @FinalUDF01     NVARCHAR(60)  = ''
         , @ReportID       NVARCHAR(10)  = ''
         , @ReportLine     NVARCHAR(5)   = ''
         , @cConsigneeKey  NVARCHAR(15) = ''
         , @cMarkForKey    NVARCHAR(15) = ''
         , @cBillToKey     NVARCHAR(15) = ''
         , @cStyle         NVARCHAR(30) = ''
         , @cSKUGroup      NVARCHAR(30) = ''

   SET @FinalUDF01 = @cUDF01_WK
   
   IF @cOrderKey <> ''
   BEGIN
      SELECT  @cConsigneeKey = ISNULL(ConsigneeKey, '')
            , @cMarkForKey   = ISNULL(MarkForKey, '')
            , @cBillToKey    = ISNULL(BillToKey, '')
      FROM ORDERS (NOLOCK)
      WHERE OrderKey = @cOrderKey 
   END

   IF @cSKU <> ''
   BEGIN
      SELECT @cStyle    = ISNULL(Style, '')
           , @cSKUGroup = ISNULL(SKUGroup, '')
      FROM SKU (NOLOCK)
      WHERE StorerKey = @cStorerKey 
      AND SKU = @cSKU;
   END

   DECLARE CUR_LOOP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT  ISNULL(UDF01,'')
         , ISNULL(UDF02,'')
         , ISNULL(UDF04,'')
         , ISNULL(Code2,'')
   FROM CODELKUP (NOLOCK)
   WHERE StorerKey = @cStorerKey
   AND LISTNAME = 'VASCustPre' 
   AND Code = @cWODType
   AND Short = 'Active' 
   
   OPEN CUR_LOOP
   FETCH NEXT FROM CUR_LOOP INTO @cUDF01_Pref
                               , @cUDF02_Pref
                               , @cUDF04_Pref
                               , @cCode2_Pref
   WHILE @@FETCH_STATUS = 0
   BEGIN
      IF @cUDF02_Pref = 'Consignee'
      BEGIN
         SET @FinalUDF01 = IIF(
            (@cUDF04_Pref = '' AND (@cCode2_Pref = @cConsigneeKey OR @cCode2_Pref = @cMarkForKey OR @cCode2_Pref = @cBillToKey))
         OR (@cUDF04_Pref = 'ConsigneeKey' AND @cCode2_Pref = @cConsigneeKey)
         OR (@cUDF04_Pref = 'MarkForKey' AND @cCode2_Pref = @cMarkForKey)
         OR (@cUDF04_Pref = 'BillToKey' AND @cCode2_Pref = @cBillToKey)
                                 , @cUDF01_Pref
                                 , @cUDF01_WK)
      END
      ELSE IF @cUDF02_Pref = 'SKU'
      BEGIN
         SET  @FinalUDF01 = IIF((@cCode2_Pref = @cSKUGroup 
                                 OR @cCode2_Pref = @cStyle)
                                 , @cUDF01_Pref
                                 , @cUDF01_WK)
      END  
      
      FETCH NEXT FROM CUR_LOOP INTO @cUDF01_Pref
                                  , @cUDF02_Pref
                                  , @cUDF04_Pref
                                  , @cCode2_Pref   
   END
   CLOSE CUR_LOOP
   DEALLOCATE CUR_LOOP
      
   IF @FinalUDF01 <> '' AND CHARINDEX('_', @FinalUDF01) > 0
   BEGIN
      SET @ReportID = LEFT(@FinalUDF01, CHARINDEX('_', @FinalUDF01) - 1);
      SET @ReportLine = SUBSTRING(@FinalUDF01, CHARINDEX('_', @FinalUDF01) + 1, LEN(@FinalUDF01));
   END

   IF @ReportID = '' OR @ReportLine = ''
   BEGIN
      SET @n_Continue = 1
      GOTO EXIT_SP
   END

   SELECT  WMR.ReportID
         , WMRD.ReportLineNo
         , IIF(WMRD.PrintType = 'LOGIREPORT', 'JReport', 'WMReport') AS PrintSource
         , ISNULL(WMRD.DefaultPrinterID, '') AS DefaultPrinterID
         , WMRD.IsPaperPrinter
         , ISNULL(WMR.KeyFieldName1, '') AS KeyFieldName1
         , ISNULL(WMR.KeyFieldName2, '') AS KeyFieldName2
         , ISNULL(WMR.KeyFieldName3, '') AS KeyFieldName3
         , ISNULL(WMR.KeyFieldName4, '') AS KeyFieldName4
         , WMR.ReportType
   FROM WMREPORTDETAIL WMRD (NOLOCK)
   JOIN WMREPORT WMR (NOLOCK) 
   ON WMR.ReportID = WMRD.ReportID 
   WHERE WMR.ModuleID = @cModuleID
   AND WMRD.StorerKey = @cStorerKey
   AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility)
   AND WMR.ReportID = @ReportID
   AND WMRD.ReportLineNo = @ReportLine

EXIT_SP:
   IF @n_Continue = 3  -- Error Occured - Process And Return      
   BEGIN      
      SET @b_Success = 0      
      IF @@TRANCOUNT > @n_StartCnt AND @@TRANCOUNT = 1 
      BEGIN               
         ROLLBACK TRAN      
      END      
      ELSE      
      BEGIN      
         WHILE @@TRANCOUNT > @n_StartCnt      
         BEGIN      
            COMMIT TRAN      
         END      
      END   
      RETURN      
   END      
   ELSE      
   BEGIN      
      SELECT @b_Success = 1      
      WHILE @@TRANCOUNT > @n_StartCnt      
      BEGIN      
         COMMIT TRAN      
      END      
      RETURN      
   END
END
GO
