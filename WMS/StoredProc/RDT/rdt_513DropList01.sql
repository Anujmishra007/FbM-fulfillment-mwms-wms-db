
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*********************************************************************************/
/* Store procedure: rdt_513DropList01                                            */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose: NLTR2                                                                */
/*                                                                               */
/* Date        Rev   Author      Purposes                                        */
/* 2026-06-02  1.0.0 JCH507      FCR-12576 Add pallet type List                  */
/*********************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_513DropList01
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
      @nScn          INT,
      @cStorerKey    NVARCHAR( 15),
      @cFacility     NVARCHAR( 5),
      @cToID         NVARCHAR( 18),
      @cPalletType   NVARCHAR( 10) 

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
      @nScn             = Scn,
      @nStep            = Step,
      @cToID            = V_String14
      
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   --Start
   IF @nFunc = 513
   BEGIN
      IF @nStep = 99 AND @nScn = 6895
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

         IF ISNULL(@cToID, '') <> ''
            SELECT @cPalletType = PalletType FROM dbo.ID WITH (NOLOCK) WHERE Id = @cToID AND Qty > 0 -- get existing pallet type

         IF ISNULL(@cPalletType, '') <> '' 
            AND EXISTS (SELECT 1 FROM @tDropDown WHERE colValue = @cPalletType)
         BEGIN
            UPDATE @tDropDown SET Selected = 1 WHERE colValue = @cPalletType
         END
         ELSE
         BEGIN
            IF (SELECT COUNT(1) FROM @tDropDown) = 1
               UPDATE @tDropDown SET Selected = 1 WHERE RowRef = 1
         END

      END
      GOTO Quit
   END


   Quit:

   SELECT coltext, colvalue, Selected
   FROM @tDropDown

END
GO

GRANT EXECUTE ON rdt.rdt_513DropList01 TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
