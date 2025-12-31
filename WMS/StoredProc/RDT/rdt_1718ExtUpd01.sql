SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1718ExtUpd01                                    */
/* Copyright: Maersk                                                    */
/*                                                                      */
/* Date         Rev  Author   Purposes                                  */
/* 2025-Dec-15  1.0  Cuize    FCR-7458 Created                          */
/************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_1718ExtUpd01] (
   @nMobile                  INT,
   @nFunc                    INT,
   @cLangCode                NVARCHAR( 3),
   @nStep                    INT,
   @nInputKey                INT,
   @cStorerKey               NVARCHAR( 15),
   @cTruckID                 NVARCHAR( 20),
   @cPalletID                NVARCHAR( 30),
   @cSealNo                  NVARCHAR( 20),
   @nErrNo                   INT           OUTPUT,
   @cErrMsg                  NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nFunc = 1718
      BEGIN
         IF @nStep = 3
         BEGIN
            IF @nInputKey = 1 -- ENTER
            BEGIN

               DECLARE    @cConfirmStatus          NVARCHAR( 20)
               DECLARE    @cUserName               NVARCHAR( 18)


               SELECT
                  @cUserName  = UserName
               FROM RDTMOBREC (NOLOCK)
               WHERE Mobile = @nMobile

               SET @cConfirmStatus = rdt.RDTGetConfig( @nFunc, 'ConfirmStatus', @cStorerKey)

               IF ISNULL(@cConfirmStatus,'') = ''
                  SET @cConfirmStatus = '7'

               --CLOSE MBOL
               UPDATE MBOL
               SET
                  Status = @cConfirmStatus,
                  EditWho = @cUserName,
                  EditDate = GETDATE()
               WHERE MbolKey IN (
                  SELECT DISTINCT MD.MbolKey
                  FROM CONTAINERDETAIL CD
                     JOIN CONTAINER C  ON C.ContainerKey = CD.ContainerKey
                     JOIN PALLETDETAIL PD ON PD.PalletKey = CD.PalletKey
                     JOIN MBOLDETAIL MD ON MD.OrderKey = PD.UserDefine01
                  WHERE C.Vessel = @cTruckID
               )

               IF @@ERROR <> 0
               BEGIN
                  SET @nErrNo = 254003
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Close Mbol Err
                  GOTO Quit
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

GRANT EXECUTE ON [rdt].[rdt_1718ExtUpd01] TO NSQL
GO
