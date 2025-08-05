SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*************************************************************************/
/* Store procedure: rdt_1756ExtScn01                                     */
/*                                                                       */
/* Modifications log:                                                    */
/* Customer: Granite                                                     */
/*                                                                       */
/* Date       Rev    Author    Purposes                                  */
/* 2025-06-09 1.0.0  NickT     FCR-5727. Created                         */
/*************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1756ExtScn01] (
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
      @nCurrenStep                        INT,
      @nCurrentScn                        INT,
      @cUserName                          NVARCHAR(18), 
      @cEquipmentProfileKey               NVARCHAR(10),
      @cNewEquipmentProfileKey            NVARCHAR(10),
      @nMenu                              INT,

      @cExtendedValidateSP                NVARCHAR(20),
      @cExtendedUpdateSP                  NVARCHAR(20),
      @cSQL                               NVARCHAR(MAX),
      @cSQLParam                          NVARCHAR(MAX),
      @cAreaKey                           NVARCHAR(10),
      @cTaskDetailKey                     NVARCHAR(10)

   SET @cExtendedUpdateSP = rdt.rdtGetConfig( @nFunc, 'ExtendedUpdateSP', @cStorerKey)
   IF @cExtendedUpdateSP = '0'
      SET @cExtendedUpdateSP = ''
   SET @cExtendedValidateSP = rdt.RDTGetConfig( @nFunc, 'ExtendedValidateSP', @cStorerKey)
   IF @cExtendedValidateSP = '0'
      SET @cExtendedValidateSP = ''

   SELECT @cAreaKey = Value FROM @tExtScnData WHERE Variable = '@cAreaKey'
   SELECT @cTaskDetailKey = Value FROM @tExtScnData WHERE Variable = '@cTaskDetailKey'

   SELECT 
      @nCurrenStep = Step, 
      @nCurrentScn = Scn,
      @cUserName = UserName,
      @nMenu = Menu
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile 

   SELECT @cEquipmentProfileKey = EquipmentProfileKey
   FROM dbo.TaskManagerUser WITH (NOLOCK) 
   WHERE UserKey = @cUserName

   IF @nFunc = @nScn AND @nFunc <> 1756 AND @nStep = 0
   BEGIN
      SELECT @cEquipmentProfileKey = EquipmentProfileKey
      FROM dbo.TaskManagerUser WITH (NOLOCK) 
      WHERE UserKey = @cUserName

      SET @cOutField01 = @cEquipmentProfileKey
      SET @cOutField02 = ''
      SET @cOutField15 = ''

      -- Set the entry point
      SET @nAfterScn  = 6529
      SET @nAfterStep = 99
   END

   IF @nFunc = 1756
   BEGIN
      IF @nCurrenStep = 0
      BEGIN
         SET @cOutField01 = @cEquipmentProfileKey
         SET @cOutField02 = ''
         SET @cOutField15 = ''

         -- Set the entry point
         SET @nAfterScn  = 6529
         SET @nAfterStep = 99
      END
      ELSE IF @nCurrenStep = 99
      BEGIN
         IF @nCurrentScn = 6529
         BEGIN
            IF @nInputKey = 1 --Enter
            BEGIN
               SET @cNewEquipmentProfileKey = @cInField02

               IF @cEquipmentProfileKey = '' AND @cNewEquipmentProfileKey = ''
               BEGIN
                  SET @nErrNo = 239601
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- MHE Needed
                  GOTO Step_99_6529_Fail
               END

               IF @cEquipmentProfileKey <> '' AND NOT EXISTS(SELECT 1 FROM dbo.EquipmentProfile WITH(NOLOCK) WHERE EquipmentProfileKey = @cEquipmentProfileKey)
               BEGIN
                  SET @nErrNo = 239602
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Invalid MHE
                  GOTO Step_99_6529_Fail
               END

               IF @cNewEquipmentProfileKey <> '' AND @cNewEquipmentProfileKey <> @cEquipmentProfileKey
               BEGIN
                  IF NOT EXISTS(SELECT 1 FROM dbo.EquipmentProfile WITH(NOLOCK) WHERE EquipmentProfileKey = @cNewEquipmentProfileKey)
                  BEGIN
                     SET @nErrNo = 239603
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP') -- Invalid New MHE
                     GOTO Step_99_6529_Fail
                  END
               END

               -- Extended validation
               IF @cExtendedValidateSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WITH (NOLOCK) WHERE name = @cExtendedValidateSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nScn, @cAreaKey, @cEquipmentProfileKey, @cNewEquipmentProfileKey, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT'
                     SET @cSQLParam =
                        '@nMobile         INT,        '              +
                        '@nFunc           INT,        '              +
                        '@cLangCode       NVARCHAR( 3),   '          +
                        '@nStep           INT,        '              +
                        '@nScn            INT,        '              +
                        '@cAreaKey        NVARCHAR( 10),  '          +
                        '@cEquipmentProfileKey NVARCHAR( 10),  '     +
                        '@cNewEquipmentProfileKey NVARCHAR( 10),  '  +
                        '@cTaskdetailKey  NVARCHAR( 10),  '          +
                        '@nErrNo          INT OUTPUT, '              +
                        '@cErrMsg         NVARCHAR( 20) OUTPUT'

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nScn, @cAreaKey, @cEquipmentProfileKey, @cNewEquipmentProfileKey, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT

                     IF @nErrNo <> 0
                        GOTO Step_99_6529_Fail
                  END
               END

               IF @cNewEquipmentProfileKey <> '' AND @cNewEquipmentProfileKey <> @cEquipmentProfileKey
               BEGIN
                  SET @cEquipmentProfileKey = @cNewEquipmentProfileKey

                  UPDATE dbo.TaskManagerUser WITH (ROWLOCK)
                  SET EquipmentProfileKey = @cNewEquipmentProfileKey,
                     EditDate = GETDATE(),
                     EditWho = @cUserName
                  WHERE UserKey = @cUserName
               END

               -- Extended update
               IF @cExtendedUpdateSP <> ''
               BEGIN
                  IF EXISTS( SELECT 1 FROM dbo.sysobjects WITH (NOLOCK) WHERE name = @cExtendedUpdateSP AND type = 'P')
                  BEGIN
                     SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
                        ' @nMobile, @nFunc, @cLangCode, @nStep, @nScn, @cEquipmentProfileKey, @cNewEquipmentProfileKey, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT'
                     SET @cSQLParam =
                        '@nMobile         INT,        '              +
                        '@nFunc           INT,        '              +
                        '@cLangCode       NVARCHAR( 3),   '          +
                        '@nStep           INT,        '              +
                        '@nScn            INT,        '              +
                        '@cEquipmentProfileKey NVARCHAR( 10),  '     +
                        '@cNewEquipmentProfileKey NVARCHAR( 10),  '  +
                        '@cTaskdetailKey  NVARCHAR( 10),  '          +
                        '@nErrNo          INT OUTPUT, '              +
                        '@cErrMsg         NVARCHAR( 20) OUTPUT'

                     EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                        @nMobile, @nFunc, @cLangCode, @nStep, @nScn, @cEquipmentProfileKey, @cNewEquipmentProfileKey, @cTaskdetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT

                     IF @nErrNo <> 0
                        GOTO Step_99_6529_Fail
                  END
               END

               SET @cOutField01 = ''
               SET @cOutField15 = ''

               SET @nAfterScn = 2100
               SET @nAfterStep = 1
            END
            ELSE IF @nInputKey = 0
            BEGIN
               -- Back to menu
               SET @nAfterScn  = @nMenu
               SET @nAfterStep = 0
            
               SET @cOutField01 = ''
               SET @cOutField02 = ''
               SET @cOutField03 = ''
               SET @cOutField04 = ''
               SET @cOutField05 = ''
               SET @cOutField06 = ''
               SET @cOutField07 = ''
               SET @cOutField08 = ''
            END

            GOTO Quit

            Step_99_6529_Fail:
               GOTO Quit

         END
      END
   END

   GOTO Quit

Quit:
   UPDATE rdt.RDTMOBREC WITH (ROWLOCK)
   SET 
      C_String30     = @cEquipmentProfileKey,
      EditDate       = GETDATE()
   WHERE Mobile = @nMobile
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1756ExtScn01 to nSQL
GO
