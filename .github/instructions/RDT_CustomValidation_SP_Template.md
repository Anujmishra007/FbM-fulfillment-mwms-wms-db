---
applyTo: "WMS/StoredProc/RDT/rdt_*ExtVal*.sql,WMS/StoredProc/RDT/rdt_*ExtValid*.sql"
description: "Template for RDT ExtendedValidateSP stored procedures (custom validation extensions). Load when creating or editing rdt_<func>ExtVal*.sql files."
---

# RDT Extended Validate SP Template

## Overview
Template for creating RDT Extended Validate Stored Procedures that perform custom validation logic before main function processing.

## Template Parameters
- `{SP_NAME}` - Stored procedure name (e.g., rdt_855ExtValid05)
- `{FUNC_NO}` - Function number (e.g., 855)
- `{TICKET_NO}` - Ticket number for version history (e.g., WMS-12345)
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
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR(3),
   @nStep          INT,
   @cStorer        NVARCHAR(15),
   @cFacility      NVARCHAR(5),
   @cRefNo         NVARCHAR(20),
   @cOrderKey      NVARCHAR(10),
   @cDropID        NVARCHAR(20),
   @cLoadKey       NVARCHAR(10),
   @cPickSlipNo    NVARCHAR(10),
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR(20)  OUTPUT, 
   @cID            NVARCHAR(18)  = '',
   @cTaskDetailKey NVARCHAR(10)  = '',
   @tExtValidate   VariableTable READONLY
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
   DECLARE @nInputKey      INT,
           @cSKU           NVARCHAR(20),
           @nQTY           INT,
           @nQTY_PPA       INT,
           @nQTY_CHK       INT,
           @nRowRef        INT,
           @cUserName      NVARCHAR(18)
           
   -- ============================================================
   -- Extract variables from @tExtValidate table
   -- ============================================================
   SELECT @cSKU      = Value FROM @tExtValidate WHERE Variable = '@cSKU'
   SELECT @nQTY      = TRY_CAST(Value AS INT) FROM @tExtValidate WHERE Variable = '@nQTY'
   SELECT @nQTY_PPA  = TRY_CAST(Value AS INT) FROM @tExtValidate WHERE Variable = '@nQTY_PPA'
   SELECT @nQTY_CHK  = TRY_CAST(Value AS INT) FROM @tExtValidate WHERE Variable = '@nQTY_CHK'
   SELECT @nRowRef   = TRY_CAST(Value AS INT) FROM @tExtValidate WHERE Variable = '@nRowRef'
   SELECT @nInputKey = TRY_CAST(Value AS INT) FROM @tExtValidate WHERE Variable = '@nInputKey'
   SELECT @cUserName = Value FROM @tExtValidate WHERE Variable = '@cUserName'

   IF @nFunc = {FUNC_NO}
   BEGIN
      IF @nStep = 1 -- Step number (adjust as needed)
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- ========================================================
            -- VALIDATION LOGIC: Add your custom validation here
            -- ========================================================
            
            -- Example: Check if record exists
            -- IF NOT EXISTS (SELECT 1 FROM dbo.TableName WITH (NOLOCK) WHERE Condition)
            -- BEGIN
            --    SET @nErrNo = 131XXX
            --    SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
            --    GOTO Quit
            -- END

            -- Example: Check business rule
            -- IF @nQTY > @nQTY_CHK
            -- BEGIN
            --    SET @nErrNo = 131XXX
            --    SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
            --    GOTO Quit
            -- END
            
         END
      END
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

## SP Parameters (from Main Function SP Dynamic Call)

The parameters match the dynamic call pattern in main function SPs (e.g., `rdtfnc_PostPickAudit`):

| Parameter | Type | Direction | Description |
|-----------|------|-----------|-------------|
| @nMobile | INT | IN | Mobile device number |
| @nFunc | INT | IN | Function number (e.g., 855) |
| @cLangCode | NVARCHAR(3) | IN | Language code |
| @nStep | INT | IN | Current step number |
| @cStorer | NVARCHAR(15) | IN | Storer key |
| @cFacility | NVARCHAR(5) | IN | Facility code |
| @cRefNo | NVARCHAR(20) | IN | Reference number |
| @cOrderKey | NVARCHAR(10) | IN | Order key |
| @cDropID | NVARCHAR(20) | IN | Drop ID / Carton ID |
| @cLoadKey | NVARCHAR(10) | IN | Load key |
| @cPickSlipNo | NVARCHAR(10) | IN | Pick slip number |
| @nErrNo | INT | OUTPUT | Error number (0=success) |
| @cErrMsg | NVARCHAR(20) | OUTPUT | Error message |
| @cID | NVARCHAR(18) | IN (optional) | Pallet ID |
| @cTaskDetailKey | NVARCHAR(10) | IN (optional) | Task detail key |
| @tExtValidate | VariableTable | READONLY | Additional variables from main SP |

## @tExtValidate Variables

The `@tExtValidate` table contains additional variables passed from the main function SP:

| Variable | Type | Description |
|----------|------|-------------|
| @cSKU | NVARCHAR(20) | SKU code |
| @nQTY | INT | Quantity entered |
| @nQTY_PPA | INT | PPA quantity |
| @nQTY_CHK | INT | Check quantity |
| @nRowRef | INT | Row reference |
| @nInputKey | INT | Input key (1=ENTER, 0=ESC) |
| @cUserName | NVARCHAR(18) | User name |

## Key Points

### 1. No Transaction Required
ExtendedValidateSP is for validation only - it should NOT modify data, so no transaction management is needed.

### 2. Error Handling Pattern
```sql
IF validation_fails
BEGIN
   SET @nErrNo = 131XXX
   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
   GOTO Quit
END
```

### 3. Standard SET Options
```sql
SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF
```

### 4. Extract Variables from @tExtValidate
```sql
SELECT @cSKU      = Value FROM @tExtValidate WHERE Variable = '@cSKU'
SELECT @nQTY      = TRY_CAST(Value AS INT) FROM @tExtValidate WHERE Variable = '@nQTY'
-- ... etc
```

### 5. Use WITH (NOLOCK) for Read Queries
Always use `WITH (NOLOCK)` for SELECT queries to avoid blocking.

## Difference from ExtendedUpdateSP

| Aspect | ExtendedValidateSP | ExtendedUpdateSP |
|--------|-------------------|------------------|
| Purpose | Validation only | Data modification |
| Transaction | Not needed | Required for UPDATE/DELETE/INSERT |
| Data changes | None | UPDATE, DELETE, INSERT |
| When called | Before main processing | After validation passes |
| @tExtValidate | Yes (READONLY) | No |

## Common Error Codes Reference
| Code | Description |
|------|-------------|
| 204351 | CartonNotPick |

## Usage Example
Replace the placeholders with actual values:
- `{SP_NAME}` -> `rdt_855ExtValid06`
- `{FUNC_NO}` -> `855`
- `{TICKET_NO}` -> `WMS-12345`
- `{AUTHOR}` -> `YourName`
- `{DATE}` -> `11-06-2026`
- `{DESCRIPTION}` -> `Validate carton status before PPA`
