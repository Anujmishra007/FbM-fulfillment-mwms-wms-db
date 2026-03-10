"""
Configuration file for Production DB vs Repo Comparison Tool
Edit these paths according to your environment
"""

import os

# ============================================================================
# PATHS - UPDATE THESE
# ============================================================================

# Production database exports (from PowerShell scripts)
# Example: "P:/ProdExports" or "/path/to/production/exports"
PROD_EXPORT_BASE = "/Users/animesh.singh/Documents/Unification_Scripts/ProdDB_Comparison/Export"

# V0 Repository path
V0_REPO_BASE = "/Users/animesh.singh/Documents/GitHub/fbm-mwms-unified-wms-db/WMS"
V0_REPO_ROOT = "/Users/animesh.singh/Documents/GitHub/fbm-mwms-unified-wms-db"

# Branch to use for V0 repository
V0_BRANCH = "master"

# Reference Excel file from compare.py (for metadata)
REFERENCE_EXCEL = "/Users/animesh.singh/Documents/Unification_Scripts/Release_Comparison/Release_Comparison_02-09-26_20-27.xlsx"

# Output directory structure (matches compare.py pattern)
import os
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_DIR = os.path.join(SCRIPT_DIR, "ProdDB_Comparison_Results")
OUTPUT_XLSX = os.path.join(OUTPUT_DIR, "ProdDB_Comparison.xlsx")

# ============================================================================
# OBJECT TYPES TO COMPARE
# ============================================================================

# These should match the folder names in both production exports and repository
# Export folders: Function, Sequence, StoredProc, Tables, Trigger, Views
# Repo folders: Function, Sequence, StoredProc, Tables, Trigger, Views
OBJECT_TYPES = [
    "StoredProc",    # Stored Procedures
    "Function",      # Functions
    "Trigger",       # Triggers
    "Sequence",      # Sequences
    "Views",         # Views
    "Tables",        # Tables
]

# ============================================================================
# OUTPUT SETTINGS
# ============================================================================

# Output directory (relative to script location)
OUTPUT_SUBDIR = "Output"

# Excel filename pattern (datetime will be appended)
EXCEL_FILENAME_PREFIX = "ProdDB_vs_Repo_Comparison"

# HTML diff subdirectory
HTML_DIFF_SUBDIR = "html_diffs"

# Summary dashboard filename
SUMMARY_FILENAME = "Summary_Dashboard.html"

# ============================================================================
# COMPARISON SETTINGS
# ============================================================================

# Enable/disable features
ENABLE_VERSION_DETECTION = True
ENABLE_COSMETIC_FILTERING = True
ENABLE_HTML_DIFFS = True
ENABLE_METADATA_IMPORT = True

# File extension filter
SQL_FILE_EXTENSION = ".sql"

# Create backup of reference Excel before modifications
CREATE_BACKUP = True

# ============================================================================
# REPORTING SETTINGS
# ============================================================================

# Columns to include in Excel report
EXCEL_COLUMNS = [
    "Filename",
    "Status",
    "Production Path",
    "Repo Path",
    "Production Latest Version",
    "Repo Latest Version",
    "Version Comparison",
    "Version Difference",
    "Production Version Count",
    "Repo Version Count",
    "Production-Only Versions",
    "Repo-Only Versions",
    "Content Difference",
    "Logic Difference",
    "Cosmetic Only",
    "Change Classification",
    "Priority",
    "Risk Level",
    "Manual Review Needed",
    "HTML Diff File",
    "Category",
    "Domain",
    "Dev Domain",
    "Unified",
    "Unified Date",
    "Analysis Notes",
    "Description"
]

# Apply conditional formatting to Excel
APPLY_EXCEL_FORMATTING = True

# Generate summary statistics
GENERATE_SUMMARY_STATS = True

# ============================================================================
# ADVANCED SETTINGS
# ============================================================================

# Maximum file size for comparison (in MB) - skip files larger than this
MAX_FILE_SIZE_MB = 50

# Enable parallel processing (for large datasets)
ENABLE_PARALLEL_PROCESSING = False
MAX_WORKERS = 4

# Verbose logging
VERBOSE = True

# Debug mode (additional logging)
DEBUG = False
