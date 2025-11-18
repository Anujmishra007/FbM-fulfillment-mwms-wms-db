
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_922DecodeSP02                                         */
/* Copyright: Maersk                                                          */
/*                                                                            */
/* Purpose: Decode for SA BAT                                                 */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 2025-11-12  JackC     1.0   FCR-8675 created                               */
/******************************************************************************/

CREATE OR ALTER PROC rdt.rdt_922DecodeSP02 ( 
   @nMobile          INT, 
   @nFunc            INT, 
   @cLangCode        NVARCHAR( 3), 
   @nStep            INT, 
   @nInputKey        INT, 
   @cStorerKey       NVARCHAR( 15),
   @cMBOLKey         NVARCHAR( 10),
   @cLoadKey         NVARCHAR( 10),
   @cOrderKey        NVARCHAR( 10),
   @cBarcode         NVARCHAR(MAX)  OUTPUT,
   @cFieldName       NVARCHAR( 10),
   @cLabelNo         NVARCHAR( 20)  OUTPUT,
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   SET @cBarcode = LTRIM(RTRIM(@cBarcode))

   IF @nFunc = 922
   BEGIN
      IF @nStep = 2 
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @cBarcode <> ''  -- UCC  Decode
            BEGIN
               IF LEN(@cBarcode) = 40 --label2
               BEGIN
                  SELECT 
                  @cLabelNo = 
                  CASE 
                     WHEN CHARINDEX('(240)', @cBarcode) > 0 THEN
                           SUBSTRING(
                              @cBarcode,
                              CHARINDEX('(240)', @cBarcode) + 5,
                              LEN(@cBarcode)
                           )
                     ELSE NULL
                  END
                  GOTO Quit
               END--label2 
               ELSE IF LEN(@cBarcode) = 34 --label4
               BEGIN
                  SELECT @cLabelNo = RIGHT(@cBarcode, 20)
                  GOTO Quit
               END
               ELSE IF LEN(@cBarcode) = 67 --label5
               BEGIN
                  SELECT @cLabelNo = SUBSTRING(@cBarcode, 19, 19)
                  GOTO Quit
               END
            END

            GOTO Quit
         END --inputkey
      END --st3
   END --922

   Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_922DecodeSP02 TO NSQL
GO
