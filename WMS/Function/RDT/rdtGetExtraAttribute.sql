SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: rdtGetExtraAttribute    					         */
/* Creation Date:                                                       */
/* Copyright: Maersk                                                    */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: Add extra paramater + value into XML                        */
/*                                                                      */
/*                                                                      */
/* Called By:      rdtScr2XMLHttp                                       */
/*                                                                      */
/*                                                                      */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Rev  Author     Purposes                                */
/* 2024-09-23   1.0  CYU027     Created                                 */
/************************************************************************/

CREATE OR ALTER PROC RDT.rdtGetExtraAttribute (
    @nScn    INT
   ,@cY      NVARCHAR(2)
   ,@nMobile INT
   ,@cAttrAndVal NVARCHAR(max) OUTPUT
)
   AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF

   DECLARE     @cStorerKey             NVARCHAR(15),
               @cAttribute             NVARCHAR(30),
               @cSValue                NVARCHAR( MAX),
               @cSValueSP              NVARCHAR( MAX),
               @cSQL                   NVARCHAR( Max),
               @cSQLParam              NVARCHAR( Max),
               @nFunc                  INT

   -- INITIAL
   SET @cAttrAndVal = ''

   SELECT
      @nScn = Scn,
      @nFunc = Func,
      @cStorerKey = StorerKey
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

----ONLY 1 RECORD
   SELECT TOP 1
      @cAttribute = Attribute,
      @cSValue    = SValue
   FROM RDT.ScreenStorerConfig WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND Scn = @nScn
      AND line = CAST(@cY as INT)
      AND (Function_ID = @nFunc or Function_ID = 0)

   --Nothing found, quit
   IF ISNULL(@cAttribute, '') = '' OR ISNULL(@cSValue, '') = ''
   BEGIN
      GOTO Quit
   END

/***********************************************************************************************
                                           Custom get AttrAndVal
***********************************************************************************************/

   -- Extended info

   IF @cSValue <> '' AND EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cSValue AND type = 'P')
   BEGIN
      SET @cSValueSP = ''
      SET @cSQL = 'EXEC rdt.' + RTRIM( @cSValue) +
                  ' @nMobile, @nFunc, @nScn, @cY, @cStorerKey, @cSValueSP OUTPUT '

      SET @cSQLParam =
              '@nMobile          INT, ' +
              '@nFunc            INT, ' +
              '@nScn             INT, ' +
              '@cY               NVARCHAR(2), ' +
              '@cStorerKey       NVARCHAR( 15), '  +
              '@cSValueSP      NVARCHAR( 20) OUTPUT '

      EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
           @nMobile, @nFunc, @nScn, @cY, @cStorerKey,
           @cSValueSP OUTPUT


      SET @cAttrAndVal =  '" ' + @cAttribute + '="' + @cSValueSP

      GOTO Quit
   END

/***********************************************************************************************
                                   Standard get AttrAndVal
***********************************************************************************************/

   SET @cAttrAndVal =  @cAttribute + '=''' + @cSValue + ''''
   GOTO Quit

Quit:

GO
GRANT EXECUTE ON [RDT].[rdtGetExtraAttribute] TO NSQL
GO
