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
/*********************************************************************************/


CREATE OR ALTER PROC [API].[isp_TPACK_PrintDocument_VAS_BySKU] (
     @cWODType             NVARCHAR(30)   = ''
   , @cStorerKey           NVARCHAR(15)   = ''
   , @cFacility            NVARCHAR(5)    = ''
   , @cOrderKey            NVARCHAR(10)   = ''
   , @cPickSlipNo          NVARCHAR(10)   = ''
   , @nCartonNo            INT            = 0
   , @cWorkOrderKey        NVARCHAR(10)   = ''
   , @cWorkOrderLineNumber NVARCHAR(5)    = ''
   , @cSKU                 NVARCHAR(50)   = ''
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

   DECLARE @n_Continue           INT            = 1  
         , @n_StartCnt           INT            = @@TRANCOUNT  

   DECLARE @cModuleID         NVARCHAR(30)   = 'TPPACK'
         , @cUDF01_WK         NVARCHAR(MAX)  = ''
         , @UDF01_Pref        NVARCHAR(MAX)  = ''
         , @UDF02_Pref        NVARCHAR(30)   = ''
         , @Code2_Pref        NVARCHAR(50)   = ''
         , @FinalUDF01        NVARCHAR(MAX)  = ''
         , @ReportID          NVARCHAR(10)   = ''
         , @ReportLine        NVARCHAR(10)   = ''

   SELECT TOP 1 @cUDF01_WK = ISNULL(UDF01,'')
   FROM CODELKUP (NOLOCK) 
   WHERE StorerKey = @cStorerKey
   AND LISTNAME = 'WKOrdType'    
   AND Code = @cWODType
   AND UDF04 = 'PRICELB'
   
   IF @@ROWCOUNT = 0
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 1007    
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') --No PRICELB configuration found in CodeLkup
      GOTO EXIT_SP  
   END

   SET @FinalUDF01 = @cUDF01_WK;
      
      -- IF NOT EXISTS (SELECT 1 
      --                FROM WORKORDERDETAIL (NOLOCK) 
      --                WHERE WorkOrderKey = @cWorkOrderKey
      --                AND WorkOrderLineNumber = @cWorkOrderLineNumber
      --                AND [Type] = @cTypeFromWOD
      --                AND SKU = @cSKU
      -- )
      -- BEGIN
      --    SET @n_Continue = 3
      --    SET @n_ErrNo = 1006    
      --    SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') --No PRICELB requirement found in WorkOrderDetail
      --    GOTO EXIT_SP  
      -- END
   -- END
   -- ELSE
   -- BEGIN
   --    IF ISNULL(@cType, '') <> ''
   --    BEGIN
   --       SET @cTypeFromWOD = @cWODType
   --    END
   --    ELSE
   --    BEGIN
   --       SELECT TOP 1 @cTypeFromWOD = Type
   --       FROM WorkOrderDetail (NOLOCK)
   --       WHERE ExternWorkOrderKey = @cOrderKey AND (StorerKey = '' OR StorerKey = @cStorerKey) AND SKU = @cSKU;
   --    END

   --    SELECT
   --    @cUDF01_WK = UDF01
   --    ,@cUDF04_WK = UDF04
   --    FROM CodeLkup (NOLOCK)
   --    WHERE Listname = 'WKOrdType' AND Code = @cTypeFromWOD AND (StorerKey = '' OR StorerKey = @cStorerKey);


   --    IF ISNULL(@cUDF01_WK,'') = ''
   --    BEGIN
   --       SET @n_Continue = 3
   --       SET @n_ErrNo = 1001    
   --       SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') --Silent Skip: WKOrdType UDF01 empty
   --       GOTO EXIT_SP  
   --    END

   --    IF @bIsAutoPrint = 1 AND UPPER(@cUDF04_WK) = 'PRICELB'
   --    BEGIN
   --       SET @n_Continue = 3
   --       SET @n_ErrNo = 1001    
   --       SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') --Silent Skip: Skipped PRICELB in PrintDoc
   --       GOTO EXIT_SP
   --    END
   -- END

   SELECT  @UDF01_Pref = ISNULL(UDF01,'')
         , @UDF02_Pref = ISNULL(UDF02,'')
         , @Code2_Pref = ISNULL(Code2,'')
   FROM CODELKUP (NOLOCK)
   WHERE StorerKey = @cStorerKey
   AND LISTNAME = 'VASCustPre' 
   AND Code = @cWODType
   AND Short = 'Active' -- Only consider active configuration for printing, inactive or no config will be treated as skip for printing

   IF @@ROWCOUNT > 0
   BEGIN
      IF @UDF02_Pref = 'Consignee'
      BEGIN
         SELECT  @FinalUDF01 = IIF((@Code2_Pref = ConsigneeKey 
                                 OR @Code2_Pref = MarkForKey 
                                 OR @Code2_Pref = BillToKey)
                                 , @UDF01_Pref
                                 , @cUDF01_WK
                                 )
         FROM ORDERS (NOLOCK)
         WHERE OrderKey = @cOrderKey 
         AND StorerKey = @cStorerKey;
      END
      ELSE IF @UDF02_Pref = 'SKU'
      BEGIN
         -- IF ISNULL(@cSKU, '') = '' AND ISNULL(@cExternLineNo, '') <> ''
         -- BEGIN
         --       SELECT TOP 1 @cSKU = pd.SKU
         --       FROM PICKDETAIL pd (NOLOCK)
         --       JOIN WorkOrderDetail wod (NOLOCK) 
         --       ON wod.ExternWorkOrderKey = pd.OrderKey 
         --       AND wod.ExternLineNo = pd.OrderLineNumber
         --       AND wod.StorerKey = pd.StorerKey
         --       WHERE pd.OrderKey = @cOrderKey 
         --       AND wod.Type = @cTypeFromWOD 
         --       AND wod.ExternLineNo = @cExternLineNo
         --       AND (pd.StorerKey = '' OR pd.StorerKey = @cStorerKey)
         -- END
         SELECT  @FinalUDF01 = IIF((@Code2_Pref = SKUGroup 
                                 OR @Code2_Pref = Style)
                                 , @UDF01_Pref
                                 , @cUDF01_WK
                                 )
         FROM SKU (NOLOCK)
         WHERE StorerKey = @cStorerKey 
         AND SKU = @cSKU;
      END
   END

   IF CHARINDEX('_', @FinalUDF01) > 0
   BEGIN
      SET @ReportID = LEFT(@FinalUDF01, CHARINDEX('_', @FinalUDF01) - 1);
      SET @ReportLine = SUBSTRING(@FinalUDF01, CHARINDEX('_', @FinalUDF01) + 1, LEN(@FinalUDF01));
   END
   -- ELSE IF CHARINDEX('/', @FinalUDF01) > 0
   -- BEGIN
   --     SET @ReportID = LEFT(@FinalUDF01, CHARINDEX('/', @FinalUDF01) - 1);
   --     SET @ReportLine = SUBSTRING(@FinalUDF01, CHARINDEX('/', @FinalUDF01) + 1, LEN(@FinalUDF01));
   -- END

   IF @ReportID = '' OR @ReportLine = ''
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 1001    
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') --Invalid UDF01 format
      GOTO EXIT_SP
   END

   IF NOT EXISTS (SELECT 1
                  FROM WORKORDERDETAIL WMRD (NOLOCK)
                  JOIN WMREPORT WMR (NOLOCK) 
                  ON WMR.ReportID = WMRD.ReportID                   
                  WHERE WMRD.ReportID = @ReportID
                  AND WMR.ModuleID = @cModuleID
                  AND WMRD.ReportLineNo = @ReportLine
                  AND WMRD.StorerKey = @cStorerKey
                  AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility)
   )
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 1005    
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') --Report detail not found
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
         , 1 AS IsSKUReport
   FROM WORKORDERDETAIL WMRD (NOLOCK)
   JOIN WMREPORT WMR (NOLOCK) 
   ON WMR.ReportID = WMRD.ReportID 
   WHERE WMRD.ReportID = @ReportID
   AND WMRD.ReportLineNo = @ReportLine
   AND WMR.ModuleID = @cModuleID
   AND WMRD.StorerKey = @cStorerKey
   AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility)
   AND WMRD.ReportType='TPVAS'

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
