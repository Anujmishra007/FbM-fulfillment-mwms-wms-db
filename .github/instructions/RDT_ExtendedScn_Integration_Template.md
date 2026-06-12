---
applyTo: "WMS/StoredProc/RDT/rdtfnc_*.sql"
description: "Template for integrating ExtScnSP entry and Step_99 backend logic into a Main Function SP. Load when wiring ExtScnSP into rdtfnc_*.sql files."
---

# RDT Extended Screen SP Integration Template

## Overview
Template for integrating Extended Screen SP into main RDT function SPs. This template covers:
1. Adding ExtScnSP entry point in existing steps (to skip/redirect flow or modify output fields)
2. Adding Step_99 section for Extended Screen SP backend logic

## Use Cases

### Use Case 1: Skip Standard Flow / Redirect to Specific Step
In existing flow, skip from a specific step to bypass the next step in standard flow, jump to a specified step (existing or newly created) according to customer requirements

### Use Case 2: Modify Next Screen Data
Change the data for the next screen, typically by modifying output fields (e.g., `SET @cOutField06 = @cLottable03`)

---

## Part 1: Add ExtScnSP Entry Point in Existing Step

**Position:** At the end of the step, after ExtendedInfoSP call, before GOTO Quit

### Template Code

```sql
   -- ========================================================
   -- EXTENDED SCREEN SP ENTRY: Redirect to Step_99 for custom screen logic
   -- ========================================================
   IF @cExtScnSP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtScnSP AND type = 'P')
      BEGIN
         GOTO Step_99
      END
   END

   GOTO Quit

   {STEP_NAME}_Fail:
   BEGIN
      -- Reset screen fields on failure
      SET @cOutField01 = ''
   END
END
GOTO Quit
```

### Complete Step Structure with ExtScnSP Entry

```sql
/********************************************************************************
Step X. screen = XXXX. {STEP_NAME}
********************************************************************************/
{STEP_NAME}:
BEGIN
   IF @nInputKey = 1 -- ENTER
   BEGIN
      -- Standard validation...
      
      -- ExtendedValidateSP call (if needed)...
      
      -- Transaction and standard update...
      
      -- ExtendedUpdateSP call (if needed)...
      
      -- Prepare next screen var
      SET @cOutField01 = @cValue1
      SET @cOutField10 = '' -- ExtendedInfo

      SET @nScn = @nNextScn
      SET @nStep = @nNextStep
   END

   IF @nInputKey = 0 -- ESC
   BEGIN
      -- Prepare previous screen var
      SET @cOutField01 = ''
      SET @cOutField10 = '' -- ExtendedInfo

      SET @nScn = @nFromScn
      SET @nStep = @nFromStep
   END

   -- ExtendedInfoSP call (if needed)...

   -- ========================================================
   -- EXTENDED SCREEN SP ENTRY (Add this block)
   -- ========================================================
   IF @cExtScnSP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtScnSP AND type = 'P')
      BEGIN
         GOTO Step_99
      END
   END

   GOTO Quit

   {STEP_NAME}_Fail:
   BEGIN
      SET @cOutField01 = ''
   END
END
GOTO Quit
```

---

## Part 2: Add Step_99 Section for Extended Screen Backend

**Position:** Before the Quit section, after all standard steps

### Template Code

```sql
/********************************************************************************
Step 99. Extended Screen - Custom screen logic handled by ExtScnSP
********************************************************************************/
Step_99:
BEGIN
   IF @cExtScnSP <> ''
   BEGIN
      IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @cExtScnSP AND type = 'P')
      BEGIN
         -- ========================================================
         -- 1. DECLARE LOCAL VARIABLES
         -- ========================================================
         DECLARE 
            @nCurrentScn      INT = @nScn,
            @nCurrentStep     INT = @nStep,
            @nPreviousScn     INT,
            @nPreviousStep    INT

         -- Get previous screen/step from RDTMOBREC
         SELECT @nPreviousScn = Scn, @nPreviousStep = Step
         FROM RDT.RDTMOBREC WITH (NOLOCK)
         WHERE Mobile = @nMobile

         -- ========================================================
         -- 2. PREPARE @tExtScnData (Pass context to ExtScnSP)
         -- ========================================================
         DELETE FROM @tExtScnData

         INSERT INTO @tExtScnData (Variable, Value) 
         VALUES
            ('@cDropID',          @cDropID),
            ('@cTaskDetailKey',   @cTaskDetailKey),
            ('@cSKU',             @cSKU),
            ('@nQTY',             CAST(@nQTY AS NVARCHAR(10))),
            ('@cFromLOC',         @cFromLOC),
            ('@cToLOC',           @cToLOC)
            -- Add more context variables as needed
         
         -- ========================================================
         -- 3. CALL rdt_ExtScnEntry (Standard entry point)
         -- ========================================================
         EXECUTE [RDT].[rdt_ExtScnEntry] 
            @cExtScnSP,
            @nMobile, @nFunc, @cLangCode, @nStep, @nScn, @nInputKey, @cFacility, @cStorerKey, @tExtScnData,
            @cInField01 OUTPUT,  @cOutField01 OUTPUT,  @cFieldAttr01 OUTPUT, @cLottable01 OUTPUT,
            @cInField02 OUTPUT,  @cOutField02 OUTPUT,  @cFieldAttr02 OUTPUT, @cLottable02 OUTPUT,
            @cInField03 OUTPUT,  @cOutField03 OUTPUT,  @cFieldAttr03 OUTPUT, @cLottable03 OUTPUT,
            @cInField04 OUTPUT,  @cOutField04 OUTPUT,  @cFieldAttr04 OUTPUT, @dLottable04 OUTPUT,
            @cInField05 OUTPUT,  @cOutField05 OUTPUT,  @cFieldAttr05 OUTPUT, @dLottable05 OUTPUT,
            @cInField06 OUTPUT,  @cOutField06 OUTPUT,  @cFieldAttr06 OUTPUT, @cLottable06 OUTPUT,
            @cInField07 OUTPUT,  @cOutField07 OUTPUT,  @cFieldAttr07 OUTPUT, @cLottable07 OUTPUT,
            @cInField08 OUTPUT,  @cOutField08 OUTPUT,  @cFieldAttr08 OUTPUT, @cLottable08 OUTPUT,
            @cInField09 OUTPUT,  @cOutField09 OUTPUT,  @cFieldAttr09 OUTPUT, @cLottable09 OUTPUT,
            @cInField10 OUTPUT,  @cOutField10 OUTPUT,  @cFieldAttr10 OUTPUT, @cLottable10 OUTPUT,
            @cInField11 OUTPUT,  @cOutField11 OUTPUT,  @cFieldAttr11 OUTPUT, @cLottable11 OUTPUT,
            @cInField12 OUTPUT,  @cOutField12 OUTPUT,  @cFieldAttr12 OUTPUT, @cLottable12 OUTPUT,
            @cInField13 OUTPUT,  @cOutField13 OUTPUT,  @cFieldAttr13 OUTPUT, @dLottable13 OUTPUT,
            @cInField14 OUTPUT,  @cOutField14 OUTPUT,  @cFieldAttr14 OUTPUT, @dLottable14 OUTPUT,
            @cInField15 OUTPUT,  @cOutField15 OUTPUT,  @cFieldAttr15 OUTPUT, @dLottable15 OUTPUT,
            @nAction, 
            @nScn OUTPUT,  @nStep OUTPUT,
            @nErrNo   OUTPUT, 
            @cErrMsg  OUTPUT,
            @cUDF01 OUTPUT, @cUDF02 OUTPUT, @cUDF03 OUTPUT,
            @cUDF04 OUTPUT, @cUDF05 OUTPUT, @cUDF06 OUTPUT,
            @cUDF07 OUTPUT, @cUDF08 OUTPUT, @cUDF09 OUTPUT,
            @cUDF10 OUTPUT, @cUDF11 OUTPUT, @cUDF12 OUTPUT,
            @cUDF13 OUTPUT, @cUDF14 OUTPUT, @cUDF15 OUTPUT,
            @cUDF16 OUTPUT, @cUDF17 OUTPUT, @cUDF18 OUTPUT,
            @cUDF19 OUTPUT, @cUDF20 OUTPUT, @cUDF21 OUTPUT,
            @cUDF22 OUTPUT, @cUDF23 OUTPUT, @cUDF24 OUTPUT,
            @cUDF25 OUTPUT, @cUDF26 OUTPUT, @cUDF27 OUTPUT,
            @cUDF28 OUTPUT, @cUDF29 OUTPUT, @cUDF30 OUTPUT

         -- ========================================================
         -- 4. ERROR HANDLING
         -- ========================================================
         IF @nErrNo <> 0
         BEGIN
            -- Custom error handling based on specific ExtScnSP (if needed)
            -- Example:
            -- IF @cExtScnSP = 'rdt_XXXXExtScn01'
            -- BEGIN
            --    -- Custom handling
            -- END
            GOTO Step_99_Fail
         END

         -- ========================================================
         -- 5. POST-PROCESSING: Handle UDF values returned from ExtScnSP
         -- ========================================================
         -- Example: Map UDF values back to main SP variables
         -- IF @cExtScnSP = 'rdt_XXXXExtScn01'
         -- BEGIN
         --    IF @nStep = @nStep_ToLoc AND @nPreviousStep = 0
         --    BEGIN
         --       SET @cDropID = @cUDF01
         --       SET @cTaskDetailKey = @cUDF02
         --    END
         -- END

      END
   END
   GOTO Quit

   Step_99_Fail:
      GOTO Quit

END
```

---

## Part 3: Variable Declaration in Step 0

Add these declarations in Step 0 of the main function SP:

### ExtScnSP Config Variable

```sql
-- Declare ExtScnSP variable
DECLARE @cExtScnSP NVARCHAR(20)

-- Read from config
SET @cExtScnSP = rdt.RDTGetConfig(@nFunc, 'ExtScnSP', @cStorerKey)
IF @cExtScnSP = '0'
   SET @cExtScnSP = ''
```

### @tExtScnData Table Variable

```sql
-- Declare table variable for passing context to ExtScnSP
DECLARE @tExtScnData VariableTable
```

### UDF Variables

```sql
-- Declare UDF variables for receiving data from ExtScnSP
DECLARE
   @cUDF01  NVARCHAR(250), @cUDF02 NVARCHAR(250), @cUDF03 NVARCHAR(250),
   @cUDF04  NVARCHAR(250), @cUDF05 NVARCHAR(250), @cUDF06 NVARCHAR(250),
   @cUDF07  NVARCHAR(250), @cUDF08 NVARCHAR(250), @cUDF09 NVARCHAR(250),
   @cUDF10  NVARCHAR(250), @cUDF11 NVARCHAR(250), @cUDF12 NVARCHAR(250),
   @cUDF13  NVARCHAR(250), @cUDF14 NVARCHAR(250), @cUDF15 NVARCHAR(250),
   @cUDF16  NVARCHAR(250), @cUDF17 NVARCHAR(250), @cUDF18 NVARCHAR(250),
   @cUDF19  NVARCHAR(250), @cUDF20 NVARCHAR(250), @cUDF21 NVARCHAR(250),
   @cUDF22  NVARCHAR(250), @cUDF23 NVARCHAR(250), @cUDF24 NVARCHAR(250),
   @cUDF25  NVARCHAR(250), @cUDF26 NVARCHAR(250), @cUDF27 NVARCHAR(250),
   @cUDF28  NVARCHAR(250), @cUDF29 NVARCHAR(250),
   @cUDF30  NVARCHAR(MAX)
```

### Step Router - Add Step 99 Entry

```sql
-- Add in step router section
IF @nStep = 99 GOTO Step_99
```

---

## Part 4: ExtScnSP Output Processing Examples

### Example 1: Redirect to Different Step

```sql
-- In ExtScnSP: Set @nAfterScn and @nAfterStep to redirect
SET @nAfterScn = 2688    -- Target screen number
SET @nAfterStep = 7      -- Target step number
```

### Example 2: Modify Output Fields

```sql
-- In ExtScnSP: Modify output fields for next screen
SET @cOutField06 = @cLottable03    -- Copy lottable to output field
SET @cOutField01 = 'Custom Value'   -- Set custom value
SET @cFieldAttr02 = 'O'            -- Make field output-only
```

### Example 3: Return Data via UDF

```sql
-- In ExtScnSP: Pass data back via UDF
SET @cUDF01 = @cDropID
SET @cUDF02 = @cTaskDetailKey
SET @cUDF03 = CAST(@nQTY AS NVARCHAR(10))

-- In Main SP Step_99: Map UDF back to variables
SET @cDropID = @cUDF01
SET @cTaskDetailKey = @cUDF02
SET @nQTY = TRY_CAST(@cUDF03 AS INT)
```

---

## Key Points

### 1. Configuration Key
```sql
-- Config key is 'ExtScnSP'
SET @cExtScnSP = rdt.RDTGetConfig(@nFunc, 'ExtScnSP', @cStorerKey)
```

### 2. Entry Point Location
ExtScnSP entry point should be added at the **end of each step**, after:
- Standard validation
- ExtendedValidateSP
- Transaction/Update
- ExtendedUpdateSP
- ExtendedInfoSP

### 3. Step_99 Standard Label
All Extended Screen logic goes through Step_99. The actual screen/step can be any number, but the entry point label is always Step_99.

### 4. rdt_ExtScnEntry
This is the standard entry point that calls the actual ExtScnSP:
```sql
EXECUTE [RDT].[rdt_ExtScnEntry] @cExtScnSP, ...
```

### 5. @tExtScnData Context Passing
Use `@tExtScnData` table variable to pass context from main SP to ExtScnSP:
```sql
INSERT INTO @tExtScnData (Variable, Value) VALUES
   ('@cDropID', @cDropID),
   ('@cTaskDetailKey', @cTaskDetailKey)
```

### 6. UDF for Return Values
Use `@cUDF01` - `@cUDF30` to pass data back from ExtScnSP to main SP.

### 7. Navigation Control
ExtScnSP controls navigation by setting:
- `@nAfterScn` - Next screen number
- `@nAfterStep` - Next step number

---

## Reference SP
- Main Function SP: `rdtfnc_TM_Replen`
- ExtScnSP Entry Point: Lines 2959-2965 (Step_ToLOC)
- Step_99 Section: Lines 3715-3920
