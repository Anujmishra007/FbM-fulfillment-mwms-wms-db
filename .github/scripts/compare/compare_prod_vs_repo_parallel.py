#!/usr/bin/env python3
"""
Production Database vs Repository Comparison Tool - PARALLEL VERSION

Matches compare.py structure with metadata loading from Release Comparison Excel
"""

import os
import re
import hashlib
import logging
from datetime import datetime
from pathlib import Path
from multiprocessing import Pool, cpu_count
from functools import partial
import openpyxl
from openpyxl import load_workbook
from openpyxl.styles import PatternFill, Font, Alignment
from difflib import HtmlDiff
import time

from config import *

# Setup logging and directories
log_file = Path(OUTPUT_DIR) / f"comparison_log_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
DIFF_DIR = Path(OUTPUT_DIR) / "ProdDB_html_diffs"
os.makedirs(OUTPUT_DIR, exist_ok=True)
os.makedirs(DIFF_DIR, exist_ok=True)

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(log_file),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


def detect_encoding(file_path):
    """Detect file encoding using multiple strategies"""
    # Try chardet for automatic detection (if available)
    try:
        import chardet
        with open(file_path, 'rb') as f:
            raw_data = f.read()
            result = chardet.detect(raw_data)
            if result['confidence'] > 0.7:
                return result['encoding'], result['confidence']
    except (ImportError, Exception):
        pass
    
    # Fallback: try common encodings
    encodings_to_try = [
        ('utf-8-sig', 'UTF-8 with BOM'),
        ('utf-8', 'UTF-8'),
        ('utf-16', 'UTF-16'),
        ('windows-1252', 'Windows-1252'),
        ('latin-1', 'Latin-1'),
        ('cp1252', 'CP1252'),
        ('iso-8859-1', 'ISO-8859-1'),
        ('gb2312', 'Chinese GB2312'),
        ('gbk', 'Chinese GBK'),
        ('big5', 'Traditional Chinese Big5')
    ]
    
    with open(file_path, 'rb') as f:
        raw_data = f.read()
    
    for encoding, desc in encodings_to_try:
        try:
            raw_data.decode(encoding)
            return encoding, 1.0  # Successfully decoded
        except (UnicodeDecodeError, LookupError):
            continue
    
    return 'utf-8', 0.0  # Default to UTF-8 with errors='replace'


def read_file_smart_encoding(file_path):
    """Read file with smart encoding detection and normalize to UTF-8
    
    This function:
    1. Detects the file's actual encoding
    2. Reads the content in that encoding
    3. Normalizes to UTF-8 for consistent comparison
    4. Handles encoding errors gracefully
    """
    detected_encoding, confidence = detect_encoding(file_path)
    
    try:
        with open(file_path, 'rb') as f:
            raw_data = f.read()
        
        # Try detected encoding first
        try:
            if confidence > 0:
                content = raw_data.decode(detected_encoding)
                # Log encoding if it's not UTF-8 (helps track encoding issues)
                if detected_encoding.lower() not in ['utf-8', 'utf-8-sig']:
                    logger.debug(f"File {file_path.name} detected as {detected_encoding} (confidence: {confidence:.2f})")
            else:
                # Low confidence - use UTF-8 with error replacement
                content = raw_data.decode('utf-8', errors='replace')
                logger.debug(f"File {file_path.name} using UTF-8 with error replacement")
        except (UnicodeDecodeError, LookupError):
            # Fallback: UTF-8 with error replacement
            content = raw_data.decode('utf-8', errors='replace')
            logger.warning(f"File {file_path.name} failed to decode as {detected_encoding}, using UTF-8 with error replacement")
        
        # Normalize encoding artifacts:
        # 1. Replace replacement character � with a marker
        content = content.replace('�', '<ENCODING_ERROR>')
        
        # 2. Normalize line endings to \n
        content = content.replace('\r\n', '\n').replace('\r', '\n')
        
        # 3. Remove BOM if present (already handled by utf-8-sig, but double-check)
        if content.startswith('\ufeff'):
            content = content[1:]
        
        return content
        
    except Exception as e:
        logger.error(f"Failed to read {file_path}: {str(e)}")
        return ""


def load_reference_metadata(file_list=None):
    """Load Category, Domain, Dev Domain, Unified, Unified Date from Reference Excel
    
    Args:
        file_list: Optional list of filenames to load metadata for (filters irrelevant files)
    """
    metadata = {}
    
    if not os.path.exists(REFERENCE_EXCEL):
        logger.warning(f"Reference Excel not found: {REFERENCE_EXCEL}")
        logger.warning("Continuing without metadata...")
        return metadata
    
    try:
        logger.info(f"Loading metadata from: {REFERENCE_EXCEL}")
        
        # Use pandas for much faster Excel reading (10-100x faster than openpyxl)
        import pandas as pd
        
        # Get all available sheets in the Excel file
        excel_file = pd.ExcelFile(REFERENCE_EXCEL, engine='openpyxl')
        available_sheets = excel_file.sheet_names
        
        # Define sheets to read (try all object type comparison sheets)
        sheets_to_read = [
            "StoredProc Comparison",
            "Trigger Comparison", 
            "Function Comparison",
            "Views Comparison",
            "Tables Comparison",
            "Sequence Comparison"
        ]
        
        # Filter to only sheets that actually exist
        sheets_to_read = [s for s in sheets_to_read if s in available_sheets]
        
        if not sheets_to_read:
            logger.warning("No comparison sheets found in reference Excel")
            return metadata
        
        logger.info(f"Found sheets: {', '.join(sheets_to_read)}")
        
        # Load metadata from all available sheets
        for sheet_name in sheets_to_read:
            logger.info(f"  Loading from sheet: {sheet_name}")
            
            # Read only necessary columns to speed up loading
            try:
                df = pd.read_excel(
                    REFERENCE_EXCEL, 
                    sheet_name=sheet_name,
                    usecols=['Filename', 'Category', 'Domain', 'Dev Domain', 'Unified', 'Unified Date'],
                    engine='openpyxl'
                )
            except Exception as e:
                logger.warning(f"  Could not read {sheet_name}: {e}")
                continue
            except Exception as e:
                logger.warning(f"  Could not read {sheet_name}: {e}")
                continue
        
            # Convert to dictionary for faster lookups
            sheet_count = 0
            for _, row in df.iterrows():
                filename = row['Filename']
                
                if not filename or pd.isna(filename):
                    continue
                
                # Normalize the Excel filename to handle all cases:
                # - Plain: isp_UpdateWorkStation.sql -> isp_UpdateWorkStation.sql
                # - With schema: dbo.isp_UpdateWorkStation.sql -> isp_UpdateWorkStation.sql
                # - Trigger with table: RDT.Table.trigger.sql -> trigger.sql OR dbo.MBOLDETAIL.ntrMBOLDetailAdd.sql -> ntrMBOLDetailAdd.sql
                
                # First, normalize extension to lowercase (handle .SQL vs .sql)
                if filename.upper().endswith('.SQL'):
                    filename = filename[:-4] + '.sql'
                
                # Then, determine if it's a trigger (has 2+ dots in name without .sql)
                name_without_ext = filename.replace('.sql', '')
                dot_count = name_without_ext.count('.')
                
                if dot_count >= 2:
                    # Could be: schema.table.trigger or just schema.name with extra dots
                    # Take last part for triggers, or remove first part for others
                    parts = name_without_ext.split('.')
                    # If it looks like schema.table.trigger, take last part
                    # Otherwise just remove schema (first part)
                    if dot_count == 2:
                        # schema.table.trigger -> trigger
                        filename_key = parts[-1] + '.sql'
                    else:
                        # schema.name.extra -> name.extra
                        filename_key = '.'.join(parts[1:]) + '.sql'
                elif dot_count == 1:
                    # schema.name -> name
                    filename_key = filename.split('.', 1)[1]
                else:
                    # Plain filename
                    filename_key = filename
                
                # If file_list is provided, only load metadata for files in that list
                # Use case-insensitive comparison
                if file_list:
                    filename_key_lower = filename_key.lower()
                    # For sets, just check membership directly (sets are already fast)
                    # Convert to lowercase for comparison
                    if filename_key_lower not in {f.lower() for f in file_list}:
                        continue
                
                # Store with lowercase key for case-insensitive lookup
                metadata_key = filename_key.lower()
                
                metadata[metadata_key] = {
                    'Category': row.get('Category', '') if not pd.isna(row.get('Category')) else '',
                    'Domain': row.get('Domain', '') if not pd.isna(row.get('Domain')) else '',
                    'Dev Domain': row.get('Dev Domain', '') if not pd.isna(row.get('Dev Domain')) else '',
                    'Unified': row.get('Unified', '') if not pd.isna(row.get('Unified')) else '',
                    'Unified Date': row.get('Unified Date', '') if not pd.isna(row.get('Unified Date')) else ''
                }
                sheet_count += 1
            
            logger.info(f"    Loaded {sheet_count} metadata entries from {sheet_name}")
        
        logger.info(f"Total metadata loaded: {len(metadata)} unique files")
        return metadata
        
    except Exception as e:
        logger.error(f"Error loading reference Excel: {e}")
        return metadata


def load_existing_comparison_data(object_type):
    """Load existing comparison data to preserve manual columns"""
    existing_data = {}
    existing_order = []
    
    if not os.path.exists(OUTPUT_XLSX):
        return existing_data, existing_order
    
    try:
        wb = load_workbook(OUTPUT_XLSX)
        sheet_name = f"{object_type} Comparison"
        
        if sheet_name not in wb.sheetnames:
            wb.close()
            return existing_data, existing_order
        
        ws = wb[sheet_name]
        headers = [cell.value for cell in ws[1]]
        col_map = {header: idx for idx, header in enumerate(headers, 1)}
        
        for row_idx in range(2, ws.max_row + 1):
            row_cells = list(ws[row_idx])
            filename = row_cells[0].value
            
            if not filename:
                continue
            
            existing_order.append(filename)
            
            # Store all manual columns
            existing_data[filename] = {
                'Category': row_cells[col_map.get('Category', 10) - 1].value if col_map.get('Category') else '',
                'Domain': row_cells[col_map.get('Domain', 11) - 1].value if col_map.get('Domain') else '',
                'Dev Domain': row_cells[col_map.get('Dev Domain', 12) - 1].value if col_map.get('Dev Domain') else '',
                'Unified': row_cells[col_map.get('Unified', 13) - 1].value if col_map.get('Unified') else '',
                'Unified Date': row_cells[col_map.get('Unified Date', 14) - 1].value if col_map.get('Unified Date') else '',
                'Analysis Notes': row_cells[col_map.get('Analysis Notes', 15) - 1].value if col_map.get('Analysis Notes') else '',
                'Description': row_cells[col_map.get('Description', 16) - 1].value if col_map.get('Description') else '',
                'Conflict Resolve(DD-MM-YY)': row_cells[col_map.get('Conflict Resolve(DD-MM-YY)', 17) - 1].value if col_map.get('Conflict Resolve(DD-MM-YY)') else ''
            }
        
        wb.close()
        logger.info(f"Loaded existing data for {len(existing_data)} files from previous comparison")
        return existing_data, existing_order
        
    except Exception as e:
        logger.warning(f"Could not load existing comparison data: {e}")
        return existing_data, existing_order


# Import core functions from original script
import sys
sys.path.insert(0, os.path.dirname(__file__))


def extract_schema_and_name(filename):
    """Extract schema and object name from filename"""
    name_without_ext = filename.replace('.sql', '')
    if '.' in name_without_ext:
        parts = name_without_ext.split('.')
        return parts[0], '.'.join(parts[1:])
    return 'dbo', name_without_ext


def normalize_filename(filename, object_type=None):
    """Remove schema and table prefixes from filename for consistent comparison
    
    Examples:
        StoredProc: dbo.isp867DecodeSP01.sql -> isp867DecodeSP01.sql
        StoredProc: API.isp_GetData.sql -> isp_GetData.sql
        Trigger: RDT.RDTUser.ntrRDTUserDelete.sql -> ntrRDTUserDelete.sql (remove schema.table)
        Trigger: dbo.Orders.trgUpdateOrder.sql -> trgUpdateOrder.sql
        isp_SimpleFile.sql -> isp_SimpleFile.sql (no change)
    """
    # Normalize extension to lowercase first (handle .SQL vs .sql)
    if filename.upper().endswith('.SQL'):
        filename = filename[:-4] + '.sql'
    
    # For triggers, need to handle schema.table.trigger.sql pattern
    # Remove .sql extension to count dots in the name part
    name_without_ext = filename.replace('.sql', '')
    dot_count = name_without_ext.count('.')
    
    if object_type == 'Trigger' and dot_count >= 2:
        # Pattern: schema.table.trigger.sql -> extract just trigger.sql
        # Split and take the last part (trigger name)
        parts = name_without_ext.split('.')
        return parts[-1] + '.sql'  # Last part + .sql extension
    elif dot_count >= 1:
        # Pattern: schema.name.sql -> extract just name.sql
        return filename.split('.', 1)[1]  # Remove first part (schema)
    
    return filename


def extract_version_history(content):
    """Extract version entries from the Updates/Modifications section
    
    Looks for the Updates or Modifications table where developers mark versions
    with each update, not the static PVCS Version or Version fields.
    Example:
        /* Updates:                                                             */
        /* Date         Author  Ver   Purposes                                  */
        /* 05-May-2022  WLChooi  1.0  DevOps Combine Script                     */
        /* 31-Oct-2023  WLChooi  1.1  UWP-10213 - Global Timezone (GTZ01)       */
    """
    # Find the CREATE statement position
    create_match = re.search(
        r'CREATE\s+(OR\s+ALTER\s+)?(PROCEDURE|PROC|FUNCTION|TRIGGER|VIEW|TABLE|SEQUENCE)',
        content,
        re.IGNORECASE
    )
    
    # Only search for versions in content BEFORE CREATE statement
    search_content = content[:create_match.start()] if create_match else content
    
    # Look for version table header pattern (Date/Author/Ver/Rev/Purposes columns)
    # Can appear with or without "Updates:" or "Modifications:" label
    
    # Strategy 1: Look for "Updates:" or "Modifications:" section label
    table_start = re.search(
        r'/\*\s*(Updates|Modifications)\s*:',
        search_content,
        re.IGNORECASE
    )
    
    # Strategy 2: If no section label, look for the column header pattern directly
    if not table_start:
        # Look for comment line with Date/Author/Ver/Rev/Purposes column headers
        table_start = re.search(
            r'/\*.*?\b(Date|Author|Ver|Rev|Purposes)\b.*?\b(Date|Author|Ver|Rev|Purposes)\b',
            search_content,
            re.IGNORECASE
        )
    
    if table_start:
        # Found the start of the version table section
        # Extract everything from this point until we find something that's not a comment
        remaining_content = search_content[table_start.start():]
        
        # Get all consecutive comment lines that are part of the version table
        # Stop when we hit a non-comment line or contains specific fields like "PVCS Version:" or "Version:"
        version_table_lines = []
        for line in remaining_content.split('\n'):
            stripped = line.strip()
            # Stop if we hit a non-comment line or a line with "PVCS Version" or generic "Version"
            if not stripped.startswith('/*') or re.search(r'(PVCS\s+Version|^\s*/\*\s*Version\s*:)', line, re.IGNORECASE):
                break
            version_table_lines.append(line)
        
        # Join all table lines
        table_content = '\n'.join(version_table_lines)
        
        # Two cases to handle:
        # Case A: Table WITH column headers (Date, Author, Ver/Rev, Purposes)
        # Case B: Table WITHOUT headers - goes straight to version entries
        
        # Check if table has column header row
        has_header_row = re.search(r'\b(Date|Author|Ver|Rev|Purposes)\b.*?\b(Date|Author|Ver|Rev|Purposes)\b', 
                                   table_content, re.IGNORECASE)
        
        if has_header_row:
            # Case A: Has column headers - validate it has Ver/Rev/Version column
            has_version_column = re.search(r'\b(Ver|Rev|Version)\b', table_content, re.IGNORECASE)
            
            if has_version_column:
                # Extract all digit.digit patterns from the table
                all_versions = re.findall(r'(\d+\.\d+)', table_content)
                
                if all_versions:
                    # Return the last version found (most recent update)
                    return all_versions[-1]
            
            # Has header but no version column - fall through to PVCS fallback
        else:
            # Case B: No column headers - look for version patterns in data lines
            # Pattern: date-like entries followed by version numbers
            
            # Extract all digit.digit patterns, but exclude dates (which have dashes/slashes)
            # Strategy: Find lines with version-like patterns but filter out date patterns
            all_versions = []
            for line in version_table_lines:
                # Skip the Updates/Modifications label line
                if re.search(r'(Updates|Modifications)\s*:', line, re.IGNORECASE):
                    continue
                
                # Look for version patterns (digit.digit) that aren't part of dates
                # Dates look like: 28-May-2014 or 05-15-2014
                # Versions look like: 1.1 or 1.22 (usually 1-2 digits on each side)
                
                # Find all digit.digit patterns
                potential_versions = re.findall(r'(\d+\.\d+)', line)
                for ver in potential_versions:
                    # Filter out patterns that look like dates (e.g., 2014.05)
                    parts = ver.split('.')
                    if len(parts) == 2:
                        # Likely a version if both parts are small numbers (not years)
                        if int(parts[0]) < 100 and int(parts[1]) < 100:
                            all_versions.append(ver)
            
            if all_versions:
                # Return the last version found (most recent update)
                return all_versions[-1]
        
        # Version table exists but couldn't extract version - fall through to PVCS Version fallback
    
    # No version table found - Fallback: Look for specific version labels like "PVCS Version:"
    # Avoid generic "Version:" field which is usually static (e.g., "Version: 5.4")
    
    # Look for PVCS Version specifically
    pvcs_version = re.search(r'PVCS\s+Version\s*:\s*(\d+\.\d+)', search_content, re.IGNORECASE)
    if pvcs_version:
        return pvcs_version.group(1)
    
    # Look for other specific version patterns (but not plain "Version:")
    # Use word boundaries to avoid matching "Ver" in "Version"
    comment_blocks = re.findall(r'/\*.*?\*/', search_content, re.DOTALL)
    comment_lines = re.findall(r'--.*?$', search_content, re.MULTILINE)
    all_comments = comment_blocks + comment_lines
    
    versions = []
    for comment in all_comments:
        # Look for specific version labels with word boundaries (but exclude plain "Version:")
        # \b ensures "Ver" doesn't match "Version", and we explicitly exclude "Version:"
        labeled_versions = re.findall(
            r'\b(?:Ver|Revision|Rev)\.?\s*:\s*(\d+\.\d+)',
            comment,
            re.IGNORECASE
        )
        if labeled_versions:
            versions.extend(labeled_versions)
    
    # Return the last version found (most recent)
    return versions[-1] if versions else "N/A"


def compare_version_numbers(prod_ver, repo_ver):
    """Compare two version numbers and return label"""
    # Handle "N/A" as None
    if prod_ver == "N/A":
        prod_ver = None
    if repo_ver == "N/A":
        repo_ver = None
    
    if prod_ver is None and repo_ver is None:
        return "No Version Info", "N/A"
    if prod_ver is None:
        return "Repo Only Has Version", "N/A"
    if repo_ver is None:
        return "Prod Only Has Version", "N/A"
    
    try:
        # Parse versions as major.minor (e.g., "1.10" -> [1, 10])
        # Don't use float() as it loses precision: float("1.10") becomes 1.1
        prod_parts = [int(x) for x in prod_ver.split('.')]
        repo_parts = [int(x) for x in repo_ver.split('.')]
        
        # Pad with zeros if needed (e.g., "1" vs "1.0")
        max_len = max(len(prod_parts), len(repo_parts))
        prod_parts.extend([0] * (max_len - len(prod_parts)))
        repo_parts.extend([0] * (max_len - len(repo_parts)))
        
        # Compare as tuples (semantic version comparison)
        if prod_parts > repo_parts:
            diff = sum((p - r) * (10 ** (max_len - i - 1)) for i, (p, r) in enumerate(zip(prod_parts, repo_parts)))
            return "Prod Higher", f"+{diff}"
        elif prod_parts < repo_parts:
            diff = sum((r - p) * (10 ** (max_len - i - 1)) for i, (p, r) in enumerate(zip(prod_parts, repo_parts)))
            return "Repo Higher", f"-{diff}"
        else:
            return "Same", "0"
    except:
        return "Version Format Error", "N/A"


def normalize_sql_for_comparison(content):
    """Extract and compare only the actual procedure/function body - ignore setup/teardown"""
    
    # STEP 0: Normalize encoding artifacts (already handled by read_file_smart_encoding)
    # Additional normalization for comparison:
    # Replace encoding error markers with a consistent placeholder
    content = content.replace('<ENCODING_ERROR>', '<ENC>')  # Consistent marker
    # Also handle legacy ? sequences (from old comparisons)
    content = re.sub(r'\?{2,}', '<ENC>', content)  # Replace multiple ? with marker
    
    # FIRST: Remove ALL comments from the entire content (before any processing)
    # This ensures comments don't interfere with pattern matching
    content_no_comments = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
    content_no_comments = re.sub(r'--.*?$', '', content_no_comments, flags=re.MULTILINE)
    
    # Remove SET statements at file beginning (cosmetic - e.g., SET ANSI_NULLS ON/OFF, SET QUOTED_IDENTIFIER ON/OFF)
    # These appear before CREATE and are database session settings, not logic
    content_no_comments = re.sub(r'^\s*SET\s+\w+\s+(ON|OFF)\s*', '', content_no_comments, flags=re.IGNORECASE | re.MULTILINE)
    
    # Remove GO statements (cosmetic)
    content_no_comments = re.sub(r'\bGO\b', '', content_no_comments, flags=re.IGNORECASE)
    
    # Remove DROP IF EXISTS patterns (cosmetic) - handle complex multi-line patterns
    # Pattern: IF EXISTS (SELECT ... FROM sysobjects/sys.objects ...) DROP TRIGGER/PROC/etc [name]
    # This can span multiple lines and include nested parentheses
    content_no_comments = re.sub(
        r'if\s+exists\s*\(.*?select.*?\)\s*drop\s+(trigger|procedure|proc|function|view|table)\s+[\w\.\[\]]+',
        '',
        content_no_comments,
        flags=re.IGNORECASE | re.DOTALL
    )
    # Pattern 2: Simpler DROP IF EXISTS syntax
    content_no_comments = re.sub(
        r'drop\s+(trigger|procedure|proc|function|view|table)\s+if\s+exists\s+[\w\.\[\]]+',
        '',
        content_no_comments,
        flags=re.IGNORECASE
    )
    
    # Remove GRANT statements (cosmetic)
    content_no_comments = re.sub(r'GRANT\s+[\w\s]+\s+ON\s+[\w\.\[\]]+\s+TO\s+[\w\.\[\]]+', '', content_no_comments, flags=re.IGNORECASE)
    
    # Remove ALTER TABLE ... ENABLE/DISABLE TRIGGER statements (cosmetic)
    content_no_comments = re.sub(r'ALTER\s+TABLE\s+[\w\.\[\]]+\s+(?:ENABLE|DISABLE)\s+TRIGGER\s+[\w\.\[\]]+', '', content_no_comments, flags=re.IGNORECASE)
    
    # Step 1: Find the CREATE statement and extract from parameter list onwards
    # Allow for newlines/whitespace before parameter list or AS/ON keyword
    # For triggers, the next keyword is ON, not AS or (
    create_match = re.search(
        r'CREATE\s+(OR\s+ALTER\s+)?(PROCEDURE|PROC|FUNCTION|TRIGGER|VIEW)\s+[\w\.\[\]]+\s*[\n\s]*(\(|AS|ON|@)',
        content_no_comments,
        re.IGNORECASE | re.MULTILINE | re.DOTALL
    )
    
    if not create_match:
        # No CREATE found, try to find parameters or AS/ON keyword
        fallback = re.sub(r'^.*?(AS\s|ON\s|@\w+)', r'\1', content_no_comments, flags=re.IGNORECASE | re.DOTALL)
        return re.sub(r'\s+', ' ', fallback).strip().lower()
    
    # Find where (, AS, ON, or @ starts in the matched text
    param_or_as = re.search(r'(\(|AS|ON|@)', create_match.group(0), re.IGNORECASE)
    if param_or_as:
        start_pos = create_match.start() + param_or_as.start()
    else:
        start_pos = create_match.end()
    
    body_content = content_no_comments[start_pos:]
    
    # Step 2: Remove everything AFTER the procedure body
    # Strategy: Find the last END, keep up to that END, remove all trailing GO/GRANT/SET
    
    # Find all END statements
    end_matches = list(re.finditer(r'\bEND\b', body_content, re.IGNORECASE))
    if end_matches:
        # Get the position after the last END
        last_end_pos = end_matches[-1].end()
        
        # Keep everything up to and including the last END
        before_end = body_content[:last_end_pos]
        after_end = body_content[last_end_pos:]
        
        # Remove everything from the first GO onwards (including GRANT, SET, etc.)
        # Handle: whitespace, optional labels (e.g., "Quit:"), optional SET statements, then GO and everything after
        cleaned_after = re.sub(r'[\s\n]*(?:\w+\s*:\s*)?[\s\n]*(?:SET\s+.*?[\s\n]+)?GO\s*.*$', '', after_end, flags=re.IGNORECASE | re.DOTALL)
        
        body_content = before_end + cleaned_after
    else:
        # No END found, just remove trailing GO and everything after
        body_content = re.sub(r'[\s\n]*(?:\w+\s*:\s*)?[\s\n]*(?:SET\s+.*?[\s\n]+)?GO\s*.*$', '', body_content, flags=re.IGNORECASE | re.DOTALL)
    
    # Step 3: Remove optional outer BEGIN...END (cosmetic difference)
    # The BEGIN right after AS is optional in SQL Server, but inner BEGIN...END blocks are NOT
    # Strategy: Remove AS keyword first, then remove first BEGIN if present
    
    # Remove leading AS keyword if present
    body_content = re.sub(r'^\s*AS\s+', '', body_content, flags=re.IGNORECASE)
    
    # Now check if first token is BEGIN (after removing AS)
    if re.match(r'^\s*BEGIN\b', body_content, re.IGNORECASE):
        # Remove the first BEGIN (it's the optional outer BEGIN)
        body_content = re.sub(r'^\s*BEGIN\b\s*', '', body_content, flags=re.IGNORECASE)
    
    # Remove SET statements with ON/OFF (cosmetic differences like SET ANSI_NULLS ON/OFF, SET CONCAT_NULL_YIELDS_NULL ON/OFF)
    body_content = re.sub(r'SET\s+\w+\s+(ON|OFF)\s*', '', body_content, flags=re.IGNORECASE)
    
    # Step 4: Normalize whitespace (comments already removed)
    # Remove empty lines and trailing whitespace
    lines = [line.strip() for line in body_content.split('\n') if line.strip()]
    body_content = ' '.join(lines)
    
    # Collapse multiple spaces to single space and remove all trailing/leading whitespace
    body_content = re.sub(r'\s+', ' ', body_content).strip()
    
    # Step 5: Normalize operator and comma spacing for true cosmetic comparison
    # Remove square brackets entirely FIRST (before removing spaces - cosmetic SQL Server allows identifiers with or without brackets)
    body_content = re.sub(r'\[([^\]]+)\]', r'\1', body_content)
    
    # Remove schema prefixes from identifiers (e.g., "dbo.tablename" -> "tablename")
    # This is cosmetic for triggers - ON dbo.Table vs ON Table
    body_content = re.sub(r'\b(dbo|rdt|api|sys)\.', '', body_content, flags=re.IGNORECASE)
    
    # Remove spaces around commas (both before and after)
    body_content = re.sub(r'\s*,\s*', ',', body_content)
    # Remove spaces around comparison operators
    body_content = re.sub(r'\s*(>=|<=|<>|!=|=|>|<)\s*', r'\1', body_content)
    # Remove spaces around parentheses (cosmetic)
    body_content = re.sub(r'\s*\(\s*', '(', body_content)
    body_content = re.sub(r'\s*\)\s*', ')', body_content)
    
    # Step 6: Convert to lowercase for case-insensitive comparison
    body_content = body_content.lower()
    
    return body_content


def generate_html_diff(prod_content, repo_content, filename, object_type):
    """Generate HTML diff file for visual comparison
    
    Both contents should already be normalized UTF-8 from read_file_smart_encoding.
    This function creates a human-friendly HTML diff with proper encoding display.
    """
    try:
        # Content should already be UTF-8 strings from read_file_smart_encoding
        # But handle edge cases where bytes might be passed
        if isinstance(prod_content, bytes):
            prod_content = prod_content.decode('utf-8', errors='replace')
        if isinstance(repo_content, bytes):
            repo_content = repo_content.decode('utf-8', errors='replace')
        
        # Replace encoding error markers with human-friendly display
        prod_content = prod_content.replace('<ENCODING_ERROR>', '[encoding error]')
        repo_content = repo_content.replace('<ENCODING_ERROR>', '[encoding error]')
        
        # Prepare content for diff
        prod_lines = [line.rstrip() for line in prod_content.splitlines()]
        repo_lines = [line.rstrip() for line in repo_content.splitlines()]
        
        # Normalize filename (remove schema prefix for HTML filename)
        normalized_filename = normalize_filename(filename, object_type)
        
        # Create HTML diff
        html_diff_file_path = DIFF_DIR / object_type / f"{normalized_filename}.html"
        html_diff_file_path.parent.mkdir(parents=True, exist_ok=True)
        
        html_diff = HtmlDiff(tabsize=4, wrapcolumn=100).make_file(
            prod_lines, repo_lines, 
            fromdesc="Production", 
            todesc="Repository"
        )
        
        # Ensure UTF-8 encoding is declared in HTML
        if '<meta charset' not in html_diff and '<meta http-equiv' not in html_diff:
            html_diff = html_diff.replace('<head>', '<head>\n<meta charset="UTF-8">')
        
        # Add custom CSS styling
        html_diff = html_diff.replace(
            "<style type=\"text/css\">",
            """<style type="text/css">
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            body {
                font-family: 'Courier New', monospace;
                font-size: 12px;
                padding: 10px;
                background-color: #f5f5f5;
            }
            h2 { margin-top:20px; margin-bottom:10px; color:#333; }
            .diff-container { border:1px solid #ccc; border-radius:4px; margin:10px 0; overflow-x:auto; }
            table > * { border:none !important; }
            table.diff { width:100%!important; border-collapse:collapse; background-color:white; border-spacing:0; table-layout:fixed; border:none; }
            table.diff tbody { display:table; width:100%; }
            table.diff tr { display:table-row; }
            table.diff colgroup col:nth-child(1) { width:2%; }
            table.diff colgroup col:nth-child(2) { width:47%; }
            table.diff colgroup col:nth-child(3) { width:1%; }
            table.diff colgroup col:nth-child(4) { width:2%; }
            table.diff colgroup col:nth-child(5) { width:47%; }
            table.diff td { padding:6px 8px; word-wrap:break-word; white-space:pre-wrap; overflow-wrap:break-word; vertical-align:top; font-size:11px; line-height:1.4; border:none !important; }
            table.diff th { padding:8px; background-color:#e8e8e8; font-weight:bold; text-align:left; font-size:12px; border:none !important; }
            thead tr th.diff_next { visibility:hidden; width:1%; padding:0; background-color:transparent; }
            table.diff .diff_header { background-color:#d0d0d0; font-weight:bold; }
            table.diff tbody tr td.diff_next { background-color:#c0c0c0; text-align:center; padding:2px 4px; width:1% !important; }
            table.diff .diff_add { background-color:#90EE90; }
            table.diff .diff_sub { background-color:#FFB6C6; }
            table.diff .diff_chg { background-color:#FFFF99; }
            """
        )
        html_diff = html_diff.replace("<body>", "<body>\n<div class='diff-container'>").replace("</body>", "</div>\n</body>")
        
        # Write HTML file
        with open(html_diff_file_path, "w", encoding="utf-8") as hf:
            hf.write(html_diff)
        
        # Return relative path for Excel hyperlink
        return f"ProdDB_html_diffs/{object_type}/{normalized_filename}.html"
        
    except Exception as e:
        logger.error(f"Error generating HTML diff for {filename}: {str(e)}")
        return ""


def classify_difference(hash_match, cosmetic_only, version_comp, prod_ver, repo_ver, prod_content, repo_content):
    """Classify the type of difference and assign priority"""
    
    if cosmetic_only:
        return "Cosmetic Only", 12, "NONE"
    
    if version_comp == "Prod Higher":
        # Check content size difference
        prod_lines = len(prod_content.split('\n'))
        repo_lines = len(repo_content.split('\n'))
        line_diff = abs(prod_lines - repo_lines)
        
        if line_diff > 50:
            return "Prod Higher - Major Changes", 1, "CRITICAL"
        elif line_diff > 10:
            return "Prod Higher - Moderate Changes", 2, "HIGH"
        else:
            return "Prod Higher - Minor Changes", 3, "MEDIUM"
    
    if version_comp == "Same":
        return "Same Version - Different Content", 4, "MEDIUM"
    
    if version_comp == "Repo Higher":
        return "Repo Higher", 10, "INFO"
    
    return "Logic Changes", 5, "MEDIUM"


def process_single_file(args):
    """Process a single file comparison (for parallel processing)"""
    prod_file, object_type, prod_path, repo_path, reference_metadata = args
    
    try:
        prod_file_path = prod_path / prod_file
        prod_content = read_file_smart_encoding(prod_file_path)
        
        # Extract object info
        schema, obj_name = extract_schema_and_name(prod_file)
        
        # Normalize filename by removing schema prefix
        # Production files are like: dbo.isp867DecodeSP01.sql or RDT.rdtAddScn2.sql
        # Repo files are like: isp867DecodeSP01.sql or rdtAddScn2.sql (without schema prefix)
        # For triggers: RDT.RDTUser.ntrRDTUserDelete.sql -> ntrRDTUserDelete.sql
        normalized_filename = normalize_filename(prod_file, object_type)
        
        # Search for file in repo with comprehensive fallback strategy
        # Priority 1: Try same schema subfolder (e.g., StoredProc/RDT/filename.sql)
        # Priority 2: Try root level (e.g., StoredProc/filename.sql)
        # Priority 3: Search all subfolders with rglob (normalized, then original, then case-insensitive)
        
        repo_file_path = None
        filenames_to_try = [normalized_filename]
        
        # Add original filename if different from normalized (e.g., BI.dspTH_Report.sql)
        if prod_file != normalized_filename:
            filenames_to_try.append(prod_file)
        
        # Priority 1: Check schema-specific subfolder (avoid comparing RDT with dbo)
        if schema and schema.upper() != 'DBO':
            for filename_variant in filenames_to_try:
                schema_specific_path = repo_path / object_type / schema.upper() / filename_variant
                if schema_specific_path.exists():
                    repo_file_path = schema_specific_path
                    break
            
            # Also try with schema prefix explicitly (e.g., RDT.filename.sql in RDT folder)
            if repo_file_path is None:
                schema_prefixed = repo_path / object_type / schema.upper() / f"{schema.upper()}.{normalized_filename}"
                if schema_prefixed.exists():
                    repo_file_path = schema_prefixed
        
        # Priority 2: Check root level (for dbo or files without schema folders)
        if repo_file_path is None:
            for filename_variant in filenames_to_try:
                root_level_path = repo_path / object_type / filename_variant
                if root_level_path.exists():
                    repo_file_path = root_level_path
                    break
        
        # Priority 3: Search in all subfolders as fallback (most comprehensive)
        if repo_file_path is None:
            repo_type_path = repo_path / object_type
            if repo_type_path.exists():
                # Try all filename variants
                for filename_variant in filenames_to_try:
                    for subfolder_file in repo_type_path.rglob(filename_variant):
                        repo_file_path = subfolder_file
                        break
                    if repo_file_path:
                        break
                
                # Last resort: case-insensitive search (handles BI.dspth_report vs BI.dspTH_Report)
                if repo_file_path is None:
                    normalized_lower = normalized_filename.lower()
                    for possible_file in repo_type_path.rglob('*.sql'):
                        if possible_file.name.lower() == normalized_lower:
                            repo_file_path = possible_file
                            break
                        # Also check if removing schema prefix matches
                        if '.' in possible_file.name:
                            file_without_schema = possible_file.name.split('.', 1)[1]
                            if file_without_schema.lower() == normalized_lower:
                                repo_file_path = possible_file
                                break
        
        if repo_file_path is None or not repo_file_path.exists():
            # Production only
            prod_latest = extract_version_history(prod_content)
            
            return {
                'Object Type': object_type,
                'Schema': schema,
                'Object Name': obj_name,
                'Difference Type': 'Production Only',
                'Priority': 1,
                'Priority Label': 'CRITICAL',
                'Prod File': prod_file,
                'Repo File': 'NOT FOUND',
                'Prod Latest Version': prod_latest or 'N/A',
                'Repo Latest Version': 'N/A',
                'Version Comparison': 'Prod Only',
                'Hash Match': False,
                'Cosmetic Only': False,
                'Category': reference_metadata.get(normalized_filename.lower(), {}).get('Category', ''),
                'Domain': reference_metadata.get(normalized_filename.lower(), {}).get('Domain', ''),
                'Dev Domain': reference_metadata.get(normalized_filename.lower(), {}).get('Dev Domain', ''),
                'Unified': reference_metadata.get(normalized_filename.lower(), {}).get('Unified', ''),
                'Unified Date': reference_metadata.get(normalized_filename.lower(), {}).get('Unified Date', '')
            }
        
        # Both exist - compare
        repo_content = read_file_smart_encoding(repo_file_path)
        
        # Hash comparison
        prod_hash = hashlib.md5(prod_content.encode()).hexdigest()
        repo_hash = hashlib.md5(repo_content.encode()).hexdigest()
        hash_match = prod_hash == repo_hash
        
        if hash_match:
            return None  # Skip identical files
        
        # Version extraction (returns string version or "N/A")
        prod_latest = extract_version_history(prod_content)
        repo_latest = extract_version_history(repo_content)
        
        version_comparison, version_diff = compare_version_numbers(prod_latest, repo_latest)
        
        # Normalize for cosmetic comparison
        prod_normalized = normalize_sql_for_comparison(prod_content)
        # DEBUG: Log metadata lookup for first few files
        if reference_metadata.get(normalized_filename.lower()):
            logger.debug(f"Metadata for {prod_file} -> {normalized_filename.lower()}: Category={reference_metadata.get(normalized_filename.lower(), {}).get('Category', 'NONE')}")
        repo_normalized = normalize_sql_for_comparison(repo_content)
        
        cosmetic_only = prod_normalized == repo_normalized
        
        # DEBUG: Log files that are marked as different but might be cosmetic
        if not cosmetic_only and len(prod_normalized) > 0 and len(repo_normalized) > 0:
            # Check if difference is very small (might be just whitespace issues)
            if abs(len(prod_normalized) - len(repo_normalized)) < 50:
                logger.debug(f"Small difference in {prod_file}: prod_len={len(prod_normalized)}, repo_len={len(repo_normalized)}")
        
        # Classify difference
        diff_type, priority, priority_label = classify_difference(
            hash_match, cosmetic_only, version_comparison,
            prod_latest, repo_latest, prod_content, repo_content
        )
        
        # Generate HTML diff for files with content differences
        html_diff_path = generate_html_diff(prod_content, repo_content, prod_file, object_type)
        
        # Get repo file relative path from object type folder
        repo_type_path = repo_path / object_type
        try:
            repo_file_relative = str(repo_file_path.relative_to(repo_type_path))
        except:
            repo_file_relative = repo_file_path.name
        
        return {
            'Object Type': object_type,
            'Schema': schema,
            'Object Name': obj_name,
            'Difference Type': diff_type,
            'Priority': priority,
            'Priority Label': priority_label,
            'Prod File': prod_file,
            'Repo File': repo_file_relative,
            'Prod Latest Version': prod_latest or 'N/A',
            'Repo Latest Version': repo_latest or 'N/A',
            'Version Comparison': version_comparison,
            'Version Diff': version_diff,
            'Hash Match': hash_match,
            'Cosmetic Only': cosmetic_only,
            'HTML Diff File': html_diff_path,
            'Category': reference_metadata.get(normalized_filename.lower(), {}).get('Category', ''),
            'Domain': reference_metadata.get(normalized_filename.lower(), {}).get('Domain', ''),
            'Dev Domain': reference_metadata.get(normalized_filename.lower(), {}).get('Dev Domain', ''),
            'Unified': reference_metadata.get(normalized_filename.lower(), {}).get('Unified', ''),
            'Unified Date': reference_metadata.get(normalized_filename.lower(), {}).get('Unified Date', '')
        }
        
    except Exception as e:
        logger.error(f"Error processing {prod_file}: {str(e)}")
        return None


def compare_object_type(object_type, reference_metadata=None):
    """Compare files for a specific object type using parallel processing"""
    logger.info(f"{'='*80}")
    logger.info(f"Starting comparison for {object_type}")
    logger.info(f"{'='*80}")
    
    if reference_metadata is None:
        reference_metadata = {}
    
    # Setup paths
    prod_base = Path(PROD_EXPORT_BASE)
    repo_base = Path(V0_REPO_BASE)
    
    prod_path = prod_base / object_type
    
    if not prod_path.exists():
        logger.warning(f"Production path not found: {prod_path}")
        return []
    
    # Get list of production files
    prod_files = sorted([f.name for f in prod_path.glob('*.sql')])
    
    if not prod_files:
        logger.warning(f"No SQL files found in {prod_path}")
        return []
    
    logger.info(f"Found {len(prod_files)} files in production exports")
    logger.info(f"Production path: {prod_path}")
    logger.info(f"Repository path: {repo_base}")
    
    # Prepare arguments for parallel processing
    file_args = [(f, object_type, prod_path, repo_base, reference_metadata) for f in prod_files]
    
    # Use multiprocessing for parallel comparison
    num_processes = min(cpu_count() - 1, 8)  # Leave 1 core free, max 8
    logger.info(f"Using {num_processes} parallel processes")
    
    results = []
    start_time = time.time()
    
    with Pool(processes=num_processes) as pool:
        # Process with progress tracking
        processed_count = 0
        for result in pool.imap_unordered(process_single_file, file_args, chunksize=10):
            if result is not None:
                results.append(result)
            processed_count += 1
            
            # Log progress every 50 files
            if processed_count % 50 == 0:
                percent = (processed_count / len(file_args)) * 100
                logger.info(f"  Progress: {processed_count}/{len(file_args)} ({percent:.1f}%) - {len(results)} differences found")
    
    elapsed = time.time() - start_time
    logger.info(f"[OK] Completed {object_type}: {len(results)} differences out of {len(prod_files)} files in {elapsed:.1f}s")
    logger.info(f"  Average: {len(prod_files)/elapsed:.1f} files/second")
    
    return results


def create_excel_report(all_results, output_path):
    """Create Excel report with separate sheets for each object type"""
    logger.info("Creating Excel report...")
    
    # Load existing workbook if it exists
    if os.path.exists(output_path):
        wb = load_workbook(output_path)
    else:
        wb = openpyxl.Workbook()
        wb.remove(wb.active)  # Remove default sheet
    
    # Color fills
    red_fill = PatternFill(start_color="FFCCCC", end_color="FFCCCC", fill_type="solid")
    orange_fill = PatternFill(start_color="FFE5CC", end_color="FFE5CC", fill_type="solid")
    yellow_fill = PatternFill(start_color="FFFFCC", end_color="FFFFCC", fill_type="solid")
    green_fill = PatternFill(start_color="CCFFCC", end_color="CCFFCC", fill_type="solid")
    
    summary_data = []
    
    for object_type, results in all_results.items():
        if not results:
            continue
        
        logger.info(f"  Creating sheet for {object_type} ({len(results)} rows)")
        
        # Load existing data for this object type
        existing_data, existing_order = load_existing_comparison_data(object_type)
        
        # Delete existing sheet if it exists to recreate it
        sheet_name = f"{object_type} Comparison"
        if sheet_name in wb.sheetnames:
            del wb[sheet_name]
        
        # Create sheet for this object type
        ws = wb.create_sheet(title=sheet_name)
        
        # Headers (matching compare.py structure)
        headers = ['Filename', 'Difference Type',
                   'Version Comparison', 'Prod Version', 'Repo Version',
                   'Prod File', 'Repo File', 'HTML Diff File',
                   'Category', 'Domain', 'Dev Domain', 'Unified', 'Unified Date',
                   'Analysis Notes', 'Description', 'Conflict Resolve(DD-MM-YY)']
        
        ws.append(headers)
        
        # Style header row
        for cell in ws[1]:
            cell.font = Font(bold=True)
            cell.fill = PatternFill(start_color="CCE5FF", end_color="CCE5FF", fill_type="solid")
        
        # Convert results to dict by filename for easy lookup
        results_dict = {row['Prod File']: row for row in results}
        
        # First, write existing files in their original order (preserve manual edits)
        new_files_count = 0
        debug_count = 0
        for filename in existing_order:
            if filename in results_dict:
                row_data = results_dict[filename]
                old_data = existing_data.get(filename, {})
                
                # DEBUG: Log first few metadata lookups
                if debug_count < 3:
                    logger.info(f"DEBUG Excel write: {filename}")
                    logger.info(f"  row_data Category: {repr(row_data.get('Category', 'KEY_MISSING'))}")
                    logger.info(f"  old_data Category: {repr(old_data.get('Category', 'KEY_MISSING'))}")
                    logger.info(f"  Final Category: {repr(old_data.get('Category') or row_data.get('Category', ''))}")
                    debug_count += 1
                
                ws.append([
                    row_data['Prod File'],
                    row_data['Difference Type'],
                    row_data['Version Comparison'],
                    row_data['Prod Latest Version'],
                    row_data['Repo Latest Version'],
                    row_data['Prod File'],
                    row_data['Repo File'],
                    row_data.get('HTML Diff File', ''),
                    old_data.get('Category') or row_data.get('Category', ''),  # Preserve or use reference
                    old_data.get('Domain') or row_data.get('Domain', ''),
                    old_data.get('Dev Domain') or row_data.get('Dev Domain', ''),
                    old_data.get('Unified') or row_data.get('Unified', ''),
                    old_data.get('Unified Date') or row_data.get('Unified Date', ''),
                    old_data.get('Analysis Notes', ''),  # Always preserve
                    old_data.get('Description', ''),  # Always preserve
                    old_data.get('Conflict Resolve(DD-MM-YY)', '')  # Always preserve manual input
                ])
                
                # Mark as processed
                results_dict[filename]['processed'] = True
        
        # Then, append new files at the bottom
        new_file_debug_count = 0
        for filename in sorted(results_dict.keys()):
            if not results_dict[filename].get('processed', False):
                new_files_count += 1
                row_data = results_dict[filename]
                
                # DEBUG: Log first few new files
                if new_file_debug_count < 3:
                    logger.info(f"DEBUG New file: {filename}")
                    logger.info(f"  Keys in row_data: {list(row_data.keys())}")
                    logger.info(f"  Category value: {repr(row_data.get('Category', 'KEY_MISSING'))}")
                    logger.info(f"  Domain value: {repr(row_data.get('Domain', 'KEY_MISSING'))}")
                    new_file_debug_count += 1
                
                # Prepare row data with explicit values
                excel_row = [
                    row_data['Prod File'],
                    row_data['Difference Type'],
                    row_data['Version Comparison'],
                    row_data['Prod Latest Version'],
                    row_data['Repo Latest Version'],
                    row_data['Prod File'],
                    row_data['Repo File'],
                    row_data.get('HTML Diff File', ''),
                    row_data.get('Category', ''),
                    row_data.get('Domain', ''),
                    row_data.get('Dev Domain', ''),
                    row_data.get('Unified', ''),
                    row_data.get('Unified Date', ''),
                    '',  # Analysis Notes - empty for new
                    '',  # Description - empty for new
                    ''   # Conflict Resolve(DD-MM-YY) - empty for manual input
                ]
                
                # DEBUG: Log the actual values being written
                if new_file_debug_count < 3:
                    logger.info(f"  Excel row data - Category (idx 8): {repr(excel_row[8])}, Domain (idx 9): {repr(excel_row[9])}")
                
                ws.append(excel_row)
        
        if new_files_count > 0:
            logger.info(f"  Added {new_files_count} new files for {object_type}")
        
        # Add hyperlinks to HTML Diff File column (column 8)
        for row_idx in range(2, ws.max_row + 1):
            html_diff_cell = ws.cell(row=row_idx, column=8)
            if html_diff_cell.value and html_diff_cell.value != '':
                html_path = html_diff_cell.value
                html_diff_cell.hyperlink = html_path
                html_diff_cell.value = "View Diff"
                html_diff_cell.font = Font(color="0000FF", underline="single")
        
        # Auto-adjust column widths
        for column in ws.columns:
            max_length = 0
            column_letter = column[0].column_letter
            for cell in column:
                try:
                    if len(str(cell.value)) > max_length:
                        max_length = len(str(cell.value))
                except:
                    pass
            adjusted_width = min(max_length + 2, 50)
            ws.column_dimensions[column_letter].width = adjusted_width
        
        # Summary for this object type
        critical_count = sum(1 for r in results if r['Priority'] <= 2)
        high_count = sum(1 for r in results if r['Priority'] in [3, 4])
        medium_count = sum(1 for r in results if r['Priority'] in [5, 6])
        prod_only = sum(1 for r in results if r['Difference Type'] == 'Production Only')
        
        summary_data.append({
            'Object Type': object_type,
            'Total Differences': len(results),
            'Critical (P1-2)': critical_count,
            'High (P3-4)': high_count,
            'Medium (P5-6)': medium_count,
            'Prod Only': prod_only
        })
    
    # Create summary sheet
    ws_summary = wb.create_sheet(title="Summary", index=0)
    summary_headers = ['Object Type', 'Total Differences', 'Critical (P1-2)', 'High (P3-4)', 'Medium (P5-6)', 'Prod Only']
    ws_summary.append(summary_headers)
    
    for cell in ws_summary[1]:
        cell.font = Font(bold=True)
        cell.fill = PatternFill(start_color="CCE5FF", end_color="CCE5FF", fill_type="solid")
    
    for row_data in summary_data:
        ws_summary.append([row_data[h] for h in summary_headers])
    
    # Auto-adjust summary columns
    for column in ws_summary.columns:
        max_length = 0
        column_letter = column[0].column_letter
        for cell in column:
            try:
                if len(str(cell.value)) > max_length:
                    max_length = len(str(cell.value))
            except:
                pass
        ws_summary.column_dimensions[column_letter].width = max_length + 2
    
    wb.save(output_path)
    logger.info(f"[OK] Excel report saved: {output_path}")
    logger.info(f"  Total sheets: {len(wb.sheetnames)}")


def main():
    """Main execution"""
    start_time = time.time()
    
    logger.info("="*80)
    logger.info("Production DB vs Repository Comparison Tool - PARALLEL VERSION")
    logger.info("="*80)
    logger.info(f"Start time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    logger.info(f"CPU cores available: {cpu_count()}")
    logger.info(f"Log file: {log_file}")
    logger.info("")
    logger.info(f"Production exports: {PROD_EXPORT_BASE}")
    logger.info(f"Repository: {V0_REPO_BASE}")
    logger.info(f"Object types: {', '.join(OBJECT_TYPES)}")
    logger.info("")
    
    # First pass: collect all production files across all object types
    logger.info("="*80)
    logger.info("STEP 1: Collecting production files...")
    logger.info("="*80)
    
    all_prod_files = set()
    for obj_type in OBJECT_TYPES:
        prod_base = Path(PROD_EXPORT_BASE)
        prod_path = prod_base / obj_type
        
        if prod_path.exists():
            prod_files = [f.name for f in prod_path.glob('*.sql')]
            # Normalize filenames to match reference Excel format
            # This removes schema prefixes and table names (for triggers)
            for pf in prod_files:
                normalized = normalize_filename(pf, obj_type)
                all_prod_files.add(normalized)
            logger.info(f"  {obj_type}: {len(prod_files)} files")
    
    logger.info(f"\nTotal unique production files: {len(all_prod_files)}")
    
    # Load reference metadata only for files that exist in production
    logger.info("\n" + "="*80)
    logger.info("STEP 2: Loading reference metadata from Excel...")
    logger.info("="*80)
    reference_metadata = load_reference_metadata(file_list=all_prod_files)
    logger.info("")
    
    # Now run the actual comparison
    logger.info("="*80)
    logger.info("STEP 3: Comparing production vs repository...")
    logger.info("="*80)
    
    all_results = {}
    
    # Process each object type
    for i, obj_type in enumerate(OBJECT_TYPES, 1):
        logger.info(f"\n[{i}/{len(OBJECT_TYPES)}] Processing {obj_type}...")
        results = compare_object_type(obj_type, reference_metadata)
        if results:
            all_results[obj_type] = results
            logger.info(f"  Found {len(results)} differences in {obj_type}")
        else:
            logger.info(f"  No differences found in {obj_type}")
    
    # Create Excel report
    if all_results:
        logger.info("\n" + "="*80)
        logger.info("GENERATING REPORT")
        logger.info("="*80)
        
        output_file = Path(OUTPUT_XLSX)
        create_excel_report(all_results, output_file)
        
        # Summary
        total_diffs = sum(len(results) for results in all_results.values())
        logger.info("\n" + "="*80)
        logger.info("SUMMARY")
        logger.info("="*80)
        for obj_type, results in all_results.items():
            critical = sum(1 for r in results if r['Priority'] <= 2)
            high = sum(1 for r in results if r['Priority'] in [3, 4])
            logger.info(f"{obj_type:15s}: {len(results):4d} differences (Critical: {critical}, High: {high})")
        logger.info(f"{'TOTAL':15s}: {total_diffs:4d} differences")
    else:
        logger.warning("\n[WARNING]  No differences found!")
    
    elapsed = time.time() - start_time
    logger.info("\n" + "="*80)
    logger.info(f"Completed in {elapsed:.1f} seconds ({elapsed/60:.1f} minutes)")
    logger.info(f"End time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    logger.info("="*80)


if __name__ == "__main__":
    main()
