---
applyTo: "WMS/StoredProc/RDT/rdt_*ExtInfo*.sql"
description: "Template for RDT ExtendedInfoSP stored procedures (custom display info extensions). Load when creating or editing rdt_<func>ExtInfo*.sql files."
---

# RDT Extended Info SP Template

## Overview
Template for creating RDT Extended Info Stored Procedures that display custom information on RDT screens or perform additional processing based on context.

## Template Parameters
- `{SP_NAME}` - Stored procedure name (e.g., rdt_851ExtInfo01)
- `{FUNC_NO}` - Function number (e.g., 851)
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
   @nAfterStep     INT,          
   @nInputKey      INT,          
   @cFacility      NVARCHAR(5), 
   @cStorerKey     NVARCHAR(15),
   @tExtInfo       VariableTable READONLY,  
   @cExtendedInfo  NVARCHAR(20) OUTPUT, 
   @nErrNo         INT           OUTPUT, 
   @cErrMsg        NVARCHAR(20) OUTPUT
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
   DECLARE @cRefNo         NVARCHAR(20),
           @cPickSlipNo    NVARCHAR(10),
           @cLoadKey       NVARCHAR(10),
           @cOrderKey      NVARCHAR(10),
           @cDropID        NVARCHAR(20),
           @cID            NVARCHAR(18),
           @cTaskDetailKey NVARCHAR(10),
           @cSKU           NVARCHAR(20),
           @nQTY           INT,
           @nCSKU          INT,
           @nCQTY          INT,
           @nPSKU          INT,
           @nPQTY          INT,
           @cOption        NVARCHAR(1)

   -- For message queue display
   DECLARE @cErrMsg01      NVARCHAR(20),
           @cErrMsg02      NVARCHAR(20),
           @cErrMsg03      NVARCHAR(20),
           @cErrMsg04      NVARCHAR(20),
           @cErrMsg05      NVARCHAR(20)

   -- ============================================================
   -- Extract variables from @tExtInfo table
   -- ============================================================
   SELECT @cRefNo       = Value FROM @tExtInfo WHERE Variable = '@cRefNo'
   SELECT @cPickSlipNo  = Value FROM @tExtInfo WHERE Variable = '@cPickSlipNo'
   SELECT @cLoadKey     = Value FROM @tExtInfo WHERE Variable = '@cLoadKey'
   SELECT @cOrderKey    = Value FROM @tExtInfo WHERE Variable = '@cOrderKey'
   SELECT @cDropID      = Value FROM @tExtInfo WHERE Variable = '@cDropID'
   SELECT @cID          = Value FROM @tExtInfo WHERE Variable = '@cID'
   SELECT @cTaskDetailKey = Value FROM @tExtInfo WHERE Variable = '@cTaskDetailKey'
   SELECT @cSKU         = Value FROM @tExtInfo WHERE Variable = '@cSKU'
   SELECT @nQTY         = TRY_CAST(Value AS INT) FROM @tExtInfo WHERE Variable = '@nQTY'
   SELECT @nCSKU        = TRY_CAST(Value AS INT) FROM @tExtInfo WHERE Variable = '@nCSKU'
   SELECT @nCQTY        = TRY_CAST(Value AS INT) FROM @tExtInfo WHERE Variable = '@nCQTY'
   SELECT @nPSKU        = TRY_CAST(Value AS INT) FROM @tExtInfo WHERE Variable = '@nPSKU'
   SELECT @nPQTY        = TRY_CAST(Value AS INT) FROM @tExtInfo WHERE Variable = '@nPQTY'
   SELECT @cOption      = Value FROM @tExtInfo WHERE Variable = '@cOption'

   IF @nFunc = {FUNC_NO}
   BEGIN
      IF @nStep = 1 -- Step number (adjust as needed)
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- ========================================================
            -- EXTENDED INFO LOGIC: Return info to display on screen
            -- ========================================================
            
            -- Example: Set extended info text to display
            -- SET @cExtendedInfo = 'Status: OK'

            -- Example: Set extended info based on condition
            -- IF some_condition
            -- BEGIN
            --    SET @cExtendedInfo = rdt.rdtgetmessage(196901, @cLangCode, 'DSP')
            -- END
            
         END

         IF @nInputKey = 0 -- ESC
         BEGIN
            -- ========================================================
            -- ESC KEY LOGIC: Display summary or additional info
            -- ========================================================
            
            -- Example: Display message queue with summary info
            -- SET @cErrMsg01 = 'RefNo: ' + @cRefNo
            -- SET @cErrMsg02 = ''
            -- SET @cErrMsg03 = 'SKU CKD: ' + RTRIM(CAST(@nCSKU AS NVARCHAR(5))) + '/' + RTRIM(CAST(@nPSKU AS NVARCHAR(5)))
            -- SET @cErrMsg04 = 'QTY CKD: ' + RTRIM(CAST(@nCQTY AS NVARCHAR(5))) + '/' + RTRIM(CAST(@nPQTY AS NVARCHAR(5)))
            -- 
            -- EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, 
            --    @cErrMsg01, @cErrMsg02, @cErrMsg03, @cErrMsg04, @cErrMsg05
            -- 
            -- SET @nErrNo = 0
            -- SET @cErrMsg = ''
            
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
| @nFunc | INT | IN | Function number (e.g., 851) |
| @cLangCode | NVARCHAR(3) | IN | Language code |
| @nStep | INT | IN | Current step number |
| @nAfterStep | INT | IN | Next step number |
| @nInputKey | INT | IN | Input key (1=ENTER, 0=ESC) |
| @cFacility | NVARCHAR(5) | IN | Facility code |
| @cStorerKey | NVARCHAR(15) | IN | Storer key |
| @tExtInfo | VariableTable | READONLY | Additional variables from main SP |
| @cExtendedInfo | NVARCHAR(20) | OUTPUT | Extended info text to display |
| @nErrNo | INT | OUTPUT | Error number (0=success) |
| @cErrMsg | NVARCHAR(20) | OUTPUT | Error message |

## @tExtInfo Variables

The `@tExtInfo` table contains additional variables passed from the main function SP:

| Variable | Type | Description |
|----------|------|-------------|
| @cRefNo | NVARCHAR(20) | Reference number |
| @cPickSlipNo | NVARCHAR(10) | Pick slip number |
| @cLoadKey | NVARCHAR(10) | Load key |
| @cOrderKey | NVARCHAR(10) | Order key |
| @cDropID | NVARCHAR(20) | Drop ID / Carton ID |
| @cID | NVARCHAR(18) | Pallet ID |
| @cTaskDetailKey | NVARCHAR(10) | Task detail key |
| @cSKU | NVARCHAR(20) | SKU code |
| @nQTY | INT | Quantity |
| @nCSKU | INT | Checked SKU count |
| @nCQTY | INT | Checked quantity |
| @nPSKU | INT | Planned SKU count |
| @nPQTY | INT | Planned quantity |
| @cOption | NVARCHAR(1) | Option flag |

## Key Points

### 1. No Transaction Required
ExtendedInfoSP is for displaying information only - it should NOT modify data, so no transaction management is needed.

### 2. Output Extended Info
```sql
-- Set the @cExtendedInfo OUTPUT parameter to display text on screen
SET @cExtendedInfo = 'Custom Info Text'

-- Or use message from rdtgetmessage
SET @cExtendedInfo = rdt.rdtgetmessage(196901, @cLangCode, 'DSP')
```

### 3. Display Message Queue
```sql
-- Use rdtInsertMsgQueue to display multi-line messages
SET @cErrMsg01 = 'Line 1 text'
SET @cErrMsg02 = 'Line 2 text'
SET @cErrMsg03 = 'Line 3 text'
SET @cErrMsg04 = 'Line 4 text'
SET @cErrMsg05 = 'Line 5 text'

EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, 
   @cErrMsg01, @cErrMsg02, @cErrMsg03, @cErrMsg04, @cErrMsg05

SET @nErrNo = 0
SET @cErrMsg = ''
```

### 4. Standard SET Options
```sql
SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF
```

### 5. Use WITH (NOLOCK) for Read Queries
Always use `WITH (NOLOCK)` for SELECT queries to avoid blocking.

## Difference from Other Extended SPs

| Aspect | ExtendedInfoSP | ExtendedValidateSP | ExtendedUpdateSP |
|--------|----------------|-------------------|------------------|
| Purpose | Display info | Validation only | Data modification |
| Transaction | Not needed | Not needed | Required |
| Data changes | None | None | UPDATE, DELETE, INSERT |
| Output | @cExtendedInfo | @nErrNo, @cErrMsg | @nErrNo, @cErrMsg |
| When called | After step processing | Before main processing | After validation passes |
| @tExtInfo/@tExtValidate | Yes (READONLY) | Yes (READONLY) | No |

## Common Error Codes Reference
| Code | Description |
|------|-------------|
| 196901 | TaskFinish |
| 196951 | Custom status code |

## Usage Example
Replace the placeholders with actual values:
- `{SP_NAME}` -> `rdt_851ExtInfo02`
- `{FUNC_NO}` -> `851`
- `{TICKET_NO}` -> `WMS-12345`
- `{AUTHOR}` -> `YourName`
- `{DATE}` -> `11-06-2026`
- `{DESCRIPTION}` -> `Display PPA summary info`
