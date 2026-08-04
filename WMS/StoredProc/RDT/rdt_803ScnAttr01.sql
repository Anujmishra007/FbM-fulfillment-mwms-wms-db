
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_803ScnAttr01                                    */
/* Purpose: Return background color for PTW/PTL sorting screen          */
/*          based on user's assigned sorting color                      */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2026-07-06 1.0  Cuize      FCR-13139. Created                        */
/************************************************************************/
CREATE OR ALTER PROC [RDT].[rdt_803ScnAttr01] (
   @nMobile          INT,
   @nFunc            INT,
   @nScn             INT,
   @cY               NVARCHAR(  2),
   @cStorerKey       NVARCHAR( 15),
   @cSValueSP        NVARCHAR( MAX) OUTPUT
)
AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

DECLARE @cStation     NVARCHAR(10)
DECLARE @cUserName    NVARCHAR(18)
DECLARE @cColorName   NVARCHAR(20)

IF @nFunc = 803
BEGIN
   -- Get station, username and color from MobRec
   -- FCR-13139: Color is stored in C_String1 (persists even after rdtPTLPieceLog becomes COMPLETE)
   SELECT @cStation   = V_String1,
          @cUserName  = UserName,
          @cColorName = C_String1
   FROM rdt.rdtMobrec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Return HEX color code from CODELKUP.UDF02
   IF @cColorName IS NOT NULL AND @cColorName <> ''
   BEGIN
      -- Screen 6920 (SortTote scan) - line 3
      IF @nScn = 6920 AND @cY = '3'
      BEGIN
         SELECT TOP 1 @cSValueSP = UDF02
         FROM dbo.CODELKUP WITH (NOLOCK)
         WHERE ListName = 'PTLLIGHTS'
           AND Code = @cStation
           AND UDF01 = @cColorName

         IF @cSValueSP IS NULL OR @cSValueSP = ''
            SET @cSValueSP = LOWER(@cColorName)
         GOTO QUIT
      END

      -- Screen 6922 (SKU scan) - line 3
      IF @nScn = 6922 AND @cY = '1'
      BEGIN
         SELECT TOP 1 @cSValueSP = UDF02
         FROM dbo.CODELKUP WITH (NOLOCK)
         WHERE ListName = 'PTLLIGHTS'
           AND Code = @cStation
           AND UDF01 = @cColorName

         IF @cSValueSP IS NULL OR @cSValueSP = ''
            SET @cSValueSP = LOWER(@cColorName)
         GOTO QUIT
      END

      -- Screen 6924 (dropid scan) - line 7
      IF @nScn = 6924 AND @cY = '7'
      BEGIN
         SELECT TOP 1 @cSValueSP = UDF02
         FROM dbo.CODELKUP WITH (NOLOCK)
         WHERE ListName = 'PTLLIGHTS'
           AND Code = @cStation
           AND UDF01 = @cColorName

         IF @cSValueSP IS NULL OR @cSValueSP = ''
            SET @cSValueSP = LOWER(@cColorName)
         GOTO QUIT
      END
   END
END

QUIT:

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_803ScnAttr01 TO NSQL
GO
