
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/***********************************************************************************/  
/* Store procedure: rdt_1620ExtScn01                                               */  
/*                                                                                 */  
/* Purpose: For AMZ DGL                                                            */
/*                                                                                 */
/* Modifications log:                                                              */  
/*                                                                                 */  
/* Date       Rev    Author     Purposes                                           */  
/* 2025-05-12 1.0.0  Dennis     FCR-3744. Created                                  */ 
/***********************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1620ExtScn01] (
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
      @cUserName              NVARCHAR( 18),
      @nMenu                  INT,
      @bDebugFlag             BINARY = 0,
      @nMOBRECStep            INT,
      @nMOBRECScn             INT,
      @cExtendedScnSP         NVARCHAR( 20),
      
      --config variable
      @nRowCount              INT,
      @cExtendedUpdateSP      NVARCHAR( 20),
      @cExtendedValidateSP    NVARCHAR( 20),
      @cExtendedInfoSP        NVARCHAR( 20),
      @cSQL                   NVARCHAR(MAX),         
      @cSQLParam              NVARCHAR(MAX),
      @cDropID                NVARCHAR( 20),
      -- 1620 Original Step1 variables
      @cMethod                         NVARCHAR( 1),
      @cPickZone                       NVARCHAR( 10),
      @cCartID                         NVARCHAR( 10),
      @cResult01                       NVARCHAR( 20),            
      @cResult02                       NVARCHAR( 20),            
      @cResult03                       NVARCHAR( 20),            
      @cResult04                       NVARCHAR( 20),            
      @cResult05                       NVARCHAR( 20),
      @cContinuePickOnAssignedCart     NVARCHAR( 1),
      @nStep_ContTask                  INT,  
      @nScn_ContTask                   INT,
      @cCartonID                       NVARCHAR( 20),
      @cCartPickMethod                 NVARCHAR( 40),
      @nCartLimit                      INT,
      @cPickNoMixWave                  NVARCHAR( 1),
      @cPickWaveKey                    NVARCHAR( 10),
      @nTranCount                      INT,
      @cGroupKey                       NVARCHAR( 10),
      @cWaveKey                        NVARCHAR( 10),
      @cLockTaskKey                    NVARCHAR( 10),
      @nNextPage                       INT,
      @cSKU                            NVARCHAR( 20),
      @cFromLoc                        NVARCHAR( 10),
      @nQTY                            INT=0,
      @cTaskDetailKey                  NVARCHAR( 10),
      @cOption                         NVARCHAR( 1),
      @cToLOC                          NVARCHAR( 10),
      @cTaskDetailCaseID               NVARCHAR( 20),
      @tExtValidate                    VariableTable,
      @b_success                       INT,
      @cLoadKey       NVARCHAR( 10),
      @cOrderKey      NVARCHAR( 10),

      -- 1620 old Step 2 variables
      @nCartonScanned      INT = 0,
      @nCartonCnt          INT = 0,
      @cSuggFromLOC        NVARCHAR( 10),
      @cSuggCartonID       NVARCHAR( 20),
      @cSuggToteId         NVARCHAR( 20),
      @cSuggSKU            NVARCHAR( 20),
      @nSuggQTY            INT = 0,
      @tGetTask            VariableTable,
      @cPickConfirmStatus  NVARCHAR( 1),
      @cCartonType         NVARCHAR( 10),
      @cPickMethod         NVARCHAR( 10),
      @cLockCaseID         NVARCHAR( 20),
      @cTotalToteQty       NVARCHAR( 5),
      @cPutAwayZone        NVARCHAR( 10),
      @nAssignedToteQty    INT,
      @cLoadDefaultPickMethod NVARCHAR( 1),
      @nMultiStorer     INT,
      @cPickSlipNo   NVARCHAR( 18)

   DECLARE @tTaskDetailKeyList TABLE
   (
      id             INT IDENTITY(1,1),
      TaskDetailKey  NVARCHAR( 10)
   )
   
   -- Set Constant value
   SET @nErrNo = 0
   SET @cErrMsg = ''

   SET @cExtendedUpdateSP = rdt.rdtGetConfig( @nFunc, 'ExtendedUpdateSP', @cStorerkey)
   IF @cExtendedUpdateSP = '0'
      SET @cExtendedUpdateSP = ''
   SET @cExtendedValidateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedValidateSP', @cStorerkey)
   IF @cExtendedValidateSP = '0'
      SET @cExtendedValidateSP = ''
   SET @cExtendedInfoSP = rdt.RDTGetConfig( @nFunc, 'ExtendedInfoSP', @cStorerkey)
   IF @cExtendedInfoSP = '0'
      SET @cExtendedInfoSP = ''

   SELECT @nMOBRECStep                 = Step,
         @nMOBRECScn                   = Scn,
         @nMenu                        = Menu,
         @cUserName                    = UserName,
         @cSKU                         = V_SKU,
         @cFromLoc                     = V_Loc,
         @cOrderKey                    = V_OrderKey,
         @cLoadKey                     = V_LoadKey,
         @nMultiStorer                 = V_Integer9,
         @cPutAwayZone                 = V_String10,
         @cPickZone                    = V_String11,
         @cLoadDefaultPickMethod       = V_String36
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   IF @bDebugFlag = 1
   BEGIN
      SELECT 'Before Main Logic', @nMOBRECScn AS MobScn, @nMOBRECStep AS MobStep, @nMenu AS Menu, @cUserName AS UserName
      SELECT * FROM @tExtScnData
   END

   -- Get data from the table
   SELECT @cOption = Value FROM @tExtScnData WHERE Variable = '@cOption'
   SELECT @cDropID = Value FROM @tExtScnData WHERE Variable = '@cDropID'

   IF @nFunc = 1620
   BEGIN
      --Next Scn is 7
      IF @nStep = 7 AND @nScn = 1876
      BEGIN
         IF @cLoadDefaultPickMethod = 'C'
         BEGIN
            SELECT TOP 1
               @cOutField09 = CASE WHEN PD.UOM = '2' THEN PD.DROPID ELSE '' END
         FROM RDT.RDTPickLock rpl WITH (NOLOCK) 
         INNER JOIN PICKDETAIL PD WITH (NOLOCK) ON PD.LOT = rpl.LOT AND PD.LOC = rpl.LOC AND PD.SKU = rpl.SKU AND RPL.ORDERKEY = PD.ORDERKEY
         WHERE rpl.StorerKey = @cStorerKey
            AND rpl.LoadKey = @cLoadKey
            AND rpl.Status = '1'
            AND rpl.AddWho = @cUserName
            AND (( ISNULL( @cPutAwayZone, '') = 'ALL') OR ( rpl.PutAwayZone = @cPutAwayZone))
            AND (( ISNULL( @cPickZone, '') = '') OR ( rpl.PickZone = @cPickZone))
            AND rpl.SKU = @cSKU
            AND rpl.PickQty = 0
         END
         ELSE
         BEGIN
            SELECT TOP 1
               @cOutField09 = CASE WHEN PD.UOM = '2' THEN PD.DROPID ELSE '' END
            FROM RDT.RDTPickLock rpl WITH (NOLOCK) 
            INNER JOIN PICKDETAIL PD WITH (NOLOCK) ON PD.LOT = rpl.LOT AND PD.LOC = rpl.LOC AND PD.SKU = rpl.SKU AND RPL.ORDERKEY = PD.ORDERKEY
            WHERE rpl.StorerKey = @cStorerKey
               AND rpl.OrderKey = @cOrderKey
               AND rpl.Status = '1'
               AND PD.Status = '0'
               AND rpl.AddWho = @cUserName
               AND rpl.SKU = @cSKU
               AND (( @nMultiStorer = 1) OR ( rpl.StorerKey = @cStorerKey))
         END

         
      END
      IF @nStep = 8 AND @nScn = 1877
      BEGIN
         IF @cLoadDefaultPickMethod = 'C'
         BEGIN
            SELECT TOP 1
               @cOutField04 = CASE WHEN PD.UOM = '2' THEN @cSKU ELSE '' END,
               @cOutField13 = CASE WHEN PD.UOM = '2' THEN PD.QTY ELSE NULL END
         FROM RDT.RDTPickLock rpl WITH (NOLOCK) 
         INNER JOIN PICKDETAIL PD WITH (NOLOCK) ON PD.LOT = rpl.LOT AND PD.LOC = rpl.LOC AND PD.SKU = rpl.SKU AND RPL.ORDERKEY = PD.ORDERKEY
         WHERE RPL.StorerKey = @cStorerKey
            AND RPL.LoadKey = @cLoadKey
            AND RPL.Status = '1'
            AND RPL.AddWho = @cUserName
            AND (( ISNULL( @cPutAwayZone, '') = 'ALL') OR ( RPL.PutAwayZone = @cPutAwayZone))
            AND (( ISNULL( @cPickZone, '') = '') OR ( RPL.PickZone = @cPickZone))
            AND RPL.SKU = @cSKU
            AND RPL.PickQty = 0
            AND ISNULL(RTRIM(RPL.DropID),'') = @cDropID
         END
         ELSE
         BEGIN
            SELECT TOP 1
               @cOutField04 = CASE WHEN PD.UOM = '2' THEN @cSKU ELSE '' END,
               @cOutField13 = CASE WHEN PD.UOM = '2' THEN PD.QTY ELSE NULL END
            FROM RDT.RDTPickLock rpl WITH (NOLOCK) 
            INNER JOIN PICKDETAIL PD WITH (NOLOCK) ON PD.LOT = rpl.LOT AND PD.LOC = rpl.LOC AND PD.SKU = rpl.SKU AND RPL.ORDERKEY = PD.ORDERKEY
            WHERE RPL.OrderKey = @cOrderKey
               AND (( @nMultiStorer = 1 AND RPL.StorerKey = @cStorerKey) OR ( @nMultiStorer <> 1 AND RPL.StorerKey = @cStorerKey))
               AND RPL.Status = '1'
               AND RPL.AddWho = @cUserName
               AND ISNULL(RTRIM(RPL.DropID),'') = @cDropID
               AND RPL.PickQty = '0'
         END
      END
   END -- 1620

   GOTO Quit

Quit:

   
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1620ExtScn01 TO NSQL
GO


