---
applyTo: "WMS/StoredProc/RDT/rdt*.sql,WMS/Message/rdt*.sql,WMS/Screen/rdt*.sql"
---

# RDT SP Change Impact Analyzer - PR Review Instructions

When reviewing PRs that contain changes to RDT stored procedures, follow this analysis methodology.

---

## IMPORTANT: Full Review Required Every Time

**CRITICAL INSTRUCTION**: 
- **ALWAYS generate the COMPLETE impact analysis report** as defined in this instruction file
- **DO NOT provide incremental or summary reviews** like "reviewed X commits" or "changes look good"
- **IGNORE any previous review comments** on this PR - treat each review request as a fresh, complete analysis
- **Every review MUST include ALL mandatory sections**: Severity Assessment, Deployment Recommendation, Affected Storers, and Severity Classification
- **DISCARD the old review comment** and replace it with the new complete review

If asked to review again after new commits, regenerate the FULL report from scratch covering all changes.

---

## Configuration

**Production Config Path**: `.github/instructions/data/V2_RDT_Production_Config.csv`

**Mapping File Format** (Config CSV columns):
| Column | Description | Example |
|--------|-------------|---------|
| WMS | WMS system identifier | AUSWMS, EMEA-UK |
| FunctionID | RDT Function ID | 600, 1812, 1864 |
| StorerKey | Storer identifier | AIRAU01, CROCS, NIKE |
| ConfigKey | Configuration key name | ExtendedUpdateSP, DecodeSP |
| Svalue | Config value (SP name or 0/1) | rdt_600ExtUpd08, 1 |

---

## PR Summary Requirements (MANDATORY)

**CRITICAL**: Every PR review comment MUST include these sections at the top:

### 1. Severity Assessment (REQUIRED)

```
## Severity: {CRITICAL / HIGH / MEDIUM / LOW}
```

| Severity | Criteria |
|----------|----------|
| **CRITICAL** | Logic error affecting ALL storers, MOBREC corruption, data loss risk, session state corruption |
| **HIGH** | Logic error affecting specific storers, execution flow break, Extension SP bypass |
| **MEDIUM** | Non-critical behavior change, variable state change with limited impact |
| **LOW** | Tech debt, code cleanup, no functional impact |

### 2. Deployment Recommendation (REQUIRED)

```
## Deployment Recommendation: {APPROVED / NEEDS REVIEW}

**Reason**: {one-line explanation}
```

### 3. Affected Storers (REQUIRED if Extension SPs involved)

```
## Affected Storers
| WMS | Storer | Extension SP | Impact |
|-----|--------|--------------|--------|
```

Look up affected storers from `.github/instructions/data/V2_RDT_Production_Config.csv` where:
- `ConfigKey` contains SP-type config (ExtScnSP, ExtendedUpdateSP, etc.)
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

## Analysis Instructions

When a PR contains RDT SQL file changes, follow these steps:

### Phase 1: Identify Changed Files and Base Branch

#### 1.1 Get Changed Files

Identify all changed SQL files in the PR:
- Files in `WMS/StoredProc/RDT/*.sql`
- Files in `WMS/Message/*.sql`
- Files in `WMS/Screen/*.sql`

#### 1.2 Classify SP Types

**Main SP Identification Rule:**
- Filename starts with `rdtfnc_` → **Main SP**
- Filename starts with `rdt_` (but not `rdtfnc_`) → **Extension SP**

```
rdtfnc_TM_CasePick.sql     → Main SP (Function 1812)
rdt_1812ExtVal01.sql       → Extension SP (belongs to 1812)
rdt_TM_CasePick_Confirm.sql → Direct Helper SP (belongs to rdtfnc_TM_CasePick)
```

**If changed file is Main SP** (`rdtfnc_*.sql`):
- Generate full impact analysis report for this SP
- Extract Function ID from `@nFunc = {number}` in the file

**If changed file is Extension SP** (`rdt_{func_id}*.sql`):
- Extract function_id from filename (e.g., `1812` from `rdt_1812ExtVal01.sql`)
- Find corresponding Main SP: `rdtfnc_*` file containing `@nFunc = 1812`
- **DO NOT generate separate report for Extension SP**
- Include Extension SP changes in Main SP report's "Extension SP Impact" section (Section 7)

### Phase 2: Extract Function Info

From Main SP, extract:
1. **Function ID**: `@nFunc = {number}`
2. **ConfigKeys**: All `rdtGetConfig(@nFunc, '{ConfigKey}', ...)` calls

### Phase 3: Discover Extension SPs

Use naming convention to find all related SPs:

#### 3.1 SP-Type ConfigKeys (Point to Extension SPs)

| ConfigKey | Glob Pattern | Description |
|-----------|--------------|-------------|
| ExtendedValidateSP | `rdt_{func}ExtVal*.sql` | Extended validation SP |
| ExtendedUpdateSP | `rdt_{func}ExtUpd*.sql` | Extended update SP |
| ExtScnSP | `rdt_{func}ExtScn*.sql` | Extended screen SP |
| ExtendedInfoSP | `rdt_{func}ExtInfo*.sql` | Extended info SP |
| ExtendedPrintSP | `rdt_{func}ExtPrint*.sql` | Extended print SP |
| ExtendedDefaultOptSP | `rdt_{func}ExtDefOpt*.sql` | Extended default option SP |
| ExtendedRefNoSP | `rdt_{func}ExtRefNo*.sql` | Extended reference SP |
| ExtSkuInfoSP | `rdt_{func}ExtSkuInfo*.sql` | Extended SKU info SP |
| GetNextTaskSP | `rdt_{func}GetTask*.sql` | Get next task SP |
| ConfirmSP | `rdt_{func}Confirm*.sql` | Confirmation SP |
| DecodeSP | `rdt_{func}DecodeSP*.sql` | Barcode decode SP |
| DecodeIDSP | `rdt_{func}DecodeID*.sql` | Decode ID SP |
| DecodeLabelNoSP | `rdt_{func}DecodeLabelNo*.sql` | Decode label SP |
| DecodeTrackNoSP | `rdt_{func}DecodeTrackNo*.sql` | Decode tracking SP |
| SwapIDSP | `rdt_{func}SwapID*.sql` | Swap ID SP |
| SwapUCCSP | `rdt_{func}SwapUCC*.sql` | Swap UCC SP |
| SwapTaskSP | `rdt_{func}SwapTask*.sql` | Swap task SP |
| DisableQTYFieldSP | `rdt_{func}DisableQTY*.sql` | Disable qty field SP |
| CreateTaskSP | `rdt_{func}CreateTask*.sql` | Create task SP |
| DefaultQTYSP | `rdt_{func}DefaultQTY*.sql` | Default qty SP |
| DefaultWeightSP | `rdt_{func}DefaultWeight*.sql` | Default weight SP |
| DefaultCartonTypeSP | `rdt_{func}DefaultCartonType*.sql` | Default carton type SP |
| MatrixSP | `rdt_{func}Matrix*.sql` | Matrix SP |
| CartonPosSP | `rdt_{func}CartonPos*.sql` | Carton position SP |
| ClosePLTSP | `rdt_{func}ClosePLT*.sql` | Close pallet SP |
| CfmExtUpdSP | `rdt_{func}CfmExtUpd*.sql` | Confirm extended update SP |
| ConUpdSP | `rdt_{func}ConUpd*.sql` | Continuous update SP |
| LOCCheckDigitSP | `rdt_{func}LOCCheckDigit*.sql` | Location check digit SP |
| LOCLookupSP | `rdt_{func}LOCLookup*.sql` | Location lookup SP |
| SuggestLocSP | `rdt_{func}SuggestLoc*.sql` | Suggest location SP |
| SuggestToLOCSP | `rdt_{func}SuggestToLOC*.sql` | Suggest to-location SP |
| GetSuggestedLOCSP | `rdt_{func}GetSuggestedLOC*.sql` | Get suggested location SP |
| CustomFetchTask_SP | `rdt_{func}CustomFetchTask*.sql` | Custom fetch task SP |
| CustomCartonIDSP | `rdt_{func}CustomCartonID*.sql` | Custom carton ID SP |
| TrackCartonTypeSP | `rdt_{func}TrackCartonType*.sql` | Track carton type SP |
| FlowThruStepSP | `rdt_{func}FlowThruStep*.sql` | Flow-thru step SP |
| PPAPrintPackListSP | `rdt_{func}PPAPrintPackList*.sql` | PPA print pack list SP |
| ReplTaskSP | `rdt_{func}ReplTask*.sql` | Replenishment task SP |
| ExtSNValSP | `rdt_{func}ExtSNVal*.sql` | Extended serial validation SP |
| DecodeLottableSP | `rdt_{func}DecodeLot*.sql` | Decode lottable SP |
| ClosePalletSP | `rdt_{func}ClosePallet*.sql` | Close pallet SP |
| AutoGenIDSP | `rdt_{func}AutoGenID*.sql` | Auto generate ID SP |

#### 3.2 Flag/Switch ConfigKeys (Value = 0/1)

| ConfigKey | Description |
|-----------|-------------|
| AllowCubeZero | Allow zero cube |
| AllowWeightZero | Allow zero weight |
| AllowLengthZero | Allow zero length |
| AllowWidthZero | Allow zero width |
| AllowHeightZero | Allow zero height |
| AllowSkipLOC | Allow skip location |
| AllowSkipTask | Allow skip task |
| AllowASNNotFinalize | Allow ASN not finalized |
| AutoScanIn | Auto scan in |
| AutoGenID | Auto generate ID |
| AutoGenMBOL | Auto generate MBOL |
| AutoGotoLotScn | Auto go to lottable screen |
| BackToASNScnWhenFullyRcv | Back to ASN screen when fully received |
| ClosePallet | Close pallet |
| ConfirmLOC | Confirm location |
| DisableQTYField | Disable qty field |
| DisableOption | Disable option |
| DisableOverReplen | Disable over replenishment |
| DisAllowRDTOverReceipt | Disallow RDT over receipt |
| DispStyleColorSize | Display style/color/size |
| EnableAllLottables | Enable all lottables |
| FlowThruScreen | Flow-thru screen |
| LockFacility | Lock facility |
| MassBuildUCC | Mass build UCC |
| MatchSKUTrackID | Match SKU tracking ID |
| MoveQTYAlloc | Move qty allocated |
| MoveQTYPick | Move qty picked |
| MultiSKUBarcode | Multi-SKU barcode |
| OverwriteToLOC | Overwrite to-location |
| SerialNoCapture | Serial number capture |
| SkipToLoc | Skip to-location |
| SkipIDExistCheck | Skip ID exist check |
| SkipConfirmBalPick | Skip confirm balance pick |
| SkipChkPSlipMustScanOut | Skip check pickslip must scan out |
| SkipChkPSlipMustScanIn | Skip check pickslip must scan in |
| SkipChkPPKQTY | Skip check prepack qty |
| SkipLottable01-04 | Skip lottable fields |
| TrackCartonType | Track carton type |
| TrackOrderWeight | Track order weight |
| TrackActualCarton | Track actual carton |
| UCCWithMultiSKU | UCC with multi-SKU |
| VerifySKU | Verify SKU |
| VerifyToID | Verify to-ID |
| VerifyPallet | Verify pallet |
| PPABlindCount | PPA blind count |
| PPACheckTolerance | PPA check tolerance |
| PPAAllowSKUNotInPickList | PPA allow SKU not in pick list |
| PPAAllowQTYExceedTolerance | PPA allow qty exceed tolerance |
| PPAPromptDiscrepancy | PPA prompt discrepancy |
| PPAShowSummary | PPA show summary |
| PreCartonization | Pre-cartonization |
| PickZoneMandatory | Pick zone mandatory |

#### 3.3 Default Value ConfigKeys

| ConfigKey | Description |
|-----------|-------------|
| DefaultQTY | Default quantity |
| DefaultOption | Default option |
| DefaultCursor | Default cursor position |
| DefaultFromID | Default from ID |
| DefaultFromLOC | Default from location |
| DefaultToLOC / DefaultToLoc | Default to location |
| DefaultSuggToLoc | Default suggested to-location |
| DefaultSKU | Default SKU |
| DefaultPickQTY | Default pick quantity |
| DefaultPickZone | Default pick zone |
| DefaultPrintLabelOption | Default print label option |
| DefaultPrintPackListOption | Default print pack list option |
| PPADefaultQTY | PPA default quantity |
| PPADefaultPQTY | PPA default pack quantity |
| TaskDefaultQty | Task default quantity |

#### 3.4 Other ConfigKeys

| ConfigKey | Description |
|-----------|-------------|
| UCCLabel | UCC label |
| UCCTypeCol | UCC type column |
| UCCVarMarker | UCC variable marker |
| RefNoLookupColumn | Reference number lookup column |
| MbolCriteria | MBOL criteria |
| NoOfOrdersAllowed | Number of orders allowed |
| MaxTrackNoInPallet | Maximum tracking numbers per pallet |
| DispStyleColorSize | Display style/color/size |
| DisplaySKU | Display SKU |
| PTLPicKZoneReq | PTL pick zone required |
| CustomCartonNo | Custom carton number |
| CartonIDOnRcptDetail | Carton ID on receipt detail |
| PPACartonIDByPackDetailLabelNo | PPA carton ID by pack detail label number |
| PPACartonIDByPackDetailDropID | PPA carton ID by pack detail drop ID |
| PPACartonIDByPickDetailCaseID | PPA carton ID by pick detail case ID |

#### 3.5 Direct Helper SPs (Non-Config)

Also find direct helper SPs by pattern:
```
rdt_TM_{FunctionName}_*.sql      (e.g., rdt_TM_CasePick_Confirm.sql)
rdt_{func}*.sql                   (e.g., rdt_1812*.sql)
```

### Phase 4: Load Storer/WMS Mapping

Using the config file at `.github/instructions/data/V2_RDT_Production_Config.csv`:

1. **Read the mapping file**:
   - CSV format with columns: WMS, FunctionID, StorerKey, ConfigKey, Svalue
   
2. **Build lookup dictionary**:
   ```
   ExtensionSP → { WMS: "xxx", StorerKey: "xxx" }
   ```

3. **For each Extension SP found in Phase 3**:
   - Look up in mapping dictionary
   - If found: Record WMS and StorerKey
   - If NOT found: Mark as "Not Configured"

4. **Special handling for changed Extension SPs**:
   - Extension SPs with git changes MUST have Storer/WMS clearly marked in report
   - These are HIGH PRIORITY for impact assessment

### Phase 5: Analyze Git Diff

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
   - If Extension SP not in mapping, flag as "Not Configured" and recommend adding to mapping

### Phase 7: Generate Report

**CRITICAL REQUIREMENTS:**
1. **Language**: Report MUST be written entirely in **English**. No Chinese text in the report.
2. **Format**: Use the exact template format below.

**Report Template:**

---

# Batch Impact Analysis Report - {SP_Name}

## 1. Summary

| Field | Value |
|-------|-------|
| **Main SP** | {filename} |
| **Function ID** | {func_id} |
| **Base Branch** | {base_branch} |
| **Change Type** | {brief description} |
| **Severity** | **{CRITICAL/HIGH/MEDIUM/LOW}** |
| **Affected Step** | {Step_X (Step N, Screen NNNN)} |
| **Analysis Date** | {YYYY-MM-DD} |

## 2. Git Diff Changes

```diff
{actual diff content}
```

## 3. Dependency Tree (Function {func_id})

```
{main_sp} (Function {func_id})
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

## 5. Execution Path Analysis

```
{Step_Label} (Line {N}):
│
├── @nInputKey = 1 (ENTER)
│   ├── {action1} ✓ Executes
│   ├── {change_point} ← CHANGE HERE
│   │
│   └── [Skipped]
│       ├── {skipped1}
│       └── {skipped2}
│
└── @nInputKey = 2 (ESC)
    └── Not affected
```

## 6. Severity Classification

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

## 7. Extension SP Impact

| ConfigKey | SP Name | WMS | Storer | Has Changes? | Will Execute? | Change Impact |
|-----------|---------|-----|--------|--------------|---------------|---------------|
| ExtScnSP | rdt_{func}ExtScn01 | APAC-SG | NIKE | No | Yes | - |
| ExtScnSP | rdt_{func}ExtScn04 | **EMEA-UK** | **ADIDAS** | **YES** | No (return) | **CRITICAL: Entire SP logic bypassed** |
| ExtendedValidateSP | rdt_{func}ExtVal01 | AMER-US | PUMA | No | Yes | - |
| ExtendedUpdateSP | rdt_{func}ExtUpd01 | Not Configured | Not Configured | No | Yes | - |
| ... | ... | ... | ... | ... | ... | ... |

### Affected Storers Summary (Grouped by WMS/Storer)

**IMPORTANT**: When Extension SP has changes, must clearly list affected Storers:

| WMS | Storer | Affected Extension SPs | Impact Level |
|-----|--------|------------------------|--------------|
| EMEA-UK | ADIDAS | rdt_{func}ExtScn04 | **CRITICAL** |
| APAC-SG | NIKE | rdt_{func}ExtScn01 | MEDIUM |

**Note**: 
- Extension SPs marked with "Has Changes? = YES" have their own modifications in this branch
- **Storer owners must be notified for testing validation**
- "Not Configured" means the Extension SP is not found in mapping file, recommend adding to mapping

## 8. Test Recommendations

| Test Scenario | Expected Result (Fixed) | Current Result (Bug) |
|---------------|-------------------------|----------------------|
| {scenario1} | {expected} | {actual} |
| {scenario2} | {expected} | {actual} |

## 9. Suggested Fix

```sql
-- Remove/Change the problematic code
{before_code}
-- Should be:
{after_code}
```

## 10. Confidence Level

| Assessment | Confidence |
|------------|------------|
| Change Identification | **HIGH/MEDIUM/LOW** - {reason} |
| Impact Scope | **HIGH/MEDIUM/LOW** - {reason} |
| Fix Suggestion | **HIGH/MEDIUM/LOW** - {reason} |

## 11. Deployment Recommendation

**CRITICAL SECTION - MUST PROVIDE CLEAR CONCLUSION**

### Can this change be deployed to Production?

| Decision | **YES / NO / CONDITIONAL** |
|----------|---------------------------|
| Recommendation | {APPROVE / REJECT / APPROVE WITH CONDITIONS} |
| Reason | {Clear explanation} |

### Deployment Checklist

| Item | Status | Notes |
|------|--------|-------|
| Code Review | {PASSED/PENDING/FAILED} | |
| UAT Status | {PASSED/PENDING/FAILED/NOT REQUIRED} | |
| Impact to Other Storers | {NONE/LOW/MEDIUM/HIGH} | {List affected storers if any} |
| Rollback Plan | {AVAILABLE/NOT NEEDED} | {Extension SP can be disabled via config} |
| Database Changes | {NONE/SCHEMA/DATA} | {Details if any} |

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

## Example PR Review Comment Format

When reviewing a PR, structure the comment like this:

```markdown
# Pull Request Review - RDT SP Analysis

## Severity: {CRITICAL / HIGH / MEDIUM / LOW}

**Reason**: {Brief explanation of why this severity level was assigned}

## Deployment Recommendation: {APPROVED / REJECT / NEEDS REVIEW}

**Reason**: {One-line explanation of the recommendation}

---

## Summary

| Field | Value |
|-------|-------|
| **Main SP** | {rdtfnc_*.sql filename} |
| **Function ID** | {Function ID from @nFunc} |
| **Change Type** | {Brief description: variable change, logic change, flow change, etc.} |
| **Affected Step** | {Step label and screen number} |

## Changes

- {Change 1: what was added/removed/modified}
- {Change 2: what was added/removed/modified}
- {Impact on surrounding logic}

## Affected Storers

{Look up from V2_RDT_Production_Config.csv}

| WMS | Storer | Extension SP | Impact |
|-----|--------|--------------|--------|
| {WMS} | {StorerKey} | {rdt_*ExtScn*.sql} | {How this storer is affected} |
| {WMS} | {StorerKey} | {rdt_*ExtUpd*.sql} | {How this storer is affected} |

## Risk Assessment

| Issue | Severity | Description |
|-------|----------|-------------|
| {Issue name} | **{CRITICAL/HIGH/MEDIUM/LOW}** | {Description of the risk} |
| {Issue name} | {Severity} | {Description of the risk} |

## Severity Classification

### CRITICAL (Must Fix Before Deploy)

| Issue ID | Description | Root Cause | Affected Scope |
|----------|-------------|------------|----------------|
| {ID-001} | {description} | Line {N}: {cause} | **ALL Storers** |

### HIGH (Review Before Deploy)

| Issue ID | Description | Root Cause | Affected Scope |
|----------|-------------|------------|----------------|
| {ID-002} | {description} | Line {N}: {cause} | {Specific storers} |

### MEDIUM (Monitor After Deploy)

| Issue ID | Description | Root Cause | Affected Scope |
|----------|-------------|------------|----------------|
| {ID-003} | {description} | Line {N}: {cause} | {Scope} |

### LOW (Tech Debt)

| Issue ID | Description | Root Cause | Affected Scope |
|----------|-------------|------------|----------------|
| {ID-004} | {description} | Line {N}: {cause} | {Scope} |

**Issue Type Legend:**
- **RUNTIME_BUG**: Logic error, SP exists and executes incorrectly
- **SESSION_BUG**: Affects MOBREC state at Quit (impacts ALL storers)
- **CONFIG_ISSUE**: SP configured but file missing (pre-existing, LOW)

## Test Recommendations

- [ ] {Test scenario 1 with specific storer/WMS}
- [ ] {Test scenario 2 with specific storer/WMS}
- [ ] {Verification step}

---

┌─────────────────────────────────────────────────────────────────┐
│  DEPLOYMENT DECISION: {APPROVED / NEEDS REVIEW}      │
│                                                                 │
│  {One sentence summary of the decision and any conditions}      │
└─────────────────────────────────────────────────────────────────┘
```

---

## Version

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.1 | 2026-04-29 | RDT Team | Added mandatory PR summary requirements (Severity, Deployment Recommendation, Affected Storers) and example format |
| 1.0 | 2026-04-29 | RDT Team | Initial PR review instructions based on RDT_SP_Analysis.md v1.7 |
