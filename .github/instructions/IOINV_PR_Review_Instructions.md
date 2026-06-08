---
applyTo: "WMS/Trigger/*.sql,WMS/Trigger/API/*.sql,WMS/StoredProc/WM/*.sql,WMS/StoredProc/API/*.sql,WMS/StoredProc/*.sql,WMS/Tables/*.sql,WMS/Tables/API/*.sql,WMS/Tables/WM/*.sql,WMS/Function/*.sql,WMS/Function/API/*.sql"
exclude: "WMS/StoredProc/rdt*.sql,WMS/Message/rdt*.sql,WMS/Screen/rdt*.sql,WMS/Trigger/RDT/*.sql,WMS/Tables/RDT/*.sql"
---


# INV / IO SP Change Impact Analyzer - PR Review Instructions

When reviewing PRs that contain changes to Inventory, Inbound & Outbound related stored procedures, follow this analysis methodology.

---

## IMPORTANT: Review Output Rules

**CRITICAL INSTRUCTION**:

**Exclude any SQL files matched by `.github/instructions/RDT_pr_review.instructions.md` (its `applyTo` patterns), and also honor this file’s `exclude` patterns. Clearly differentiate which files are in-scope vs excluded.**
**What to OUTPUT (ONLY these sections):**
- Output ONLY the sections defined in "PR Summary Requirements" below
- Do NOT output anything beyond those 4 mandatory sections

**Fresh Review Every Time:**
- **DO NOT provide incremental or summary reviews** like "reviewed X commits" or "changes look good"
- **IGNORE any previous review comments** on this PR - treat each review request as a fresh analysis
- **DISCARD the old review** and replace it with the new review

If asked to review again after new commits, regenerate the report from scratch covering ALL changes in the PR.

---

## Configuration

**Production Config Path**: `.github/instructions/data/V2_IO_Config.csv`

**Mapping File Format** (Config CSV columns):

| Column | Description | Example |
|--------|-------------|---------|
| StorerKey | Storer identifier |  |
| ConfigKey | Configuration key name |  |
| Svalue | Config value (SP name or 0/1) |  |

---

## PR Summary Requirements (MANDATORY)

**CRITICAL**: Every PR review comment MUST include these sections at the top:

### 1. Severity Assessment (REQUIRED)

```
## Severity: {CRITICAL / HIGH / MEDIUM / LOW}
```

| Severity     | Criteria                                                                                       |
|--------------|------------------------------------------------------------------------------------------------|
| **CRITICAL** | Logic error affecting ALL storers, MOBREC corruption, data loss risk, session state corruption |
| **HIGH**     | Logic error affecting specific storers, execution flow break, Extension SP bypass              |
| **MEDIUM**   | Non-critical behavior change, variable state change with limited impact                        |
| **LOW**      | Tech debt, code cleanup, no functional impact, **new SP not yet configured**                   |

**New SP Severity Rule**: When a **new SP is introduced** that does not exist in the production config (V2_IO_Config.csv), the severity should be **LOW** by default. Since the SP is not configured for any storer/WMS, it will not execute in production and cannot affect existing functionality. Only escalate severity if the new SP:
- Modifies shared code paths that affect other SPs
- Introduces changes to Main SP logic that impacts configured Extension SPs
- Contains syntax errors that would cause deployment failures

### 2. Deployment Recommendation (REQUIRED)

```
## Deployment Recommendation: {APPROVED / NEEDS REVIEW}

**Reason**: {one-line explanation}
```

### 3. Affected Storers (REQUIRED if Extension SPs involved)

```
## Affected Storers
| Storer | StoredProc/Trigger     | Impact |
|--------|------------------------|--------|
```

Look up affected storers from `.github/instructions/data/V2_IO_Config.csv` where:
- `ConfigKey` contains SP-type config ( CustomizedSP, Flags to enable code blocks, etc.)
- `Svalue` matches the Extension SP name pattern for the Function ID

### 4. Severity Classification (REQUIRED)

```
## Severity Classification

### CRITICAL (Must Fix Before Deploy)

| Issue ID | Description | Root Cause | Affected Scope |
|----------|-------------|------------|----------------|

### HIGH (Review Before Deploy)

| Issue ID | Description | Root Cause | Affected Scope |
|----------|-------------|------------|----------------|

### MEDIUM (Monitor After Deploy)

| Issue ID | Description | Root Cause | Affected Scope |
|----------|-------------|------------|----------------|

### LOW (Tech Debt)

| Issue ID | Description | Root Cause | Affected Scope |
|----------|-------------|------------|----------------|
```

**Issue Type Legend:**
- **RUNTIME_BUG**: Logic error, SP exists and executes incorrectly
- **SESSION_BUG**: Affects MOBREC state at Quit (impacts ALL storers)
- **CONFIG_ISSUE**: SP configured but file missing (pre-existing, LOW)

---

## Exclusions - Do NOT Flag These Issues

**Case sensitivity differences**: SQL Server is case-insensitive for identifiers, variables, column names, and keywords. Do not flag changes that only differ in letter casing as these are functionally identical and have no runtime impact.

Examples:
- `V_string41` vs `V_String41` - same variable
- `@cPickStatus = V_string41` vs `@cPickStatus = V_String41` - same assignment
- `SELECT` vs `select` vs `Select` - same keyword

## Analysis Instructions

When a PR contains non-RDT SQL file changes, follow these steps:

### Phase 1: Identify Changed Files and Base Branch

#### 1.1 Get Changed Files
- All files with the Format: (`Exclusions mentioned`)
  - `WMS/Trigger/*.sql`
  - `WMS/Trigger/API/*.sql`
  - `WMS/StoredProc/WM/*.sql`
  - `WMS/StoredProc/API/*.sql`
  - `WMS/StoredProc/*.sql`
  - `WMS/Tables/*.sql`
  - `WMS/Tables/API/*.sql`
  - `WMS/Tables/WM/*.sql`
  - `WMS/Function/*.sql`
  - `WMS/Function/API/*.sql`
- Exclude files in 
  - `WMS/StoredProc/rdt*.sql`
  - `WMS/Message/rdt*.sql`
  - `WMS/Screen/rdt*.sql`
  - `WMS/Trigger/RDT/*.sql`
  - `WMS/Tables/RDT/*.sql`


#### 1.2 Classify SP Types

**Common SP vs Custom SP Identification (for Extension/Helper SPs):**
- **Primary rule (required):** Check the file's version history header and read the `Purpose` field first.
  - If `Purpose` indicates standard/shared/base usage, classify as **Common SP**.
  - If `Purpose` indicates customer/storer/project-specific behavior, classify as **Custom SP**.
- **Filename is secondary evidence only** (use when `Purpose` is missing/ambiguous):
  - non-standard naming convention like `ispRLWAV01`, `ispRLREP00_VIVO`
  - Called from StorerConfig within common SP and present in V2_IO_Config.csv
- **Conflict rule:** If `Purpose` and filename pattern conflict, `Purpose` wins.
- **Priority rule (when both concepts apply):**
  - First classify by role: **Main / Extension / Direct Helper**
  - Then classify implementation type: **Common / Custom**
  - Example: a file can be `Extension SP + Custom SP` at the same time


### Phase 2: Extract Function Info

From all changed SP's, extract **ConfigKeys**: All `dbo.fnc_GetRight`,`nspGetRight`,`nspGetRight2` or any such related calls that triggers customized SP.
- Extract the `ConfigKey` parameter value from these calls
- This will be used to identify which Custom/ Extension SPs are executed and which Storers are affected
- The output of these calls would be SValue which determines which SP is executed for which storer based on the mapping file or if the codeblock within the SP is executed at all (like in the case of return statement before the code block)
- If ConfigKey is not found, look for any direct calls to Extension SPs within the Main SP and extract those SP names as well

### Phase 3: Load Storer/WMS Mapping

Using the config file at `.github/instructions/data/V2_IO_Config.csv`:

1. **Read the mapping file**:
    - CSV format with columns: StorerKey, ConfigKey, Svalue

2. **Build lookup dictionary**:
   ```
   StoredProc, Trigger → { StorerKey: "xxx" }
   ```

3. **For each Extension SP found in Phase 2**:
    - Look up in mapping dictionary
    - If found: Record StorerKey
    - If NOT found: Mark as "Not Configured or might have been Mapped through Codelookup"

4. **Special handling for changed Extension SPs**:
    - Extension SPs with git changes MUST have Storer/WMS clearly marked in report
    - These are HIGH PRIORITY for impact assessment

### Phase 4: Analyze Git Diff

Identify:
- Added lines (+)
- Removed lines (-)
- Affected Step labels
- Variable changes
- GOTO flow changes
- **Extension SPs with changes** (mark in Section 7)

**IMPORTANT**:
- Extension SP changes should NOT generate separate reports
- Extension SP changes should be marked in the Main SP report's "Extension SP Impact" section
- If an Extension SP has changes, analyze its diff and include impact in Main SP report

### Phase 6: Impact Analysis

Check:
1. **Skipped Logic**: What code is bypassed by the change?
2. **Variable State**: How do variables change?
3. **MOBREC Impact**: What's saved to MOBREC at Quit?
4. **Extension SP Impact**: Which SPs are affected?
5. **Extension SP Changes**: For any Extension SP that also has changes:
    - Analyze its git diff
    - Determine impact on Main SP flow
    - Mark "Has Changes? = YES" in Section 7
    - Add change impact description in Section 7
6. **Storer/WMS Impact**:
    - For each affected Extension SP, look up WMS and Storer from mapping
    - Group impacts by WMS/Storer for easy notification
    - Highlight which Storers need to be notified for testing validation
    - If Custom SP not in mapping, flag as "Not Configured or might have been Mapped through Codelookup" and recommend adding to mapping

### Phase 7: Generate Report

**CRITICAL REQUIREMENTS:**
1. **Language**: Report MUST be written entirely in **English**. No Chinese text in the report.
2. **Format**: Use the exact template format below.

**Report Template:**

---

# Batch Impact Analysis Report - {SP_Name}

## 1. Summary

| Field             | Value                          |
|-------------------|--------------------------------|
| **Main SP**       | {filename}                     |
| **Base Branch**   | {base_branch}                  |
| **Change Type**   | {brief description}            |
| **Severity**      | **{CRITICAL/HIGH/MEDIUM/LOW}** |
| **Affected Step** | {Step_X (Step N, Screen NNNN)} |
| **Analysis Date** | {YYYY-MM-DD}                   |

## 2. Git Diff Changes

```diff
{actual diff content}
```

## 3. Dependency Tree (Function {func_id})

```
{main_sp} 
│
├── Direct Helper SPs ({count}) - {ALL EXIST / X MISSING}
│   ├── {sp_name}.sql ✓
│   ├── {sp_name}.sql ✗ MISSING
│   └── ...
│
├── {ConfigKey} ({count})
│   ├── {sp_name}.sql ✓
│   └── ...
│
└── Total: {N} Related SPs ({M} EXIST, {K} MISSING)
```

## 4. Impact Analysis

### Skipped/Affected Logic

| Line Range | Description | Impact |
|------------|-------------|--------|
| {lines} | {what's skipped} | {consequence} |

### Variable State Impact

| Variable | Before Change | After Change | Impact |
|----------|---------------|--------------|--------|
| @{var} | {state} | {state} | {impact} |


## 5. Severity Classification

### CRITICAL (Must Fix Before Deploy)

| Issue ID | Description | Root Cause | Affected Scope |
|----------|-------------|------------|----------------|
| {ID-001} | {description} | Line {N}: {cause} | **ALL Storers** |

### HIGH (Review Before Deploy)
| Issue ID | Description | Root Cause | Affected Scope |
|----------|-------------|------------|----------------|

### MEDIUM (Monitor After Deploy)
| Issue ID | Description | Root Cause | Affected Scope |
|----------|-------------|------------|----------------|

### LOW (Tech Debt)
| Issue ID | Description | Root Cause | Affected Scope |
|----------|-------------|------------|----------------|

**Issue Type Legend:**
- **RUNTIME_BUG**: Logic error, SP exists and executes
- **SESSION_BUG**: Affects MOBREC state at Quit (impacts ALL storers)
- **CONFIG_ISSUE**: SP configured but file missing (pre-existing, LOW)

## 6. Custom SP Impact
- Example:

| ConfigKey             | SP Name    | Storer     | Has Changes? | Will Execute? | Change Impact                          |
|-----------------------|------------|------------|--------------|---------------|----------------------------------------|
| PostFinalizeReceiptSP | mspASNFZ04 | SAZAMILDMC | YES          | Yes           | **CRITICAL: Entire SP logic bypassed** |
| ReleaseWave_SP        | mspRLWAV10 | SKETST     | YES          | No            | **CRITICAL: SP Deleted**               |
| ...                   | ...        | ...        | ...          | ...           | ...                                    |

### Affected Storers Summary (Grouped by WMS/Storer)

**IMPORTANT**: When Custom SP has changes, must clearly list affected Storers:

| Storer | Affected Extension SPs | Impact Level |
|--------|------------------------|--------------|
| ADIDAS | mspRLWAV10             | **CRITICAL** |
| NIKE   | mspRLWAV10             | **MEDIUM**   |

**Note**:
- Custom SPs marked with "Has Changes? = YES" have their own modifications in this branch
- **Storer owners must be notified for testing validation**
- "Not Configured" means the Extension SP is not found in mapping file, recommend adding to mapping

## 8. Test Recommendations

| Test Scenario | Expected Result (Fixed) | Current Result (Bug) |
|---------------|-------------------------|----------------------|
| {scenario1}   | {expected}              | {actual}             |
| {scenario2}   | {expected}              | {actual}             |

## 9. Suggested Fix

```sql
-- Remove/Change the problematic code
{before_code}
-- Should be:
{after_code}
```

## 10. Confidence Level

| Assessment            | Confidence                     |
|-----------------------|--------------------------------|
| Change Identification | **HIGH/MEDIUM/LOW** - {reason} |
| Impact Scope          | **HIGH/MEDIUM/LOW** - {reason} |
| Fix Suggestion        | **HIGH/MEDIUM/LOW** - {reason} |

## 11. Deployment Recommendation

**CRITICAL SECTION - MUST PROVIDE CLEAR CONCLUSION**

### Can this change be deployed to Production?

| Decision       | **YES / NO / CONDITIONAL**                   |
|----------------|----------------------------------------------|
| Recommendation | {APPROVE / REJECT / APPROVE WITH CONDITIONS} |
| Reason         | {Clear explanation}                          |

### Deployment Checklist

| Item                    | Status                               | Notes                                              |
|-------------------------|--------------------------------------|----------------------------------------------------|
| Code Review             | {PASSED/PENDING/FAILED}              |                                                    |
| UAT Status              | {PASSED/PENDING/FAILED/NOT REQUIRED} |                                                    |
| Impact to Other Storers | {NONE/LOW/MEDIUM/HIGH}               | {List affected storers if any}                     |
| Rollback Plan           | {AVAILABLE/NOT NEEDED}               | {Custom SP/ CodeBlocks can be disabled via config} |
| Database Changes        | {NONE/SCHEMA/DATA}                   | {Details if any}                                   |

### Final Verdict

```
┌─────────────────────────────────────────────────────────────────┐
│  DEPLOYMENT DECISION: {APPROVED / REJECTED / NEEDS MORE INFO}  │
│                                                                 │
│  {One sentence summary of the decision and any conditions}      │
└─────────────────────────────────────────────────────────────────┘
```

**Conditions for Deployment** (if applicable):
- {Condition 1}
- {Condition 2}

---

**Conclusion**: {One sentence summary of the issue and recommendation}

---
