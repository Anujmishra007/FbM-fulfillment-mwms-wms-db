SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1638ExtUpd10                                    */
/* Copyright: Maersk                                                    */
/*                                                                      */
/* Date        Rev  Author   Purposes                                   */
/* 2025-02-10  1.0  Ung      FCR-2545 Created                           */
/************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_1638ExtUpd10] (
   @nMobile      INT,
   @nFunc        INT,
   @nStep        INT,
   @nAfterStep   INT,
   @nInputKey    INT,
   @cLangCode    NVARCHAR( 3),
   @cFacility    NVARCHAR( 5),
   @cStorerkey   NVARCHAR( 15),
   @cPalletKey   NVARCHAR( 30),
   @cCartonType  NVARCHAR( 10),
   @cCaseID      NVARCHAR( 20),
   @cLOC         NVARCHAR( 10),
   @cSKU         NVARCHAR( 20),
   @nQTY         INT,
   @cLength      NVARCHAR(5),
   @cWidth       NVARCHAR(5),
   @cHeight      NVARCHAR(5),
   @cGrossWeight NVARCHAR(5),
   @nErrNo       INT           OUTPUT,
   @cErrMsg      NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT


   IF @nFunc = 1638 -- Scan to pallet
   BEGIN
      IF @nStep = 1 OR  -- Pallet
         @nStep = 8     -- Reopen pallet
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Pallet LOC different
            IF EXISTS( SELECT TOP 1 1 
               FROM dbo.PalletDetail WITH (NOLOCK)
               WHERE PalletKey = @cPalletKey
                  AND LOC <> @cLOC)
            BEGIN
               BEGIN TRAN
               SAVE TRAN rdt_1638ExtUpd10

               -- Loop pallet detail
               DECLARE @cPalletLineNumber NVARCHAR( 5)
               DECLARE @curUpdPlt   CURSOR
               SET @curUpdPlt = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
                  SELECT PalletLineNumber
                  FROM dbo.PalletDetail WITH (NOLOCK)
                  WHERE PalletKey = @cPalletKey
                     AND LOC <> @cLOC
                  ORDER BY PalletLineNumber
               OPEN @curUpdPlt
               FETCH NEXT FROM @curUpdPlt INTO @cPalletLineNumber
               WHILE @@FETCH_STATUS = 0
               BEGIN
                  -- Update pallet LOC
                  UPDATE dbo.PalletDetail SET
                     LOC = @cLOC,
                     EditWho = SUSER_SNAME(),
                     EditDate = GETDATE()
                  WHERE PalletKey = @cPalletKey
                     AND PalletLineNumber = @cPalletLineNumber

                  IF @@ERROR <> 0
                  BEGIN
                     SET @nErrNo = 232901
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPD PLTD Fail
                     GOTO RollBackTran
                  END

                  FETCH NEXT FROM @curUpdPlt INTO @cPalletLineNumber
               END
               
               COMMIT TRAN rdt_1638ExtUpd10
            END
         END
      END
   END

   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_1638ExtUpd10 -- Only rollback change made here
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO
GRANT EXECUTE ON [rdt].[rdt_1638ExtUpd10] TO NSQL
GO
