if exists (select * from dbo.sysobjects where id = object_id(N'[rdt].[rdtfnc_Move_UCC]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [rdt].[rdtfnc_Move_UCC]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Store procedure: rdtfnc_Move_UCC                                     */
/* Copyright      : IDS                                                 */
/*                                                                      */
/* Purpose: normal receipt                                              */
/*                                                                      */
/* Called from: 3                                                       */
/*    1. From PowerBuilder                                              */
/*    2. From scheduler                                                 */
/*    3. From others stored procedures or triggers                      */
/*    4. From interface program. DX, DTS                                */
/*                                                                      */
/* Exceed version: 5.4                                                  */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2006-07-12 1.0  UngDH    Created                                     */
/* 2009-07-06 1.1  Vicky    Add in EventLog (Vicky06)                   */
/* 2011-11-11 1.2  ChewKP   LCI Project Changes Update UCC Table        */
/*                          (ChewKP01)                                  */
/* 2011-12-21 1.3  James    Revamp rdt_move (james01)                   */
/* 2012-02-14 1.4  James    Include from loc to scan (james02)          */
/* 2012-07-17 1.5  James    Storerconfig to control whether need to scan*/
/*                          from loc (james03)                          */
/* 2012-07-19 1.6  ChewKP   SOS#250946 - Move UCC Update to SP rdt_Move */
/*                          (ChewKP02)                                  */
/* 2013-06-14 1.7  James    SOS#281065 - Bug fix (james04)              */  
/* 2013-09-20 1.8  Ung      Fix FromID not pass-in to rdt_move          */
/*                          Add MoveByUCCDefaultCursorToID              */
/* 2015-01-07 1.9  ChewKP   SOS#330113 - Add ExtendedValidate Config    */
/*                          (ChewKP03)                                  */
/* 2015-04-24 2.0  Ung      SOS340172 Add ExtendedUpdateSP              */
/*                          Revise ExtendedValidateSP                   */
/* 2016-09-30 2.1  Ung      Performance tuning                          */
/* 2018-11-01 2.2  James    Reinitialse variable before exit (james05)  */        
/* 2018-02-20 2.3 YeeKung   WMS-8020 Add RDTSTDEVENTLOG                 */      
/* 2019-03-26 2.4  James    WMS-8352 Add From ID (james06)              */
/*                          Add Loc lookup                              */
/* 2020-05-04 2.5  Ung      WMS-12637 Add ConfirmSP                     */
/************************************************************************/

CREATE  PROCEDURE [RDT].[rdtfnc_Move_UCC] (
   @nMobile    INT,
   @nErrNo     INT  OUTPUT,
   @cErrMsg    NVARCHAR( 20) OUTPUT -- screen limitation, 20 char max
) AS
SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF  

-- Misc variable
DECLARE 
   @cUCC         NVARCHAR( 20), 
   @cChkFacility NVARCHAR( 5), 
   @i            INT

-- RDT.RDTMobRec variable
DECLARE 
   @nFunc      INT,
   @nScn       INT,
   @nStep      INT,
   @cLangCode  NVARCHAR( 3),
   @nInputKey  INT,
   @nMenu      INT, 

   @cStorerKey NVARCHAR( 15),
   @cFacility  NVARCHAR( 5), 
   
   @cSKU       NVARCHAR( 20), 
   @cSKUDescr  NVARCHAR( 60), 

   @cUCC1      NVARCHAR( 20), 
   @cUCC2      NVARCHAR( 20), 
   @cUCC3      NVARCHAR( 20), 
   @cUCC4      NVARCHAR( 20), 
   @cUCC5      NVARCHAR( 20), 
   @cUCC6      NVARCHAR( 20), 
   @cUCC7      NVARCHAR( 20), 
   @cUCC8      NVARCHAR( 20), 
   @cUCC9      NVARCHAR( 20), 

   @cToLOC     NVARCHAR( 10), 
   @cToID      NVARCHAR( 18), 
   @cUserName  NVARCHAR(18), -- (Vicky06)
   @cFromLOC   NVARCHAR( 10), -- (james02)
   @cExtendedValidateSP NVARCHAR( 20), -- (ChewKP03)
   @cExtendedUpdateSP   NVARCHAR( 20), 
   @cSQL                NVARCHAR(1000), -- (ChewKP03)
   @cSQLParam           NVARCHAR(1000), -- (ChewKP03)
   @cFromID             NVARCHAR( 18), -- (james06)
   @cLOCLookUP          NVARCHAR(20),           
   
   @cInField01 NVARCHAR( 60),   @cOutField01 NVARCHAR( 60),
   @cInField02 NVARCHAR( 60),   @cOutField02 NVARCHAR( 60),
   @cInField03 NVARCHAR( 60),   @cOutField03 NVARCHAR( 60),
   @cInField04 NVARCHAR( 60),   @cOutField04 NVARCHAR( 60),
   @cInField05 NVARCHAR( 60),   @cOutField05 NVARCHAR( 60),
   @cInField06 NVARCHAR( 60),   @cOutField06 NVARCHAR( 60), 
   @cInField07 NVARCHAR( 60),   @cOutField07 NVARCHAR( 60), 
   @cInField08 NVARCHAR( 60),   @cOutField08 NVARCHAR( 60), 
   @cInField09 NVARCHAR( 60),   @cOutField09 NVARCHAR( 60), 
   @cInField10 NVARCHAR( 60),   @cOutField10 NVARCHAR( 60), 
   @cInField11 NVARCHAR( 60),   @cOutField11 NVARCHAR( 60), 
   @cInField12 NVARCHAR( 60),   @cOutField12 NVARCHAR( 60), 
   @cInField13 NVARCHAR( 60),   @cOutField13 NVARCHAR( 60), 
   @cInField14 NVARCHAR( 60),   @cOutField14 NVARCHAR( 60), 
   @cInField15 NVARCHAR( 60),   @cOutField15 NVARCHAR( 60)

-- Load RDT.RDTMobRec
SELECT 
   @nFunc      = Func,
   @nScn       = Scn,
   @nStep      = Step,
   @nInputKey  = InputKey,
   @nMenu      = Menu,
   @cLangCode  = Lang_code,

   @cStorerKey = StorerKey,
   @cFacility  = Facility,
   @cUserName  = UserName,-- (Vicky06)

   @cSKU       = V_SKU, 
   @cSKUDescr  = V_SKUDescr, 

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
   @cFromLOC   = V_String12,  -- (james02)
   @cExtendedValidateSP = V_String13, -- (ChewKP03)
   @cExtendedUpdateSP   = V_String14,
   @cFromID       = V_String15,
   @cLOCLookUP    = V_String18,      

   @cInField01 = I_Field01,   @cOutField01 = O_Field01,
   @cInField02 = I_Field02,   @cOutField02 = O_Field02,
   @cInField03 = I_Field03,   @cOutField03 = O_Field03, 
   @cInField04 = I_Field04,   @cOutField04 = O_Field04, 
   @cInField05 = I_Field05,   @cOutField05 = O_Field05, 
   @cInField06 = I_Field06,   @cOutField06 = O_Field06, 
   @cInField07 = I_Field07,   @cOutField07 = O_Field07, 
   @cInField08 = I_Field08,   @cOutField08 = O_Field08, 
   @cInField09 = I_Field09,   @cOutField09 = O_Field09, 
   @cInField10 = I_Field10,   @cOutField10 = O_Field10, 
   @cInField11 = I_Field11,   @cOutField11 = O_Field11, 
   @cInField12 = I_Field12,   @cOutField12 = O_Field12, 
   @cInField13 = I_Field13,   @cOutField13 = O_Field13, 
   @cInField14 = I_Field14,   @cOutField14 = O_Field14, 
   @cInField15 = I_Field15,   @cOutField15 = O_Field15

FROM RDTMOBREC (NOLOCK)
WHERE Mobile = @nMobile

IF @nFunc = 514 -- Move (UCC)
BEGIN
   -- Redirect to respective screen
   IF @nStep = 0 GOTO Step_0   -- Func = Move (generic)
   IF @nStep = 1 GOTO Step_1   -- Scn = 808. UCC1..9, SKU, Desc1, Desc2
   IF @nStep = 2 GOTO Step_2   -- Scn = 809. ToLOC, ToID
   IF @nStep = 3 GOTO Step_3   -- Scn = 810. Message
   IF @nStep = 4 GOTO Step_4   -- Scn = 811. FROM LOC -- (james02)
END

RETURN -- Do nothing if incorrect step


/********************************************************************************
Step 0. func = 514. Menu
********************************************************************************/
Step_0:
BEGIN
   -- Set the entry point
   IF rdt.RDTGetConfig( @nFunc, 'MoveByUCCScanFromLOC', @cStorerKey) <> '1'   -- (james03)
   BEGIN
      SET @nScn = 808
      SET @nStep = 1
   END
   ELSE
   BEGIN
      SET @nScn = 811   -- (james02)
      SET @nStep = 4
   END
   
   -- (ChewKP03)
   SET @cExtendedValidateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedValidateSP', @cStorerKey)
   IF @cExtendedValidateSP = '0'  
      SET @cExtendedValidateSP = ''
   SET @cExtendedUpdateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedUpdateSP', @cStorerKey)
   IF @cExtendedUpdateSP = '0'  
      SET @cExtendedUpdateSP = ''

   SET @cLOCLookUP = rdt.rdtGetConfig( @nFunc, 'LOCLookUPSP', @cStorerKey)      
   IF @cLOCLookUP = '0'            
      SET @cLOCLookUP = ''            
   
   -- (Vicky06) EventLog - Sign In Function
   EXEC RDT.rdt_STD_EventLog
      @cActionType = '1', -- Sign in function
      @cUserID     = @cUserName,
      @nMobileNo   = @nMobile,
      @nFunctionID = @nFunc,
      @cFacility   = @cFacility,
      @cStorerKey  = @cStorerkey

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

   SET @cFROMLOC = ''
   SET @cToLOC = ''
   SET @cToID = ''
   SET @cSKU = ''
   SET @cSKUDescr = ''

   --Prep next screen var
   SET @cOutField01 = '' -- UCC1
   SET @cOutField02 = ''
   SET @cOutField03 = ''
   SET @cOutField04 = ''
   SET @cOutField05 = ''
   SET @cOutField06 = ''
   SET @cOutField07 = ''
   SET @cOutField08 = ''
   SET @cOutField09 = '' -- UCC9
   SET @cOutField10 = '' -- SKU
   SET @cOutField11 = '' -- Desc1
   SET @cOutField12 = '' -- Desc2

END
GOTO Quit


/********************************************************************************
Step 1. Scn = 806. Move From screen
   UCC1  (field01)
   UCC2  (field02)
   UCC3  (field03)
   UCC4  (field04)
   UCC5  (field05)
   UCC6  (field06)
   UCC7  (field07)
   UCC8  (field08)
   UCC9  (field09)
   SKU   (field10)
   Desc1 (field11)
   Desc2 (field12)
********************************************************************************/
Step_1:
BEGIN
   IF @nInputKey = 1 -- Yes or Send
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
        SET @nErrNo = 60601
         SET @cErrMsg = rdt.rdtgetmessage( 60601, @cLangCode, 'DSP') --'UCC needed'
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_1_Fail
      END

      -- Put all UCC into temp table
      DECLARE @tUCC TABLE (UCC NVARCHAR( 20), i INT)
      INSERT INTO @tUCC (UCC, i) VALUES (@cInField01, 1)
      INSERT INTO @tUCC (UCC, i) VALUES (@cInField02, 2)
      INSERT INTO @tUCC (UCC, i) VALUES (@cInField03, 3)
      INSERT INTO @tUCC (UCC, i) VALUES (@cInField04, 4)
      INSERT INTO @tUCC (UCC, i) VALUES (@cInField05, 5)
      INSERT INTO @tUCC (UCC, i) VALUES (@cInField06, 6)
      INSERT INTO @tUCC (UCC, i) VALUES (@cInField07, 7)
      INSERT INTO @tUCC (UCC, i) VALUES (@cInField08, 8)
      INSERT INTO @tUCC (UCC, i) VALUES (@cInField09, 9)

      -- Validate UCC scanned more than once
      SELECT @i = MAX( i)
      FROM @tUCC
      WHERE UCC <> '' AND UCC IS NOT NULL
      GROUP BY UCC
      HAVING COUNT( UCC) > 1

      IF @@ROWCOUNT <> 0
      BEGIN
         SET @nErrNo = 60602
         SET @cErrMsg = rdt.rdtgetmessage( 60602, @cLangCode, 'DSP') --'UCC DoubleScan'
         EXEC rdt.rdtSetFocusField @nMobile, @i
         GOTO Step_1_Fail
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
                     '1', -- Received, 
                     @cChkLOC = @cFromLOC
                  
                  IF @nErrNo = 0
                  BEGIN
                     -- Extended validate
                     IF @cExtendedValidateSP <> ''
                     BEGIN
                        IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')
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
                     GOTO Step_1_Fail
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

         -- Prepare current screen var
         SET @cOutField10 = @cSKU
         SET @cOutField11 = SUBSTRING( @cSKUDescr,  1, 20)
         SET @cOutField12 = SUBSTRING( @cSKUDescr, 21, 20)

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
      ELSE
      BEGIN
         -- Extended validate
         IF @cExtendedValidateSP <> ''
         BEGIN
            IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')
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
                  GOTO Step_2_Fail
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
         SET @nScn = @nScn + 1
         SET @nStep = @nStep + 1
      END
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
      SET @nScn  = @nMenu
      SET @nStep = 0
      SET @cOutField01 = ''
   END

   Step_1_Fail:

END
GOTO Quit


/********************************************************************************
Step 2. scn = 809. Move to screen
   ToID  (field01)
   ToLOC (field02)
********************************************************************************/
Step_2:
BEGIN
   IF @nInputKey = 1 -- Yes or Send
   BEGIN
      -- Screen mapping
      SET @cToID = @cInField01
      SET @cToLOC = @cInField02

      -- Retain ToID value
      SET @cOutField01 = @cInField01

      -- Validate blank
      IF @cToLOC = '' OR @cToLOC IS NULL
      BEGIN
         SET @nErrNo = 60603
         SET @cErrMsg = rdt.rdtgetmessage( 60603, @cLangCode, 'DSP') --'ToLOC needed'
         EXEC rdt.rdtSetFocusField @nMobile, 2
         GOTO Step_2_Fail
      END

      IF @cLOCLookUP <> ''      
      BEGIN      
         EXEC rdt.rdt_LOCLookUp @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFacility,       
            @cToLOC     OUTPUT,       
            @nErrNo     OUTPUT,       
            @cErrMsg    OUTPUT      

         IF @nErrNo <> 0      
            GOTO Step_2_Fail      
      END       
         
      -- Get LOC
      SELECT @cChkFacility = Facility
      FROM dbo.LOC (NOLOCK)
      WHERE LOC = @cToLOC
   
      -- Validate LOC
      IF @@ROWCOUNT = 0
      BEGIN
         SET @nErrNo = 60604
         SET @cErrMsg = rdt.rdtgetmessage( 60604, @cLangCode, 'DSP') --'Invalid ToLOC'
         SET @cOutField02 = ''
         EXEC rdt.rdtSetFocusField @nMobile, 2
         GOTO Step_2_Fail
      END
   
      -- Validate ToLOC's facility
      IF NOT (rdt.rdtGetConfig( 0, 'MoveToLOCNotCheckFacility', @cStorerKey) = '1')
         IF @cChkFacility <> @cFacility
         BEGIN
            SET @nErrNo = 60605
            SET @cErrMsg = rdt.rdtgetmessage( 60605, @cLangCode, 'DSP') --'Diff facility'
            SET @cOutField02 = ''
            EXEC rdt.rdtSetFocusField @nMobile, 2
            GOTO Step_2_Fail
         END

      -- Extended validate
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedValidateSP AND type = 'P')
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
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cToID, @cToLoc, @cFromLoc, @cFromID, '', 
               @cUCC1, @cUCC2, @cUCC3, @cUCC4, @cUCC5, @cUCC6, @cUCC7, @cUCC8, @cUCC9, 
               @nErrNo OUTPUT, @cErrMsg OUTPUT 

            IF @nErrNo <> 0 
               GOTO Step_2_Fail
         END
      END

      DECLARE @nTranCount  INT
      SET @nTranCount = @@TRANCOUNT
      BEGIN TRAN
      SAVE TRAN rdtfnc_Move_UCC

      -- Confirm
      EXEC rdt.rdt_Move_UCC_Confirm @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cFacility, 
         @cToID, @cToLoc, @cFromLoc, @cFromID, 
         @cUCC1, @cUCC2, @cUCC3, @cUCC4, @cUCC5, @cUCC6, @cUCC7, @cUCC8, @cUCC9, 
         @i OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT 
      IF @nErrNo <> 0 
      BEGIN
         ROLLBACK TRAN rdtfnc_Move_UCC
         WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
            COMMIT TRAN

         SET @cOutField01 = @cUCC1
         SET @cOutField02 = @cUCC2
         SET @cOutField03 = @cUCC3
         SET @cOutField04 = @cUCC4
         SET @cOutField05 = @cUCC5
         SET @cOutField06 = @cUCC6
         SET @cOutField07 = @cUCC7
         SET @cOutField08 = @cUCC8
         SET @cOutField09 = @cUCC9
         SET @cOutField10 = @cSKU
         SET @cOutField11 = SUBSTRING( @cSKUDescr,  1, 20)
         SET @cOutField12 = SUBSTRING( @cSKUDescr, 21, 20)

         -- Go back to UCC screen indicate which UCC encountered error
         -- Not reset so that user do not need to rescan the ToID, ToLOC again and again if multiple UCC encounter error
         EXEC rdt.rdtSetFocusField @nMobile, @i

         -- Go to prev screen
         SET @nScn = @nScn - 1
         SET @nStep = @nStep - 1

         GOTO Step_2_Fail
      END

      -- Extended update
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM dbo.sysobjects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM(@cExtendedUpdateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cToID, @cToLoc, @cFromLoc, @cFromID, ' + 
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
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cToID, @cToLoc, @cFromLoc, @cFromID, 
               @cUCC1, @cUCC2, @cUCC3, @cUCC4, @cUCC5, @cUCC6, @cUCC7, @cUCC8, @cUCC9, 
               @nErrNo OUTPUT, @cErrMsg OUTPUT 

            IF @nErrNo <> 0 
            BEGIN
               ROLLBACK TRAN rdtfnc_Move_UCC
               WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                  COMMIT TRAN
               GOTO Step_2_Fail
            END
         END
      END

      COMMIT TRAN rdtfnc_Move_UCC
      WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
         COMMIT TRAN
         
      -- Go to next screen
      SET @nScn = @nScn + 1
      SET @nStep = @nStep + 1
   END

   IF @nInputKey = 0 -- Esc or No
   BEGIN
      -- Prepare prev screen var
      SET @cToID = ''
      SET @cToLOC = ''
      SET @cOutField01 = @cUCC1
      SET @cOutField02 = @cUCC2
      SET @cOutField03 = @cUCC3
      SET @cOutField04 = @cUCC4
      SET @cOutField05 = @cUCC5
      SET @cOutField06 = @cUCC6
      SET @cOutField07 = @cUCC7
      SET @cOutField08 = @cUCC8
      SET @cOutField09 = @cUCC9
      SET @cOutField10 = @cSKU
      SET @cOutField11 = SUBSTRING( @cSKUDescr,  1, 20)
      SET @cOutField12 = SUBSTRING( @cSKUDescr, 21, 20)

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

      -- Go to prev screen
      SET @nScn = @nScn - 1
      SET @nStep = @nStep - 1
   END
   
   Step_2_Fail:
   
END
GOTO Quit


/********************************************************************************
Step 3. scn = 810. Message screen
   Msg
********************************************************************************/
Step_3:
BEGIN
   -- Go back to SKU screen  
   IF rdt.RDTGetConfig( @nFunc, 'MoveByUCCScanFromLOC', @cStorerKey) <> '1'   -- (james04)  
   BEGIN  
      SET @nScn  = @nScn - 2  
      SET @nStep = @nStep - 2  
   END  
   ELSE  
   BEGIN  
      SET @nScn  = @nScn + 1  
      SET @nStep = @nStep + 1  
   END

   -- Init next screen var
   SET @cUCC1 = ''
   SET @cUCC2 = ''
   SET @cUCC3 = ''
   SET @cUCC4 = ''
   SET @cUCC5 = ''
   SET @cUCC6 = ''
   SET @cUCC7 = ''
   SET @cUCC8 = ''
   SET @cUCC9 = ''
   SET @cSKU = ''
   SET @cSKUDescr = ''
   SET @cToID = ''
   SET @cToLOC = ''
   SET @cFromLOC = ''
   
   
   SET @cOutField01 = '' -- UCC1
   SET @cOutField02 = '' 
   SET @cOutField03 = '' 
   SET @cOutField04 = '' 
   SET @cOutField05 = '' 
   SET @cOutField06 = '' 
   SET @cOutField07 = '' 
   SET @cOutField08 = '' 
   SET @cOutField09 = '' -- UCC9
   SET @cOutField10 = '' -- SKU
   SET @cOutField11 = '' -- Desc1
   SET @cOutField12 = '' -- Desc2
   EXEC rdt.rdtSetFocusField @nMobile, 1
END
GOTO Quit

/********************************************************************************
Step 4. scn = 811. FROM LOC screen
   FROM LOC  (field01)
********************************************************************************/
Step_4:
BEGIN
   IF @nInputKey = 1 -- Yes or Send
   BEGIN
      -- Screen mapping
      SET @cFromLOC = @cInField01
      SET @cFromID = @cInField02
      
      -- Validate blank
      IF @cFromLOC = '' OR @cFromLOC IS NULL
      BEGIN
         SET @nErrNo = 60607
         SET @cErrMsg = rdt.rdtgetmessage( 60607, @cLangCode, 'DSP') --'FROMLOC needed'
         SET @cOutField01 = ''
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_4_Fail
      END

      IF @cLOCLookUP <> ''      
      BEGIN      
         EXEC rdt.rdt_LOCLookUp @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerkey, @cFacility,       
            @cFromLOC   OUTPUT,       
            @nErrNo     OUTPUT,       
            @cErrMsg    OUTPUT      

         IF @nErrNo <> 0      
            GOTO Step_4_Fail      
      END  

      -- Get LOC
      SELECT @cChkFacility = Facility
      FROM dbo.LOC (NOLOCK)
      WHERE LOC = @cFromLOC
   
      -- Validate LOC
      IF @@ROWCOUNT = 0
      BEGIN
         SET @nErrNo = 60608
         SET @cErrMsg = rdt.rdtgetmessage( 60608, @cLangCode, 'DSP') --'Invalid FROMLOC'
         SET @cOutField01 = ''
         EXEC rdt.rdtSetFocusField @nMobile, 1
         GOTO Step_4_Fail
      END
   
      -- Validate ToLOC's facility
      IF NOT (rdt.rdtGetConfig( 0, 'MoveToLOCNotCheckFacility', @cStorerKey) = '1')
      BEGIN
         IF @cChkFacility <> @cFacility
         BEGIN
            SET @nErrNo = 60609
            SET @cErrMsg = rdt.rdtgetmessage( 60609, @cLangCode, 'DSP') --'Diff facility'
            SET @cOutField01 = ''
            EXEC rdt.rdtSetFocusField @nMobile, 1
            GOTO Step_4_Fail
         END
      END
      
      -- (james06)
      IF ISNULL( @cFromID, '') <> ''
      BEGIN
         IF NOT EXISTS ( SELECT 1 FROM dbo.LOTxLOCxID WITH (NOLOCK)
                         WHERE Loc = @cFromLoc
                         AND   ID = @cFromID
                         AND   StorerKey = @cStorerKey
                         AND   Qty  > 0) -- can move allocated or picked
         BEGIN
            SET @nErrNo = 60610
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Invalid FromID'
            SET @cOutField01 = ''
            EXEC rdt.rdtSetFocusField @nMobile, 2
            GOTO Step_4_Fail
         END
      END

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

      SET @cToLOC = ''
      SET @cToID = ''
      SET @cSKU = ''
      SET @cSKUDescr = ''

      --Prep next screen var
      SET @cOutField01 = '' -- UCC1
      SET @cOutField02 = ''
      SET @cOutField03 = ''
      SET @cOutField04 = ''
      SET @cOutField05 = ''
      SET @cOutField06 = ''
      SET @cOutField07 = ''
      SET @cOutField08 = ''
      SET @cOutField09 = '' -- UCC9
      SET @cOutField10 = '' -- SKU
      SET @cOutField11 = '' -- Desc1
      SET @cOutField12 = '' -- Desc2
      
      -- Go to Next screen
      SET @nScn = @nScn - 3
      SET @nStep = @nStep - 3
   END
   
   IF @nInputKey = 0 -- ESC
   BEGIN
     -- (Vicky06) EventLog - Sign Out Function
     EXEC RDT.rdt_STD_EventLog
       @cActionType = '9', -- Sign Out function
       @cUserID     = @cUserName,
       @nMobileNo   = @nMobile,
       @nFunctionID = @nFunc,
       @cFacility   = @cFacility,
       @cStorerKey  = @cStorerkey

      -- Back to menu
      SET @nFunc = @nMenu
      SET @nScn  = @nMenu
      SET @nStep = 0
      SET @cOutField01 = ''
   END
   
   Step_4_Fail:
END
GOTO Quit

/********************************************************************************
Quit. Update back to I/O table, ready to be pick up by JBOSS
********************************************************************************/
Quit:
BEGIN
   UPDATE RDTMOBREC WITH (ROWLOCK) SET 
      EditDate = GETDATE(), 
      ErrMsg = @cErrMsg, 
      Func   = @nFunc,
      Step   = @nStep,
      Scn    = @nScn,

      StorerKey  = @cStorerKey,
      Facility   = @cFacility, 
      -- UserName   = @cUserName,-- (Vicky06)

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
   
      V_String10 = @cToLOC, 
      V_String11 = @cToID, 
      V_String12 = @cFromLOC, -- (james02)
      V_String13 = @cExtendedValidateSP, -- (ChewKP03)
      V_String14 = @cExtendedUpdateSP,                        
      V_String15 = @cFromID,
      V_String18 = @cLOCLookUP,         

      I_Field01 = @cInField01,  O_Field01 = @cOutField01, 
      I_Field02 = @cInField02,  O_Field02 = @cOutField02, 
      I_Field03 = @cInField03,  O_Field03 = @cOutField03, 
      I_Field04 = @cInField04,  O_Field04 = @cOutField04, 
      I_Field05 = @cInField05,  O_Field05 = @cOutField05, 
      I_Field06 = @cInField06,  O_Field06 = @cOutField06, 
      I_Field07 = @cInField07,  O_Field07 = @cOutField07, 
      I_Field08 = @cInField08,  O_Field08 = @cOutField08, 
      I_Field09 = @cInField09,  O_Field09 = @cOutField09, 
      I_Field10 = @cInField10,  O_Field10 = @cOutField10, 
      I_Field11 = @cInField11,  O_Field11 = @cOutField11, 
      I_Field12 = @cInField12,  O_Field12 = @cOutField12, 
      I_Field13 = @cInField13,  O_Field13 = @cOutField13, 
      I_Field14 = @cInField14,  O_Field14 = @cOutField14, 
      I_Field15 = @cInField15,  O_Field15 = @cOutField15

   WHERE Mobile = @nMobile
END

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON RDT.rdtfnc_Move_UCC TO NSQL
GO
