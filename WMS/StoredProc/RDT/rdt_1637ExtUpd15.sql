SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1637ExtUpd15                                    */
/* Copyright      : Maersk                                              */
/* Customer       : HBDS                                                */
/*                                                                      */
/* Purpose: Update ContainerDetail as 5                                 */
/*                                                                      */
/* Date       Rev    Author     Purposes                                */
/* 2025-10-23 1.0.0  NickT      FCR-8619 Created                        */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1637ExtUpd15] (
   @nMobile       INT,
   @nFunc         INT,
   @cLangCode     NVARCHAR( 3),
   @nStep         INT,
   @nInputKey     INT,
   @cStorerkey    NVARCHAR( 15),
   @cContainerKey NVARCHAR( 10),
   @cMBOLKey      NVARCHAR( 10),
   @cSSCCNo       NVARCHAR( 20),
   @cPalletKey    NVARCHAR( 18),
   @cTrackNo      NVARCHAR( 20),
   @cOption       NVARCHAR( 1),
   @nErrNo        INT           OUTPUT,
   @cErrMsg       NVARCHAR( 20) OUTPUT
)
AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @nTranCount INT

   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN  -- Begin our own transaction
   SAVE TRAN rdt_1637ExtUpd15 -- For rollback or commit only our own transaction

   IF @nFunc = 1637 -- Scan to container
   BEGIN
      IF @nStep = 3  -- Close container
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            DECLARE @tCONTAINERDETAIL TABLE
            (
               ContainerKey       NVARCHAR( 20),
               ContainerLineNumber NVARCHAR( 5),
               PRIMARY KEY (ContainerKey, ContainerLineNumber)
            )

            INSERT INTO @tCONTAINERDETAIL ( ContainerKey, ContainerLineNumber)
            SELECT ContainerKey, ContainerLineNumber
            FROM dbo.CONTAINERDETAIL WITH(ROWLOCK)
            WHERE ContainerKey = @cContainerKey
               AND PalletKey = @cPalletKey
               AND Status = '0'

            BEGIN TRY
               UPDATE CD
               SET
                  Status = '5',
                  Trafficcop = NULL,
                  EditWho = SUSER_SNAME(),
                  EditDate = GETDATE()
               FROM dbo.CONTAINERDETAIL CD WITH(ROWLOCK)
               INNER JOIN @tCONTAINERDETAIL TCD
                  ON CD.ContainerKey = TCD.ContainerKey
                  AND CD.ContainerLineNumber = TCD.ContainerLineNumber
            END TRY
            BEGIN CATCH
               SET @nErrNo = 249751
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Update Container Details Failed
               GOTO RollBackTran
            END CATCH
         END
      END
   END

   COMMIT TRAN
   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_1637ExtUpd15 -- Only rollback change made here
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON  [RDT].[rdt_1637ExtUpd15] TO [NSQL]
GO
