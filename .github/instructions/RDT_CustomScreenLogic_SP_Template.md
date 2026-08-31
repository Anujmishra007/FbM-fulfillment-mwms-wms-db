---
applyTo: "WMS/StoredProc/RDT/rdt_*ExtScn*.sql"
description: "Template for RDT ExtendedScnSP stored procedures (custom screen logic / Step_99 handling). Load when creating or editing rdt_<func>ExtScn*.sql files."
---

# RDT Extended Screen SP Template

## Overview
Template for creating RDT Extended Screen Stored Procedures that handle custom screen logic, screen navigation, and field I/O operations in RDT functions.

## Template Parameters
- `{SP_NAME}` - Stored procedure name (e.g., rdt_1730ExtScn01)
- `{FUNC_NO}` - Function number (e.g., 1730)
- `{TICKET_NO}` - Ticket number for version history (e.g., FCR-12345)
- `{AUTHOR}` - Author name
- `{DATE}` - Creation date (DD-MM-YYYY)
- `{DESCRIPTION}` - Brief description of the SP purpose

## Template

```sql
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Store procedure: {SP_NAME}                                                 */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Date       Rev  Author      Purposes                                       */
/* {DATE} 1.0  {AUTHOR}    {TICKET_NO} {DESCRIPTION}                          */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[{SP_NAME}] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR(3),
   @nStep            INT,
   @nScn             INT,
   @nInputKey        INT,
   @cFacility        NVARCHAR(5),
   @cStorerKey       NVARCHAR(15),
   @tExtScnData      VariableTable READONLY,
   @cInField01       NVARCHAR(60) OUTPUT,  @cOutField01 NVARCHAR(60) OUTPUT,  @cFieldAttr01 NVARCHAR(1) OUTPUT,  @cLottable01 NVARCHAR(18) OUTPUT,
   @cInField02       NVARCHAR(60) OUTPUT,  @cOutField02 NVARCHAR(60) OUTPUT,  @cFieldAttr02 NVARCHAR(1) OUTPUT,  @cLottable02 NVARCHAR(18) OUTPUT,
   @cInField03       NVARCHAR(60) OUTPUT,  @cOutField03 NVARCHAR(60) OUTPUT,  @cFieldAttr03 NVARCHAR(1) OUTPUT,  @cLottable03 NVARCHAR(18) OUTPUT,
   @cInField04       NVARCHAR(60) OUTPUT,  @cOutField04 NVARCHAR(60) OUTPUT,  @cFieldAttr04 NVARCHAR(1) OUTPUT,  @dLottable04 DATETIME      OUTPUT,
   @cInField05       NVARCHAR(60) OUTPUT,  @cOutField05 NVARCHAR(60) OUTPUT,  @cFieldAttr05 NVARCHAR(1) OUTPUT,  @dLottable05 DATETIME      OUTPUT,
   @cInField06       NVARCHAR(60) OUTPUT,  @cOutField06 NVARCHAR(60) OUTPUT,  @cFieldAttr06 NVARCHAR(1) OUTPUT,  @cLottable06 NVARCHAR(30) OUTPUT,
   @cInField07       NVARCHAR(60) OUTPUT,  @cOutField07 NVARCHAR(60) OUTPUT,  @cFieldAttr07 NVARCHAR(1) OUTPUT,  @cLottable07 NVARCHAR(30) OUTPUT,
   @cInField08       NVARCHAR(60) OUTPUT,  @cOutField08 NVARCHAR(60) OUTPUT,  @cFieldAttr08 NVARCHAR(1) OUTPUT,  @cLottable08 NVARCHAR(30) OUTPUT,
   @cInField09       NVARCHAR(60) OUTPUT,  @cOutField09 NVARCHAR(60) OUTPUT,  @cFieldAttr09 NVARCHAR(1) OUTPUT,  @cLottable09 NVARCHAR(30) OUTPUT,
   @cInField10       NVARCHAR(60) OUTPUT,  @cOutField10 NVARCHAR(60) OUTPUT,  @cFieldAttr10 NVARCHAR(1) OUTPUT,  @cLottable10 NVARCHAR(30) OUTPUT,
   @cInField11       NVARCHAR(60) OUTPUT,  @cOutField11 NVARCHAR(60) OUTPUT,  @cFieldAttr11 NVARCHAR(1) OUTPUT,  @cLottable11 NVARCHAR(30) OUTPUT,
   @cInField12       NVARCHAR(60) OUTPUT,  @cOutField12 NVARCHAR(60) OUTPUT,  @cFieldAttr12 NVARCHAR(1) OUTPUT,  @cLottable12 NVARCHAR(30) OUTPUT,
   @cInField13       NVARCHAR(60) OUTPUT,  @cOutField13 NVARCHAR(60) OUTPUT,  @cFieldAttr13 NVARCHAR(1) OUTPUT,  @dLottable13 DATETIME      OUTPUT,
   @cInField14       NVARCHAR(60) OUTPUT,  @cOutField14 NVARCHAR(60) OUTPUT,  @cFieldAttr14 NVARCHAR(1) OUTPUT,  @dLottable14 DATETIME      OUTPUT,
   @cInField15       NVARCHAR(60) OUTPUT,  @cOutField15 NVARCHAR(60) OUTPUT,  @cFieldAttr15 NVARCHAR(1) OUTPUT,  @dLottable15 DATETIME      OUTPUT,
   @nAction          INT,
   @nAfterScn        INT OUTPUT,
   @nAfterStep       INT OUTPUT,
   @nErrNo           INT OUTPUT,
   @cErrMsg          NVARCHAR(20) OUTPUT,
   @cUDF01  NVARCHAR(250) OUTPUT, @cUDF02 NVARCHAR(250) OUTPUT, @cUDF03 NVARCHAR(250) OUTPUT,
   @cUDF04  NVARCHAR(250) OUTPUT, @cUDF05 NVARCHAR(250) OUTPUT, @cUDF06 NVARCHAR(250) OUTPUT,
   @cUDF07  NVARCHAR(250) OUTPUT, @cUDF08 NVARCHAR(250) OUTPUT, @cUDF09 NVARCHAR(250) OUTPUT,
   @cUDF10  NVARCHAR(250) OUTPUT, @cUDF11 NVARCHAR(250) OUTPUT, @cUDF12 NVARCHAR(250) OUTPUT,
   @cUDF13  NVARCHAR(250) OUTPUT, @cUDF14 NVARCHAR(250) OUTPUT, @cUDF15 NVARCHAR(250) OUTPUT,
   @cUDF16  NVARCHAR(250) OUTPUT, @cUDF17 NVARCHAR(250) OUTPUT, @cUDF18 NVARCHAR(250) OUTPUT,
   @cUDF19  NVARCHAR(250) OUTPUT, @cUDF20 NVARCHAR(250) OUTPUT, @cUDF21 NVARCHAR(250) OUTPUT,
   @cUDF22  NVARCHAR(250) OUTPUT, @cUDF23 NVARCHAR(250) OUTPUT, @cUDF24 NVARCHAR(250) OUTPUT,
   @cUDF25  NVARCHAR(250) OUTPUT, @cUDF26 NVARCHAR(250) OUTPUT, @cUDF27 NVARCHAR(250) OUTPUT,
   @cUDF28  NVARCHAR(250) OUTPUT, @cUDF29 NVARCHAR(250) OUTPUT,
   @cUDF30  NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   -- ============================================================
   -- Variable declarations
   -- ============================================================
   DECLARE
      @nCurrentStep    INT,
      @nCurrentScn     INT,
      @nTranCount      INT

   -- Initialize UDF outputs
   SET @cUDF01 = ''
   SET @cUDF02 = ''
   SET @cUDF03 = ''
   SET @cUDF04 = ''

   -- Only process for specific function
   IF @nFunc <> {FUNC_NO}
      GOTO Quit

   -- Get current session info from RDTMOBREC
   SELECT 
      @nCurrentStep = Step,
      @nCurrentScn = Scn
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   /********************************************************************************
   Step 99: Extended Screen (Standard step label for extended screens)
   ********************************************************************************/
   IF @nCurrentStep = 99
   BEGIN
      IF @nInputKey = 1 -- ENTER
      BEGIN
         -- ========================================================
         -- ENTER KEY LOGIC: Process user input and navigate
         -- ========================================================
         
         -- Example: Get input from @tExtScnData
         -- DECLARE @cInputValue NVARCHAR(60)
         -- SELECT @cInputValue = Value FROM @tExtScnData WHERE Variable = '@cInputField'

         -- Example: Validation
         -- IF @cInputValue = '' OR @cInputValue IS NULL
         -- BEGIN
         --    SET @nErrNo = 131XXX
         --    SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
         --    GOTO Step_99_Fail
         -- END

         -- Example: Set output fields for next screen
         -- SET @cOutField01 = 'Value1'
         -- SET @cOutField02 = 'Value2'

         -- Example: Set UDF values for parent SP
         -- SET @cUDF01 = 'CustomValue1'
         -- SET @cUDF02 = 'CustomValue2'

         -- Navigate to next screen
         -- SET @nAfterScn = 1234
         -- SET @nAfterStep = 99

         GOTO Quit
      END

      IF @nInputKey = 0 -- ESC
      BEGIN
         -- ========================================================
         -- ESC KEY LOGIC: Navigate back to previous screen
         -- ========================================================
         
         -- Example: Set output fields for previous screen
         -- SET @cOutField01 = ''

         -- Navigate to previous screen
         -- SET @nAfterScn = 1230
         -- SET @nAfterStep = 3

         GOTO Quit
      END

      Step_99_Fail:
         -- Reset screen fields on failure
         -- SET @cOutField01 = ''
         -- SET @nAfterScn = @nCurrentScn
         -- SET @nAfterStep = 99
   END

Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.{SP_NAME} TO NSQL
GO
```

## SP Parameters (Fixed Parameters)

ExtendedScnSP has a fixed parameter signature that cannot be changed:

### Basic Parameters
| Parameter | Type | Direction | Description |
|-----------|------|-----------|-------------|
| @nMobile | INT | IN | Mobile device number |
| @nFunc | INT | IN | Function number |
| @cLangCode | NVARCHAR(3) | IN | Language code |
| @nStep | INT | IN | Current step number |
| @nScn | INT | IN | Current screen number |
| @nInputKey | INT | IN | Input key (1=ENTER, 0=ESC) |
| @cFacility | NVARCHAR(5) | IN | Facility code |
| @cStorerKey | NVARCHAR(15) | IN | Storer key |
| @tExtScnData | VariableTable | READONLY | Additional variables from main SP |
| @nAction | INT | IN | Action code |
| @nAfterScn | INT | OUTPUT | Next screen number to navigate |
| @nAfterStep | INT | OUTPUT | Next step number to navigate |
| @nErrNo | INT | OUTPUT | Error number (0=success) |
| @cErrMsg | NVARCHAR(20) | OUTPUT | Error message |

### Field I/O Parameters (15 sets)
Each field has 4 parameters:
| Parameter | Type | Direction | Description |
|-----------|------|-----------|-------------|
| @cInFieldXX | NVARCHAR(60) | OUTPUT | Input value from screen field |
| @cOutFieldXX | NVARCHAR(60) | OUTPUT | Output value to screen field |
| @cFieldAttrXX | NVARCHAR(1) | OUTPUT | Field attribute (''=editable, 'O'=output only) |
| @cLottableXX / @dLottableXX | NVARCHAR/DATETIME | OUTPUT | Lottable value |

### UDF Parameters (30 fields)
| Parameter | Type | Direction | Description |
|-----------|------|-----------|-------------|
| @cUDF01 - @cUDF29 | NVARCHAR(250) | OUTPUT | User defined fields for custom data |
| @cUDF30 | NVARCHAR(MAX) | OUTPUT | Large user defined field |

## Key Points

### 1. Configuration Name
The RDT config key for ExtendedScnSP is `ExtScnSP`:
```sql
SET @cExtendedScnSP = rdt.RDTGetConfig(@nFunc, 'ExtScnSP', @cStorerKey)
```

### 2. Step Label Convention
Extended screen sections use `Step_99` as the standard step label:
```sql
IF @nCurrentStep = 99
BEGIN
   -- Extended screen logic
END
```

### 3. Screen Navigation
Use `@nAfterScn` and `@nAfterStep` to control navigation:
```sql
-- Navigate to specific screen
SET @nAfterScn = 1738
SET @nAfterStep = 99

-- Navigate back
SET @nAfterScn = 1732
SET @nAfterStep = 3
```

### 4. Field I/O Operations
```sql
-- Read input from user
SET @cInputValue = @cInField01

-- Set output to display
SET @cOutField01 = 'Display Value'

-- Set field as output only (non-editable)
SET @cFieldAttr01 = 'O'

-- Set field as editable
SET @cFieldAttr01 = ''
```

### 5. UDF for Passing Data to Parent SP
```sql
-- Pass custom data back to parent SP
SET @cUDF01 = CAST(@nQty AS NVARCHAR(10))
SET @cUDF02 = @cSKU
SET @cUDF03 = @cReason
```

### 6. Error Handling Pattern
```sql
IF validation_fails
BEGIN
   SET @nErrNo = 131XXX
   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
   GOTO Step_99_Fail
END
```

### 7. Standard SET Options
```sql
SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF
```

## Difference from Other Extended SPs

| Aspect | ExtendedScnSP | ExtendedInfoSP | ExtendedValidateSP | ExtendedUpdateSP |
|--------|---------------|----------------|-------------------|------------------|
| Purpose | Custom screen logic | Display info | Validation only | Data modification |
| Parameters | Fixed (90+) | 12 | 16 | 19 |
| Field I/O | 15 sets (In/Out/Attr/Lottable) | None | None | None |
| UDF | 30 fields | None | None | None |
| Navigation | @nAfterScn, @nAfterStep | None | None | None |
| Transaction | Optional | Not needed | Not needed | Required |
| Config Key | ExtScnSP | ExtendedInfoSP | ExtendedValidateSP | ExtendedUpdateSP |
| Step Label | Step_99 | N/A | N/A | N/A |

## Common Error Codes Reference
| Code | Description |
|------|-------------|
| 64070 | ToLoc is needed |
| 64071 | Invalid ToLoc |
| 64072 | Different Facility |

## Usage Example
Replace the placeholders with actual values:
- `{SP_NAME}` -> `rdt_1730ExtScn02`
- `{FUNC_NO}` -> `1730`
- `{TICKET_NO}` -> `FCR-12345`
- `{AUTHOR}` -> `YourName`
- `{DATE}` -> `11-06-2026`
- `{DESCRIPTION}` -> `Custom IQC screen logic`
