SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: rdt_663DropList02                                            */
/* Copyright      : Maersk                                                       */
/* Customer       : GRAPE ALLIANCE (PTY) LTD - POOL                              */
/*                                                                               */
/* Purpose: Grape                                                                */
/*                                                                               */
/* Date        Rev   Author      Purposes                                        */
/* 2026-07-15  1.0.0 MBI165      FCR-15040 Create                                */
/*********************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_663DropList02]
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
      RowRef      INT IDENTITY(1,1),
      ColText     NVARCHAR (125) NULL,
      ColValue    NVARCHAR (125) NULL,
      Selected    BIT
   )
    DECLARE @cKitKey     NVARCHAR( 10)
    DECLARE @cPalletType NVARCHAR (125)

   --GET SESSION
   SELECT
      @nFunc            = Func,
      @cStorerKey       = StorerKey,
      @cFacility        = Facility,
      @nStep            = Step,
      @cKitKey          = V_String1
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   SELECT TOP 1 
      @cPalletType = PalletType
   FROM dbo.KITDETAIL WITH(NOLOCK)
   WHERE KITKEY = @cKitKey
      AND StorerKey = @cStorerKey
      AND TYPE = 'T'
      AND ISNULL(PalletType,'') <> ''
   ORDER BY KITKey, KITLineNumber

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
         BEGIN
            UPDATE @tDropDown SET Selected = 1 WHERE RowRef = 1
         END
         ELSE
         BEGIN
         IF ISNULL(@cPalletType,'') <> '' 
            UPDATE @tDropDown SET Selected = 1 WHERE colvalue = @cPalletType
         END
      END
      GOTO Quit
   END

   Quit:

   SELECT coltext, colvalue, Selected
   FROM @tDropDown
END
GO

GRANT EXECUTE ON rdt.rdt_663DropList02 TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO