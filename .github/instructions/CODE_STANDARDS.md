---
applyTo: "WMS/**/*.sql"
description: "T-SQL coding standards for the Maersk WMS database (RDT, IO/INV, Tables, Triggers, Functions). Load when authoring or reviewing any SQL file under WMS/."
---

# WMS / RDT SQL Code Standards

> This specification applies to all WMS SQL development (RDT, IO/INV, Tables, Triggers, Functions, Messages, Screens) and code review across the `FbM-fulfillment-mwms-wms-db` repository.
>
> Target engine: **Microsoft SQL Server (T-SQL)**.

---

## 1. Script Format

### 1.1 Line Breaker
- **Must use** Windows line break (CRLF)
- **Do not use** Unix line break (LF)

### 1.2 TAB Size
- **Do not use** TAB control character
- **Must use** 3 spaces instead of TAB

---

## 2. Coding Standard (Must Follow)

### 2.1 General Standard

All newly created scripts must follow these rules, even if code is copied from existing scripts.

#### 2.1.1 CREATE OR ALTER
**Must** use `CREATE OR ALTER` in SP and Function scripts so the same script works for both initial deployment and subsequent upgrades.

```sql
-- Good
CREATE OR ALTER PROC [RDT].[rdt_855ExtUpd03] (
   ...
)

-- Bad
CREATE PROC [RDT].[rdt_855ExtUpd03] (
   ...
)
```

#### 2.1.2 TRY...CATCH for Data Operations
All `DELETE`, `UPDATE`, `INSERT`, `MERGE` operations **must** be wrapped in `BEGIN TRY... BEGIN CATCH` blocks.

```sql
-- Good
BEGIN TRY
   UPDATE dbo.PackDetail SET
      QTY = QTY + @nQTY,
      EditWho = SUSER_SNAME(),
      EditDate = GETDATE()
   WHERE PickSlipNo = @cPickSlipNo
END TRY
BEGIN CATCH
   SET @nErrNo = ERROR_NUMBER()
   SET @cErrMsg = ERROR_MESSAGE()
   GOTO RollBackTran
END CATCH

-- Bad
UPDATE dbo.PackDetail SET
   QTY = QTY + @nQTY
WHERE PickSlipNo = @cPickSlipNo
IF @@ERROR <> 0
   GOTO RollBackTran
```

#### 2.1.3 Schema Prefix
All table references **must** include schema prefix.

```sql
-- Good
SELECT * FROM dbo.PackDetail WITH (NOLOCK)
UPDATE dbo.Orders SET Status = '9'

-- Bad
SELECT * FROM PackDetail WITH (NOLOCK)
UPDATE Orders SET Status = '9'
```

#### 2.1.4 ROWLOCK for Updates
**Must** add `WITH (ROWLOCK)` when updating data.

```sql
-- Good
UPDATE dbo.PackDetail WITH (ROWLOCK) SET
   QTY = QTY + @nQTY
WHERE PickSlipNo = @cPickSlipNo

-- Bad
UPDATE dbo.PackDetail SET
   QTY = QTY + @nQTY
WHERE PickSlipNo = @cPickSlipNo
```

#### 2.1.5 TRY_CAST for Type Conversion
**Must** use `TRY_CAST` for data type conversion, avoid implicit conversion.

```sql
-- Good
SET @nQTY = TRY_CAST(@cInput AS INT)
IF @nQTY IS NULL
BEGIN
   SET @nErrNo = 60001
   SET @cErrMsg = 'Invalid number'
   GOTO Quit
END

-- Bad
SET @nQTY = CAST(@cInput AS INT)  -- May throw error
SET @nQTY = @cInput               -- Implicit conversion
```

#### 2.1.6 GRANT Permission
**Must** grant execution permission to `NSQL` role at end of SP or Function scripts.

```sql
CREATE OR ALTER PROC [RDT].[rdt_855ExtUpd03] (...)
AS
BEGIN
   ...
END
GO

GRANT EXECUTE ON RDT.rdt_855ExtUpd03 TO NSQL
GO
```

#### 2.1.7 Unique Error Numbers
Each error number **must** be unique in the system. Error number definitions should be included in `[SPName]_message.sql`.

#### 2.1.8 NOLOCK for Queries
Unless there's a specific reason, all query statements **must** add `WITH (NOLOCK)`.

```sql
-- Good
SELECT * FROM dbo.PackDetail WITH (NOLOCK) WHERE StorerKey = @cStorer

-- Bad (unless specific reason)
SELECT * FROM dbo.PackDetail WHERE StorerKey = @cStorer
```

#### 2.1.9 GO Statement
`GO` statement **must** be appended at the end of `CREATE PROCEDURE` script and `GRANT Permission` script.

```sql
CREATE OR ALTER PROC [RDT].[rdt_855ExtUpd03] (...)
AS
BEGIN
   ...
END
GO                              -- Required

GRANT EXECUTE ON RDT.rdt_855ExtUpd03 TO NSQL
GO                              -- Required
```

---

### 2.2 Extended Screen Standard

All newly created Extended Screen scripts or new Extended Screen entries in base Function SPs must follow these rules.

#### 2.2.1 Configuration Name
RDT Extended Screen configuration name **must** be `ExtScnSP`.

```sql
SET @cExtendedScnSP = rdt.RDTGetConfig(@nFunc, 'ExtScnSP', @cStorer)
```

#### 2.2.2 Step Label
Extended Screen section step label **must** be `Step_99`.

```sql
IF @nStep = 99 GOTO Step_99
...
Step_99:
BEGIN
   -- Extended screen logic
END
```

#### 2.2.3 Unified Variable Names
Variable names in Extended Screen SP **must** be unified to ensure everyone has consistent understanding of their values, avoiding ambiguity.

| Variable Name | Description | Source |
|---------------|-------------|--------|
| `@nMobRecScn` | Screen value from RDTMOBREC table | Database read |
| `@nMobRecStep` | Step value from RDTMOBREC table | Database read |
| `@nStep` | Step value passed to Extended Screen SP | Parameter input |
| `@nScn` | Screen value passed to Extended Screen SP | Parameter input |
| `@nAfterStep` | Next step value returned to main SP | OUTPUT |
| `@nAfterScn` | Next screen value returned to main SP | OUTPUT |
| `@nPreStep` | Previous step that calls Extended Screen SP | Parameter input |
| `@nPreScn` | Previous screen that calls Extended Screen SP | Parameter input |

---

## 3. Best Practice

### 3.1 Query Performance
Consider query performance when writing statements, avoid long-running queries. Try to hit primary keys or indexes in conditions.

```sql
-- Good: Uses primary key
SELECT * FROM dbo.PickDetail WITH (NOLOCK)
WHERE PickDetailKey = @cPickDetailKey

-- Good: Uses index
SELECT * FROM dbo.PickDetail WITH (NOLOCK)
WHERE StorerKey = @cStorer AND SKU = @cSKU

-- Bad: Full table scan
SELECT * FROM dbo.PickDetail WITH (NOLOCK)
WHERE Description LIKE '%keyword%'
```

### 3.2 Primary Key for Updates/Deletes
Use primary keys to update or delete data whenever possible.

```sql
-- Good
UPDATE dbo.PackDetail WITH (ROWLOCK) SET
   QTY = @nQTY
WHERE PackDetailKey = @nPackDetailKey

-- Less optimal
UPDATE dbo.PackDetail WITH (ROWLOCK) SET
   QTY = @nQTY
WHERE PickSlipNo = @cPickSlipNo AND CartonNo = @nCartonNo AND LabelLine = @cLabelLine
```

### 3.3 Use Table Variables or Temp Tables for Batch Updates/Deletes
When batch updating or deleting data, prefer using table variables or temp tables to limit operation scope, avoid using complex WHERE conditions directly.

```sql
-- Good: Use table variable to control update scope
DECLARE @tPickDetails TABLE (
   id INT IDENTITY(1, 1),
   PickDetailKey NVARCHAR(10),
   Qty INT
)

INSERT INTO @tPickDetails (PickDetailKey, Qty)
SELECT PickDetailKey, Qty FROM dbo.PickDetail WITH (NOLOCK)
WHERE StorerKey = @cStorer AND Status = '5'

WHILE 1 = 1
BEGIN
   SELECT TOP 1 @cPickDetailKey = PickDetailKey, @nQty = Qty, @nLoopIndex = id
   FROM @tPickDetails WHERE id > @nLoopIndex
   
   IF @@ROWCOUNT = 0 BREAK
   
   UPDATE dbo.TargetTable WITH (ROWLOCK)
   SET PickDetailKey = @cPickDetailKey
   WHERE EXISTS (
      SELECT 1 FROM @tSourceTable ST 
      WHERE ST.KeyColumn = TargetTable.KeyColumn 
      AND ST.id BETWEEN @nStartIndex AND @nEndIndex
   )
END

-- Bad: Direct complex WHERE clause for batch update
UPDATE dbo.TargetTable WITH (ROWLOCK)
SET Status = '9'
WHERE StorerKey = @cStorer 
   AND Status = '5'
   AND CreateDate < DATEADD(DAY, -30, GETDATE())
   AND EXISTS (SELECT 1 FROM dbo.Orders WHERE ...)
```

**Benefits:**
- Better performance control (can process in batches)
- Avoid long-running table locks
- Easier to debug and trace
- Can add error handling in loops

### 3.4 Minimal Transactions
When adding transactions, ensure only necessary operations are included.

```sql
-- Good: Only necessary operations in transaction
-- Validation outside transaction
IF NOT EXISTS (SELECT 1 FROM dbo.PackDetail WITH (NOLOCK) WHERE ...)
BEGIN
   SET @nErrNo = 131251
   GOTO Quit
END

BEGIN TRY
   BEGIN TRAN
   UPDATE dbo.PackDetail WITH (ROWLOCK) SET ...
   COMMIT TRAN
END TRY
BEGIN CATCH
   ROLLBACK TRAN
END CATCH

-- Bad: Unnecessary operations in transaction
BEGIN TRAN
SELECT @nCount = COUNT(*) FROM dbo.PackDetail  -- Read in transaction
IF @nCount > 0
   UPDATE dbo.PackDetail SET ...
COMMIT TRAN
```

### 3.5 Comments for Complex Logic
Add comments in areas with complex logic to help others understand the code.

```sql
-- Calculate tolerance: Allow +/- 5% variance
-- Formula: (Expected - Actual) / Expected * 100
IF ABS(@nExpQTY - @nActQTY) * 100 / NULLIF(@nExpQTY, 0) > 5
BEGIN
   SET @nErrNo = 131252
   GOTO Quit
END
```

---

## 4. Quick Reference Checklist

### Code Review Checklist

| # | Check Item | Rule ID |
|---|------------|---------|
| 1 | Use CRLF line break | FORMAT-001 |
| 2 | Use 3 spaces indentation, no TAB | FORMAT-002 |
| 3 | Use CREATE OR ALTER | GENERAL-001 |
| 4 | DELETE/UPDATE/INSERT/MERGE has TRY...CATCH | GENERAL-002 |
| 5 | Table reference has schema prefix | GENERAL-003 |
| 6 | UPDATE has WITH (ROWLOCK) | GENERAL-004 |
| 7 | Type conversion uses TRY_CAST | GENERAL-005 |
| 8 | Has GRANT TO NSQL at end | GENERAL-006 |
| 9 | Error number is unique | GENERAL-007 |
| 10 | SELECT has WITH (NOLOCK) | GENERAL-008 |
| 11 | Has GO statement | GENERAL-009 |
| 12 | ExtScnSP config name is correct | EXTSCN-001 |
| 13 | Extended Screen uses Step_99 | EXTSCN-002 |
| 14 | Variable naming is unified | EXTSCN-003 |
| 15 | Batch update/delete uses table variable or temp table | BEST-003 |

---

## 5. Related Templates

- [RDT Extended SP Development Guide](./RDT_ExtendedSP_Development_Guide.md)
- [RDT Custom Validation SP Template](./RDT_CustomValidation_SP_Template.md)
- [RDT Custom Data Update SP Template](./RDT_CustomDataUpdate_SP_Template.md)
- [RDT Custom Display Info SP Template](./RDT_CustomDisplayInfo_SP_Template.md)
- [RDT Custom Screen Logic SP Template](./RDT_CustomScreenLogic_SP_Template.md)
- [RDT Extended SP Call Template](./RDT_ExtendedSP_Call_Template.md)
- [RDT Extended Scn Integration Template](./RDT_ExtendedScn_Integration_Template.md)
- [Machine-readable rules (JSON)](./code_standards.json)
- [RDT PR Review playbook](./RDT_pr_review.instructions.md)
- [IO/INV PR Review playbook](./IOINV_PR_Review.instructions.md)
