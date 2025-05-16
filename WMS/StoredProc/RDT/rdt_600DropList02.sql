
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*********************************************************************************/
/* Store procedure: rdt_600DropList02                                            */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose: DropList SP --NL-GRAPE                                               */
/*                                                                               */
/* Date        Rev  Author      Purposes                                         */
/* 2025-03-17  1.0  CYU027     FCR-2729 Add Type List                            */
/*********************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_600DropList02
@nMobile          INT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @nFunc         INT,
      @nStep         INT,
      @cStorerKey   NVARCHAR( 15),
      @cFacility    NVARCHAR(  5)

   DECLARE   @tDropDown TABLE
      (
         RowRef INT IDENTITY(1,1),
         ColText   NVARCHAR (125) NULL,
         ColValue  NVARCHAR (125) NULL,
         Selected  BIT
      )

   --GET SESSION
   SELECT
      @nFunc            = Func,
      @cStorerKey       = V_StorerKey,
      @nStep            = Step,
      @cFacility        = Facility
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   --Start
   IF @nFunc = 600
   BEGIN
      IF @nStep = 99
      BEGIN

         INSERT INTO @tDropDown (coltext, colvalue, Selected)
         SELECT
            PalletTypeName, PalletType, 0
         FROM dbo.PalletTypeMaster WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
           AND Facility = @cFacility
           AND PalletTypeInUse = 'Y'

      END
      GOTO Quit
   END


   Quit:

   SELECT coltext, colvalue, Selected
   FROM @tDropDown

END
GO

GRANT EXECUTE ON rdt.rdt_600DropList02 TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
