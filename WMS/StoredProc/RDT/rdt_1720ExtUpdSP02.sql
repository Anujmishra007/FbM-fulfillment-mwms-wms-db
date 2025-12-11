SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO  
/************************************************************************/
/* Store procedure: rdt_1720ExtUpdSP02                                  */
/* Copyright      : Maersk WMS                                          */
/*                                                                      */
/* Purpose: Pallet Consolidation Extended Update                        */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author   Purposes                                   */
/* 2025-12-11  1.0  NickT    FCR-8808 Created                           */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1720ExtUpdSP02] (
      @nMobile        INT,
      @nFunc          INT,
      @cLangCode      NVARCHAR( 3),
      @nStep          INT,
      @nInputKey      INT,
      @cStorerKey     NVARCHAR( 15),
      @cFacility      NVARCHAR( 5),
      @cFromPalletID  NVARCHAR( 20),
      @cToPalletID    NVARCHAR( 20),
      @cDropID        NVARCHAR( 20),
      @nErrNo         INT           OUTPUT,
      @cErrMsg        NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @cPalletLineNumber         NVARCHAR( 5),
      @cNewPalletLineNumber      NVARCHAR( 5)

   IF @nFunc = 1720
   BEGIN
      IF @nStep = 3
      BEGIN
         BEGIN TRAN

         DECLARE CUR_PD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT PalletLineNumber
         FROM dbo.PalletDetail WITH (NOLOCK)  
         WHERE PalletKey = @cFromPalletID
         AND CaseID = @cDropID
            ORDER BY PalletLineNumber

         OPEN CUR_PD

         FETCH NEXT FROM CUR_PD INTO @cPalletLineNumber
         WHILE @@FETCH_STATUS <> -1
         BEGIN
            SET @cNewPalletLineNumber = ''

            SELECT 
               @cNewPalletLineNumber = RIGHT( '00000' + CAST( CAST( IsNULL( MAX( PalletLineNumber), 0) AS INT) + 1 AS VARCHAR( 5)), 5)
            FROM dbo.PalletDetail WITH (NOLOCK)
            WHERE PalletKey = @cToPalletID
            
            BEGIN TRY
               UPDATE dbo.PalletDetail WITH(ROWLOCK)
               SET 
                  PalletKey = @cToPalletID,
                  PalletLineNumber = @cNewPalletLineNumber 
               WHERE PalletKey = @cFromPalletID
                  AND PalletLineNumber = @cPalletLineNumber
                  AND CaseID = @cDropID
            END TRY
            BEGIN CATCH
               ROLLBACK TRAN
               SET @nErrNo = 253451
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UpdPalletDetFail
               GOTO Quit
            END CATCH

            FETCH NEXT FROM CUR_PD INTO @cPalletLineNumber
         END
         CLOSE CUR_PD  
         DEALLOCATE CUR_PD  

         IF NOT EXISTS ( SELECT 1 FROM dbo.PalletDetail WITH (NOLOCK) WHERE PalletKey = @cFromPalletID )
         BEGIN
            BEGIN TRY
               DELETE FROM dbo.Pallet
               WHERE PalletKey = @cFromPalletID
            END TRY
            BEGIN CATCH
               ROLLBACK TRAN
               SET @nErrNo = 253452
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DelPalletFail
               GOTO Quit
            END CATCH
         END

         COMMIT TRAN
      END
   END
   Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1720ExtUpdSP02 TO NSQL
GO
