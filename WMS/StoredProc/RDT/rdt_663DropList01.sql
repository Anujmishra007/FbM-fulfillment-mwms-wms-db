
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*********************************************************************************/
/* Store procedure: rdt_663DropList01                                            */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose: Grape                                                                */
/*                                                                               */
/* Date        Rev   Author      Purposes                                        */
/* 2025-03-09  1.0.0 JCH507      FCR-2728 Add pallet type List                   */
/*********************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_663DropList01
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
      @cStorerKey    NVARCHAR( 15),
      @cFacility     NVARCHAR( 5) 

   DECLARE   @tDropDown TABLE
      (
         RowRef   INT IDENTITY(1,1),
         ColText  NVARCHAR (125) NULL,
         ColValue NVARCHAR (125) NULL,
         Selected BIT
      )

   --GET SESSION
   SELECT
      @nFunc            = Func,
      @cStorerKey       = StorerKey,
      @cFacility        = Facility,
      @nStep            = Step
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   --Start
   IF @nFunc = 663
   BEGIN
      IF @nStep = 3
      BEGIN

         INSERT INTO @tDropDown (coltext, colvalue, Selected)
         SELECT PalletTypeName,
                PalletType,
                0
         FROM dbo.PalletTypeMaster WITH (NOLOCK)
         WHERE Storerkey = @cStorerKey
            AND Facility = @cFacility
            AND PalletTypeInUse = 'Y'
         ORDER BY PalletType

         IF (SELECT COUNT(1) FROM @tDropDown) = 1
            UPDATE @tDropDown SET Selected = 1 WHERE RowRef = 1

      END
      GOTO Quit
   END


   Quit:

   SELECT coltext, colvalue, Selected
   FROM @tDropDown

END
GO

GRANT EXECUTE ON rdt.rdt_663DropList01 TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
