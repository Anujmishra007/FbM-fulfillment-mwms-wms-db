SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_API_UpdatePrinter                                  */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Update the workstation PrinterGroup                          */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-01   1.0  GCH225     Created                                          */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_API_UpdatePrinter] (
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
      @cLangCode     NVARCHAR( 3),
      @nFunc         INT,
      @cWorkstation  NVARCHAR( 30),
      @cPrinterID    NVARCHAR( 20),
      @cPrinterType  NVARCHAR( 20),
      @cLabelPrinter NVARCHAR( 20),
      @cPaperPrinter NVARCHAR( 20)


   --Decode Json Format
   SELECT  @nFunc = Func
         , @cLangCode = LangCode
         , @cWorkstation = Workstation
         , @cPrinterID = PrinterID
         , @cPrinterType = PrinterType
   FROM OPENJSON(@c_RequestString)
   WITH (
	      Func        INT,
         LangCode    NVARCHAR( 3),
         Workstation NVARCHAR( 30),
         PrinterID   NVARCHAR( 20),
         PrinterType NVARCHAR( 20)
   )

   --Data Validate
   IF @cWorkstation = ''
   BEGIN
      SET @b_Success = 0
      SET @n_ErrNo = 10601
      SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Unable to retrieve Workstation ID.'

      GOTO EXIT_SP
   END

   IF @cPrinterType = ''
   BEGIN
      SET @b_Success = 0
      SET @n_ErrNo = 10602
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Unable to retrieve Printer Type.'

      GOTO EXIT_SP
   END

   IF @cPrinterID = ''
   BEGIN
      SET @b_Success = 0
      SET @n_ErrNo = 10603
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Unable to retrieve Printer ID.'

      GOTO EXIT_SP
   END

   IF @cPrinterType ='Label'
   BEGIN
      SELECT @cPaperPrinter = PrinterID
      FROM  api.AppPrinter (NOLOCK)
      WHERE Workstation = @cWorkstation
         AND PrinterType = 'Paper'

      IF @cPaperPrinter  = @cPrinterID
      BEGIN
         SET @b_Success = 0
         SET @n_ErrNo = 10604
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'LabelPrinter cannot same with PaperPrinter.'

         GOTO EXIT_SP
      END
   END

   IF @cPrinterType ='Paper'
   BEGIN
      SELECT @cLabelPrinter = PrinterID
      FROM  api.AppPrinter (NOLOCK)
      WHERE Workstation = @cWorkstation
         AND PrinterType = 'Label'

      IF @cLabelPrinter  = @cPrinterID
      BEGIN
         SET @b_Success = 0
         SET @n_ErrNo = 10605
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'PaperPrinter cannot same with LabelPrinter.'

         GOTO EXIT_SP
      END
   END

   IF EXISTS (SELECT TOP 1 1 FROM api.AppPrinter WITH (nolock) WHERE Workstation = @cWorkstation AND PrinterType = @cPrinterType)
   BEGIN

	   UPDATE api.AppPrinter WITH (ROWLOCK)
      SET PrinterID = @cPrinterID
      WHERE Workstation = @cWorkstation
      AND PrinterType = @cPrinterType

      IF @@ERROR <> 0
      BEGIN
         SET @b_Success = 0
         SET @n_ErrNo = 10606
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update into AppPrinter.'
         GOTO EXIT_SP
      END
   END
   ELSE
   BEGIN
	   INSERT INTO api.AppPrinter (AppName,Workstation,PrinterID,PrinterType)
	   VALUES('TouchPad',@cWorkstation,@cPrinterID,@cPrinterType)

	   IF @@ERROR <> 0
      BEGIN
         SET @b_Success = 0
         SET @n_ErrNo = 10607
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Insert into AppPrinter.'
         GOTO EXIT_SP
      END
   END

   SET @b_Success = 1
	SET @c_ResponseString = ISNULL((SELECT CAST ( 1 AS BIT ) AS 'Success' FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                           ), '') 

   EXIT_SP:
      REVERT
END