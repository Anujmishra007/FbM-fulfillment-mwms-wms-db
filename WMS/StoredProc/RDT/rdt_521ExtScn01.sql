SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/**********************************************************************************/
/* Store procedure: rdt_521ExtScn01                                               */
/* Copyright      : Maersk                                                        */
/* Client         : Puma                                                          */
/*                                                                                */
/* Purpose:                                                                       */
/*                                                                                */
/* Date       Rev     Author   Purposes                                           */
/* 2025-03-14 1.0.0   Dennis   FCR-3449                                           */
/**********************************************************************************/

CREATE OR ALTER  PROC [RDT].[rdt_521ExtScn01] (
   @nMobile          INT,           
   @nFunc            INT,           
   @cLangCode        NVARCHAR( 3),  
   @nStep            INT,           
   @nScn             INT,           
   @nInputKey        INT,           
   @cFacility        NVARCHAR( 5),  
   @cStorerKey       NVARCHAR( 15), 
   @tExtScnData      VariableTable READONLY,
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
   @nAction          INT, --0 Jump Screen, 1 Prepare output fields .....
   @nAfterScn        INT OUTPUT, @nAfterStep    INT OUTPUT, 
   @nErrNo           INT            OUTPUT, 
   @cErrMsg          NVARCHAR( 20)  OUTPUT,
   @cUDF01  NVARCHAR( 250) OUTPUT, @cUDF02 NVARCHAR( 250) OUTPUT, @cUDF03 NVARCHAR( 250) OUTPUT,
   @cUDF04  NVARCHAR( 250) OUTPUT, @cUDF05 NVARCHAR( 250) OUTPUT, @cUDF06 NVARCHAR( 250) OUTPUT,
   @cUDF07  NVARCHAR( 250) OUTPUT, @cUDF08 NVARCHAR( 250) OUTPUT, @cUDF09 NVARCHAR( 250) OUTPUT,
   @cUDF10  NVARCHAR( 250) OUTPUT, @cUDF11 NVARCHAR( 250) OUTPUT, @cUDF12 NVARCHAR( 250) OUTPUT,
   @cUDF13  NVARCHAR( 250) OUTPUT, @cUDF14 NVARCHAR( 250) OUTPUT, @cUDF15 NVARCHAR( 250) OUTPUT,
   @cUDF16  NVARCHAR( 250) OUTPUT, @cUDF17 NVARCHAR( 250) OUTPUT, @cUDF18 NVARCHAR( 250) OUTPUT,
   @cUDF19  NVARCHAR( 250) OUTPUT, @cUDF20 NVARCHAR( 250) OUTPUT, @cUDF21 NVARCHAR( 250) OUTPUT,
   @cUDF22  NVARCHAR( 250) OUTPUT, @cUDF23 NVARCHAR( 250) OUTPUT, @cUDF24 NVARCHAR( 250) OUTPUT,
   @cUDF25  NVARCHAR( 250) OUTPUT, @cUDF26 NVARCHAR( 250) OUTPUT, @cUDF27 NVARCHAR( 250) OUTPUT,
   @cUDF28  NVARCHAR( 250) OUTPUT, @cUDF29 NVARCHAR( 250) OUTPUT, 
   @cUDF30 NVARCHAR( MAX)  OUTPUT   --to support max length parameter output
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nMOBRECStep     INT
   DECLARE @nMOBRECScn      INT
   DECLARE @cAllowAllocatedUCCPutaway NVARCHAR( 1),
   @cUCCNo   NVARCHAR( 100),
   @cBarcode NVARCHAR(60),
   @cDecodeSP NVARCHAR( 20),
   @nMultiSKU           INT,  
   @nUCCQTY             INT,  
   @nQTYAlloc           INT,  
   @nTotalRec           INT,  
   @cExtendedValidateSP NVARCHAR( 20),    -- (james02)  
   @cExtendedUpdateSP   NVARCHAR( 20),    -- (james02)  
   @cExtendedInfo       NVARCHAR( 20),    -- (james03)  
   @cExtendedInfoSP     NVARCHAR( 20),    -- (james03)  
   @cPAZone             NVARCHAR( 10),    -- (james03)  
   @cLOT                NVARCHAR( 10),    -- (james04)  
   @nPABookingKey       INT,              -- (james04)  
   @nPAErrNo            INT,              -- (james04)  
   @cPAMatchSuggestLOC  NVARCHAR( 1),     -- (cc02)  
   @cNotDisplayPAZone   NVARCHAR( 1),
   @cFromLOC            NVARCHAR( 10),  
   @cID                 NVARCHAR( 18),  
   @cToLOC              NVARCHAR( 10),  
   @cSuggestedLOC       NVARCHAR( 10),  
   @cPickAndDropLoc     NVARCHAR( 10),  
   @cSKU                NVARCHAR( 20),  
   @cOption             NVARCHAR( 1),  
   @cPrinter            NVARCHAR( 10),  
   @cUserName           NVARCHAR( 18),  
   @cPUOM               NVARCHAR( 10),
   @nMenu               INT
   DECLARE  
   @cSQL                NVARCHAR( MAX),  
   @cSQLParam           NVARCHAR( MAX)  

   SET @cDecodeSP = rdt.RDTGetConfig( @nFunc, 'DecodeSP', @cStorerKey)
   IF @cDecodeSP = '0'
      SET @cDecodeSP = ''
   SET @cExtendedInfoSP = rdt.rdtGetConfig( @nFunc, 'ExtendedInfoSP', @cStorerKey)  
   IF @cExtendedInfoSP = '0'  
      SET @cExtendedInfoSP = ''  
   SET @cExtendedUpdateSP = rdt.rdtGetConfig( @nFunc, 'ExtendedUpdateSP', @cStorerKey)  
   IF @cExtendedUpdateSP = '0'  
      SET @cExtendedUpdateSP = ''  
   SET @cExtendedValidateSP = rdt.rdtGetConfig( @nFunc, 'ExtendedValidateSP', @cStorerKey)  
   IF @cExtendedValidateSP = '0'  
      SET @cExtendedValidateSP = ''  

   SELECT @nMOBRECStep      = [Step]
      ,@nMOBRECScn          = [Scn]
      ,@cPrinter            = Printer
      ,@cUserName           = UserName
      ,@nMenu               = Menu
      ,@cAllowAllocatedUCCPutaway = C_STRING1
   FROM rdt.rdtMobRec WITH (NOLOCK)  
   WHERE Mobile = @nMobile  

   IF @nMOBRECStep = 0
   BEGIN
      SET @cAllowAllocatedUCCPutaway = rdt.RDTGetConfig( @nFunc, 'AllowAllocatedUCCPutaway', @cStorerKey)  
      IF @cAllowAllocatedUCCPutaway = '1'
      BEGIN
         SET @nAfterStep = 99
         GOTO QUIT
      END
   END
   IF @nMOBRECStep = 99
   BEGIN
      IF @nMOBRECScn = 926 --UCC Screen
      BEGIN
         IF @nInputKey = 1 -- Yes or Send  
         BEGIN  
            -- Screen mapping  
            SET @cUCCNo = @cInField01  

            SET @cUCCNo = RTRIM(LTRIM(ISNULL(@cUCCNo,'')))

            IF @cUCCNo = ''  
            BEGIN  
               SET @nErrNo = 50011  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 'UCC req'  
               GOTO Step_1_Fail  
            END  
      
            SET @cBarcode = @cUCCNo

            -- Decode
            -- Standard decode
            IF @cDecodeSP = '1'
            BEGIN
               EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cBarcode,
                     @cUCCNo  = @cUCCNo  OUTPUT,
                     @nErrNo  = @nErrNo   OUTPUT,
                     @cErrMsg = @cErrMsg  OUTPUT,
                     @cType   = 'UCCno'
                  IF @nErrNo <> 0
                     GOTO Step_1_Fail
            END

            IF NOT EXISTS (SELECT 1 FROM dbo.UCC WITH (NOLOCK)  
                           WHERE StorerKey = @cStorerKey  
                           AND   UCCNo = @cUCCNo  
                           AND   (Status = '1' OR Status = '3')
                           )
            BEGIN  
               SET @nErrNo = 50012  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 'INVALID UCC'  
               GOTO Step_1_Fail  
            END  
      
            -- Get LOC, ID  
            SET @cFromLOC = ''  
            SET @cID = ''  
            SELECT TOP 1  
               @cFromLOC = LOC,  
               @cID = ID,  
               @cSKU = SKU,  
               @nUCCQTY = QTY,  
               @cLOT = LOT  
            FROM dbo.UCC WITH (NOLOCK)  
            WHERE StorerKey = @cStorerKey  
            AND   UCCNo = @cUCCNo  
            AND   (Status = '1' OR Status = '3') 
            
            SET @nTotalRec = 0  
            IF NOT EXISTS (SELECT 1 FROM dbo.PICKDETAIL (NOLOCK) WHERE StorerKey = @cStorerKey AND DropID = @cUCCNo)
               SET @cAllowAllocatedUCCPutaway = '0'

            IF @cAllowAllocatedUCCPutaway = '1'
            BEGIN
               SELECT  
                  @nTotalRec = COUNT( DISTINCT UCC.SKU) -- Total no of SKU  
               FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)  
               JOIN dbo.UCC UCC WITH (NOLOCK) ON (LLI.StorerKey = UCC.StorerKey AND LLI.SKU = UCC.SKU AND LLI.LOT = UCC.LOT AND LLI.LOC = UCC.LOC AND LLI.ID = UCC.ID)  
               WHERE LLI.StorerKey = @cStorerKey  
               AND   (LLI.QTY - LLI.QTYPicked - (CASE WHEN LLI.QtyReplen < 0 THEN 0 ELSE LLI.QtyReplen END)) > 0  
               AND   UCC.UCCNo = @cUCCNo  
               AND   (UCC.Status = '1' OR UCC.Status = '3') 
         
               IF @nTotalRec = 0  
               BEGIN  
                  SET @nErrNo = 85605  
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'No record'  
                  GOTO Step_1_Fail  
               END
               -- Check if UCC multi SKU  
               SET @nMultiSKU = 0  
               SELECT @nMultiSKU = COUNT( DISTINCT SKU)  
               FROM dbo.UCC WITH (NOLOCK)  
               WHERE StorerKey = @cStorerKey  
               AND   UCCNo = @cUCCNo  
               AND   (Status = '1' OR Status = '3') 

               SELECT @nUCCQTY = ISNULL( SUM( Qty), 0)  
               FROM dbo.UCC WITH (NOLOCK)  
               WHERE StorerKey = @cStorerKey  
               AND   UCCNo = @cUCCNo  
               AND   (Status = '1' OR Status = '3')
            END
            ELSE
            BEGIN
               SELECT  
                  @nTotalRec = COUNT( DISTINCT UCC.SKU), -- Total no of SKU  
                  @nQTYAlloc = IsNULL( SUM( QTYAllocated + (CASE WHEN LLI.QtyReplen < 0 THEN 0 ELSE LLI.QtyReplen END)), 0)  -- SHONG 26022013  
               FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)  
               JOIN dbo.UCC UCC WITH (NOLOCK) ON (LLI.StorerKey = UCC.StorerKey AND LLI.SKU = UCC.SKU AND LLI.LOT = UCC.LOT AND LLI.LOC = UCC.LOC AND LLI.ID = UCC.ID)  
               WHERE LLI.StorerKey = @cStorerKey  
               AND   (LLI.QTY - LLI.QTYAllocated - LLI.QTYPicked - (CASE WHEN LLI.QtyReplen < 0 THEN 0 ELSE LLI.QtyReplen END)) > 0  
               AND   UCC.UCCNo = @cUCCNo  
               AND   UCC.Status = '1'  
         
               IF @nTotalRec = 0  
               BEGIN  
                  SET @nErrNo = 85605  
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'No record'  
                  GOTO Step_1_Fail  
               END  
         
               -- Validate QTY allocated  
               IF @nQTYAlloc > 0  
               BEGIN  
                  SET @nErrNo = 85606  
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'QTY allocated'  
                  GOTO Step_1_Fail  
               END  
               
               -- Check if UCC multi SKU  
               SET @nMultiSKU = 0  
               SELECT @nMultiSKU = COUNT( DISTINCT SKU)  
               FROM dbo.UCC WITH (NOLOCK)  
               WHERE StorerKey = @cStorerKey  
               AND   UCCNo = @cUCCNo  
               AND   (Status = '1') 

               SELECT @nUCCQTY = ISNULL( SUM( Qty), 0)  
               FROM dbo.UCC WITH (NOLOCK)  
               WHERE StorerKey = @cStorerKey  
               AND   UCCNo = @cUCCNo  
               AND   Status = '1'  
            END

            IF @nMultiSKU > 1  
            BEGIN  
               -- If it is multi sku, check if it is allow to putaway with mix sku ucc  
               IF rdt.RDTGetConfig( @nFunc, 'PutawayMixSKUUCC', @cStorerKey) = 1  
               BEGIN  
                  -- Check if we have inventory to move  
      
                  SET @cOutField01 = ''  
      
                  -- Go to next screen  
                  SET @nAfterScn = 929 
                  SET @nAfterStep = 4 
      
                  GOTO Quit  
               END  
               ELSE  -- config not turn on then error  
               BEGIN  
                  SET @nErrNo = 50014  
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- 'MIX SKU UCC'  
                  GOTO Step_1_Fail  
               END  
            END  
      
            IF @cExtendedValidateSP <> ''  
            BEGIN  
               IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')  
               BEGIN  
                  SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +  
                     ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT'  
                  SET @cSQLParam =  
                     '@nMobile         INT,       '     +  
                     '@nFunc           INT,       '     +  
                     '@cLangCode       NVARCHAR( 3),  ' +  
                     '@nStep           INT,       '     +  
                     '@nInputKey       INT,       '     +  
                     '@cStorerKey      NVARCHAR( 15), ' +  
                     '@cUCCNo          NVARCHAR( 20), ' +  
                     '@cSuggestedLOC   NVARCHAR( 10), ' +  
                     '@cToLOC          NVARCHAR( 10), ' +  
                     '@nErrNo          INT OUTPUT,    ' +  
                     '@cErrMsg         NVARCHAR( 20) OUTPUT'  
      
                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
                     @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT  
      
                  IF @nErrNo <> 0  
                  BEGIN  
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  
                     GOTO Step_1_Fail  
                  END  
               END  
            END  
      
            -- Get suggest LOC  
            SET @nPAErrNo = 0  
            SET @nPABookingKey = 0  
            EXEC rdt.rdt_UCCPutaway_GetSuggestLOC @nMobile, @nFunc, @cLangCode, @cUserName, @cStorerKey, @cFacility  
               ,@cFromLOC  
               ,@cID  
               ,@cLOT  
               ,@cUCCNo  
               ,@cSKU  
               ,@nUCCQTY  
               ,@cSuggestedLOC   OUTPUT  
               ,@cPickAndDropLoc OUTPUT  
               ,@nPABookingKey   OUTPUT  
               ,@nPAErrNo  OUTPUT  
               ,@cErrMsg         OUTPUT  
            IF @nPAErrNo <> 0 AND  
               @nPAErrNo <> -1 -- No suggested LOC  
            BEGIN  
               SET @nErrNo = @nPAErrNo  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  
               GOTO Step_1_Fail  
            END  
      
            -- Check any suggested LOC  
            IF ISNULL( @cSuggestedLOC, '') = ''  
            BEGIN  
               SET @nErrNo = 50016  
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- NoSuitableLOC  
               -- GOTO Step_1_Fail  
            END  
            ELSE  
            BEGIN  
               SELECT @cPAZone = PutAwayZone  
               FROM dbo.SKU WITH (NOLOCK)  
               WHERE StorerKey = @cStorerKey  
                  AND SKU = @cSKU  
      
               -- Extended update -- (ChewKP01)  
               IF @cExtendedUpdateSP <> ''  
               BEGIN  
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')  
                  BEGIN  
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +  
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT'  
                     SET @cSQLParam =  
                        '@nMobile         INT,       '     +  
                        '@nFunc           INT,       '     +  
                        '@cLangCode       NVARCHAR( 3),  ' +  
                        '@nStep           INT,       '     +  
                        '@nInputKey       INT,       '     +  
                        '@cStorerKey      NVARCHAR( 15), ' +  
                        '@cUCCNo          NVARCHAR( 20), ' +  
                        '@cSuggestedLOC   NVARCHAR( 10), ' +  
                        '@cToLOC          NVARCHAR( 10), ' +  
                        '@nErrNo          INT OUTPUT,    ' +  
                        '@cErrMsg         NVARCHAR( 20) OUTPUT'  
      
                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT  
      
                     IF @nErrNo <> 0  
                     BEGIN  
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  
                        GOTO Step_1_Fail  
                     END  
                  END  
               END  
            END  
      
            -- Extended info  
            SET @cExtendedInfo = ''  
            IF @cExtendedInfoSP <> ''  
            BEGIN  
               IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedInfoSP AND type = 'P')  
               BEGIN  
                  SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +  
                     ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC, ' +  
                     ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'  
                  SET @cSQLParam =  
                     '@nMobile         INT,           ' +  
                     '@nFunc           INT,           ' +  
                     '@cLangCode       NVARCHAR( 3),  ' +  
                     '@nStep           INT,           ' +  
                     '@nInputKey       INT,           ' +  
                     '@cStorerKey      NVARCHAR( 15), ' +  
                     '@cUCCNo          NVARCHAR( 20), ' +  
                     '@cSuggestedLOC   NVARCHAR( 10), ' +  
                     '@cToLOC          NVARCHAR( 10), ' +  
                     '@cExtendedInfo   NVARCHAR( 20) OUTPUT, ' +  
                     '@nErrNo          INT           OUTPUT, ' +  
                     '@cErrMsg         NVARCHAR( 20) OUTPUT  '  
      
                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam,  
                     @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cUCCNo, @cSuggestedLOC, @cToLOC,  
                     @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT  
      
                  IF @nErrNo <> 0  
                  BEGIN  
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  
                     GOTO Step_1_Fail  
                  END  
               END  
            END  
      
            SET @cOutField01 = @cUCCNo  
            SET @cOutField02 = @cFromLOC  
            SET @cOutField03 = @cSuggestedLOC  
            SET @cOutField04 = ''  
            SET @cOutField05 = CASE WHEN @cNotDisplayPAZone = '1' THEN '' ELSE 'PA ZONE: ' + @cPAZone END-- (james03)/(james05)  
            SET @cOutField06 = @cExtendedInfo   -- (james03)  
      
            -- Go to next screen  
            SET @nAfterScn = 927
            SET @nAfterStep = 2 

            SET @cUDF01 = @cUCCNo
            SET @cUDF02 = @cFromLOC
            SET @cUDF03 = @cID 
            SET @cUDF04 = @cSKU 
            SET @cUDF05 = CAST(@nUCCQTY AS NVARCHAR)
            SET @cUDF06 = @cLOT
            SET @cUDF07 = @cSuggestedLOC
         END  
      
         IF @nInputKey = 0 -- Esc or No  
         BEGIN  
            -- (Vicky06) EventLog - Sign Out Function  
            EXEC RDT.rdt_STD_EventLog  
            @cActionType = '9', -- Sign Out function  
            @cUserID     = @cUserName,  
            @nMobileNo   = @nMobile,  
            @nFunctionID = @nFunc,  
            @cFacility   = @cFacility,  
            @cStorerkey  = @cStorerkey  
      
            -- Back to menu  
            SET @nFunc = @nMenu  
            SET @nAfterScn  = @nMenu  
            SET @nAfterStep = 0  
         END  
         GOTO Quit  
      
         Step_1_Fail:  
         BEGIN  
            SET @cOutField01 = ''  
            SET @cUCCNo = ''  
         END  
      END
   END
   IF @nMOBRECStep = 2
   BEGIN
      IF @cAllowAllocatedUCCPutaway = '1' AND @nInputKey = 0
      BEGIN
         SET @nAfterStep = 99
         SET @nAfterScn = 926
         GOTO QUIT
      END
   END
   IF @nMOBRECStep = 3
   BEGIN
      IF @cAllowAllocatedUCCPutaway = '1'
      BEGIN
         SET @nAfterStep = 99
         SET @nAfterScn = 926
         GOTO QUIT
      END
   END
   GOTO Quit

Quit:  
BEGIN  
   UPDATE RDTMOBREC WITH (ROWLOCK) SET  
      C_STRING1 = @cAllowAllocatedUCCPutaway
   WHERE Mobile = @nMobile  
END
END

SET QUOTED_IDENTIFIER OFF 
GO	
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON rdt.rdt_521ExtScn01 TO NSQL
GO
