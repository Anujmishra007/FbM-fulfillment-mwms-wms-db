---
applyTo: "WMS/StoredProc/RDT/rdt_*ExtUpd*.sql"
description: "Template for RDT ExtendedUpdateSP stored procedures (custom data update extensions, transaction-aware). Load when creating or editing rdt_<func>ExtUpd*.sql files."
---

# RDT Extended Update SP Template

## Overview
Template for creating RDT Extended Update Stored Procedures that handle database modifications (UPDATE, DELETE, INSERT).

## Template Parameters
- `{SP_NAME}` - Stored procedure name (e.g., rdt_855ExtUpd03)
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
   @nMobile         INT, 
   @nFunc           INT, 
   @cLangCode       NVARCHAR(3), 
   @nStep           INT, 
   @nInputKey       INT, 
   @cStorerKey      NVARCHAR(15),  
   @cRefNo          NVARCHAR(10), 
   @cPickSlipNo     NVARCHAR(10), 
   @cLoadKey        NVARCHAR(10), 
   @cOrderKey       NVARCHAR(10), 
   @cDropID         NVARCHAR(20), 
   @cSKU            NVARCHAR(20),  
   @nQty            INT,  
   @cOption         NVARCHAR(1),  
   @nErrNo          INT OUTPUT,  
   @cErrMsg         NVARCHAR(20) OUTPUT,
   @cID             NVARCHAR(18) = '',
   @cTaskDetailKey  NVARCHAR(10) = '',
   @cReasonCode     NVARCHAR(20) = '' OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   -- ============================================================
   -- TRANSACTION MANAGEMENT: Required for UPDATE/DELETE/INSERT
   -- ============================================================
   DECLARE @nTranCount INT
   SET @nTranCount = @@TRANCOUNT

   -- Declare local variables here
   -- DECLARE @cVariable NVARCHAR(20)

   IF @nFunc = {FUNC_NO}
   BEGIN
      IF @nStep = 1 -- Step number
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            -- ========================================================
            -- VALIDATION SECTION: Check conditions before transaction
            -- ========================================================
            
            -- Example: Check if record exists
            -- IF NOT EXISTS (SELECT TOP 1 1 FROM TableName WITH (NOLOCK) WHERE Condition)
            -- BEGIN
            --    SET @nErrNo = 131XXX
            --    SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
            --    GOTO Quit
            -- END

            -- ========================================================
            -- TRANSACTION SECTION: BEGIN TRANSACTION for data changes
            -- ========================================================
            BEGIN TRAN
            SAVE TRAN {SP_NAME}

            -- UPDATE Example
            -- UPDATE dbo.TableName SET
            --    Column1 = @Value1,
            --    EditWho = SUSER_SNAME(),
            --    EditDate = GETDATE()
            -- WHERE Condition
            -- IF @@ERROR <> 0
            -- BEGIN
            --    SET @nErrNo = 131XXX
            --    SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
            --    GOTO RollBackTran
            -- END

            -- INSERT Example
            -- INSERT INTO dbo.TableName (Column1, Column2, AddWho, AddDate)
            -- VALUES (@Value1, @Value2, SUSER_SNAME(), GETDATE())
            -- IF @@ERROR <> 0
            -- BEGIN
            --    SET @nErrNo = 131XXX
            --    SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
            --    GOTO RollBackTran
            -- END

            -- DELETE Example
            -- DELETE FROM dbo.TableName WHERE Condition
            -- IF @@ERROR <> 0
            -- BEGIN
            --    SET @nErrNo = 131XXX
            --    SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
            --    GOTO RollBackTran
            -- END

            -- ========================================================
            -- COMMIT TRANSACTION: Commit only our own transaction
            -- ========================================================
            COMMIT TRAN {SP_NAME}
            WHILE @@TRANCOUNT > @nTranCount
               COMMIT TRAN

         END

         IF @nInputKey = 0 -- ESC
         BEGIN
            -- Handle ESC key logic (usually no transaction needed)
         END
      END
   END
   GOTO Quit

-- ============================================================
-- ERROR HANDLING: Rollback and cleanup
-- ============================================================
RollBackTran:
   ROLLBACK TRAN {SP_NAME}
Quit:
   WHILE @@TRANCOUNT > @nTranCount
      COMMIT TRAN
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.{SP_NAME} to nSQL
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
| @nInputKey | INT | IN | Input key (1=ENTER, 0=ESC) |
| @cStorerKey | NVARCHAR(15) | IN | Storer key |
| @cRefNo | NVARCHAR(10) | IN | Reference number |
| @cPickSlipNo | NVARCHAR(10) | IN | Pick slip number |
| @cLoadKey | NVARCHAR(10) | IN | Load key |
| @cOrderKey | NVARCHAR(10) | IN | Order key |
| @cDropID | NVARCHAR(20) | IN | Drop ID / Carton ID |
| @cSKU | NVARCHAR(20) | IN | SKU code |
| @nQty | INT | IN | Quantity |
| @cOption | NVARCHAR(1) | IN | Option flag |
| @nErrNo | INT | OUTPUT | Error number (0=success) |
| @cErrMsg | NVARCHAR(20) | OUTPUT | Error message |
| @cID | NVARCHAR(18) | IN (optional) | Pallet ID |
| @cTaskDetailKey | NVARCHAR(10) | IN (optional) | Task detail key |
| @cReasonCode | NVARCHAR(20) | OUTPUT (optional) | Reason code |

## Key Points

### 1. Transaction Management (Required for UPDATE/DELETE/INSERT)
```sql
DECLARE @nTranCount INT
SET @nTranCount = @@TRANCOUNT

-- Before data modification
BEGIN TRAN
SAVE TRAN {SP_NAME}

-- After successful modification
COMMIT TRAN {SP_NAME}
WHILE @@TRANCOUNT > @nTranCount
   COMMIT TRAN
```

### 2. Error Handling Pattern
```sql
IF @@ERROR <> 0
BEGIN
   SET @nErrNo = 131XXX
   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')
   GOTO RollBackTran
END
```

### 3. Rollback Section
```sql
RollBackTran:
   ROLLBACK TRAN {SP_NAME}
Quit:
   WHILE @@TRANCOUNT > @nTranCount
      COMMIT TRAN
```

### 4. Standard SET Options
```sql
SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF
```

### 5. Validation Before Transaction
- Always validate data BEFORE starting the transaction
- Use `WITH (NOLOCK)` for read queries during validation
- Use appropriate error codes and messages

### 6. Audit Columns
Always update audit columns when modifying data:
- `EditWho = SUSER_SNAME()`
- `EditDate = GETDATE()`
- `AddWho = SUSER_SNAME()` (for INSERT)
- `AddDate = GETDATE()` (for INSERT)

## Common Error Codes Reference
| Code | Description |
|------|-------------|
| 131251 | SKUNotInCarton |
| 131252 | Over packed |
| 131253 | UPDPackDtlFail |

## Usage Example
Replace the placeholders with actual values:
- `{SP_NAME}` -> `rdt_855ExtUpd04`
- `{FUNC_NO}` -> `855`
- `{TICKET_NO}` -> `WMS-12345`
- `{AUTHOR}` -> `YourName`
- `{DATE}` -> `11-06-2026`
- `{DESCRIPTION}` -> `Add new pack detail update logic`
