
/************************************************************************/
/* Store procedure: rdt_1650ExtUpd02                                    */
/* Purpose: Insert pallet id into RDT.RDTScanToTruck                   */
/*          Update PACKHEADER status for CSCUK01                        */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2023-06-01 1.0  James      WMS-22733. Created                        */
/* 2026-03-24 2.0  AGA399     Merged rdt_1650ExtUpd06 - PackHeader upd  */
/* 2026-05-15 3.0  SKE140     Merged rdt_1650ExtUpd06 - rdt_1650ExtUpd02 */
/************************************************************************/

CREATE OR ATLER PROC [RDT].[rdt_1650ExtUpdCSC] (
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
         @cLoadKey          NVARCHAR( 10),
         @cOrderKey         NVARCHAR( 10),
         @cMBOL4PltID       NVARCHAR( 10),
         @nRowRef           INT,
         @cFacility         NVARCHAR( 5),
         @npickedQty        INT = 0,
         @nPackedQty        INT = 0

 DECLARE @curUpd            CURSOR

 SELECT @cFacility = Facility
 FROM RDT.RDTMOBREC WITH (NOLOCK)
 WHERE Mobile = @nMobile

 SET @nTranCount = @@TRANCOUNT
 BEGIN TRAN
 SAVE TRAN rdt_1650ExtUpd02

 IF @nFunc = 1650
 BEGIN
    IF @nInputKey = 1
    BEGIN

       ---------- STEP 2: Scan pallet to truck + confirm PackHeader ----------
       IF @nStep = 2
       BEGIN
          IF ISNULL( @cPalletID, '') = ''
          BEGIN
             SET @nErrNo = 201951
             SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- PALLET ID REQ
             GOTO RollBackTran
          END

          SELECT TOP 1 @cOrderKey = OrderKey
          FROM dbo.PickDetail WITH (NOLOCK)
          WHERE StorerKey = @cStorerKey
          AND   ID        = @cPalletID
          AND   [Status]  < '9'
          ORDER BY 1

          -- Get MBOLKey / LoadKey for this pallet
          SELECT @cMBOL4PltID = MbolKey,
                 @cLoadKey    = LoadKey
          FROM dbo.MBOLDetail WITH (NOLOCK)
          WHERE OrderKey = @cOrderKey

          -- Insert scan-to-truck record if not already completed
          IF NOT EXISTS ( SELECT 1
                          FROM RDT.RDTScanToTruck WITH (NOLOCK)
                          WHERE MBOLKey  = @cMBOL4PltID
                          AND   RefNo    = @cPalletID
                          AND   [Status] = '9')
          BEGIN
             INSERT INTO RDT.RDTScanToTruck
                    ( MBOLKey,      LoadKey,    CartonType,    RefNo,
                      URNNo,        Status,     AddWho,        AddDate,
                      EditWho,      EditDate,   Door )
             VALUES ( @cMBOLKey,   @cLoadKey,  'SCNPT2DOOR',  @cPalletID,
                      '',           '1',        sUser_sName(), GETDATE(),
                      sUser_sName(), GETDATE(), @cDoor )

             IF @@ERROR <> 0
             BEGIN
                SET @nErrNo = 201952
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- InsScn2TrkFail
                GOTO RollBackTran
             END
          END

          -- Update PackHeader to status '9' when all qty packed (merged from ExtUpd06)
          IF NOT EXISTS ( SELECT 1
                          FROM PackHeader WITH (NOLOCK)
                          WHERE OrderKey IN ( SELECT OrderKey FROM PickDetail WITH (NOLOCK)
                                              WHERE ID        = @cPalletID
                                              AND   StorerKey = @cStorerKey )
                          AND StorerKey = @cStorerKey
                          AND [Status]  = '9')
          BEGIN
             SELECT @npickedQty = SUM(qty)
             FROM PickDetail WITH (NOLOCK)
             WHERE OrderKey IN ( SELECT OrderKey FROM PickDetail WITH (NOLOCK)
                                 WHERE ID        = @cPalletID
                                 AND   StorerKey = @cStorerKey )
             AND StorerKey = @cStorerKey

             SELECT @nPackedQty = SUM(pd.qty)
             FROM PackDetail pd WITH (NOLOCK)
             INNER JOIN PackHeader ph WITH (NOLOCK) ON pd.PickSlipNo = ph.PickSlipNo
             WHERE ph.OrderKey IN ( SELECT OrderKey FROM PickDetail WITH (NOLOCK)
                                    WHERE ID        = @cPalletID
                                    AND   StorerKey = @cStorerKey )
             AND ph.StorerKey = @cStorerKey

             IF @npickedQty = @nPackedQty
             BEGIN
                UPDATE PackHeader
                SET    [Status] = '9'
                WHERE  OrderKey IN ( SELECT OrderKey FROM PickDetail WITH (NOLOCK)
                                     WHERE ID        = @cPalletID
                                     AND   StorerKey = @cStorerKey )
                AND    StorerKey = @cStorerKey
                AND    [Status] <> '9'

                IF @@ERROR <> 0
                BEGIN
                   SET @nErrNo = 221001
                   SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- PackCfm Fail
                   GOTO RollBackTran
                END
             END
          END

          GOTO Quit
       END -- End nStep = 2

       ---------- STEP 3: Close all scan-to-truck records for MBOL ----------
       IF @nStep = 3
       BEGIN
          IF NOT EXISTS ( SELECT 1
                          FROM dbo.PickDetail  PD WITH (NOLOCK)
                          JOIN dbo.MBOLDetail  MD WITH (NOLOCK) ON ( PD.OrderKey = MD.OrderKey )
                          WHERE PD.StorerKey     = @cStorerKey
                          AND   ISNULL(PD.ID,'') <> ''
                          AND   MD.MBOLKey        = @cMbolKey
                          AND   NOT EXISTS ( SELECT 1
                                             FROM rdt.rdtScanToTruck ST WITH (NOLOCK)
                                             WHERE MD.MBOLKey    = ST.MBOLKey
                                             AND   PD.ID         = ST.RefNo
                                             AND   ST.CartonType = 'SCNPT2DOOR'))
             AND @cOption = '1'
          BEGIN
             SET @curUpd = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
             SELECT RowRef
             FROM rdt.rdtScanToTruck WITH (NOLOCK)
             WHERE MBOLKey    = @cMbolKey
             AND   CartonType = 'SCNPT2DOOR'
             AND   [Status]   = '1'

             OPEN @curUpd
             FETCH NEXT FROM @curUpd INTO @nRowRef

             WHILE @@FETCH_STATUS = 0
             BEGIN
                UPDATE rdt.rdtScanToTruck
                SET    [Status]  = '9',
                       EditWho   = SUSER_SNAME(),
                       EditDate  = GETDATE()
                WHERE  RowRef = @nRowRef

                IF @@ERROR <> 0
                BEGIN
            SET @nErrNo = 201953
                   SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- CloseScn2TrkEr
                   GOTO RollBackTran
                END

                FETCH NEXT FROM @curUpd INTO @nRowRef
             END
          END
       END -- End nStep = 3

    END -- End nInputKey = 1
 END -- End nFunc = 1650

 COMMIT TRAN rdt_1650ExtUpd02
 GOTO Quit

RollBackTran:
 ROLLBACK TRAN rdt_1650ExtUpd02

Quit:
 WHILE @@TRANCOUNT > @nTranCount
    COMMIT TRAN

END
