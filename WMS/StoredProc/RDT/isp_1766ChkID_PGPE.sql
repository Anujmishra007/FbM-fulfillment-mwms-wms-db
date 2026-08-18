/******************************************************************************/
/* Store procedure: isp_1766ChkID_PGPE                                        */
/* Copyright      : LF Logistics                                              */
/* Customer       : PGPE                                                      */
/*                                                                            */
/* Purpose: Verify Pallet ID in inventory, with or without a load            */
/*                                                                            */
/* Date         Author    Ver.  Purposes                                      */
/* 2026-06-25   FRO014    1.0   RITM9002126/UWP-61808 Created                 */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[isp_1766ChkID_PGPE]
   @nMobile   INT,
   @nFunc     INT,
   @cLangCode NVARCHAR( 3),
   @cID       NVARCHAR( 18),
   @nErrNo    INT           OUTPUT,
   @cErrMsg   NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cStorerKey NVARCHAR( 15)

   SET @nErrNo = 0

   SELECT @cStorerKey = StorerKey
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   IF NOT EXISTS (
      SELECT TOP 1 1
      FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
      WHERE LLI.StorerKey = @cStorerKey
         AND LLI.Id = @cID
   )
   BEGIN
      SET @nErrNo = 1
      GOTO Quit
   END

Quit:
END
GO

GRANT EXECUTE ON [dbo].[isp_1766ChkID_PGPE] TO [NSQL]
GO
