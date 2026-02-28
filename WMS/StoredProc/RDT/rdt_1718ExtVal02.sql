SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1718ExtVal02                                    */
/* Copyright: Maersk                                                    */
/*                                                                      */
/* Date         Rev  Author   Purposes                                  */
/* 2025-Dec-15  1.0  Cuize    FCR-7458 Created                          */
/************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_1718ExtVal02] (
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @nInputKey       INT,
   @cFacility       NVARCHAR( 5),
   @cStorerKey      NVARCHAR( 15),
   @cTruckID        NVARCHAR( 20),
   @cPalletID       NVARCHAR( 30),
   @cSealNo         NVARCHAR( 20),
   @tExtValidate    VARIABLETABLE READONLY,
   @nErrNo          INT           OUTPUT,
   @cErrMsg         NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF


   DECLARE    @cOption        NVARCHAR( 1)



   IF @nFunc = 1718
   BEGIN
      IF @nStep = 2
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SELECT
               @cOption = ISNULL(RTRIM(I_Field02),'')
            FROM RDTMOBREC (NOLOCK)
            WHERE Mobile = @nMobile


            IF @cOption = '1'  --Close Truck
            BEGIN
               IF EXISTS (
                  SELECT 1
                  FROM CONTAINERDETAIL CD
                          JOIN CONTAINER C  ON C.ContainerKey = CD.ContainerKey
                          JOIN PALLETDETAIL PD ON PD.PalletKey = CD.PalletKey
                  WHERE C.Vessel = @cTruckID
                    AND PD.UserDefine01 NOT IN (
                     SELECT MD2.OrderKey
                     FROM MBOLDETAIL MD2
                     WHERE MD2.MbolKey IN (
                        SELECT MD.MbolKey
                        FROM MBOLDETAIL MD
                        WHERE MD.OrderKey = PD.UserDefine01
                     )
                  )
               )
               BEGIN
                  SET @nErrNo = 254002
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
                  GOTO Quit
               END
            END

         END
      END

   END

   Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_1718ExtVal02] TO NSQL
GO
