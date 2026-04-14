
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************************************/
/* Store procedure: rdt_514ExtScn01                                                             */
/* Copyright      : Maersk                                                                      */
/* Customer       : Granite Levis                                                               */
/*                                                                                              */
/*                                                                                              */
/* Date       Rev    Author   Purposes                                                          */
/* 2026-04-08 1.0    NLT013   FCR-11631 Create                                                  */
/************************************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_514ExtScn01] (
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
   @nAction          INT,
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
   @cUDF30  NVARCHAR( MAX)  OUTPUT   --to support max length parameter output
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @nMenu      INT,
      @cSQL         NVARCHAR( MAX), 
      @cSQLParam    NVARCHAR( MAX), 
      @cUCC         NVARCHAR( 20),
      @cChkFacility NVARCHAR( 5),
      @nRowRef      INT,
      @i            INT,
      @curUCC       CURSOR

-- RDT.RDTMobRec variable
   DECLARE
      
      @cSKU         NVARCHAR( 20),
      @cSKUDescr    NVARCHAR( 60),
      @cBarcode     NVARCHAR( MAX),
      @cBarcodeUCC  NVARCHAR( 60),
      @cUCCNo       NVARCHAR( 20),

      @cUCC1      NVARCHAR( 20),
      @cUCC2      NVARCHAR( 20),
      @cUCC3      NVARCHAR( 20),
      @cUCC4      NVARCHAR( 20),
      @cUCC5      NVARCHAR( 20),
      @cUCC6      NVARCHAR( 20),
      @cUCC7      NVARCHAR( 20),
      @cUCC8      NVARCHAR( 20),
      @cUCC9      NVARCHAR( 20),

      @cToLOC       NVARCHAR( 10),
      @cToID        NVARCHAR( 18),
      @cFromLOC     NVARCHAR( 10),
      @cFromID      NVARCHAR( 18),
      @cUCCStatus NVARCHAR( 10),

      @cExtendedValidateSP NVARCHAR( 20), 
      @cExtendedUpdateSP   NVARCHAR( 20),
      @cLOCLookUP          NVARCHAR( 20),
      @c2DBarcode          NVARCHAR( 1),
      @cDecodeSP           NVARCHAR( 20),
      @cExtScnSP           NVARCHAR( 20),

      @nTotalUCC  INT,
      @nPage      INT,
      @nUCCOnPage INT,
      @nCurrentScn      INT,
      @nCurrentStep     INT

   DECLARE
      @nStep_Start            INT, 
      @nStep_UCC              INT,  @nScn_UCC              INT,
      @nStep_ToLOC            INT,  @nScn_ToLOC            INT,
      @nStep_Message          INT,  @nScn_Message          INT,
      @nStep_FromLOC          INT,  @nScn_FromLOC          INT,
      @nStep_2DUCC            INT,  @nScn_2DUCC            INT

   SELECT
      @nStep_Start            = 0, 
      @nStep_UCC              = 1,  @nScn_UCC            = 808,
      @nStep_ToLOC            = 2,  @nScn_ToLOC          = 809,
      @nStep_Message          = 3,  @nScn_Message        = 810,
      @nStep_FromLOC          = 4,  @nScn_FromLOC        = 811,
      @nStep_2DUCC            = 5,  @nScn_2DUCC          = 812

   SELECT
      @nMenu      = Menu,
      @nCurrentScn = Scn,
      @nCurrentStep = Step,
      @cSKU       = V_SKU,
      @cSKUDescr  = V_SKUDescr,
      @cBarcode   = V_Barcode,

      @cUCC1      = V_String1,
      @cUCC2      = V_String2,
      @cUCC3      = V_String3,
      @cUCC4      = V_String4,
      @cUCC5      = V_String5,
      @cUCC6      = V_String6,
      @cUCC7      = V_String7,
      @cUCC8      = V_String8,
      @cUCC9      = V_String9,

      @cToLOC     = V_String10,
      @cToID      = V_String11,
      @cFromLOC   = V_String12,
      @cFromID    = V_String15,
      @cUCCStatus = V_String16,
      @cUDF01     = V_String17,

      @cExtendedValidateSP = V_String20,
      @cExtendedUpdateSP   = V_String21,
      @c2DBarcode          = V_String22,
      @cLOCLookUP          = V_String23,
      @cDecodeSP           = V_String24,
      @cExtScnSP           = V_String25,

      @nTotalUCC  = V_Integer1,
      @nPage      = V_Integer2,
      @nUCCOnPage = V_Integer3

   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   SET @cUDF02 = ''

   IF @nCurrentStep = 99
   BEGIN
      IF @nCurrentScn = @nScn_UCC
      BEGIN
         SET @cUDF02 = 'NO UPD RDTMOBREC'
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- Retain key-in value
            SET @cOutField01 = @cInField01
            SET @cOutField02 = @cInField02
            SET @cOutField03 = @cInField03
            SET @cOutField04 = @cInField04
            SET @cOutField05 = @cInField05
            SET @cOutField06 = @cInField06
            SET @cOutField07 = @cInField07
            SET @cOutField08 = @cInField08
            SET @cOutField09 = @cInField09

            -- Validate blank
            IF @cInField01 = '' AND
               @cInField02 = '' AND
               @cInField03 = '' AND
               @cInField04 = '' AND
               @cInField05 = '' AND
               @cInField06 = '' AND
               @cInField07 = '' AND
               @cInField08 = '' AND
               @cInField09 = ''
            BEGIN
               -- Nothing in log
               IF NOT EXISTS( SELECT TOP 1 1 FROM rdt.rdtMoveUCCLog WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND AddWho = SUSER_SNAME())
               BEGIN
                  SET @nErrNo = 263451
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UCC needed'
                  EXEC rdt.rdtSetFocusField @nMobile, 1
                  GOTO SCN_UCC_FAIL
               END
            END
            
               -- Decode
               -- Standard decode
            IF @cDecodeSP = '1'
            BEGIN
               SET @i = 1
               WHILE @i < 10
               BEGIN
                  IF @i = 1 SELECT @cBarcodeUCC = @cInField01,@cUCC = @cUCC1
                  IF @i = 2 SELECT @cBarcodeUCC = @cInField02,@cUCC = @cUCC2
                  IF @i = 3 SELECT @cBarcodeUCC = @cInField03,@cUCC = @cUCC3
                  IF @i = 4 SELECT @cBarcodeUCC = @cInField04,@cUCC = @cUCC4
                  IF @i = 5 SELECT @cBarcodeUCC = @cInField05,@cUCC = @cUCC5
                  IF @i = 6 SELECT @cBarcodeUCC = @cInField06,@cUCC = @cUCC6
                  IF @i = 7 SELECT @cBarcodeUCC = @cInField07,@cUCC = @cUCC7
                  IF @i = 8 SELECT @cBarcodeUCC = @cInField08,@cUCC = @cUCC8
                  IF @i = 9 SELECT @cBarcodeUCC = @cInField09,@cUCC = @cUCC9

                  IF @cBarcodeUCC <> '' AND @cBarcodeUCC <> @cUCC
                  BEGIN
                     SET @cUCCNo = ''
                     EXEC rdt.rdt_Decode @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, @cBarcodeUCC,
                              @cUCCNo  = @cUCCNo  OUTPUT,
                              @nErrNo  = @nErrNo   OUTPUT,
                              @cErrMsg = @cErrMsg  OUTPUT,
                              @cType   = 'UCCno'
                     IF @nErrNo <> 0
                        GOTO SCN_UCC_FAIL

                     IF @i = 1 SELECT  @cInField01 = @cUCCNo ,@cOutField01 = @cUCCNo
                     IF @i = 2 SELECT  @cInField02 = @cUCCNo ,@cOutField02 = @cUCCNo
                     IF @i = 3 SELECT  @cInField03 = @cUCCNo ,@cOutField03 = @cUCCNo
                     IF @i = 4 SELECT  @cInField04 = @cUCCNo ,@cOutField04 = @cUCCNo
                     IF @i = 5 SELECT  @cInField05 = @cUCCNo ,@cOutField05 = @cUCCNo
                     IF @i = 6 SELECT  @cInField06 = @cUCCNo ,@cOutField06 = @cUCCNo
                     IF @i = 7 SELECT  @cInField07 = @cUCCNo ,@cOutField07 = @cUCCNo
                     IF @i = 8 SELECT  @cInField08 = @cUCCNo ,@cOutField08 = @cUCCNo
                     IF @i = 9 SELECT  @cInField09 = @cUCCNo ,@cOutField09 = @cUCCNo
                  END
                  SET @i = @i + 1
               END
            END

            -- Validate if anything changed
            IF @cUCC1 <> @cInField01 OR
               @cUCC2 <> @cInField02 OR
               @cUCC3 <> @cInField03 OR
               @cUCC4 <> @cInField04 OR
               @cUCC5 <> @cInField05 OR
               @cUCC6 <> @cInField06 OR
               @cUCC7 <> @cInField07 OR
               @cUCC8 <> @cInField08 OR
               @cUCC9 <> @cInField09
            -- There are changes, remain in current screen
            BEGIN
               DECLARE @cInField NVARCHAR( 20)
               DECLARE @nLastValidatedUCC NVARCHAR( 20)
               SET @nLastValidatedUCC = ''
               
               -- Check newly scanned UCC. Validated UCC will be saved to respective @cUCC variable
               SET @i = 1
               WHILE @i < 10
               BEGIN
                  IF @i = 1 SELECT @cInField = @cInField01, @cUCC = @cUCC1
                  IF @i = 2 SELECT @cInField = @cInField02, @cUCC = @cUCC2
                  IF @i = 3 SELECT @cInField = @cInField03, @cUCC = @cUCC3
                  IF @i = 4 SELECT @cInField = @cInField04, @cUCC = @cUCC4
                  IF @i = 5 SELECT @cInField = @cInField05, @cUCC = @cUCC5
                  IF @i = 6 SELECT @cInField = @cInField06, @cUCC = @cUCC6
                  IF @i = 7 SELECT @cInField = @cInField07, @cUCC = @cUCC7
                  IF @i = 8 SELECT @cInField = @cInField08, @cUCC = @cUCC8
                  IF @i = 9 SELECT @cInField = @cInField09, @cUCC = @cUCC9

                  -- Value changed
                  IF @cInField <> @cUCC
                  BEGIN
                     -- Consist a new value
                     IF @cInField <> ''
                     BEGIN
                        IF @cFromLOC = ''
                           SET @cFromLOC = NULL

                        -- Validate UCC
                        EXEC RDT.rdtIsValidUCC @cLangCode, @nErrNo OUTPUT, @cErrMsg OUTPUT, 
                           @cInField, -- UCC
                           @cStorerKey, 
                           @cUCCStatus, -- 1=Received, 3=Alloc
                           @cChkLOC = @cFromLOC

                        IF @nErrNo = 0
                        BEGIN
                           -- Check UCC scanned
                           IF EXISTS( SELECT 1
                              FROM rdt.rdtMoveUCCLog WITH (NOLOCK)
                              WHERE StorerKey = @cStorerKey
                                 AND UCCNo = @cInField
                                 AND AddWho = SUSER_SNAME())
                           BEGIN
                              SET @nErrNo = 263452
                              SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'UCC DoubleScan'
                           END
                        END
                        
                        IF @nErrNo = 0
                        BEGIN
                           -- Extended validate
                           IF @cExtendedValidateSP <> ''
                           BEGIN
                              IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedValidateSP AND type = 'P')
                              BEGIN
                                 SET @cSQL = 'EXEC rdt.' + RTRIM(@cExtendedValidateSP) +
                                    ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cToID, @cToLoc, @cFromLoc, @cFromID, @cUCC, ' + 
                                    ' @cUCC1, @cUCC2, @cUCC3, @cUCC4, @cUCC5, @cUCC6, @cUCC7, @cUCC8, @cUCC9, ' + 
                                    ' @nErrNo OUTPUT, @cErrMsg OUTPUT '
                                 SET @cSQLParam =
                                    '@nMobile        INT, ' +
                                    '@nFunc          INT, ' +
                                    '@cLangCode      NVARCHAR( 3),  ' +
                                    '@nStep          INT, ' +
                                    '@nInputKey      INT, ' + 
                                    '@cStorerKey     NVARCHAR( 15), ' +
                                    '@cToID          NVARCHAR( 18), ' +
                                    '@cToLoc         NVARCHAR( 10), ' +
                                    '@cFromLoc       NVARCHAR( 10), ' +
                                    '@cFromID        NVARCHAR( 18), ' +
                                    '@cUCC           NVARCHAR( 20), ' +
                                    '@cUCC1          NVARCHAR( 20), ' +
                                    '@cUCC2          NVARCHAR( 20), ' +
                                    '@cUCC3          NVARCHAR( 20), ' +
                                    '@cUCC4          NVARCHAR( 20), ' +
                                    '@cUCC5          NVARCHAR( 20), ' +
                                    '@cUCC6          NVARCHAR( 20), ' +
                                    '@cUCC7          NVARCHAR( 20), ' +
                                    '@cUCC8          NVARCHAR( 20), ' +
                                    '@cUCC9          NVARCHAR( 20), ' +
                                    '@nErrNo         INT           OUTPUT, ' + 
                                    '@cErrMsg        NVARCHAR( 20) OUTPUT'
                              
                                 EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                                    @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cToID, @cToLoc, @cFromLoc, @cFromID, @cInField, 
                                    '', '', '', '', '', '', '', '', '', 
                                    @nErrNo OUTPUT, @cErrMsg OUTPUT 
                              END
                           END
                        END
                        
                        IF @nErrNo = 0
                           SET @nLastValidatedUCC = @cInField -- UCC
                        ELSE 
                        BEGIN
                           

                           -- Error, clear the UCC field
                           IF @i = 1 SELECT @cUCC1 = '', @cInField01 = '', @cOutField01 = ''
                           IF @i = 2 SELECT @cUCC2 = '', @cInField02 = '', @cOutField02 = ''
                           IF @i = 3 SELECT @cUCC3 = '', @cInField03 = '', @cOutField03 = ''
                           IF @i = 4 SELECT @cUCC4 = '', @cInField04 = '', @cOutField04 = ''
                           IF @i = 5 SELECT @cUCC5 = '', @cInField05 = '', @cOutField05 = ''
                           IF @i = 6 SELECT @cUCC6 = '', @cInField06 = '', @cOutField06 = ''
                           IF @i = 7 SELECT @cUCC7 = '', @cInField07 = '', @cOutField07 = ''
                           IF @i = 8 SELECT @cUCC8 = '', @cInField08 = '', @cOutField08 = ''
                           IF @i = 9 SELECT @cUCC9 = '', @cInField09 = '', @cOutField09 = ''
                           EXEC rdt.rdtSetFocusField @nMobile, @i
                           
                           -- Remove old value
                           IF @cUCC <> '' 
                           BEGIN
                              DELETE rdt.rdtMoveUCCLog 
                              WHERE StorerKey = @cStorerKey
                                 AND UCCNo = @cUCC
                                 AND AddWho = SUSER_SNAME()
                           
                              SELECT @nTotalUCC = COUNT(1) 
                              FROM rdt.rdtMoveUCCLog WITH (NOLOCK)
                              WHERE StorerKey = @cStorerKey
                                 AND AddWho = SUSER_SNAME()
                                 
                              -- Refresh counter
                              SET @cOutField13 = CAST( @nTotalUCC AS NVARCHAR( 3))
                           END

                           IF EXISTS(SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK)
                                    WHERE CaseID = @cInField
                                       AND StorerKey = @cStorerKey
                                       AND Status <> '9')
                           BEGIN
                              SET @nErrNo = 263453
                              SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- UCC belongs to an active task
                              GOTO SCN_UCC_FAIL
                           END

                           DECLARE @cUCCStatusTmp VARCHAR(1)

                           SELECT @cUCCStatusTmp = Status 
                           FROM dbo.UCC WITH (NOLOCK)
                           WHERE UCCNo  = @cInField
                              AND StorerKey = @cStorerKey

                           IF @@ROWCOUNT = 0
                           BEGIN
                              SET @nErrNo = 263459
                              SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  UCC does not exist
                              GOTO SCN_UCC_FAIL
                           END 

                           IF @cUCCStatusTmp = '0'
                           BEGIN
                              SET @nErrNo = 263454
                              SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  UCC not received
                              GOTO SCN_UCC_FAIL
                           END

                           IF @cUCCStatusTmp = '3'
                           BEGIN
                              SET @nErrNo = 263455
                              SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  UCC is allocated
                              GOTO SCN_UCC_FAIL
                           END

                           IF @cUCCStatusTmp = '5'
                           BEGIN
                              SET @nErrNo = 263456
                              SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  UCC is picked
                              GOTO SCN_UCC_FAIL
                           END

                           IF @cUCCStatusTmp = '6'
                           BEGIN
                              SET @nErrNo = 263457
                              SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  UCC is consumed
                              GOTO SCN_UCC_FAIL
                           END

                           IF @cUCCStatusTmp NOT IN( '1', 'H' )
                           BEGIN
                              SET @nErrNo = 263458
                              SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Invalid UCC status
                              GOTO SCN_UCC_FAIL
                           END
                           
                           GOTO SCN_UCC_FAIL
                        END
                     END
                     
                     -- Save to UCC variable
                     IF @i = 1 SET @cUCC1 = @cInField01
                     IF @i = 2 SET @cUCC2 = @cInField02
                     IF @i = 3 SET @cUCC3 = @cInField03
                     IF @i = 4 SET @cUCC4 = @cInField04
                     IF @i = 5 SET @cUCC5 = @cInField05
                     IF @i = 6 SET @cUCC6 = @cInField06
                     IF @i = 7 SET @cUCC7 = @cInField07
                     IF @i = 8 SET @cUCC8 = @cInField08
                     IF @i = 9 SET @cUCC9 = @cInField09
                     
                     -- Save to log
                     -- Remove old value
                     IF @cUCC <> '' 
                        DELETE rdt.rdtMoveUCCLog 
                        WHERE StorerKey = @cStorerKey
                           AND UCCNo = @cUCC
                           AND AddWho = SUSER_SNAME()
                     
                     -- Add new value
                     IF @cInField <> '' 
                        INSERT INTO rdt.rdtMoveUCCLog (StorerKey, UCCNo, RecNo) 
                        SELECT @cStorerKey, @cInField, (@nPage-1) * @nUCCOnPage + @i
                  END
                  SET @i = @i + 1
               END
               
               -- Get SKU and desc of last validated UCC
               IF @nLastValidatedUCC <> ''
                  SELECT 
                     @cSKU = SKU.SKU, 
                     @cSKUDescr = SKU.Descr
                  FROM dbo.UCC UCC (NOLOCK)
                     INNER JOIN dbo.SKU SKU (NOLOCK) ON (SKU.StorerKey = UCC.StorerKey AND SKU.SKU = UCC.SKU)
                  WHERE SKU.StorerKey = @cStorerKey
                     AND UCC.UCCNo = @nLastValidatedUCC
                     AND UCC.Status = '1' -- Received

               SELECT @nTotalUCC = COUNT(1) 
               FROM rdt.rdtMoveUCCLog WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND AddWho = SUSER_SNAME()

               -- Prepare current screen var
               SET @cOutField10 = @cSKU
               SET @cOutField11 = SUBSTRING( @cSKUDescr,  1, 20)
               SET @cOutField12 = SUBSTRING( @cSKUDescr, 21, 20)
               SET @cOutField13 = CAST( @nTotalUCC AS NVARCHAR( 3))

               -- Turn to next page
               IF @cUCC1 <> '' AND 
                  @cUCC2 <> '' AND 
                  @cUCC3 <> '' AND 
                  @cUCC4 <> '' AND 
                  @cUCC5 <> '' AND 
                  @cUCC6 <> '' AND 
                  @cUCC7 <> '' AND 
                  @cUCC8 <> '' AND 
                  @cUCC9 <> '' 
               BEGIN
                  -- Prepare next page
                  SELECT
                     @cUCC1 = '', @cOutField01 = '', 
                     @cUCC2 = '', @cOutField02 = '', 
                     @cUCC3 = '', @cOutField03 = '', 
                     @cUCC4 = '', @cOutField04 = '', 
                     @cUCC5 = '', @cOutField05 = '', 
                     @cUCC6 = '', @cOutField06 = '', 
                     @cUCC7 = '', @cOutField07 = '', 
                     @cUCC8 = '', @cOutField08 = '', 
                     @cUCC9 = '', @cOutField09 = ''

                  EXEC rdt.rdtSetFocusField @nMobile, 1 -- UCC1
                  SET @nPage += 1
               END
               ELSE
               BEGIN
                  -- Set next field focus
                  SET @i = 1 -- start from 1st field
                  IF @cInField01 <> '' SET @i = @i + 1
                  IF @cInField02 <> '' SET @i = @i + 1
                  IF @cInField03 <> '' SET @i = @i + 1
                  IF @cInField04 <> '' SET @i = @i + 1
                  IF @cInField05 <> '' SET @i = @i + 1
                  IF @cInField06 <> '' SET @i = @i + 1
                  IF @cInField07 <> '' SET @i = @i + 1
                  IF @cInField08 <> '' SET @i = @i + 1
                  IF @cInField09 <> '' SET @i = @i + 1
                  IF @i > 9 SET @i = 1
                  EXEC rdt.rdtSetFocusField @nMobile, @i
               END
            END
            ELSE
            BEGIN
               -- Turn to next page
               IF @cUCC1 <> '' AND 
                  @cUCC2 <> '' AND 
                  @cUCC3 <> '' AND 
                  @cUCC4 <> '' AND 
                  @cUCC5 <> '' AND 
                  @cUCC6 <> '' AND 
                  @cUCC7 <> '' AND 
                  @cUCC8 <> '' AND 
                  @cUCC9 <> '' 
               BEGIN
                  SET @nPage += 1
                  
                  -- Load page
                  SELECT 
                     @cUCC1 = '', @cUCC2 = '', @cUCC3 = '', @cUCC4 = '', @cUCC5 = '', 
                     @cUCC6 = '', @cUCC7 = '', @cUCC8 = '', @cUCC9 = ''
                     
                  SELECT
                     @cUCC1 = CASE WHEN RecNo % @nUCCOnPage = 1 THEN UCCNo ELSE @cUCC1 END, 
                     @cUCC2 = CASE WHEN RecNo % @nUCCOnPage = 2 THEN UCCNo ELSE @cUCC2 END, 
                     @cUCC3 = CASE WHEN RecNo % @nUCCOnPage = 3 THEN UCCNo ELSE @cUCC3 END, 
                     @cUCC4 = CASE WHEN RecNo % @nUCCOnPage = 4 THEN UCCNo ELSE @cUCC4 END, 
                     @cUCC5 = CASE WHEN RecNo % @nUCCOnPage = 5 THEN UCCNo ELSE @cUCC5 END, 
                     @cUCC6 = CASE WHEN RecNo % @nUCCOnPage = 6 THEN UCCNo ELSE @cUCC6 END, 
                     @cUCC7 = CASE WHEN RecNo % @nUCCOnPage = 7 THEN UCCNo ELSE @cUCC7 END, 
                     @cUCC8 = CASE WHEN RecNo % @nUCCOnPage = 8 THEN UCCNo ELSE @cUCC8 END, 
                     @cUCC9 = CASE WHEN RecNo % @nUCCOnPage = 0 THEN UCCNo ELSE @cUCC9 END
                  FROM rdt.rdtMoveUCCLog WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey 
                     AND AddWho = SUSER_SNAME()
                     AND RecNo BETWEEN @nPage * @nUCCOnPage - (9-1) AND @nPage * @nUCCOnPage
                  
                  SET @cOutField01 = @cUCC1
                  SET @cOutField02 = @cUCC2
                  SET @cOutField03 = @cUCC3
                  SET @cOutField04 = @cUCC4
                  SET @cOutField05 = @cUCC5
                  SET @cOutField06 = @cUCC6
                  SET @cOutField07 = @cUCC7
                  SET @cOutField08 = @cUCC8
                  SET @cOutField09 = @cUCC9
                  SET @cOutField10 = '' -- @cSKU
                  SET @cOutField11 = '' -- SUBSTRING( @cSKUDescr,  1, 20)
                  SET @cOutField12 = '' -- SUBSTRING( @cSKUDescr, 21, 20)
                  SET @cOutField13 = CAST( @nTotalUCC AS NVARCHAR(3))
                  
                  EXEC rdt.rdtSetFocusField @nMobile, 1 --UCC1
                  GOTO Quit
               END
               
               -- Extended validate
               IF @cExtendedValidateSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedValidateSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM(@cExtendedValidateSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cToID, @cToLoc, @cFromLoc, @cFromID,  @cUCC, ' + 
                        ' @cUCC1, @cUCC2, @cUCC3, @cUCC4, @cUCC5, @cUCC6, @cUCC7, @cUCC8, @cUCC9, ' + 
                        ' @nErrNo OUTPUT, @cErrMsg OUTPUT '
                     SET @cSQLParam =
                        '@nMobile        INT, ' +
                        '@nFunc          INT, ' +
                        '@cLangCode      NVARCHAR( 3),  ' +
                        '@nStep          INT, ' +
                        '@nInputKey      INT, ' + 
                        '@cStorerKey     NVARCHAR( 15), ' +
                        '@cToID          NVARCHAR( 18), ' +
                        '@cToLoc         NVARCHAR( 10), ' +
                        '@cFromLoc       NVARCHAR( 10), ' +
                        '@cFromID        NVARCHAR( 18), ' +
                        '@cUCC           NVARCHAR( 20), ' +
                        '@cUCC1          NVARCHAR( 20), ' +
                        '@cUCC2          NVARCHAR( 20), ' +
                        '@cUCC3          NVARCHAR( 20), ' +
                        '@cUCC4          NVARCHAR( 20), ' +
                        '@cUCC5          NVARCHAR( 20), ' +
                        '@cUCC6          NVARCHAR( 20), ' +
                        '@cUCC7          NVARCHAR( 20), ' +
                        '@cUCC8          NVARCHAR( 20), ' +
                        '@cUCC9          NVARCHAR( 20), ' +
                        '@nErrNo         INT           OUTPUT, ' + 
                        '@cErrMsg        NVARCHAR( 20) OUTPUT'
                  
                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cToID, @cToLoc, @cFromLoc, @cFromID, '', 
                        @cUCC1, @cUCC2, @cUCC3, @cUCC4, @cUCC5, @cUCC6, @cUCC7, @cUCC8, @cUCC9, 
                        @nErrNo OUTPUT, @cErrMsg OUTPUT 
         
                     IF @nErrNo <> 0 
                        GOTO Quit
                  END
               END

               -- Prep next screen var
               -- Not reset so that user do not need to rescan the ToID, ToLOC again and again if multiple UCC encounter error
               -- (system will return back to this screen to indicate which UCC encounter the error)
               -- SET @cToID = '' 
               -- SET @cToLOC = ''
               SET @cOutField01 = @cToID
               SET @cOutField02 = @cToLOC

               IF rdt.rdtGetConfig( @nFunc, 'MoveByUCCDefaultCursorToID', @cStorerKey) = '1'
                  EXEC rdt.rdtSetFocusField @nMobile, 1 --ToID
               ELSE
                  EXEC rdt.rdtSetFocusField @nMobile, 2 --ToLOC

               -- Go to next screen
               SET @nAfterScn = @nScn_ToLOC
               SET @nAfterStep = @nStep_ToLOC
            END
         END

         IF @nInputKey = 0 -- ESC
         BEGIN
            IF @nPage > 1
            BEGIN
               SET @nPage -= 1
               
               -- Load page
               SELECT 
                  @cUCC1 = '', @cUCC2 = '', @cUCC3 = '', @cUCC4 = '', @cUCC5 = '', 
                  @cUCC6 = '', @cUCC7 = '', @cUCC8 = '', @cUCC9 = ''
               SELECT
                  @cUCC1 = CASE WHEN RecNo % @nUCCOnPage = 1 THEN UCCNo ELSE @cUCC1 END, 
                  @cUCC2 = CASE WHEN RecNo % @nUCCOnPage = 2 THEN UCCNo ELSE @cUCC2 END, 
                  @cUCC3 = CASE WHEN RecNo % @nUCCOnPage = 3 THEN UCCNo ELSE @cUCC3 END, 
                  @cUCC4 = CASE WHEN RecNo % @nUCCOnPage = 4 THEN UCCNo ELSE @cUCC4 END, 
                  @cUCC5 = CASE WHEN RecNo % @nUCCOnPage = 5 THEN UCCNo ELSE @cUCC5 END, 
                  @cUCC6 = CASE WHEN RecNo % @nUCCOnPage = 6 THEN UCCNo ELSE @cUCC6 END, 
                  @cUCC7 = CASE WHEN RecNo % @nUCCOnPage = 7 THEN UCCNo ELSE @cUCC7 END, 
                  @cUCC8 = CASE WHEN RecNo % @nUCCOnPage = 8 THEN UCCNo ELSE @cUCC8 END, 
                  @cUCC9 = CASE WHEN RecNo % @nUCCOnPage = 0 THEN UCCNo ELSE @cUCC9 END
               FROM rdt.rdtMoveUCCLog WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey 
                  AND AddWho = SUSER_SNAME()
                  AND RecNo BETWEEN @nPage * @nUCCOnPage - (9-1) AND @nPage * @nUCCOnPage

               SET @cOutField01 = @cUCC1
               SET @cOutField02 = @cUCC2
               SET @cOutField03 = @cUCC3
               SET @cOutField04 = @cUCC4
               SET @cOutField05 = @cUCC5
               SET @cOutField06 = @cUCC6
               SET @cOutField07 = @cUCC7
               SET @cOutField08 = @cUCC8
               SET @cOutField09 = @cUCC9
               SET @cOutField10 = '' -- @cSKU
               SET @cOutField11 = '' -- SUBSTRING( @cSKUDescr,  1, 20)
               SET @cOutField12 = '' -- SUBSTRING( @cSKUDescr, 21, 20)
               SET @cOutField13 = CAST( @nTotalUCC AS NVARCHAR(3))
               
               EXEC rdt.rdtSetFocusField @nMobile, 1 --UCC1
            END
            ELSE
            BEGIN
               SET @curUCC = CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
                  SELECT RowRef
                  FROM rdt.rdtMoveUCCLog WITH (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND AddWho = SUSER_SNAME()
               OPEN @curUCC 
               FETCH NEXT FROM @curUCC INTO @nRowRef
               WHILE @@FETCH_STATUS = 0
               BEGIN
                  DELETE rdt.rdtMoveUCCLog WHERE RowRef = @nRowRef
                  FETCH NEXT FROM @curUCC INTO @nRowRef
               END
               
               -- EventLog
               EXEC RDT.rdt_STD_EventLog
                  @cActionType = '9', -- Sign Out
                  @nMobileNo   = @nMobile,
                  @nFunctionID = @nFunc,
                  @cFacility   = @cFacility,
                  @cStorerKey  = @cStorerkey

               -- Initiate var before exit to prevent  
               -- next module using isvalidqty having  
               -- overflowed int error coz UCC 20 digits  
               -- (james05)  
               SET @cUCC1 = ''  
               SET @cUCC2 = ''  
               SET @cUCC3 = ''  
               SET @cUCC4 = ''  
               SET @cUCC5 = ''  
               SET @cUCC6 = ''  
               SET @cUCC7 = ''  
               SET @cUCC8 = ''  
               SET @cUCC9 = '' 
               
               -- Back to menu
               SET @nFunc = @nMenu
               SET @nAfterScn  = @nMenu
               SET @nAfterStep = 0
               SET @cOutField01 = ''
            END
         END

         SCN_UCC_FAIL:
      END
   END

   IF @nAfterStep = 1
   BEGIN
      SET @nAfterStep = 99
      SET @nAfterScn = @nScn_UCC
      SET @cUDF02 = 'NO UPD RDTMOBREC'

      IF @nCurrentStep = 0
      BEGIN
         -- Storer configure
         SET @c2DBarcode = rdt.RDTGetConfig( @nFunc, '2DBarcode', @cStorerKey)
         
         SET @cDecodeSP = rdt.RDTGetConfig( @nFunc, 'DecodeSP', @cStorerKey)
         IF @cDecodeSP = '0'
            SET @cDecodeSP = ''
         SET @cExtendedValidateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedValidateSP', @cStorerKey)
         IF @cExtendedValidateSP = '0'
            SET @cExtendedValidateSP = ''
         SET @cExtendedUpdateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedUpdateSP', @cStorerKey)
         IF @cExtendedUpdateSP = '0'
            SET @cExtendedUpdateSP = ''
         SET @cLOCLookUP = rdt.rdtGetConfig( @nFunc, 'LOCLookUPSP', @cStorerKey)
         IF @cLOCLookUP = '0'
            SET @cLOCLookUP = ''

         SET @cExtScnSP = rdt.RDTGetConfig( @nFunc, 'ExtScnSP', @cStorerKey)
         IF @cExtScnSP = '0'
            SET @cExtScnSP = ''

         -- UCC status allowed
         SET @cUCCStatus = '1' -- Received
         IF rdt.RDTGetConfig( @nFunc, 'MoveQTYAlloc', @cStorerKey) = '1'
            SET @cUCCStatus += '3' -- Alloc

         -- Initiate var
         SET @cUCC1 = ''
         SET @cUCC2 = ''
         SET @cUCC3 = ''
         SET @cUCC4 = ''
         SET @cUCC5 = ''
         SET @cUCC6 = ''
         SET @cUCC7 = ''
         SET @cUCC8 = ''
         SET @cUCC9 = ''
         SET @nTotalUCC = 0
         SET @nPage = 1

         SET @cFromLOC = ''
         SET @cToLOC = ''
         SET @cToID = ''
         SET @cSKU = ''
         SET @cSKUDescr = ''
      END
   END

Quit:
   IF @cUDF02 = 'NO UPD RDTMOBREC'
   BEGIN
      UPDATE rdt.rdtMobRec WITH (ROWLOCK) SET
         EditDate = GETDATE(),
         ErrMsg = @cErrMsg,
         Func   = @nFunc,
         Step   = @nAfterStep,
         Scn    = @nAfterScn,

         StorerKey  = @cStorerKey,
         Facility   = @cFacility,

         V_SKU      = @cSKU,
         V_SKUDescr = @cSKUDescr,

         V_String1  = @cUCC1,
         V_String2  = @cUCC2,
         V_String3  = @cUCC3,
         V_String4  = @cUCC4,
         V_String5  = @cUCC5,
         V_String6  = @cUCC6,
         V_String7  = @cUCC7,
         V_String8  = @cUCC8,
         V_String9  = @cUCC9,
         V_Barcode  = @cBarcode,

         V_String10 = @cToLOC,
         V_String11 = @cToID,
         V_String12 = @cFromLOC,
         V_String15 = @cFromID,
         V_String16 = @cUCCStatus,
         V_String17 = @cUDF01,

         V_String20 = @cExtendedValidateSP,
         V_String21 = @cExtendedUpdateSP,
         V_String22 = @c2DBarcode,
         V_String23 = @cLOCLookUP,
         V_String24 = @cDecodeSP,
         V_String25 = @cExtScnSP,

         V_Integer1 = @nTotalUCC,
         V_Integer2 = @nPage,
         V_Integer3 = @nUCCOnPage,

         I_Field01 = @cInField01,  O_Field01 = @cOutField01,   FieldAttr01  = @cFieldAttr01,
         I_Field02 = @cInField02,  O_Field02 = @cOutField02,   FieldAttr02  = @cFieldAttr02,
         I_Field03 = @cInField03,  O_Field03 = @cOutField03,   FieldAttr03  = @cFieldAttr03,
         I_Field04 = @cInField04,  O_Field04 = @cOutField04,   FieldAttr04  = @cFieldAttr04,
         I_Field05 = @cInField05,  O_Field05 = @cOutField05,   FieldAttr05  = @cFieldAttr05,
         I_Field06 = @cInField06,  O_Field06 = @cOutField06,   FieldAttr06  = @cFieldAttr06,
         I_Field07 = @cInField07,  O_Field07 = @cOutField07,   FieldAttr07  = @cFieldAttr07,
         I_Field08 = @cInField08,  O_Field08 = @cOutField08,   FieldAttr08  = @cFieldAttr08,
         I_Field09 = @cInField09,  O_Field09 = @cOutField09,   FieldAttr09  = @cFieldAttr09,
         I_Field10 = @cInField10,  O_Field10 = @cOutField10,   FieldAttr10  = @cFieldAttr10,
         I_Field11 = @cInField11,  O_Field11 = @cOutField11,   FieldAttr11  = @cFieldAttr11,
         I_Field12 = @cInField12,  O_Field12 = @cOutField12,   FieldAttr12  = @cFieldAttr12,
         I_Field13 = @cInField13,  O_Field13 = @cOutField13,   FieldAttr13  = @cFieldAttr13,
         I_Field14 = @cInField14,  O_Field14 = @cOutField14,   FieldAttr14  = @cFieldAttr14,
         I_Field15 = @cInField15,  O_Field15 = @cOutField15,   FieldAttr15  = @cFieldAttr15

      WHERE Mobile = @nMobile
   END
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON rdt.rdt_514ExtScn01 TO NSQL 
GO  
