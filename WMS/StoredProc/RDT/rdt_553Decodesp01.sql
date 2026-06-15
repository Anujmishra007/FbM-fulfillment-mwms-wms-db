SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************************/
/* Store procedure: rdt_553Decodesp01                                   */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Date       Rev  Author  Purposes                                     */
/* 2026-06-12 1.0  NAC037  Decoding for PMI --UWP-58798                 */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_553Decodesp01](
   @nMobile              INT,
   @nFunc                INT,
   @cLangCode            NVARCHAR( 3),
   @nStep                INT,
   @nInputKey            INT,
   @cStorerKey           NVARCHAR( 15),
   @cIDBarcode           NVARCHAR( 2000)   OUTPUT,
   @cUserDefine08        NVARCHAR(30)      OUTPUT,
   @cUserDefine09        NVARCHAR(30)      OUTPUT,
   @nErrNo               INT               OUTPUT,
   @cErrMsg              NVARCHAR( 20)     OUTPUT

)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF


   DECLARE @cTempUCC AS NVARCHAR(MAX)
   DECLARE @cLocalUCC   NVARCHAR(20)


   IF @nFunc = 553 -- UCCreturn receiving
   BEGIN
      IF @nStep = 2 -- MUID
      BEGIN
         IF @nInputKey = 1 -- ENTER
            BEGIN
               Set @cTempUCC = @cIDBarcode
               IF @cTempUCC <> '' --Barcode
               BEGIN
                  IF LEN( LTRIM(RTRIM( @cTempUCC))) <> 25
                  BEGIN
                     SET @nErrNo = 226801
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                     GOTO Quit
                  END

                  SET @cIDBarcode = SUBSTRING( @cTempUCC, 8, 18)


                  GOTO Quit
               END
            END
      END

      IF @nStep = 3 -- SKU
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF @cIDBarcode <> ''
            BEGIN
               SET @cTempUCC = LTRIM(RTRIM( @cIDBarcode))
               IF LEN(@cTempUCC) = 49 --Fertin label
               BEGIN
                  SET @cLocalUCC = SUBSTRING(@cTempUCC, 19, 17)

               END--len 49
               ELSE IF LEN(@cTempUCC) = 57 --Swedish label 57
               BEGIN
                  SET @cLocalUCC = SUBSTRING(@cTempUCC, 19, 17)
                  SET @cUserDefine09 = RIGHT(@cTempUCC, 6)

               END-- len57
               ELSE IF LEN(@cTempUCC) = 58 --Swedish label 58
               BEGIN
                  SET @cLocalUCC = SUBSTRING(@cTempUCC, 19, 18)
                  SET @cUserDefine09 = RIGHT(@cTempUCC, 6)

               END-- len57
               ELSE IF LEN(@cTempUCC) = 40
               BEGIN
                  --V1.0.0 logic
                  SET @cLocalUCC = SUBSTRING( @cTempUCC, 21, 40)
                  SET @cUserDefine09 = SUBSTRING( @cTempUCC,1 ,20)
               END --len 40
               ELSE
               BEGIN
                  SET @nErrNo = 226802
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END

               SET @cIDBarcode = @cLocalUCC --return decode value
               GOTO Quit

            END
         END
      END
   END

   Quit:


   UPDATE RDTMOBREC WITH (ROWLOCK) SET

      V_String3 = @cUserDefine09
   WHERE Mobile = @nMobile
END

GO
