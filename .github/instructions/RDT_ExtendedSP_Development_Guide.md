---
applyTo: "WMS/StoredProc/RDT/**/*.sql,WMS/Message/rdt*.sql,WMS/Screen/rdt*.sql"
description: "Developer guide that consolidates all RDT Extended SP templates (Validate, Update, Info, Scn) and integration patterns. Load when working on any RDT SP."
---

# RDT Extended SP Development Guide

## Overview
Comprehensive guide for developing RDT Extended SPs in the Maersk WMS (`FbM-fulfillment-mwms-wms-db`) repository. This guide consolidates all Extended SP templates and provides a complete reference for implementing RDT customizations on Microsoft SQL Server (T-SQL).

---

## Quick Reference: When to Use Which Template

| Scenario | Template to Use |
|----------|-----------------|
| Need custom validation logic | [ExtendedValidateSP](#1-extended-validate-sp) |
| Need custom data update | [ExtendedUpdateSP](#2-extended-update-sp) |
| Need to display custom info | [ExtendedInfoSP](#3-extended-info-sp) |
| Need custom screen logic | [ExtendedScnSP](#4-extended-scn-sp) |
| Need to add Extended SP call in main flow | [Extended SP Call](#5-extended-sp-call) |
| Need to integrate ExtScnSP entry and Step_99 | [Extended Scn Integration](#6-extended-scn-integration) |

---

## Code Standards Reference

Before writing any code, review the code standards:
- **Code Standards:** [CODE_STANDARDS.md](./CODE_STANDARDS.md)
- **JSON Rules:** [code_standards.json](./code_standards.json)

### Key Rules Checklist
- [ ] Use CRLF line break
- [ ] Use 3 spaces indentation, no TAB
- [ ] Use CREATE OR ALTER
- [ ] DELETE/UPDATE/INSERT/MERGE has TRY...CATCH
- [ ] Table reference has schema prefix (dbo., rdt.)
- [ ] UPDATE has WITH (ROWLOCK)
- [ ] Type conversion uses TRY_CAST
- [ ] Has GRANT TO NSQL at end
- [ ] SELECT has WITH (NOLOCK)
- [ ] Has GO statement
- [ ] Batch update/delete uses table variable or temp table

---

## 1. Extended Validate SP

**Purpose:** Execute custom validation logic after main flow validation

**Template File:** [RDT_CustomValidation_SP_Template.md](./RDT_CustomValidation_SP_Template.md)

**Features:**
- No transaction management needed
- Receive context via @tExtValidate
- Return @nErrNo and @cErrMsg on validation failure

**Parameter Signature:**
```sql
CREATE OR ALTER PROC [RDT].[rdt_XXXExtValidXX] (
   @nMobile, @nFunc, @cLangCode, @nStep,
   @cStorer, @cFacility, @cRefNo, @cOrderKey, @cDropID, @cLoadKey, @cPickSlipNo,
   @nErrNo OUTPUT, @cErrMsg OUTPUT,
   @cID, @cTaskDetailKey, @tExtValidate READONLY
)
```

---

## 2. Extended Update SP

**Purpose:** Execute custom data modification after main flow update

**Template File:** [RDT_CustomDataUpdate_SP_Template.md](./RDT_CustomDataUpdate_SP_Template.md)

**Features:**
- **Transaction management required** (BEGIN TRAN / SAVE TRAN / COMMIT / ROLLBACK)
- Called within main flow transaction
- ROLLBACK required on error

**Parameter Signature:**
```sql
CREATE OR ALTER PROC [RDT].[rdt_XXXExtUpdXX] (
   @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey,
   @cStorerKey, @cRefNo, @cPickSlipNo, @cLoadKey, @cOrderKey, @cDropID,
   @cSKU, @nQty, @cOption,
   @nErrNo OUTPUT, @cErrMsg OUTPUT,
   @cID, @cTaskDetailKey, @cReasonCode OUTPUT
)
```

---

## 3. Extended Info SP

**Purpose:** Display custom information on screen

**Template File:** [RDT_CustomDisplayInfo_SP_Template.md](./RDT_CustomDisplayInfo_SP_Template.md)

**Features:**
- No transaction management needed
- Receive context via @tExtInfo
- Return display text via @cExtendedInfo OUTPUT

**Parameter Signature:**
```sql
CREATE OR ALTER PROC [RDT].[rdt_XXXExtInfoXX] (
   @nMobile, @nFunc, @cLangCode, @nStep, @nAfterStep, @nInputKey,
   @cFacility, @cStorerKey, @tExtInfo READONLY,
   @cExtendedInfo OUTPUT, @nErrNo OUTPUT, @cErrMsg OUTPUT
)
```

---

## 4. Extended Scn SP

**Purpose:** Handle custom screen logic, screen navigation and field I/O

**Template File:** [RDT_CustomScreenLogic_SP_Template.md](./RDT_CustomScreenLogic_SP_Template.md)

**Features:**
- Fixed parameter signature (90+ parameters)
- 15 sets of field I/O (InField/OutField/FieldAttr/Lottable)
- 30 UDF fields
- Navigation control via @nAfterScn/@nAfterStep

**Main Parameters:**
```sql
CREATE OR ALTER PROC [RDT].[rdt_XXXExtScnXX] (
   @nMobile, @nFunc, @cLangCode, @nStep, @nScn, @nInputKey,
   @cFacility, @cStorerKey, @tExtScnData READONLY,
   @cInField01-15, @cOutField01-15, @cFieldAttr01-15, @cLottable01-15,
   @nAction, @nAfterScn OUTPUT, @nAfterStep OUTPUT,
   @nErrNo OUTPUT, @cErrMsg OUTPUT,
   @cUDF01-30 OUTPUT
)
```

---

## 5. Extended SP Call

**Purpose:** Add dynamic Extended SP call code in main flow steps

**Template File:** [RDT_ExtendedSP_Call_Template.md](./RDT_ExtendedSP_Call_Template.md)

**Call Sequence:**
```
Step_X:
   [Standard Validation]
         ↓
   [ExtendedValidateSP]  ← (1)
         ↓
   BEGIN TRAN
         ↓
   [Standard Update]
         ↓
   [ExtendedUpdateSP]    ← (2)
         ↓
   COMMIT TRAN
         ↓
   [ExtendedInfoSP]      ← (3)
```

---

## 6. Extended Scn Integration

**Purpose:** Integrate ExtScnSP entry and Step_99 backend logic in main flow

**Template File:** [RDT_ExtendedScn_Integration_Template.md](./RDT_ExtendedScn_Integration_Template.md)

**Contents:**
- Part 1: Add ExtScnSP entry in existing step
- Part 2: Step_99 backend logic code
- Part 3: Step 0 variable declaration
- Part 4: ExtScnSP output processing examples

---

## Implementation Workflow

### Step 1: Identify Requirements

| Requirement Type | SP to Create | Main SP to Modify |
|------------------|--------------|-------------------|
| Custom validation | ExtendedValidateSP | Add dynamic call code |
| Custom update | ExtendedUpdateSP | Add dynamic call code |
| Display custom info | ExtendedInfoSP | Add dynamic call code |
| Custom screen/navigation | ExtendedScnSP | Add entry + Step_99 |

### Step 2: Create Extended SP

1. Select the corresponding template
2. Replace template parameters:
   - `{SP_NAME}` - SP name
   - `{FUNC_NO}` - Function number
   - `{TICKET_NO}` - Jira Ticket
   - `{AUTHOR}` - Author
   - `{DATE}` - Date (DD-MM-YYYY)
   - `{DESCRIPTION}` - Description

### Step 3: Modify Main Function SP

1. **Step 0:** Add config read code
   ```sql
   SET @cExtendedValidateSP = rdt.RDTGetConfig(@nFunc, 'ExtendedValidateSP', @cStorerKey)
   SET @cExtendedUpdateSP = rdt.RDTGetConfig(@nFunc, 'ExtendedUpdateSP', @cStorerKey)
   SET @cExtendedInfoSP = rdt.RDTGetConfig(@nFunc, 'ExtendedInfoSP', @cStorerKey)
   SET @cExtScnSP = rdt.RDTGetConfig(@nFunc, 'ExtScnSP', @cStorerKey)
   ```

2. **Target Step:** Add dynamic call code (refer to template #5)

3. **Step_99:** If using ExtScnSP, add Step_99 code (refer to template #6)

### Step 4: Create RDT Config

```sql
-- Insert config for storer
INSERT INTO dbo.StorerConfig (StorerKey, ConfigKey, sValue, AddWho, AddDate)
VALUES (@cStorerKey, 'ExtendedValidateSP', 'rdt_XXXExtValidXX', SUSER_SNAME(), GETDATE())

INSERT INTO dbo.StorerConfig (StorerKey, ConfigKey, sValue, AddWho, AddDate)
VALUES (@cStorerKey, 'ExtendedUpdateSP', 'rdt_XXXExtUpdXX', SUSER_SNAME(), GETDATE())

INSERT INTO dbo.StorerConfig (StorerKey, ConfigKey, sValue, AddWho, AddDate)
VALUES (@cStorerKey, 'ExtendedInfoSP', 'rdt_XXXExtInfoXX', SUSER_SNAME(), GETDATE())

INSERT INTO dbo.StorerConfig (StorerKey, ConfigKey, sValue, AddWho, AddDate)
VALUES (@cStorerKey, 'ExtScnSP', 'rdt_XXXExtScnXX', SUSER_SNAME(), GETDATE())
```

### Step 5: Create Message File (If Needed)

If there are new error codes, create `[SPName]_message.sql`:
```sql
-- Insert error message
INSERT INTO dbo.RDTMessage (MsgNo, LangCode, MsgType, Message, AddWho, AddDate)
VALUES (131XXX, 'EN', 'DSP', 'Error message text', SUSER_SNAME(), GETDATE())
```

---

## Extended SP Comparison Table

| Aspect | ValidateSP | UpdateSP | InfoSP | ScnSP |
|--------|------------|----------|--------|-------|
| Purpose | Validation | Data modification | Display info | Screen logic |
| Transaction | Not needed | Required | Not needed | Optional |
| Config Key | ExtendedValidateSP | ExtendedUpdateSP | ExtendedInfoSP | ExtScnSP |
| Parameter Count | 16 | 19 | 12 | 90+ |
| Context Passing | @tExtValidate | Direct parameters | @tExtInfo | @tExtScnData |
| Return Data | @nErrNo, @cErrMsg | @nErrNo, @cErrMsg | @cExtendedInfo | UDF01-30 |
| Call Location | After validation | After update | After ENTER/ESC | End of step |

---

## File Naming Conventions

| File Type | Naming Format | Example |
|-----------|---------------|---------|
| ExtendedValidateSP | rdt_{FuncNo}ExtValid{XX}.sql | rdt_855ExtValid05.sql |
| ExtendedUpdateSP | rdt_{FuncNo}ExtUpd{XX}.sql | rdt_855ExtUpd03.sql |
| ExtendedInfoSP | rdt_{FuncNo}ExtInfo{XX}.sql | rdt_851ExtInfo01.sql |
| ExtendedScnSP | rdt_{FuncNo}ExtScn{XX}.sql | rdt_1730ExtScn01.sql |
| Message File | rdt_{FuncNo}Ext{Type}{XX}_message.sql | rdt_855ExtUpd03_message.sql |

---

## Related Templates

| # | Template | Location |
|---|----------|----------|
| 1 | Custom Validation SP | [RDT_CustomValidation_SP_Template.md](./RDT_CustomValidation_SP_Template.md) |
| 2 | Custom Data Update SP | [RDT_CustomDataUpdate_SP_Template.md](./RDT_CustomDataUpdate_SP_Template.md) |
| 3 | Custom Display Info SP | [RDT_CustomDisplayInfo_SP_Template.md](./RDT_CustomDisplayInfo_SP_Template.md) |
| 4 | Custom Screen Logic SP | [RDT_CustomScreenLogic_SP_Template.md](./RDT_CustomScreenLogic_SP_Template.md) |
| 5 | Extended SP Call | [RDT_ExtendedSP_Call_Template.md](./RDT_ExtendedSP_Call_Template.md) |
| 6 | Extended Scn Integration | [RDT_ExtendedScn_Integration_Template.md](./RDT_ExtendedScn_Integration_Template.md) |
| 7 | Code Standards | [CODE_STANDARDS.md](./CODE_STANDARDS.md) |
| 8 | RDT PR Review Playbook | [RDT_pr_review.instructions.md](./RDT_pr_review.instructions.md) |
| 9 | IO/INV PR Review Playbook | [IOINV_PR_Review.instructions.md](./IOINV_PR_Review.instructions.md) |
