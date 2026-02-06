SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_API_GetPrinterList                                 */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Get the list of PrinterGroup                                 */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-01   1.0  GCH225     Created                                          */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_API_GetPrinterList] (
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

   DECLARE @n_Continue                    INT            = 1  
         , @n_StartCnt                    INT            = @@TRANCOUNT  
         , @b_sp_Success                  INT  
         , @n_sp_err                      INT  
         , @c_sp_errmsg                   NVARCHAR(250)  = ''
         , @DBUserName                    NVARCHAR(100)
         , @b_sp_ExecuteAs                BIT

   DECLARE
      @cLangCode           NVARCHAR(3),
      @nFunc               INT,
      @cWorkstation        NVARCHAR(30),
      @cLabelPrinter       NVARCHAR(20),
      @cPaperPrinter       NVARCHAR(20),
      @cLabelPrinterConfig NVARCHAR(20),
      @cPaperPrinterConfig NVARCHAR(20)

   DECLARE @tempListPrinter TABLE (
      printer NVARCHAR(10)
   )
   --Decode Json Format
   SELECT @nFunc = Func
        , @cLangCode = LangCode
        , @cWorkstation = Workstation
        , @cLabelPrinter = LabelPrinter
        , @cPaperPrinter = PaperPrinter
   FROM OPENJSON(@c_RequestString)
   WITH (
	      Func           INT
       , LangCode       NVARCHAR(3)
       , Workstation    NVARCHAR(30)
       , LabelPrinter   NVARCHAR(20)
       , PaperPrinter   NVARCHAR(20)
   )

   --Data Validate  - ScanNo
   IF @cWorkstation = ''
   BEGIN
      IF ISNULL(@cLabelPrinter,'')='' AND ISNULL(@cPaperPrinter,'')=''
      BEGIN
         SET @b_Success = 0
         SET @n_ErrNo = 10251
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Unable to retrieve Workstation ID.'
         GOTO EXIT_SP
      END
   END
   ELSE
   BEGIN
      SELECT @cLabelPrinterConfig = PrinterID FROM api.AppPrinter WITH (NOLOCK) WHERE Workstation = @cWorkstation AND PrinterType = 'Label'
      SELECT @cPaperPrinterConfig = PrinterID FROM api.AppPrinter WITH (NOLOCK) WHERE Workstation = @cWorkstation AND PrinterType = 'Paper'
   END

   INSERT INTO @tempListPrinter (printer)
   SELECT AllPrinter
   FROM (
   SELECT PrinterID AS AllPrinter
   FROM rdt.rdtPrinter (NOLOCK)
   UNION
   SELECT DISTINCT PrinterGroup AS AllPrinter
   FROM rdt.rdtPrinterGroup (NOLOCK)
   ) t

   SET @b_Success = 1
   SET @c_ResponseString = ISNULL((
                              SELECT @cLabelPrinterConfig AS LabelPrinterConfig
                              ,@cPaperPrinterConfig AS PaperPrinterConfig
                              ,(SELECT JSON_QUERY('[' + STRING_AGG(CAST(QUOTENAME(printer, '"') AS NVARCHAR(MAX)), ',') + ']') as result 
                                 FROM @tempListPrinter) as LabelPrinter
                              ,(SELECT JSON_QUERY('[' + STRING_AGG(CAST(QUOTENAME(printer, '"') AS NVARCHAR(MAX)), ',') + ']') as result 
                                 FROM @tempListPrinter) as PaperPrinter
                              FOR JSON PATH , WITHOUT_ARRAY_WRAPPER
                               ), '') 

   IF ISNULL(@c_RequestString, '') = ''
      SET @c_RequestString = '[]'

   EXIT_SP:
      REVERT
END

