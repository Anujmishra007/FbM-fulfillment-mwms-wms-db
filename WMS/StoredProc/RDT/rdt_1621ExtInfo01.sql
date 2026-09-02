SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1621ExtInfo01                                   */
/* Copyright      : Maersk                                              */
/* Customer       : REIND RE03                                          */
/*                                                                      */
/* Purpose: Extended info to display scanned Drop ID on screen 1883     */
/*          field 8 for Fn 1621 / REIND storer cluster picking          */
/*                                                                      */
/* Called from:                                                         */
/*                                                                      */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author      Purposes                                 */
/* 2026-08-06 1.0  NickT       FCR-13984. Created                       */
/************************************************************************/

CREATE OR ALTER PROCEDURE [rdt].[rdt_1621ExtInfo01]
   @nMobile       INT,
   @nFunc         INT,
   @cLangCode     NVARCHAR(  3),
   @nStep         INT,
   @nInputKey     INT,
   @cWaveKey      NVARCHAR( 10),
   @cLoadKey      NVARCHAR( 10),
   @cOrderKey     NVARCHAR( 10),
   @cDropID       NVARCHAR( 20),
   @cStorerKey    NVARCHAR( 15),
   @cSKU          NVARCHAR( 20),
   @cLOC          NVARCHAR( 10),
   @cExtendedInfo NVARCHAR( 20) OUTPUT

AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   SET @cExtendedInfo = ''

   IF @nFunc = 1621
   BEGIN
      IF @nStep = 7
      BEGIN
         IF @nInputKey = 1
         BEGIN
            SET @cExtendedInfo = @cDropID
         END
      END
      ELSE IF @nStep = 8
      BEGIN
         IF @nInputKey = 1
         BEGIN
            SET @cExtendedInfo = @cDropID
         END
      END
      ELSE IF @nStep = 9
      BEGIN
         IF @nInputKey = 1
         BEGIN
            SET @cExtendedInfo = @cDropID
         END
      END
      ELSE IF @nStep = 16
      BEGIN
         IF @nInputKey = 1
         BEGIN
            SET @cExtendedInfo = @cDropID
         END
      END
   END

   QUIT:
END -- End Procedure
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1621ExtInfo01 TO NSQL
GO
