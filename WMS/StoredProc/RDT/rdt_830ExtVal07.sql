SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_830ExtVal07                                     */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* customer       : Danone copy from rdt_830ExtVal06                    */
/* Purpose: DropID compulsory                                           */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 2026-08-16. 1.0. NYE018.     FCR-14824 created                       */
/************************************************************************/
          
CREATE OR ALTER   PROC [RDT].[rdt_830ExtVal07]  (
   @nMobile       INT,             
   @nFunc         INT,             
   @cLangCode     NVARCHAR( 3),    
   @nStep         INT,             
   @nInputKey     INT,             
   @cFacility     NVARCHAR( 5),    
   @cStorerKey    NVARCHAR( 15),   
   @cPickSlipNo   NVARCHAR( 10),  
   @cPickZone     NVARCHAR( 10),  
   @cSuggLOC      NVARCHAR( 10),   
   @cLOC          NVARCHAR( 10),   
   @cDropID       NVARCHAR( 20),   
   @cSKU          NVARCHAR( 20),   
   @cLottable01   NVARCHAR( 18),   
   @cLottable02   NVARCHAR( 18),   
   @cLottable03   NVARCHAR( 18),   
   @dLottable04   DATETIME,        
   @dLottable05   DATETIME,        
   @cLottable06   NVARCHAR( 30),   
   @cLottable07   NVARCHAR( 30),   
   @cLottable08   NVARCHAR( 30),   
   @cLottable09   NVARCHAR( 30),   
   @cLottable10   NVARCHAR( 30),   
   @cLottable11   NVARCHAR( 30),   
   @cLottable12   NVARCHAR( 30),   
   @dLottable13   DATETIME,        
   @dLottable14   DATETIME,        
   @dLottable15   DATETIME,        
   @nTaskQTY      INT,             
   @nQTY          INT,             
   @cToLOC        NVARCHAR( 10),   
   @cOption       NVARCHAR( 1),    
   @nErrNo        INT           OUTPUT,  
   @cErrMsg       NVARCHAR( 20) OUTPUT   
) AS  

BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cUOM           NVARCHAR(10)
   DECLARE @cPickDetailID  NVARCHAR(20)
   DECLARE @nPickDetailQty NUMERIC(13,4)
   DECLARE @nLotQty        NUMERIC(13,4)
   DECLARE @nLotQtyPicked  NUMERIC(13,4)

   IF @nFunc = 830 -- PickSKU
   BEGIN
      IF @nStep = 2 -- LOC
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            IF @cDropID = ''
            BEGIN
               SET @nErrNo = 277401
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Need DropID
               GOTO Quit
            END

            -- Look up PICKDETAIL and LotxLocxId to validate DropID against ID based on UOM
            SELECT TOP 1
               @cUOM           = PD.UOM,
               @cPickDetailID  = PD.ID,
               @nPickDetailQty = PD.Qty,
               @nLotQty        = ISNULL(LI.Qty, 0),
               @nLotQtyPicked  = ISNULL(LI.QtyPicked, 0)
            FROM dbo.PICKDETAIL PD (NOLOCK)
            LEFT JOIN dbo.LotxLocxId LI (NOLOCK)
               ON  LI.Storerkey = PD.Storerkey
               AND LI.SKU       = PD.SKU
               AND LI.Loc       = PD.Loc
               AND LI.ID        = PD.ID
            WHERE PD.PickSlipNo = @cPickSlipNo
              AND PD.Storerkey  = @cStorerKey
              AND PD.Loc        = @cSuggLOC
              AND PD.Status     <> '9'

            IF @cUOM = '1' -- Each: DropID must equal ID
            BEGIN
               IF @cDropID <> @cPickDetailID
               BEGIN
                  SET @nErrNo = 277403
                  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Wrong DropID
                  GOTO Quit
               END
            END
            ELSE IF @cUOM = '6' -- Case/pallet
            BEGIN
               IF (@nLotQty - @nLotQtyPicked) <> @nPickDetailQty
               BEGIN
                  -- Partial pick: DropID must NOT equal ID
                  IF @cDropID = @cPickDetailID
                  BEGIN
                     SET @nErrNo = 277404
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Wrong DropID
                     GOTO Quit
                  END
               END
               ELSE
               BEGIN
                  -- Full pick: DropID must equal ID
                  IF @cDropID <> @cPickDetailID
                  BEGIN
                     SET @nErrNo = 277405
                     SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Wrong DropID
                     GOTO Quit
                  END
               END
            END

            -- Check for duplicate DropID across any PICKDETAIL (same or different pickslip)
            IF EXISTS (
               SELECT 1
               FROM dbo.PICKDETAIL PD (NOLOCK)
               WHERE PD.Storerkey = @cStorerKey
                 AND PD.DropID    = @cDropID
                 AND PD.PickSlipNo <> @cPickSlipNo
                 AND PD.Status    <> '9'
                 AND NOT EXISTS (
                    SELECT 1 FROM dbo.PackHeader PH WITH(NOLOCK)
                    WHERE PH.PickSlipNo = @cPickSlipNo
                      AND PD.Orderkey      = PH.Orderkey
                 )
            )
            BEGIN
               SET @nErrNo = 277402
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --Duplicate DropID
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

GRANT EXECUTE ON [rdt].[rdt_830ExtVal07] TO NSQL
GO
