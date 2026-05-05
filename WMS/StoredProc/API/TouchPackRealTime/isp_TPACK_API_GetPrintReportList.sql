SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_API_GetPrintReportList                             */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Get the list of Print Report Types                           */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2026-04-15   1.0  GCH225     Created                                          */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_API_GetPrintReportList] (
     @b_Debug           INT            = 0  
   , @c_Format          VARCHAR(10)    = ''  
   , @c_UserID          NVARCHAR(256)  = ''  
   , @c_OperationType   NVARCHAR(60)   = ''  
   , @c_RequestString   NVARCHAR(MAX)  = ''  
   , @b_Success         INT            = 0   OUTPUT  
   , @n_ErrNo           INT            = 0   OUTPUT  
   , @c_ErrMsg          NVARCHAR(250)  = ''  OUTPUT  
   , @c_ResponseString  NVARCHAR(MAX)  = ''  OUTPUT  
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @n_Continue     INT            = 1  
         , @n_StartCnt     INT            = @@TRANCOUNT  
         , @b_sp_Success   INT  
         , @n_sp_err       INT  
         , @c_sp_errmsg    NVARCHAR(250)  = ''
         , @DBUserName     NVARCHAR(100)
         , @b_sp_ExecuteAs BIT

   DECLARE @cType          NVARCHAR(30)
         , @bIsDiscrete    BIT
         , @bIsCustom      BIT
         , @cLangCode      NVARCHAR(3)
         , @cPickSlipNo    NVARCHAR(10)
         , @cOrderKey      NVARCHAR(10)
         , @cLoadKey       NVARCHAR(10)
         , @cDropID        NVARCHAR(20)
         , @cStorerKey     NVARCHAR(15)
         , @cFacility      NVARCHAR(5)
         , @nPageIndex     INT
         , @cPaperType     NVARCHAR(20)
         , @cWorkstation   NVARCHAR(20)
         , @cLabelPrinter  NVARCHAR(10)
         , @cPaperPrinter  NVARCHAR(10)
         , @cModuleID       NVARCHAR(30)

   SET @cModuleID = 'TPPack'

   --Decode Json Format
   SELECT  @cType       = cType
         , @bIsDiscrete = bIsDiscrete
         , @bIsCustom   = bIsCustom
         , @cPickSlipNo = cPickSlipNo
         , @cOrderKey   = cOrderKey
         , @cLoadKey    = cLoadKey
         , @cDropID     = cDropID
         , @cLangCode   = cLangCode
         , @cStorerKey  = cStorerKey
         , @cFacility   = cFacility
         , @cPaperType  = cPaperType
   FROM OPENJSON(@c_RequestString)
   WITH (
	      cType       NVARCHAR(30)
	    , bIsDiscrete BIT
	    , bIsCustom   BIT
       , cPickSlipNo NVARCHAR(10)      
       , cOrderKey   NVARCHAR(10)
       , cLoadKey    NVARCHAR(10)      
       , cDropID     NVARCHAR(20)
       , cLangCode   NVARCHAR(3)
       , cStorerKey  NVARCHAR(15)
       , cFacility   NVARCHAR(5)
       , cPaperType  NVARCHAR(20)
   )
   
   IF NOT EXISTS( SELECT  1 
                  FROM WMREPORT WMR WITH (NOLOCK) 
                  JOIN WMREPORTDETAIL WMRD (NOLOCK) 
                  ON WMR.ReportID = WMRD.ReportID
                  WHERE WMRD.Storerkey = @cStorerKey 
                  AND WMR.ModuleID = @cModuleID
                  AND (
                     (@cPaperType = 'Label' AND WMRD.IsPaperPrinter <> 'Y') 
                     OR 
                     (@cPaperType = 'Paper' AND WMRD.IsPaperPrinter = 'Y')
                     )
   )  
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = IIF(@cPaperType = 'Label', 15501, 15502)
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'No Label/Paper Report Type Found.'
      GOTO EXIT_SP  
   END

PROCEED:
   SET @c_ResponseString = ISNULL ((SELECT DISTINCT WMR.ReportType AS cReportType
                                    FROM WMREPORT WMR WITH (NOLOCK) 
                                    JOIN WMREPORTDETAIL WMRD (NOLOCK) 
                                    ON WMR.ReportID = WMRD.ReportID
                                    WHERE WMRD.Storerkey = @cStorerKey 
                                    AND WMR.ModuleID = @cModuleID
                                    AND (
                                       (@cPaperType = 'Label' AND WMRD.IsPaperPrinter <> 'Y') 
                                       OR 
                                       (@cPaperType = 'Paper' AND WMRD.IsPaperPrinter = 'Y')
                                       )
                                    AND (WMRD.Facility = '' OR WMRD.Facility = @cFacility) 
                                    FOR JSON AUTO, ROOT('PrintReports')
                                    ),'{"PrintReports":[]}')

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
