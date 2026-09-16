SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: rdt_HandleCollectData                                      */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Purpose        : Called by rdtHandleHttp when the returning SCN has a      */
/*                  V_DATA field. Reads StorerConfig key 'CollectDataSP';     */
/*                  if configured, calls that SP with mobile, step, scn.      */
/*                                                                            */
/* Modifications log:                                                         */
/* Date         Author    Ver.    Purposes                                    */
/* 2026-08-28   DennisA   1.0.0   FCR-15406 Created                          */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_HandleCollectData]
   @nMobile    INT,
   @nStep      INT,
   @nScn       INT,
   @cXML       NVARCHAR( MAX) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nFunc          INT
   DECLARE @cStorerKey     NVARCHAR( 15)
   DECLARE @cCollectDataSP NVARCHAR( 100)
   DECLARE @cSQL           NVARCHAR( MAX)
   DECLARE @cSQLParam      NVARCHAR( MAX)

   SELECT
      @nFunc      = Func,
      @cStorerKey = StorerKey
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   SET @cCollectDataSP = rdt.RDTGetConfig( @nFunc, 'CollectDataSP', @cStorerKey)

   INSERT INTO dbo.TraceInfo ( TraceName,                  TimeIn,     Step1,                          Step2,                       Step3,                       Col1,         Col2,               Col3)
   VALUES                    ('HandleCollectData', GETDATE(), CAST( @nMobile AS NVARCHAR(20)), CAST( @nStep AS NVARCHAR(20)), CAST( @nScn AS NVARCHAR(20)), @cStorerKey,  CAST( @nFunc AS NVARCHAR(20)), ISNULL( @cCollectDataSP, 'NULL'))

   IF ISNULL( @cCollectDataSP, '') NOT IN ('0', '') AND
      EXISTS( SELECT 1 FROM sys.sysobjects WHERE name = @cCollectDataSP AND type = 'P')
   BEGIN
      SET @cSQL =
         'EXEC rdt.' + RTRIM( @cCollectDataSP) +
         ' @nMobile, @nStep, @nScn, @cXML OUTPUT'

      SET @cSQLParam =
         '@nMobile  INT,           ' +
         '@nStep    INT,           ' +
         '@nScn     INT,           ' +
         '@cXML     NVARCHAR(MAX) OUTPUT'

      EXEC sp_executesql @cSQL, @cSQLParam,
         @nMobile, @nStep, @nScn, @cXML OUTPUT
   END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_HandleCollectData TO NSQL
GO
