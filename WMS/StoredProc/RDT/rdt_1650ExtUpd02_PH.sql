SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************************/
/* Store procedure: rdt_1650ExtUpd02_PH                                 */
/* Purpose: Insert pallet id into RDT.RDTScanToTruck                    */
/* Customer: NLRT - PHARMA                                              */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2026-03-04 1.0  MBI165     Created                                   */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1650ExtUpd02_PH] (
   @nMobile          INT,
   @nFunc            INT,
   @nStep            INT,
   @cLangCode        NVARCHAR( 3),
   @nInputKey        INT,
   @cStorerKey       NVARCHAR( 15),
   @cPalletID        NVARCHAR( 20),
   @cMbolKey         NVARCHAR( 10),
   @cDoor            NVARCHAR( 20),
   @cOption          NVARCHAR( 1),
   @nAfterStep       INT,
   @nErrNo           INT           OUTPUT,
   @cErrMsg          NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nTranCount        INT,
           @cLoadkey          NVARCHAR( 10),
           @cOrderkey         NVARCHAR( 10),
           @cMBOL4PltID       NVARCHAR( 10),
           @nRowRef           INT,
           @cUserName         NVARCHAR( 128),
           @cPickDetailKey    NVARCHAR( 10), 
           @cFromLoc          NVARCHAR( 10),
           @cFacility         NVARCHAR( 5), 
           @cSku              NVARCHAR( 20), 
           @cLot              NVARCHAR( 10),
           @nQty              INT, 
           @cMoveRefKey       NVARCHAR( 10), 
           @bSuccess          INT
        

   DECLARE @curUpd            CURSOR

	DECLARE @tPickDetailKey TABLE 
   (
      PickDetailKey NVARCHAR(10) PRIMARY KEY CLUSTERED NOT NULL
   )

   SELECT @cFacility = Facility,
      @cUserName = UserName
   FROM RDT.RDTMOBREC WITH (NOLOCK) 
   WHERE Mobile = @nMobile
   
   
   SET @nTranCount = @@TRANCOUNT
   BEGIN TRAN
   SAVE TRAN rdt_1650ExtUpd02


   IF @nInputKey = 1
   BEGIN
      IF @nStep = 2
      BEGIN
         IF ISNULL( @cPalletID, '') = ''
         BEGIN
            SET @nErrNo = 273001
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --PALLET ID REQ
            GOTO RollBackTran
         END

         SELECT TOP 1 @cOrderKey = OrderKey
         FROM dbo.PickDetail WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
         AND   ID = @cPalletID
         AND  [Status] < '9'

         -- Get the mbolkey for this particular pallet id
         SELECT @cMBOL4PltID = MbolKey, @cLoadKey = LoadKey
         FROM dbo.MBOLDetail WITH (NOLOCK)
         WHERE OrderKey = @cOrderKey


        DECLARE CUR_LOOP CURSOR LOCAL READ_ONLY FAST_FORWARD FOR 
         SELECT LLI.StorerKey, LLI.SKU, LLI.LOT, LLI.LOC, LLI.Qty
         FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
         JOIN dbo.LOC LOC WITH (NOLOCK) ON ( LLI.LOC = LOC.LOC)
         WHERE LLI.ID = @cPalletID
         AND   LLI.Qty > 0
         AND   LOC.Facility = @cFacility
         AND   LOC.LOC <> @cDoor
         
         OPEN CUR_LOOP
         FETCH NEXT FROM CUR_LOOP INTO @cStorerKey, @cSku, @cLot, @cFromLoc, @nQty
         WHILE @@FETCH_STATUS <> -1 
         BEGIN
            SET @cMoveRefKey = ''
            SET @bSuccess = 1    
            EXECUTE   nspg_getkey    
                     'MoveRefKey'    
                     , 10    
                     , @cMoveRefKey       OUTPUT    
                     , @bSuccess          OUTPUT    
                     , @nErrNo            OUTPUT    
                     , @cErrMsg           OUTPUT 

            IF NOT @bSuccess = 1    
            BEGIN    
               SET @nErrNo = 273002   
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Get RFKey Fail 
               GOTO Quit
            END

            DELETE FROM @tPickDetailKey

            -- (james04)
            DECLARE CUR_UPDMOVREF CURSOR LOCAL READ_ONLY FAST_FORWARD FOR 
            SELECT DISTINCT PickDetailKey 
            FROM dbo.PickDetail WITH (NOLOCK)
            WHERE  ID = @cPalletID
               AND    StorerKey = @cStorerKey
               AND    SKU = @cSku
               AND    Status < '9'
               AND    ShipFlag <> 'Y'
               AND    LOT = @cLot
               AND    LOC = @cFromLoc
               AND    LOC <> @cDoor
            OPEN CUR_UPDMOVREF 
            FETCH NEXT FROM CUR_UPDMOVREF INTO @cPickDetailKey
            WHILE @@FETCH_STATUS <> -1
            BEGIN TRY
               UPDATE dbo.PickDetail WITH (ROWLOCK) SET 
                MoveRefKey = @cMoveRefKey
               ,EditWho    = SUSER_NAME()
               ,EditDate   = GETDATE()
               ,Trafficcop = NULL
               WHERE PickDetailKey = @cPickDetailKey
            END TRY
            BEGIN CATCH
               SET @nErrNo = 273003
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --LOCK PDTL FAIL 
               CLOSE CUR_UPDMOVREF
               DEALLOCATE CUR_UPDMOVREF
               GOTO Quit
            END CATCH

               INSERT INTO @tPickDetailKey (PickDetailKey)
               VALUES (@cPickDetailKey)

               FETCH NEXT FROM CUR_UPDMOVREF INTO @cPickDetailKey
            END
            CLOSE CUR_UPDMOVREF
            DEALLOCATE CUR_UPDMOVREF

            --Update all SKU on pallet to new ASRS LOC
            EXEC nspItrnAddMove
                  NULL                                        
               , @cStorerKey              -- @c_StorerKey   
               , @cSku                    -- @c_Sku         
               , @cLot                    -- @c_Lot         
               , @cFromLoc                -- @c_FromLoc     
               , @cPalletID               -- @c_FromID      
               , @cDoor                   -- @c_ToLoc       
               , ''                       -- @c_ToID ( Set 'CLEAR' to lose id)
               , '0'                      -- @c_Status      
               , ''                       -- @c_lottable01  
               , ''                       -- @c_lottable02  
               , ''                       -- @c_lottable03  
               , NULL                     -- @d_lottable04  
               , NULL                     -- @d_lottable05  
               , ''                       -- @c_lottable06  
               , ''                       -- @c_lottable07  
               , ''                       -- @c_lottable08  
               , ''                       -- @c_lottable09  
               , ''                       -- @c_lottable10  
               , ''                       -- @c_lottable11  
               , ''                       -- @c_lottable12  
               , NULL                     -- @d_lottable13  
               , NULL                     -- @d_lottable14  
               , NULL                     -- @d_lottable15  
               , 0                        -- @n_casecnt     
               , 0                        -- @n_innerpack   
               , @nQty                    -- @n_qty         
               , 0                        -- @n_pallet      
               , 0                        -- @f_cube        
               , 0                        -- @f_grosswgt    
               , 0                        -- @f_netwgt      
               , 0                        -- @f_otherunit1  
               , 0                        -- @f_otherunit2  
               , @cOrderKey               -- @c_SourceKey   
               , 'rdt_ScanToDoor_Confirm' -- @c_SourceType  
               , ''                       -- @c_PackKey     
               , ''                       -- @c_UOM         
               , 0                        -- @b_UOMCalc     
               , NULL                     -- @d_EffectiveD  
               , ''                       -- @c_itrnkey     
               , @bSuccess   OUTPUT       -- @b_Success   
               , @nErrNo     OUTPUT       -- @n_err       
               , @cErrMsg    OUTPUT       -- @c_errmsg    
               , @cMoveRefKey             -- @c_MoveRefKey     
                                                                  
            IF @@ERROR <> 0 OR RTRIM(@cErrMsg) <> ''
            BEGIN
               SET @nErrNo = 273004   
               SET @cErrMsg = @cErrMsg--rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Lose ID Fail 
               GOTO Quit
            END

            BEGIN TRY
               UPDATE PD WITH (ROWLOCK) 
               SET
                  MoveRefKey = '',
                  EditWho    = SUSER_NAME(),
                  EditDate   = GETDATE(),
                  Trafficcop = NULL
                  --ID = @cPalletID
               FROM dbo.PICKDETAIL PD WITH (ROWLOCK)
               INNER JOIN @tPickDetailKey TPD ON PD.PickDetailKey = TPD.PickDetailKey

            END TRY
            BEGIN CATCH
               SET @nErrNo = 273005
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --REL PDTL FAIL 
               GOTO Quit
            END CATCH

            FETCH NEXT FROM CUR_LOOP INTO @cStorerKey, @cSku, @cLot, @cFromLoc, @nQty
         END
         CLOSE CUR_LOOP
         DEALLOCATE CUR_LOOP


         -- Add record into RDTScanToTruck (james01)
         IF NOT EXISTS ( SELECT 1 FROM RDT.RDTScanToTruck WITH (NOLOCK)
                         WHERE MBOLKey = @cMBOL4PltID
                         AND   RefNo = @cPalletID
                         AND  [Status] = '9')
         BEGIN TRY
            INSERT INTO RDT.RDTScanToTruck
                   (MBOLKey, LoadKey, CartonType, RefNo, URNNo, Status, AddWho, AddDate, EditWho, EditDate, Door)
            VALUES (@cMBOLKey, @cLoadKey, 'SCNPT2DOOR', @cPalletID, '', '9', sUser_sName(), GETDATE(), sUser_sName(), GETDATE(), @cDoor)
         END TRY

         BEGIN CATCH
            SET @nErrNo = 273006
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InsScn2TrkFail
            GOTO RollBackTran
         END CATCH

         GOTO Quit
      END

      IF @nStep = 3 AND @cOption = '1'
      BEGIN
         IF NOT EXISTS ( SELECT 1
                         FROM dbo.PickDetail PD WITH (NOLOCK)
                         JOIN dbo.MBOLDetail MD WITH (NOLOCK) ON ( PD.OrderKey = MD.OrderKey)
                         WHERE PD.StorerKey = @cStorerKey
                         AND   ISNULL( PD.ID, '') <> ''
                         AND   MD.MBOLKey = @cMbolKey
                         AND   NOT EXISTS ( SELECT 1 FROM rdt.rdtScanToTruck ST WITH (NOLOCK)
                                            WHERE MD.MBOLKey = ST.MBOLKey
                                            AND   PD.ID = ST.RefNo
                                            AND   ST.CartonType = 'SCNPT2DOOR')) 
         BEGIN
            SELECT TOP 1 @cOrderKey = OrderKey
            FROM dbo.ORDERS WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
            AND   ISNULL(MBolKey,'') = @cMbolKey
            AND   ISNULL(@cMbolKey,'') <> ''
            AND   status = '5' 
        
            BEGIN TRY
            UPDATE Orders WITH (ROWLOCK)
               SET status = '8'
               WHERE ISNULL(MBolKey,'') = @cMbolKey
               AND  ISNULL(@cMbolKey,'') <> ''
               AND  STORERKEY = @cStorerKey
               AND status = '5'
            END TRY
            BEGIN CATCH
               SET @nErrNo = 273007
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPDATE ORDERS FAIL 
               GOTO Quit
            END CATCH
            
            
         END

      END
   END

   COMMIT TRAN rdt_1650ExtUpd02

   GOTO Quit

RollBackTran:
   ROLLBACK TRAN rdt_1650ExtUpd02 -- Only rollback change made here
Quit:
   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN

END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_1650ExtUpd02_PH] TO NSQL
GO
