SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO 

/************************************************************************/  
/* Store procedure: rdt_832ExtScn01                                     */
/*                                                                      */  
/* Customer: MGACA                                                      */
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date         Rev  Author     Purposes                                */
/* 2025-09-17   1.0  Cuize      FCR-7763 Add ExtScn                     */
/************************************************************************/  
  
CREATE OR ALTER PROC [RDT].[rdt_832ExtScn01] (
   @nMobile      INT,           
   @nFunc        INT,           
   @cLangCode    NVARCHAR( 3),  
   @nStep INT,           
   @nScn  INT,           
   @nInputKey    INT,           
   @cFacility    NVARCHAR( 5),  
   @cStorerKey   NVARCHAR( 15), 

   @tExtScnData   VariableTable READONLY,

   @cInField01       NVARCHAR( 60) OUTPUT,  @cOutField01 NVARCHAR( 60) OUTPUT,  @cFieldAttr01 NVARCHAR( 1) OUTPUT,  @cLottable01 NVARCHAR( 18) OUTPUT,  
   @cInField02       NVARCHAR( 60) OUTPUT,  @cOutField02 NVARCHAR( 60) OUTPUT,  @cFieldAttr02 NVARCHAR( 1) OUTPUT,  @cLottable02 NVARCHAR( 18) OUTPUT,  
   @cInField03       NVARCHAR( 60) OUTPUT,  @cOutField03 NVARCHAR( 60) OUTPUT,  @cFieldAttr03 NVARCHAR( 1) OUTPUT,  @cLottable03 NVARCHAR( 18) OUTPUT,  
   @cInField04       NVARCHAR( 60) OUTPUT,  @cOutField04 NVARCHAR( 60) OUTPUT,  @cFieldAttr04 NVARCHAR( 1) OUTPUT,  @dLottable04 DATETIME      OUTPUT,  
   @cInField05       NVARCHAR( 60) OUTPUT,  @cOutField05 NVARCHAR( 60) OUTPUT,  @cFieldAttr05 NVARCHAR( 1) OUTPUT,  @dLottable05 DATETIME      OUTPUT,  
   @cInField06       NVARCHAR( 60) OUTPUT,  @cOutField06 NVARCHAR( 60) OUTPUT,  @cFieldAttr06 NVARCHAR( 1) OUTPUT,  @cLottable06 NVARCHAR( 30) OUTPUT, 
   @cInField07       NVARCHAR( 60) OUTPUT,  @cOutField07 NVARCHAR( 60) OUTPUT,  @cFieldAttr07 NVARCHAR( 1) OUTPUT,  @cLottable07 NVARCHAR( 30) OUTPUT, 
   @cInField08       NVARCHAR( 60) OUTPUT,  @cOutField08 NVARCHAR( 60) OUTPUT,  @cFieldAttr08 NVARCHAR( 1) OUTPUT,  @cLottable08 NVARCHAR( 30) OUTPUT, 
   @cInField09       NVARCHAR( 60) OUTPUT,  @cOutField09 NVARCHAR( 60) OUTPUT,  @cFieldAttr09 NVARCHAR( 1) OUTPUT,  @cLottable09 NVARCHAR( 30) OUTPUT, 
   @cInField10       NVARCHAR( 60) OUTPUT,  @cOutField10 NVARCHAR( 60) OUTPUT,  @cFieldAttr10 NVARCHAR( 1) OUTPUT,  @cLottable10 NVARCHAR( 30) OUTPUT, 
   @cInField11       NVARCHAR( 60) OUTPUT,  @cOutField11 NVARCHAR( 60) OUTPUT,  @cFieldAttr11 NVARCHAR( 1) OUTPUT,  @cLottable11 NVARCHAR( 30) OUTPUT,
   @cInField12       NVARCHAR( 60) OUTPUT,  @cOutField12 NVARCHAR( 60) OUTPUT,  @cFieldAttr12 NVARCHAR( 1) OUTPUT,  @cLottable12 NVARCHAR( 30) OUTPUT,
   @cInField13       NVARCHAR( 60) OUTPUT,  @cOutField13 NVARCHAR( 60) OUTPUT,  @cFieldAttr13 NVARCHAR( 1) OUTPUT,  @dLottable13 DATETIME      OUTPUT,
   @cInField14       NVARCHAR( 60) OUTPUT,  @cOutField14 NVARCHAR( 60) OUTPUT,  @cFieldAttr14 NVARCHAR( 1) OUTPUT,  @dLottable14 DATETIME      OUTPUT,
   @cInField15       NVARCHAR( 60) OUTPUT,  @cOutField15 NVARCHAR( 60) OUTPUT,  @cFieldAttr15 NVARCHAR( 1) OUTPUT,  @dLottable15 DATETIME      OUTPUT,
   @nAction      INT, --0 Jump Screen, 2. Prepare output fields, Step = 99 is a new screen
   @nAfterScn    INT OUTPUT, @nAfterStep    INT OUTPUT, 
   @nErrNo             INT            OUTPUT, 
   @cErrMsg            NVARCHAR( 1024)  OUTPUT,
   @cUDF01  NVARCHAR( 250) OUTPUT, @cUDF02 NVARCHAR( 250) OUTPUT, @cUDF03 NVARCHAR( 250) OUTPUT,
   @cUDF04  NVARCHAR( 250) OUTPUT, @cUDF05 NVARCHAR( 250) OUTPUT, @cUDF06 NVARCHAR( 250) OUTPUT,
   @cUDF07  NVARCHAR( 250) OUTPUT, @cUDF08 NVARCHAR( 250) OUTPUT, @cUDF09 NVARCHAR( 250) OUTPUT,
   @cUDF10  NVARCHAR( 250) OUTPUT, @cUDF11 NVARCHAR( 250) OUTPUT, @cUDF12 NVARCHAR( 250) OUTPUT,
   @cUDF13  NVARCHAR( 250) OUTPUT, @cUDF14 NVARCHAR( 250) OUTPUT, @cUDF15 NVARCHAR( 250) OUTPUT,
   @cUDF16  NVARCHAR( 250) OUTPUT, @cUDF17 NVARCHAR( 250) OUTPUT, @cUDF18 NVARCHAR( 250) OUTPUT,
   @cUDF19  NVARCHAR( 250) OUTPUT, @cUDF20 NVARCHAR( 250) OUTPUT, @cUDF21 NVARCHAR( 250) OUTPUT,
   @cUDF22  NVARCHAR( 250) OUTPUT, @cUDF23 NVARCHAR( 250) OUTPUT, @cUDF24 NVARCHAR( 250) OUTPUT,
   @cUDF25  NVARCHAR( 250) OUTPUT, @cUDF26 NVARCHAR( 250) OUTPUT, @cUDF27 NVARCHAR( 250) OUTPUT,
   @cUDF28  NVARCHAR( 250) OUTPUT, @cUDF29 NVARCHAR( 250) OUTPUT, @cUDF30 NVARCHAR( 250) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @nRowCount                 INT,
      @cPackInfoRefNo            NVARCHAR( 20),
      @cCartonID                 NVARCHAR( 20),
      @cOption                   NVARCHAR(2),
      @cDoc1Value                NVARCHAR( 20),
      @nFlagStep4Failed          NVARCHAR(1) = 'N',
      @cPackInfo                 NVARCHAR( 4),
      @cDoc1Label                NVARCHAR( 20),
      @nTranCount                INT


   SELECT
      @nScn                = Scn,
      @nStep               = Step,
      @cPackInfoRefNo      = V_String5,
      @cDoc1Label          = V_String10,
      @cDoc1Value          = V_String11,
      @cCartonID           = V_String1,
      @cPackInfo           = V_String26
   FROM RDTMOBREC (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nFunc = 832
   BEGIN
      IF @nStep = 1
      BEGIN
         IF @nInputKey = 1 --Enter Pickslip
         BEGIN


            SET @cOutField01 = @cInField02 -- docValue
            SET @nAfterScn = 6675
            SET @nAfterStep = 99

            GOTO Quit

         END
      END

      IF @nStep = 4
      BEGIN
         IF @nInputKey = 1 --Enter Pickslip
         BEGIN

            SET @cPackInfoRefNo  = CASE WHEN @cFieldAttr04 = '' THEN @cInField04 ELSE @cOutField04 END

            DECLARE @cOriginalRefNo NVARCHAR(20) = ''

            SELECT @cOriginalRefNo = RefNo
               FROM PACKDETAIL WITH (NOLOCK )
            WHERE Storerkey = @cStorerKey
              AND PickSlipNo = @cDoc1Value
              AND RefNO2 = @cCartonID
              --AND RefNo = @cPackInfoRefNo


            --Origin RefNo is empty
            IF ISNULL(@cOriginalRefNo,'') = ''
            BEGIN

               SET @nTranCount = @@TRANCOUNT

               BEGIN TRAN
               SAVE TRAN rdt_832ExtScn01

               UPDATE PACKDETAIL WITH (ROWLOCK)
               SET RefNo = @cPackInfoRefNo
               WHERE PickSlipNo = @cDoc1Value
               AND RefNo2 = @cCartonID
               IF @@ERROR <> 0
               BEGIN
                  SET @nFlagStep4Failed = 'Y'
                  SET @nErrNo = 247002
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPdPackdetailFail
                  GOTO RBack
               END

               UPDATE PI WITH (ROWLOCK)
               SET PI.RefNo = @cPackInfoRefNo, PI.TrackingNo = @cPackInfoRefNo
               FROM PackInfo PI WITH (ROWLOCK)
               JOIN Packdetail PD
                  ON PI.PickSlipNo = PD.PickSlipNo
                  AND PI.CartonNo = PD.CartonNo
               WHERE PD.PickSlipNo = @cDoc1Value
                  AND PD.RefNo2 = @cCartonID
               IF @@ERROR <> 0
               BEGIN
                  SET @nFlagStep4Failed = 'Y'
                  SET @nErrNo = 247003
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPdPackdetailFail
                  GOTO RBack
               END

               --Back to step2
               SET @cOutField01 = '' -- CartonID

               SET @nAfterScn = 5581
               SET @nAfterStep = 2

               GOTO Quit

            END
            ELSE --Original Refno Not empty
            BEGIN

               IF (@cOriginalRefNo = @cPackInfoRefNo)
               BEGIN
                  SET @nFlagStep4Failed = 'Y'
                  SET @nErrNo = 247004
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --SameRefNoAlreadyAssigned
                  GOTO Quit
               END

               SET @cOutField01 = @cCartonID

               --Goto OverWrite Screen
               SET @nAfterScn = 6676
               SET @nAfterStep = 99

               GOTO Quit

            END

         END
      END

      IF @nStep = 99
      BEGIN
         IF @nScn = 6675
         BEGIN

            IF @nInputKey = 1
            BEGIN

               SET @cOption = @cInField02

               IF @cOption NOT IN ('1','9')
               BEGIN
                  SET @nErrNo = 247005
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidOption
                  GOTO Quit
               END

               IF @cOption = 1
               BEGIN

                  --Need tracking
                  SET @cOutField01 = '' -- CartonID

                  SET @nAfterScn = 5581
                  SET @nAfterStep = 2

                  GOTO Quit

               END

               IF @cOption = 9
               BEGIN


                  DECLARE @refNoDefault NVARCHAR(20)
                  SELECT @refNoDefault = short
                  FROM CodeLkup WITH (NOLOCK)
                  WHERE ListName = 'RDTDEFVAL'
                    AND Code = '832-REFNO'
                    AND StorerKey = @cStorerKey


                  IF ISNULL(@refNoDefault,'') <> ''
                  BEGIN

                     SET @nTranCount = @@TRANCOUNT

                     BEGIN TRAN
                     SAVE TRAN rdt_832ExtScn01

                     UPDATE PACKDETAIL WITH (ROWLOCK)
                     SET RefNo = @refNoDefault
                     WHERE PickSlipNo = @cDoc1Value
                     IF @@ERROR <> 0
                     BEGIN
                        SET @nErrNo = 247006
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPdPackdetailFail
                        GOTO RBack
                     END

                     UPDATE PackInfo WITH (ROWLOCK)
                     SET RefNo = @refNoDefault, TrackingNo = @refNoDefault
                     WHERE PickSlipNo = @cDoc1Value
                     IF @@ERROR <> 0
                     BEGIN
                        SET @nErrNo = 247007
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPdPackInfoFail
                        GOTO RBack
                     END
                  END


                  -- Prepare next screen var
                  SET @cOutField01 = @cDoc1Label
                  SET @cOutField02 = '' -- Doc1Value


                  SET @nAfterScn = 5580
                  SET @nAfterStep = 1

                  GOTO Quit

               END
            END
            ELSE
            BEGIN

               SET @cOutField01 = @cDoc1Label
               SET @cOutField02 = '' -- Doc1Value

               SET @nAfterScn = 5580
               SET @nAfterStep = 1

               GOTO Quit
            END

         END

         IF @nScn = 6676
         BEGIN
            IF @nInputKey = 1
            BEGIN

               SET @cOption = @cInField02

               IF @cOption NOT IN ('1','9')
               BEGIN
                  SET @nErrNo = 247005
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidOption
                  GOTO Quit
               END

               IF @cOption = '1' --Overwrite
               BEGIN

                  SET @nTranCount = @@TRANCOUNT

                  BEGIN TRAN
                  SAVE TRAN rdt_832ExtScn01

                  UPDATE PACKDETAIL WITH (ROWLOCK)
                  SET RefNo = @cPackInfoRefNo
                  WHERE PickSlipNo = @cDoc1Value
                    AND RefNo2 = @cCartonID
                  IF @@ERROR <> 0
                  BEGIN
                     SET @nErrNo = 247008
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPdPackdetailFail
                     GOTO RBack
                  END

                  UPDATE PI WITH (ROWLOCK)
                  SET PI.RefNo = @cPackInfoRefNo, PI.TrackingNo = @cPackInfoRefNo
                  FROM PackInfo PI WITH (ROWLOCK)
                     JOIN Packdetail PD
                        ON PI.PickSlipNo = PD.PickSlipNo
                        AND PI.CartonNo = PD.CartonNo
                  WHERE PD.PickSlipNo = @cDoc1Value
                     AND PD.RefNo2 = @cCartonID
                  IF @@ERROR <> 0
                  BEGIN
                     SET @nErrNo = 247009
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UPdPackdetailFail
                     GOTO RBack
                  END

                  --Back to step2
                  SET @cOutField01 = '' -- CartonID

                  SET @nAfterScn = 5581
                  SET @nAfterStep = 2

                  GOTO Quit

               END

               IF @cOption = '9' --Cancel
               BEGIN
                  --Back to step2
                  SET @cOutField01 = '' -- CartonID

                  SET @nAfterScn = 5581
                  SET @nAfterStep = 2

                  GOTO Quit
               END


            END



         END


      END
   END

   GOTO Quit

   RBACK:
   ROLLBACK TRAN rdt_832ExtScn01
   Quit:
   IF @nFlagStep4Failed = 'Y'
   BEGIN
      SET @cFieldAttr01 = CASE WHEN CHARINDEX( 'T', @cPackInfo) = 0 THEN 'O' ELSE '' END
      SET @cFieldAttr02 = CASE WHEN CHARINDEX( 'C', @cPackInfo) = 0 THEN 'O' ELSE '' END
      SET @cFieldAttr03 = CASE WHEN CHARINDEX( 'W', @cPackInfo) = 0 THEN 'O' ELSE '' END
      SET @cFieldAttr04 = CASE WHEN CHARINDEX( 'R', @cPackInfo) = 0 THEN 'O' ELSE '' END

      SET @nAfterScn = 5583
      SET @nAfterStep = 4
   END

   WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_832ExtScn01 to nSQL
GO
