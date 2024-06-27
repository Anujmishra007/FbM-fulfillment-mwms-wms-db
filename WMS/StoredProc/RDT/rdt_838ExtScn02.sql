
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/  
/* Store procedure: rdt_838ExtScn02                                     */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2024-06-27 1.0  JACKC      FCR-392. Created                          */  
/************************************************************************/  
  
CREATE OR ALTER PROC [RDT].[rdt_838ExtScn02] (
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
   @cErrMsg            NVARCHAR( 20)  OUTPUT,
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
      --rdtmobrec
      @cUserName             NVARCHAR( 18),
      @nMenu                 INT,
      
      
      @nRowCount             INT,
      @cExtendedUpdateSP     NVARCHAR( 20),
      @cExtendedValidateSP   NVARCHAR( 20),
      @cExtendedInfoSP       NVARCHAR( 20),

      @cDropID               NVARCHAR( 20), 
      @cRefNo                NVARCHAR( 20),
      @cPickSlipNo           NVARCHAR( 10),
      @cLoadKey              NVARCHAR( 10),
      @cOrderKey             NVARCHAR( 10),
      @cID                   NVARCHAR( 18),
      @cOption               NVARCHAR( 1),
      @cInputKey             NVARCHAR( 1),
      @cSKU                  NVARCHAR( 20),
      @cTaskDetailKey        NVARCHAR( 20),
      @cPreviousSKU          NVARCHAR( 20),
      @cPPAStatus            NVARCHAR( 1),
      @cReasonCode           NVARCHAR( 20),
      @cDisableQTYField      NVARCHAR( 1),
      @cPPADefaultQTY        NVARCHAR( 1),
      @cTaskDefaultQty       NVARCHAR( 1),
      @cTaskQty              NVARCHAR( 5),
      @cSQL                  NVARCHAR( MAX),
      @cSQLParam             NVARCHAR( MAX), 
      @nQTY                  INT,
      @nTotalCQty            INT,
      @nTotalPQty            INT,

      @cStatus               NVARCHAR( 1),
      @cPPADefaultPQTY       NVARCHAR( 1)
      

   DECLARE @tReturnData TABLE
   (
      Variable	   NVARCHAR(30),
      Value       NVARCHAR(100)
   )

   
   SET @nErrNo = 0
   SET @cErrMsg = ''
   SET @cTaskDetailKey = ''

   SELECT @cDropID = Value FROM @tExtScnData WHERE Variable = '@cDropID'
   SELECT @cRefNo = Value FROM @tExtScnData WHERE Variable = '@cRefNo'
   SELECT @cPickSlipNo = Value FROM @tExtScnData WHERE Variable = '@cPickSlipNo'
   SELECT @cLoadKey = Value FROM @tExtScnData WHERE Variable = '@cLoadKey'
   SELECT @cOrderKey = Value FROM @tExtScnData WHERE Variable = '@cOrderKey'
   SELECT @cID = Value FROM @tExtScnData WHERE Variable = '@cID'
   SELECT @cSKU = Value FROM @tExtScnData WHERE Variable = '@cSKU'
   SELECT @nQTY = CAST(Value AS INT) FROM @tExtScnData WHERE Variable = '@nQTY'
   SELECT @nScn = CAST(Value AS INT) FROM @tExtScnData WHERE Variable = '@nScn'

   SET @cExtendedUpdateSP = rdt.rdtGetConfig( @nFunc, 'ExtendedUpdateSP', @cStorerkey)
   IF @cExtendedUpdateSP = '0'
      SET @cExtendedUpdateSP = ''
   SET @cExtendedValidateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedValidateSP', @cStorerkey)
   IF @cExtendedValidateSP = '0'
      SET @cExtendedValidateSP = ''
   SET @cExtendedInfoSP = rdt.RDTGetConfig( @nFunc, 'ExtendedInfoSP', @cStorerkey)
   IF @cExtendedInfoSP = '0'
      SET @cExtendedInfoSP = ''
 

   SELECT @nStep = Step,
      @nMenu               = Menu,
      @cUserName           = UserName,
      @cDisableQTYField    = V_String23,
      @cPPADefaultQTY      = V_String14,
      @cTaskQty            = V_String6,
      @cTaskDefaultQty     = V_String7
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   IF @nFunc = 838
   BEGIN
      IF @nStep = 0
      BEGIN
         IF @nAction = 0 -- new screen
         BEGIN
            IF @nInputKey = 1 --Enter
            BEGIN
               EXEC rdt.rdtSetFocusField @nMobile, 1 --CartNo
               SET @nAfterScn = 6385
               SET @nAfterStep = 99
               GOTO Quit
            END
            ELSE IF @nInputKey = 0 --ESC
            BEGIN
               --Back to Menu
               -- EventLog
               EXEC RDT.rdt_STD_EventLog
                  @cActionType = '9', -- Sign-out
                  @cUserID     = @cUserName,
                  @nMobileNo   = @nMobile,
                  @nFunctionID = @nFunc,
                  @cFacility   = @cFacility,
                  @cStorerKey  = @cStorerKey,
                  @nStep       = @nStep

               -- Back to menu
               SET @nFunc = @nMenu
               SET @nScn  = @nMenu
               SET @nStep = 0
               SET @cOutField01 = '' -- Option


               GOTO Quit
            END --inputkey 0
         END -- action 0
      END -- step 0
      ELSE IF @nStep = 99
      BEGIN
         IF @nScn = 6385
         BEGIN
            IF @nInputKey = 0
            BEGIN
               --Back to Menu
               -- EventLog
               EXEC RDT.rdt_STD_EventLog
                  @cActionType = '9', -- Sign-out
                  @cUserID     = @cUserName,
                  @nMobileNo   = @nMobile,
                  @nFunctionID = @nFunc,
                  @cFacility   = @cFacility,
                  @cStorerKey  = @cStorerKey,
                  @nStep       = @nStep

               -- Back to menu
               SET @nAfterScn  = @nMenu
               SET @nAfterStep = 0
               SET @cOutField01 = '' -- Option
            END
            ELSE IF @nInputKey = 1
            BEGIN
               SET @cOption = @cInField01

               IF @cOption NOT IN ('1', '9') --1. Short Pick  9. Not Short Pick
               BEGIN
                  SET @nErrNo = 217351
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvalidOption
                  GOTO Quit
               END

               -- Extended update
               IF @cExtendedUpdateSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +      
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cRefNo, @cPickSlipNo, @cLoadKey, @cOrderKey, @cDropID, ' +       
                        ' @cSKU, @nQty, @cOption, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cID, @cTaskDetailKey,@cReasonCode OUTPUT'        
                     SET @cSQLParam =      
                        '@nMobile         INT,       ' +      
                        '@nFunc           INT,       ' +      
                        '@cLangCode       NVARCHAR( 3),  ' +      
                        '@nStep           INT,           ' +      
                        '@nInputKey       INT,           ' +      
                        '@cStorerKey      NVARCHAR( 15), ' +      
                        '@cRefNo          NVARCHAR( 10), ' +      
                        '@cPickSlipNo     NVARCHAR( 10), ' +      
                        '@cLoadKey        NVARCHAR( 10), ' +      
                        '@cOrderKey       NVARCHAR( 10), ' +      
                        '@cDropID         NVARCHAR( 20), ' +      
                        '@cSKU            NVARCHAR( 20), ' +      
                        '@nQty            INT,           ' +      
                        '@cOption         NVARCHAR( 1),  ' +      
                        '@nErrNo          INT           OUTPUT, ' +      
                        '@cErrMsg         NVARCHAR( 20) OUTPUT, ' +      
                        '@cID             NVARCHAR( 18), ' +       
                        '@cTaskDetailKey  NVARCHAR( 10), ' +        
                        '@cReasonCode     NVARCHAR( 20)  OUTPUT '
               
                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,        
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cRefNo, @cPickSlipNo, @cLoadKey, @cOrderKey, @cDropID, @cSKU, @nQty, @cOption,
                        @nErrNo OUTPUT, @cErrMsg OUTPUT, @cID, @cTaskDetailKey, @cReasonCode OUTPUT

                     IF @nErrNo <> 0
                        GOTO Quit
                  END
               END
               
               SET @cOutField01 = ''
               IF @cDisableQTYField = '1'
               BEGIN
                  SET @cFieldAttr09 = 'O' -- PQTY
                  SET @cFieldAttr10 = 'O' -- MQTY
               END

               IF @cOption = '1'
               BEGIN
                  SET @cOutField01 = '' --@cSKU
                  SET @cOutField02 = '' --@cSKU
                  SET @cOutField03 = '' --SUBSTRING( @cSKUDesc, 1, 20)
                  SET @cOutField04 = '' --SUBSTRING( @cSKUDesc, 21, 40)
                  SET @cOutField05 = '' --@cStyle
                  SET @cOutField06 = '' --@cColor
                  SET @cOutField07 = '' --@cSize
                  SET @cOutField08 = '' --@nPUOM_Div, @cPUOM_Desc, @cMUOM_Desc
                  SET @cOutField09 = CASE WHEN @cPPADefaultPQTY <> '' THEN @cPPADefaultPQTY ELSE '' END --@nPUOM
                  SET @cOutField10 = CASE WHEN @cTaskDefaultQty = '1' THEN @cTaskQty ELSE @cPPADefaultQTY END --@nMUOM
                  SET @cOutField11 = '' --@nPQTY_CHK
                  SET @cOutField12 = '' --@nMQTY_CHK
                  SET @cOutField13 = '' --@nPQTY_PPA
                  SET @cOutField14 = '' --@nMQTY_PPA
                  SET @cOutField15 = '' --@cExtendedInfo
                  --SET @cOutField16 = '' --@cPackQTYIndicator
                  EXEC rdt.rdtSetFocusField @nMobile, 1 --SKU
               END
               ELSE IF @cOption = '9'
               BEGIN
                  SET @cOutField02 = @cSKU
                  SET @cOutField10 = CASE WHEN @cTaskDefaultQty = '1' THEN @cTaskQty ELSE @cPPADefaultQTY END --@nMUOM
               END

               SET @nAfterScn = 816
               SET @nAfterStep = 3
            END -- Inputkey 1
         END -- SCN 6385
      END -- STEP 99
   END -- 838

   GOTO Quit

Quit:
   SELECT * FROM @tReturnData
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_838ExtScn02 TO NSQL
GO


