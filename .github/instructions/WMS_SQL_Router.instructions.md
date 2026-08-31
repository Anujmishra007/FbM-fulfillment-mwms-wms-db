---
applyTo: "WMS/**/*.sql,**/*.sql"
description: "Top-level router for the Maersk WMS SQL repository. Use this to decide which deeper instructions / templates / PR-review playbooks to load for the file(s) under discussion."
---

# WMS SQL Repository Router

This repository (`FbM-fulfillment-mwms-wms-db`) is the source of truth for the **Maersk Fulfilled by Maersk (FbM) Warehouse Management System (WMS)** database. Everything is **Microsoft SQL Server (T-SQL)**. Object types you will encounter:

| Path | Object type | Naming examples |
|------|-------------|-----------------|
| `WMS/StoredProc/RDT/rdtfnc_*.sql` | RDT Main Function SP (handheld terminal flow) | `rdtfnc_TM_CasePick.sql` |
| `WMS/StoredProc/RDT/rdt_*.sql` | RDT Extension / Helper SP | `rdt_1812ExtScn01.sql`, `rdt_TM_CasePick_Confirm.sql` |
| `WMS/Message/rdt*.sql` | RDT message catalog inserts | `rdt_855ExtUpd03_message.sql` |
| `WMS/Screen/rdt*.sql` | RDT screen metadata | |
| `WMS/StoredProc/*.sql` | Generic Inventory / Inbound / Outbound SP | `isp_*`, `nsp_*`, `msp_*`, `lsp_*` |
| `WMS/StoredProc/WM/*.sql`, `WMS/StoredProc/API/*.sql` | WM-schema / API-schema SPs | |
| `WMS/Function/*.sql`, `WMS/Function/API/*.sql` | Scalar / table-valued functions | |
| `WMS/Trigger/*.sql`, `WMS/Trigger/API/*.sql`, `WMS/Trigger/RDT/*.sql` | DML triggers | `ntr*` prefix |
| `WMS/Tables/*.sql`, `WMS/Tables/API/*.sql`, `WMS/Tables/WM/*.sql`, `WMS/Tables/RDT/*.sql` | Table DDL | |
| `WMS/Views/*.sql` | Views | |
| `WMS/Sequence/*.sql`, `WMS/UDF_DataType/*.sql`, `WMS/Master/*.sql`, `WMS/Data/*.sql`, `WMS/Jobs/*.sql`, `WMS/Security/*.sql` | Misc database objects | |

## Always-on Coding Rules

For **any** SQL change in this repo, follow:

- [CODE_STANDARDS.md](./CODE_STANDARDS.md) — human-readable T-SQL standards (CREATE OR ALTER, TRY/CATCH, schema prefix, ROWLOCK, NOLOCK, TRY_CAST, GRANT TO NSQL, GO statements, CRLF + 3-space indent).
- [code_standards.json](./code_standards.json) — same rules in machine-readable form (used by automated checks).

## How to Pick the Right Deeper Instructions

### 1. Editing an RDT SP (`WMS/StoredProc/RDT/...`)

| Filename pattern | Purpose | Load this template |
|------------------|---------|--------------------|
| `rdtfnc_*.sql` | Main Function SP | [RDT_ExtendedSP_Call_Template.md](./RDT_ExtendedSP_Call_Template.md), [RDT_ExtendedScn_Integration_Template.md](./RDT_ExtendedScn_Integration_Template.md) |
| `rdt_<func>ExtVal*.sql` / `rdt_<func>ExtValid*.sql` | Extended Validate SP | [RDT_CustomValidation_SP_Template.md](./RDT_CustomValidation_SP_Template.md) |
| `rdt_<func>ExtUpd*.sql` | Extended Update SP (transactional) | [RDT_CustomDataUpdate_SP_Template.md](./RDT_CustomDataUpdate_SP_Template.md) |
| `rdt_<func>ExtInfo*.sql` | Extended Info SP | [RDT_CustomDisplayInfo_SP_Template.md](./RDT_CustomDisplayInfo_SP_Template.md) |
| `rdt_<func>ExtScn*.sql` | Extended Screen SP (Step_99) | [RDT_CustomScreenLogic_SP_Template.md](./RDT_CustomScreenLogic_SP_Template.md) |
| Any of the above | Overview & workflow | [RDT_ExtendedSP_Development_Guide.md](./RDT_ExtendedSP_Development_Guide.md) |

When **reviewing** an RDT PR (or asked to assess impact), follow:
- [RDT_pr_review.instructions.md](./RDT_pr_review.instructions.md) — uses [`data/V2_RDT_Production_Config.csv`](./data/V2_RDT_Production_Config.csv) to enumerate affected storers / WMS regions.

### 2. Editing a non-RDT WMS SP, Trigger, Table, or Function

(`WMS/StoredProc/*.sql`, `WMS/StoredProc/WM/*.sql`, `WMS/StoredProc/API/*.sql`, `WMS/Trigger/**/*.sql`, `WMS/Tables/**/*.sql`, `WMS/Function/**/*.sql` — **excluding** anything matched by the RDT block above.)

When **reviewing** such a PR, follow:
- [IOINV_PR_Review.instructions.md](./IOINV_PR_Review.instructions.md) — uses [`data/V2_IO_Config.csv`](./data/V2_IO_Config.csv) to enumerate affected storers and to classify Common vs Custom SPs via the file's `Purpose` header and `nspGetRight*` / `dbo.fnc_GetRight` calls.

For **authoring** changes, apply the always-on rules from `CODE_STANDARDS.md`; no specialized template currently exists for IO/INV SPs — model after similar files in the same folder.

### 3. Editing message catalogs (`WMS/Message/*.sql`)

- Allocate a **system-unique** error number (rule `GENERAL-007`).
- Keep error text aligned with messages already in the same area.
- RDT messages: filename mirrors the SP, e.g. `rdt_855ExtUpd03_message.sql`.

### 4. Editing schema (`WMS/Tables/**/*.sql`)

- Use `dbo.` / `RDT.` / `WM.` / `API.` schema prefix everywhere.
- Mirror DDL conventions in neighbouring `*.sql` (column casing, default constraints, `_DELLOG` shadow tables).
- Any column rename/drop / type change is a **breaking schema change** — flag as `priority: high` or higher in PR review.

## Exclusions / Boundaries

- The `RDT_pr_review` and `IOINV_PR_Review` playbooks are **mutually exclusive** by glob — never apply both to the same file.
- Compiled / generated content under `WMS/Compile All WMS/` is historical and out of scope for new development.
- `.lock.yml` files under `.github/workflows/` are generated by `gh aw compile` — never hand-edit.

## Quick Triage Cheatsheet (for `issue-triage` workflow)

Use these area labels when classifying issues:

| Label | Matches issues / files about |
|-------|------------------------------|
| `area: rdt` | RDT handheld flows, `rdtfnc_*`, `rdt_*`, RDT screens / messages |
| `area: inventory` | Adjustments, IQC, stock take, ABC, `isp_*Adj*`, `isp_*CC*`, `isp_*IQC*`, `isp_*Stk*` |
| `area: inbound` | Receipt, ASN, putaway, `isp_ASN*`, `isp_REC*`, `isp_RC*`, `isp_PO*`, `nspAL*`, `mspASN*`, `mspPOA*`, `nspPR*` |
| `area: outbound` | Wave, allocation, pick, pack, ship, MBOL, load, `isp_RLWAV*`, `isp_RVWAV*`, `isp_WAV*`, `isp_PK*`, `isp_PAK*`, `isp_MB*`, `isp_SHP*`, `isp_LP*`, `msp_*Wave*`, `nspRP*` |
| `area: interface` | Transmit logs, EAI / TMS / WCS / OMS / WSITF, `isp_ITF_*`, `isp_TCP*`, `isp_WS*`, `isp_RCM_*`, `ntr*Transmitlog*` |
| `area: reporting` | `isp_RPT_*`, `*_rpt.sql`, JReport, dashboards |
| `area: schema` | Anything under `WMS/Tables/`, `WMS/Sequence/`, `WMS/UDF_DataType/` |
| `area: trigger` | Anything under `WMS/Trigger/` (`ntr*` prefix) |
| `area: deploy` | `.github/workflows/*DEPLOY*.yaml`, `Compile All WMS/`, `version.sql` |
| `area: agentic` | Anything under `.github/workflows/*.md` (gh-aw agentic workflows) |

