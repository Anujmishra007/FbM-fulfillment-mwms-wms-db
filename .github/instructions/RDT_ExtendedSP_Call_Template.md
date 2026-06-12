---
applyTo: "WMS/StoredProc/RDT/rdtfnc_*.sql"
description: "Template for inserting dynamic Extension SP call blocks (ExtendedValidateSP / ExtendedUpdateSP / ExtendedInfoSP / ExtScnSP) into a Main Function SP. Load when editing rdtfnc_*.sql files."
---

# RDT Extended SP Dynamic Call Template

## Overview
Template for adding dynamic Extended SP calls in main RDT function SPs. This template shows how to integrate ExtendedValidateSP, ExtendedUpdateSP, and ExtendedInfoSP calls into a specific step of the main function flow.

## Template Parameters
- `{STEP_NAME}` - Step label name (e.g., Step_ToLOC)
- `{SP_NAME}` - Main function SP name (e.g., rdtfnc_TM_Replen)

---

## 1. Extended Validate SP Call

**Position:** After standard validation, before transaction begins

**Purpose:** Perform custom validation before any data modification

### Template Code

```sql
      -- ========================================================
      -- EXTENDED VALIDATE SP: Custom validation after standard checks
      -- ========================================================
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @cStorerKey, @cFacility, @cRefNo, @cOrderKey, @cDropID, @cLoadKey, @cPickSlipNo, ' + 
               ' @nErrNo OUTPUT, @cErrMsg OUTPUT, @cID, @cTaskDetailKey, @tExtValidate '
            SET @cSQLParam =
               '@nMobile        INT, ' +
               '@nFunc          INT, ' +
               '@cLangCode      NVARCHAR( 3),  ' +
               '@nStep          INT,           ' +
               '@cStorerKey     NVARCHAR( 15), ' +
               '@cFacility      NVARCHAR( 5),  ' +
               '@cRefNo         NVARCHAR( 20), ' +
               '@cOrderKey      NVARCHAR( 10), ' +
               '@cDropID        NVARCHAR( 20), ' +
               '@cLoadKey       NVARCHAR( 10), ' +
               '@cPickSlipNo    NVARCHAR( 10), ' +
               '@nErrNo         INT           OUTPUT, ' +
               '@cErrMsg        NVARCHAR( 20) OUTPUT, ' + 
               '@cID            NVARCHAR( 18), ' + 
               '@cTaskDetailKey NVARCHAR( 10), ' + 
               '@tExtValidate   VARIABLETABLE READONLY'
            
            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @cStorerKey, @cFacility, @cRefNo, @cOrderKey, @cDropID, @cLoadKey, @cPickSlipNo, 
               @nErrNo OUTPUT, @cErrMsg OUTPUT, @cID, @cTaskDetailKey, @tExtValidate

            IF @nErrNo <> 0
            BEGIN
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
               GOTO {STEP_NAME}_Fail
            END
         END
      END
```

### Simplified Version (Function-Specific Parameters)

```sql
      -- Extended Validate
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedValidateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @cTaskDetailKey, @cToLoc, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,           ' +
               '@nFunc           INT,           ' +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,           ' +
               '@cTaskDetailKey  NVARCHAR( 10), ' +
               '@cToLoc          NVARCHAR( 10), ' +
               '@nErrNo          INT OUTPUT,    ' +
               '@cErrMsg         NVARCHAR( 20) OUTPUT'

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @cTaskDetailKey, @cToLoc, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
               GOTO Quit
         END
      END
```

---

## 2. Extended Update SP Call

**Position:** After standard update/transaction, before COMMIT

**Purpose:** Perform custom data modifications within the same transaction

### Template Code

```sql
      -- ========================================================
      -- EXTENDED UPDATE SP: Custom update within transaction
      -- ========================================================
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cRefNo, @cPickSlipNo, @cLoadKey, @cOrderKey, @cDropID, ' + 
               ' @cSKU, @nQty, @cOption, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cID, @cTaskDetailKey, @cReasonCode OUTPUT' 
            SET @cSQLParam =
               '@nMobile         INT,           ' +
               '@nFunc           INT,           ' +
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
               '@cReasonCode     NVARCHAR( 20) OUTPUT ' 

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cStorerKey, @cRefNo, @cPickSlipNo, @cLoadKey, @cOrderKey, @cDropID, 
               @cSKU, @nQty, @cOption, @nErrNo OUTPUT, @cErrMsg OUTPUT, @cID, @cTaskDetailKey, @cReasonCode OUTPUT      

            IF @nErrNo <> 0
            BEGIN
               ROLLBACK TRAN {SP_NAME}
               WHILE @@TRANCOUNT > @nTranCount
                  COMMIT TRAN
               GOTO Quit
            END
         END
      END
```

### Simplified Version (Function-Specific Parameters)

```sql
      -- Extended Update
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedUpdateSP) +
               ' @nMobile, @nFunc, @cLangCode, @nStep, @cTaskDetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT'
            SET @cSQLParam =
               '@nMobile         INT,           ' +
               '@nFunc           INT,           ' +
               '@cLangCode       NVARCHAR( 3),  ' +
               '@nStep           INT,           ' +
               '@cTaskDetailKey  NVARCHAR( 10), ' +
               '@nErrNo          INT OUTPUT,    ' +
               '@cErrMsg         NVARCHAR( 20) OUTPUT '

            EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
               @nMobile, @nFunc, @cLangCode, @nStep, @cTaskDetailKey, @nErrNo OUTPUT, @cErrMsg OUTPUT

            IF @nErrNo <> 0
            BEGIN
               ROLLBACK TRAN {SP_NAME}
               WHILE @@TRANCOUNT > @nTranCount
                  COMMIT TRAN
               GOTO Quit
            END
         END
      END
```

---

## 3. Extended Info SP Call

**Position:** After both @nInputKey = 1 (ENTER) and @nInputKey = 0 (ESC) blocks, before GOTO Quit

**Purpose:** Display custom information on screen for both ENTER and ESC scenarios

### Template Code

```sql
   -- ========================================================
   -- EXTENDED INFO SP: Display custom info (after ENTER and ESC blocks)
   -- ========================================================
   IF @cExtendedInfoSP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedInfoSP AND type = 'P')
      BEGIN
         INSERT INTO @tExtInfo (Variable, Value) VALUES 
            ('@cRefNo',       @cRefNo), 
            ('@cPickSlipNo',  @cPickSlipNo), 
            ('@cLoadKey',     @cLoadKey), 
            ('@cOrderKey',    @cOrderKey), 
            ('@cDropID',      @cDropID), 
            ('@cID',          @cID), 
            ('@cTaskDetailKey',  @cTaskDetailKey), 
            ('@cSKU',         @cSKU), 
            ('@nQTY',         CAST( @nQTY AS NVARCHAR( 10))), 
            ('@nCSKU',        CAST( @nCSKU AS NVARCHAR( 10))), 
            ('@nCQTY',        CAST( @nCQTY AS NVARCHAR( 10))), 
            ('@nPSKU',        CAST( @nPSKU AS NVARCHAR( 10))), 
            ('@nPQTY',        CAST( @nPQTY AS NVARCHAR( 10))), 
            ('@cOption',      @cOption)
         
         SET @cExtendedInfo = ''
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
            ' @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @tExtInfo, ' +
            ' @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT'
         SET @cSQLParam =
            ' @nMobile        INT,           ' +
            ' @nFunc          INT,           ' +
            ' @cLangCode      NVARCHAR( 3),  ' +
            ' @nStep          INT,           ' +
            ' @nAfterStep     INT,           ' +
            ' @nInputKey      INT,           ' +
            ' @cFacility      NVARCHAR( 5),  ' +
            ' @cStorerKey     NVARCHAR( 15), ' +
            ' @tExtInfo       VariableTable READONLY, ' + 
            ' @cExtendedInfo  NVARCHAR( 20) OUTPUT, ' + 
            ' @nErrNo         INT           OUTPUT, ' +
            ' @cErrMsg        NVARCHAR( 20) OUTPUT  '
         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey, @cFacility, @cStorerKey, @tExtInfo, 
            @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT
      
         SET @cOutField10 = @cExtendedInfo
      END
   END
```

### Simplified Version (Function-Specific Parameters)

```sql
   -- Extended Info
   IF @cExtendedInfoSP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedInfoSP AND type = 'P')
      BEGIN
         SET @cExtendedInfo1 = ''
         SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtendedInfoSP) +
            ' @nMobile, @nFunc, @cLangCode, @nStep, @cTaskDetailKey, @cExtendedInfo1 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nAfterStep'
         SET @cSQLParam =
            '@nMobile         INT,           ' +
            '@nFunc           INT,           ' +
            '@cLangCode       NVARCHAR( 3),  ' +
            '@nStep           INT,           ' +
            '@cTaskDetailKey  NVARCHAR( 10), ' +
            '@cExtendedInfo1  NVARCHAR( 20) OUTPUT, ' +
            '@nErrNo          INT           OUTPUT, ' +
            '@cErrMsg         NVARCHAR( 20) OUTPUT, ' +
            '@nAfterStep      INT '

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
            @nMobile, @nFunc, @cLangCode, @nStep, @cTaskDetailKey, @cExtendedInfo1 OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT, @nAfterStep

         SET @cOutField10 = @cExtendedInfo1
      END
   END
```

---

## Complete Step Structure Example

Below is a complete example showing where each Extended SP call should be placed within a step:

```sql
/********************************************************************************
Step X. screen = XXXX. {STEP_NAME}
********************************************************************************/
{STEP_NAME}:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- ========================================================
      -- 1. STANDARD VALIDATION
      -- ========================================================
      -- Check blank field
      IF @cInputField = ''
      BEGIN
         SET @nErrNo = 72285
         SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
         GOTO {STEP_NAME}_Fail
      END

      -- Other standard validations...

      -- ========================================================
      -- 2. EXTENDED VALIDATE SP (After standard validation)
      -- ========================================================
      IF @cExtendedValidateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedValidateSP AND type = 'P')
         BEGIN
            -- Dynamic call code here...
            IF @nErrNo <> 0
               GOTO {STEP_NAME}_Fail
         END
      END

      -- ========================================================
      -- 3. BEGIN TRANSACTION
      -- ========================================================
      DECLARE @nTranCount INT
      SET @nTranCount = @@TRANCOUNT
      BEGIN TRAN
      SAVE TRAN {SP_NAME}

      -- ========================================================
      -- 4. STANDARD UPDATE
      -- ========================================================
      EXEC rdt.rdt_StandardUpdate ...
      IF @nErrNo <> 0
      BEGIN
         ROLLBACK TRAN {SP_NAME}
         WHILE @@TRANCOUNT > @nTranCount
            COMMIT TRAN
         GOTO Quit
      END

      -- ========================================================
      -- 5. EXTENDED UPDATE SP (After standard update, before COMMIT)
      -- ========================================================
      IF @cExtendedUpdateSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedUpdateSP AND type = 'P')
         BEGIN
            -- Dynamic call code here...
            IF @nErrNo <> 0
            BEGIN
               ROLLBACK TRAN {SP_NAME}
               WHILE @@TRANCOUNT > @nTranCount
                  COMMIT TRAN
               GOTO Quit
            END
         END
      END

      -- ========================================================
      -- 6. COMMIT TRANSACTION
      -- ========================================================
      COMMIT TRAN {SP_NAME}
      WHILE @@TRANCOUNT > @nTranCount
         COMMIT TRAN

      -- Prepare next screen var
      SET @cOutField01 = @cValue1
      SET @cOutField10 = '' -- ExtendedInfo placeholder

      SET @nScn = @nNextScn
      SET @nStep = @nNextStep
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      -- Prepare previous screen var
      SET @cOutField01 = ''
      SET @cOutField10 = '' -- ExtendedInfo placeholder

      SET @nScn = @nFromScn
      SET @nStep = @nFromStep
   END

   -- ========================================================
   -- 7. EXTENDED INFO SP (After both ENTER and ESC blocks)
   -- ========================================================
   IF @cExtendedInfoSP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtendedInfoSP AND type = 'P')
      BEGIN
         -- Dynamic call code here...
         SET @cOutField10 = @cExtendedInfo
      END
   END

   GOTO Quit

   {STEP_NAME}_Fail:
      -- Reset screen fields on failure
      SET @cOutField01 = ''
END
```

---

## Key Points

### 1. Call Sequence
| Order | Extended SP | Position | Purpose |
|-------|-------------|----------|---------|
| 1 | ExtendedValidateSP | After standard validation | Custom validation |
| 2 | ExtendedUpdateSP | After standard update, before COMMIT | Custom data modification |
| 3 | ExtendedInfoSP | After ENTER and ESC blocks | Display custom info |

### 2. Error Handling
- **ExtendedValidateSP:** GOTO {STEP_NAME}_Fail on error
- **ExtendedUpdateSP:** ROLLBACK + GOTO Quit on error
- **ExtendedInfoSP:** Usually no error handling needed (display only)

### 3. Transaction Context
- **ExtendedValidateSP:** Called BEFORE transaction
- **ExtendedUpdateSP:** Called WITHIN transaction (rollback on error)
- **ExtendedInfoSP:** Called AFTER transaction (no transaction context)

### 4. Variable Declaration in Step 0
Make sure to declare the Extended SP variables and read from config in Step 0:

```sql
-- Declare variables
DECLARE @cExtendedValidateSP NVARCHAR(20)
DECLARE @cExtendedUpdateSP   NVARCHAR(20)
DECLARE @cExtendedInfoSP     NVARCHAR(20)

-- Read from config
SET @cExtendedValidateSP = rdt.RDTGetConfig(@nFunc, 'ExtendedValidateSP', @cStorerKey)
IF @cExtendedValidateSP = '0'
   SET @cExtendedValidateSP = ''

SET @cExtendedUpdateSP = rdt.RDTGetConfig(@nFunc, 'ExtendedUpdateSP', @cStorerKey)
IF @cExtendedUpdateSP = '0'
   SET @cExtendedUpdateSP = ''

SET @cExtendedInfoSP = rdt.RDTGetConfig(@nFunc, 'ExtendedInfoSP', @cStorerKey)
IF @cExtendedInfoSP = '0'
   SET @cExtendedInfoSP = ''
```

---

## Reference SP
- Main Function SP: `rdtfnc_TM_Replen` (Step_ToLOC)
- ExtendedValidateSP: Lines 2765-2787
- ExtendedUpdateSP: Lines 2828-2854
- ExtendedInfoSP: Lines 2933-2957
