SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1718ExtUpd01                                    */
/* Copyright: Maersk                                                    */
/*                                                                      */
/* Date         Rev  Author   Purposes                                  */
/* 2026-05-09   1.0  NickT    FCR-12388 Created                          */
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

   DECLARE @nTranCount INT

   DECLARE    
      @cConfirmStatus          NVARCHAR( 20),
      @cUserName               NVARCHAR( 18),
      @cMBOLKey                NVARCHAR( 10),
      @nLoopIndex              INT

   SELECT
      @cUserName  = UserName
   FROM RDTMOBREC (NOLOCK)
   WHERE Mobile = @nMobile

   SET @cConfirmStatus = rdt.RDTGetConfig( @nFunc, 'ConfirmStatus', @cStorerKey)

   IF ISNULL(@cConfirmStatus,'') = ''
      SET @cConfirmStatus = '7'

   IF @nFunc = 1718
   BEGIN
      IF @nStep = 3
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            DECLARE @tMBOL TABLE 
            (
               Rowref INT IDENTITY(1,1),
               MbolKey INT PRIMARY KEY
            )

            INSERT INTO @tMBOL (MbolKey)
            SELECT DISTINCT MD.MbolKey
            FROM dbo.CONTAINERDETAIL CD WITH(NOLOCK)
            INNER JOIN dbo.CONTAINER CT WITH(NOLOCK) ON CT.ContainerKey = CD.ContainerKey
            INNER JOIN dbo.PALLETDETAIL PD WITH(NOLOCK) ON PD.PalletKey = CD.PalletKey
            INNER JOIN dbo.MBOLDETAIL MD WITH(NOLOCK) ON MD.OrderKey = PD.UserDefine01
            WHERE CT.Vessel = @cTruckID
               AND CT.Status <> '9'

            SET @nTranCount = @@TRANCOUNT  
            BEGIN TRAN  
            SAVE TRAN rdt_1718ExtUpd01
            BEGIN TRY
               UPDATE M WITH(ROWLOCK)
               SET
                  Status = @cConfirmStatus,
                  EditWho = @cUserName,
                  EditDate = GETDATE()
               FROM dbo.MBOL M
               INNER JOIN @tMBOL T ON M.MbolKey = T.MbolKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 266001  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Close MBOL failed
               GOTO RollBackTran
            END CATCH
         END
      END
   END
   GOTO Quit  
  
RollBackTran:  
   ROLLBACK TRAN rdt_1718ExtUpd01  
Quit:  
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started  
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_1718ExtUpd01] TO NSQL
GO