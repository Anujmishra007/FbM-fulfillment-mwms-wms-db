SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1813ExtUpd02                                    */
/* Copyright: Maersk                                                    */
/*                                                                      */
/* Date         Rev  Author   Purposes                                  */
/* Aug-10-2025  1.0  Cuize    FCR-5780 Merge Pallet with SN             */
/************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_1813ExtUpd02] (
   @nMobile          INT,
   @nFunc            INT, 
   @cLangCode        NVARCHAR( 3), 
   @nStep            INT, 
   @nInputKey        INT, 
   @cStorerKey       NVARCHAR( 15), 
   @cFromID          NVARCHAR( 20), 
   @cOption          NVARCHAR( 1), 
   @cSKU             NVARCHAR( 20), 
   @nQty             INT, 
   @cToID            NVARCHAR( 20), 
   @nErrNo           INT           OUTPUT, 
   @cErrMsg          NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @dDEbug NVARCHAR(10) = '0'

   DECLARE @cLOT     NVARCHAR( 10)
   DECLARE @cItrnKey NVARCHAR(10)
   DECLARE @b_Success   INT


   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN
   SAVE TRAN rdt_1813ExtUpd02


   IF @nFunc = 1813 -- Scan to pallet
   BEGIN
      
      IF @nStep IN ( 5 , 7 )  -- Merge entire Pallet
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN

            --FROMID entire moved to TOID
            IF NOT EXISTS(
               SELECT 1 FROM LOTxLOCxID (NOLOCK)
                  WHERE QTY > 0
                    AND ID = @cFromID
                    AND StorerKey = @cStorerKey
            )
            AND EXISTS(
               SELECT 1 FROM LOTxLOCxID (NOLOCK)
               WHERE QTY > 0
                 AND ID = @cToID
                 AND StorerKey = @cStorerKey
            )
            BEGIN
               DECLARE @LLI_SKU TABLE (
                  RowNum INT IDENTITY(1,1),
                  LOT VARCHAR(10),
                  Loc VARCHAR(20),
                  Qty INT,
                  Sku VARCHAR(30)
               );

               --move all SKU in this ID
               INSERT INTO @LLI_SKU (LOT, Qty, Sku)
               SELECT
                  LOT, Qty, Sku
               FROM SerialNo WITH (NOLOCK)
               WHERE QTY > 0
                 AND ID = @cFromID
                 AND StorerKey = @cStorerKey


               DECLARE @i INT = 1;
               DECLARE @max INT;
               DECLARE @cLLI_SKU  NVARCHAR( 20);


               SELECT @max = COUNT(*) FROM @LLI_SKU;

               WHILE @i <= @max
               BEGIN

                  SELECT
                     @cLLI_SKU = Sku,
                     @cLOT = LOT
                  FROM @LLI_SKU
                  WHERE RowNum = @i;

                  IF EXISTS(
                     SELECT 1 FROM dbo.SKU WITH (NOLOCK)
                     WHERE SKU = @cLLI_SKU
                       AND StorerKey = @cStorerKey
                       AND SerialNoCapture IN ('1','3')
                     ) -- SN Capture
                  BEGIN

                     DECLARE @nSuccess INT = 1
                     EXECUTE nspg_getkey
                             'ItrnKey'
                           , 10
                           , @cItrnKey OUTPUT
                           , @nSuccess OUTPUT
                           , @nErrNo OUTPUT
                           , @cErrMsg OUTPUT
                     IF @nSuccess <> 1
                     BEGIN
                        SET @nErrNo = 221309
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_getkey
                        GOTO RBack
                     END

                     IF @dDEbug = '1'
                      BEGIN
                        INSERT INTO TraceInfo (TraceName, TimeIn, Step1, Step2, Step3, step4)
                        VALUES( 'rdt_1813ExtUpd02', GETDATE(), @cLLI_SKU,@cLOT, @cFromID, @cToID)
                     END

                     EXEC dbo.msp_SerialNoMoveCheck
                          @c_itrnkey    = @cItrnKey
                        , @c_StorerKey  = @cStorerKey
                        , @c_Sku        = @cLLI_SKU
                        , @c_Lot        = @cLOT
                        , @c_fromloc    = ''
                        , @c_fromid     = @cFromID
                        , @c_ToLoc      = ''
                        , @c_ToID       = @cToID
                        , @c_packkey    = ''
                        , @c_Status     = ''
                        , @n_casecnt    = ''
                        , @n_innerpack  = ''
                        , @n_Qty        = ''
                        , @n_pallet     = ''
                        , @f_cube       = ''
                        , @f_grosswgt   = ''
                        , @f_netwgt     = ''
                        , @f_otherunit1 = ''
                        , @f_otherunit2 = ''
                        , @c_lottable01 = ''
                        , @c_lottable02 = ''
                        , @c_lottable03 = ''
                        , @d_lottable04 = ''
                        , @d_lottable05 = ''
                        , @c_lottable06 = ''
                        , @c_lottable07 = ''
                        , @c_lottable08 = ''
                        , @c_lottable09 = ''
                        , @c_lottable10 = ''
                        , @c_lottable11 = ''
                        , @c_lottable12 = ''
                        , @d_lottable13 = ''
                        , @d_lottable14 = ''
                        , @d_lottable15 = ''
                        , @b_Success    = @b_Success OUTPUT
                        , @n_err        = @nErrNo     OUTPUT
                        , @c_errmsg     = @cErrMsg  OUTPUT
                        , @c_MoveRefKey = ''
                        , @c_Channel    = ''
                        , @n_Channel_ID = ''

                     IF @nSuccess <> 1
                     BEGIN
                        SET @nErrNo = 244052
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --ITrnSerialNoMove
                        GOTO RBack
                     END
                  END
                  SET @i += 1;

               END


            END

         END

      END

   GOTO Quit

   RBack:
   ROLLBACK TRANSACTION rdt_1813ExtUpd02
   Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN

   END
END

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_1813ExtUpd02] TO NSQL
GO

