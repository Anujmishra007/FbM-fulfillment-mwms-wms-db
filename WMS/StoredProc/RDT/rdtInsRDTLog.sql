
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/******************************************************************************/
/* Store procedure: rdtInsRDTLog                                              */
/* Copyright      : IDS / Maersk                                              */
/* Purpose: Insert a log entry into rdt.rdtLog table.                         */
/*                                                                            */ 
/* Modifications log:                                                         */
/* Date        Rev  Author        Purposes                                    */
/* 2026-08-14  1.0  Jack Cheng    UWP-57695 Created                           */
/******************************************************************************/

CREATE OR ALTER PROC [rdt].[rdtInsRDTLog]
(
   @nMobile        INT,
   @cMsgType       NVARCHAR(50)    = '',
   @nErrNo         INT             = 0,
   @cMsgData       NVARCHAR(4000)  = '',
   @cSPName        NVARCHAR(100)   = '',
   @nSPLineNumber  INT             = 0,
   @cUDF01         NVARCHAR(100)   = '',
   @cUDF02         NVARCHAR(100)   = '',
   @cUDF03         NVARCHAR(100)   = '',
   @cUDF04         NVARCHAR(100)   = '',
   @cUDF05         NVARCHAR(100)   = '',
   @cUDF06         NVARCHAR(100)   = '',
   @cUDF07         NVARCHAR(100)   = '',
   @cUDF08         NVARCHAR(100)   = '',
   @cUDF09         NVARCHAR(100)   = '',
   @cUDF10         NVARCHAR(100)   = '',
   @nOutErrNo      INT             OUTPUT,
   @cOutErrMsg     NVARCHAR(1024)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag  INT           = 0

   DECLARE @cStorerKey  NVARCHAR(15)  = ''
   DECLARE @cFacility   NVARCHAR(5)   = ''
   DECLARE @nFunc       INT           = 0
   DECLARE @nStep       INT           = 0
   DECLARE @nScn        INT           = 0
   DECLARE @cTraceID    NVARCHAR(100) = ''

   SET @nOutErrNo = 0
   SET @cOutErrMsg = ''

   BEGIN TRY
      -- Step 1: Get session context from RDTMOBREC
      SELECT
         @cStorerKey = ISNULL(StorerKey, ''),
         @cFacility  = ISNULL(Facility, ''),
         @nFunc      = Func,
         @nStep      = Step,
         @nScn       = Scn
      FROM RDT.RDTMOBREC WITH (NOLOCK)
      WHERE Mobile = @nMobile

      IF @@ROWCOUNT = 0
      BEGIN
         SET @nOutErrNo = 278151
         SET @cOutErrMsg = rdt.rdtgetmessage(278151, 'us_english', 'DSP')
         GOTO Quit
      END

      -- Step 2: Get TraceID (empty string if no record)
      SELECT @cTraceID = ISNULL(TraceID, '')
      FROM RDT.RDTMOBTraceID WITH (NOLOCK)
      WHERE Mobile = @nMobile

      -- Step 3: Insert log record
      BEGIN TRY
         INSERT INTO RDT.rdtLog
         (
            Mobile, StorerKey, Facility, Func, Step, Scn,
            MsgType, ErrNo, MsgData, SPName, SPLineNumber,
            UDF01, UDF02, UDF03, UDF04, UDF05,
            UDF06, UDF07, UDF08, UDF09, UDF10,
            TraceID
         )
         VALUES
         (
            @nMobile, @cStorerKey, @cFacility, @nFunc, @nStep, @nScn,
            @cMsgType, @nErrNo, @cMsgData, @cSPName, @nSPLineNumber,
            @cUDF01, @cUDF02, @cUDF03, @cUDF04, @cUDF05,
            @cUDF06, @cUDF07, @cUDF08, @cUDF09, @cUDF10,
            @cTraceID
         )
      END TRY
      BEGIN CATCH
         SET @nOutErrNo = 278152
         SET @cOutErrMsg = rdt.rdtgetmessage(278152, 'us_english', 'DSP') + ' ' + ERROR_MESSAGE()
         GOTO Quit
      END CATCH
   END TRY
   BEGIN CATCH
      -- Unexpected error: fault-tolerant wrapper ensures SP never throws to caller
      SET @nOutErrNo = 278153
      SET @cOutErrMsg = rdt.rdtgetmessage(278153, 'us_english', 'DSP') + ' ' + ERROR_MESSAGE()
      GOTO Quit
   END CATCH

   Quit:
      IF @nDebugFlag = 1
         SELECT @nOutErrNo AS nErrNo, @cOutErrMsg AS ErrMsg
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdtInsRDTLog TO NSQL
GO
