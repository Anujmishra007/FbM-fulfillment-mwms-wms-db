SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************************/
/* Store procedure: rdtHandle_SetUser                                               */
/* Copyright      : Maersk                                                          */
/*                                                                                  */
/* Purpose: Execute functional SP                                                   */
/*                                                                                  */
/* Date        Rev  Author      Purposes                                            */
/* 12-11-2014  1.0  Ung         Created                                             */
/* 02-11-2016  1.1  Ung         Fix recompile due to SET DATEFORMAT                 */
/* 2026-08-14  1.2  JCH507      UWP-57695 Catch SQL exception from dynamic SP call  */
/************************************************************************************/
/************************************************************************/
/* Store procedure: rdtHandle_SetUser                                   */
/* Copyright      : LFLogistics                                         */
/*                                                                      */
/* Purpose: Dynamic lottable                                            */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 12-11-2014  1.0  Ung         Created                                 */
/* 02-11-2016  1.1  Ung         Fix recompile due to SET DATEFORMAT     */
/* 2026-08-14  1.2  JCH507      UWP-57695 Catch SQL exception from dynamic SP call */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdtHandle_SetUser]
   @nMobile          INT, 
   @nFunc            INT, 
   @cLangCode        NVARCHAR( 3), 
   @cUserName        NVARCHAR(18), 
   @cStoredProcName  NVARCHAR( 1024), 
   @nErrNo           INT           OUTPUT,  
   @cErrMsg          NVARCHAR(125) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag       INT            = 0

   DECLARE @cSQLErrProcName  NVARCHAR(128)  = ''
   DECLARE @nSQLErrLine      INT            = 0
   DECLARE @cSQLErrMsg       NVARCHAR(4000) = ''
   DECLARE @nLogErrNo        INT            = 0
   DECLARE @cLogErrMsg       NVARCHAR(1024) = ''
   DECLARE @cUDF01           NVARCHAR(100) = ''

   -- SETUSER             -- Reset back to original sql login (i.e. RDT)
   -- SETUSER @cUserName  -- Set it as the sql login that user key-in
   EXECUTE AS LOGIN = @cUserName
   
   -- Change to user date format
   -- DECLARE @cDateFormat NVARCHAR( 3)
   -- SET @cDateFormat = RDT.rdtGetDateFormat( @cUserName)      
   -- SET DATEFORMAT @cDateFormat
   
   SELECT @cStoredProcName = N'EXEC RDT.' + RTRIM(@cStoredProcName)      
   SELECT @cStoredProcName = RTRIM(@cStoredProcName) + ' @nMobile, @nErrNo OUTPUT,  @cErrMsg OUTPUT'      
   BEGIN TRY
      EXEC sp_executesql @cStoredProcName, N'@nMobile int, @nErrNo int OUTPUT, @cErrMsg NVARCHAR(125) OUTPUT',
         @nMobile,
         @nErrNo OUTPUT,
         @cErrMsg OUTPUT
   END TRY
   BEGIN CATCH
      SET @cSQLErrProcName = ISNULL(ERROR_PROCEDURE(), '')
      SET @nSQLErrLine     = ISNULL(ERROR_LINE(), 0)
      SET @cSQLErrMsg      = ISNULL(ERROR_MESSAGE(), '')

      IF @@TRANCOUNT > 0
      BEGIN
         IF XACT_STATE() = -1
            SET @cUDF01 = 'Tran is uncommittable state. Rollback by rdtHandle_SetUser. Check RDTMessage by TraceID'
         ELSE IF XACT_STATE() = 1 
            SET @cUDF01 = 'Tran is committable state. Rollback by rdtHandle_SetUser. Check RDTMessage by TraceID'

         ROLLBACK TRANSACTION
      END

      SET @nErrNo  = 275451
      SET @cErrMsg = rdt.rdtgetmessage(275451, @cLangCode, 'DSP')

      BEGIN TRY
         UPDATE RDT.RDTMOBREC WITH (ROWLOCK) SET
            ErrMsg = @cErrMsg
         WHERE Mobile = @nMobile
      END TRY
      BEGIN CATCH
         IF @nDebugFlag = 1
            SELECT 'Update RDTMOBREC failed. Error: ' + ERROR_MESSAGE()
      END CATCH
      
      BEGIN TRY
         EXEC rdt.rdtInsRDTLog
            @nMobile       = @nMobile,
            @cMsgType      = 'SQLException',
            @nErrNo        = 275451, --Unhandled exception error. Fixed err no. It is needed by MOP alert.
            @cMsgData      = @cSQLErrMsg,
            @cSPName       = @cSQLErrProcName,
            @nSPLineNumber = @nSQLErrLine,
            @cUDF01        = @cUDF01, --Remark
            @nOutErrNo     = @nLogErrNo  OUTPUT,
            @cOutErrMsg    = @cLogErrMsg OUTPUT
      END TRY
      BEGIN CATCH
         IF @nDebugFlag = 1
            SELECT 'Insert RDTLog failed. Error: ' + ERROR_MESSAGE()
      END CATCH

      IF @nDebugFlag = 1
         SELECT 'InsRdtLogError', @nLogErrNo AS ErrNo, @cLogErrMsg AS ErrMsg
   END CATCH

   REVERT                  -- Need DB compatible level 9.0 (SQL 2005)
   -- SETUSER              -- Reset back to original sql login (i.e. RDT)  
   
END -- End Procedure
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdtHandle_SetUser TO NSQL
GO