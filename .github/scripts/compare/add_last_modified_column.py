"""
Add Last Modified column to ProdDB_Comparison.xlsx
Reads Last Modified dates from ExportReport CSV files and adds them as 2nd column
"""
import openpyxl
from openpyxl.styles import Font, PatternFill
from openpyxl.utils import get_column_letter, column_index_from_string
import csv
import os
from datetime import datetime
import re

def convert_date_format(date_str):
    """Convert date from 'M/D/YYYY H:MM:SS AM/PM' to 'DD-MMM-YYYY HH:MM' format"""
    if not date_str:
        return ''
    
    try:
        # Parse the input date format (e.g., "6/14/2021 12:01:52 PM")
        dt = datetime.strptime(date_str, '%m/%d/%Y %I:%M:%S %p')
        # Format to desired output (e.g., "14-Jun-2021 12:01")
        return dt.strftime('%d-%b-%Y %H:%M')
    except ValueError as e:
        print(f"Warning: Could not parse date '{date_str}': {e}")
        return date_str  # Return original if parsing fails

def shift_cell_reference(cell_ref, col_shift=1, insert_col=2):
    """
    Shift a cell reference (e.g., 'T5') by col_shift columns if it's at or after insert_col.
    Returns the new cell reference.
    """
    match = re.match(r'^([A-Z]+)(\d+)$', cell_ref)
    if not match:
        return cell_ref

    col_letters = match.group(1)
    row_num = match.group(2)

    col_idx = column_index_from_string(col_letters)

    # Only shift columns at or after the insert position
    if col_idx >= insert_col:
        new_col_idx = col_idx + col_shift
        new_col_letters = get_column_letter(new_col_idx)
        return f"{new_col_letters}{row_num}"

    return cell_ref


def preserve_hyperlinks(ws):
    """
    Preserve all hyperlinks from a worksheet.
    Returns a list of (cell_ref, target, display_text) tuples.
    """
    hyperlinks = []
    for hyperlink in ws.hyperlinks:
        cell = ws[hyperlink.ref]
        display_text = cell.value
        hyperlinks.append({
            'ref': hyperlink.ref,
            'target': hyperlink.target,
            'display': display_text
        })
    return hyperlinks


def restore_hyperlinks(ws, hyperlinks, col_shift=1, insert_col=2):
    """
    Restore hyperlinks with shifted cell references.
    """
    # Clear existing hyperlinks
    ws.hyperlinks = []

    for hl in hyperlinks:
        old_ref = hl['ref']
        new_ref = shift_cell_reference(old_ref, col_shift, insert_col)

        # Create new hyperlink at shifted position
        cell = ws[new_ref]
        cell.hyperlink = hl['target']
        cell.value = hl['display']
        cell.style = "Hyperlink"


def load_export_report_data(csv_file_path):
    """Load Last Modified data from ExportReport CSV file"""
    last_modified_map = {}
    
    if not os.path.exists(csv_file_path):
        print(f"Warning: {csv_file_path} not found")
        return last_modified_map
    
    # Try different encodings
    encodings = ['utf-8-sig', 'utf-8', 'latin-1', 'cp1252']
    
    for encoding in encodings:
        try:
            with open(csv_file_path, 'r', encoding=encoding) as f:
                reader = csv.DictReader(f)
                for row in reader:
                    filename = row.get('FileName', '').strip()
                    last_modified = row.get('LastModified', '').strip()
                    if filename:
                        converted = convert_date_format(last_modified)
                        # Store with original name (e.g., "dbo.isp_Proc.sql")
                        last_modified_map[filename] = converted
                        last_modified_map[filename.lower()] = converted
                        # Also store with schema prefix stripped for normalized lookup
                        # Handle schema.name.sql (e.g., dbo.isp_Proc.sql -> isp_Proc.sql)
                        # Handle schema.table.trigger.sql (e.g., RDT.RDTUser.ntrDelete.sql -> ntrDelete.sql)
                        name_no_ext = filename.replace('.sql', '').replace('.SQL', '')
                        parts = name_no_ext.split('.')
                        if len(parts) >= 2:
                            # Store without schema: last part + .sql
                            stripped = parts[-1] + '.sql'
                            last_modified_map[stripped] = converted
                            last_modified_map[stripped.lower()] = converted
                            # Also store without schema but with table for triggers: table.trigger.sql
                            if len(parts) >= 3:
                                stripped2 = parts[-2] + '.' + parts[-1] + '.sql'
                                last_modified_map[stripped2] = converted
                                last_modified_map[stripped2.lower()] = converted
            break  # Success, exit loop
        except (UnicodeDecodeError, KeyError) as e:
            if encoding == encodings[-1]:
                print(f"Error reading {csv_file_path}: {e}")
            continue
    
    return last_modified_map

def add_last_modified_column(workbook_path, export_reports_dir):
    """Add Last Modified column as 2nd column to all sheets"""
    
    # Mapping of sheet names to their corresponding ExportReport CSV files
    # CSV files live in Export/{ObjectType}/_ExportReport.csv
    sheet_to_csv = {
        'StoredProc Comparison': 'StoredProc/_ExportReport.csv',
        'Sequence Comparison': 'Sequence/_ExportReport.csv',
        'Trigger Comparison': 'Trigger/_ExportReport.csv',
        'Function Comparison': 'Function/_ExportReport.csv',
        'View Comparison': 'Views/_ExportReport.csv',
        'Views Comparison': 'Views/_ExportReport.csv',
        'Table Comparison': 'Tables/_ExportReport.csv',
        'Tables Comparison': 'Tables/_ExportReport.csv',
        'Job Comparison': 'Jobs/_ExportReport.csv',
        'Jobs Comparison': 'Jobs/_ExportReport.csv'
    }
    
    # Mapping of sheet names to their Export subfolder (for filesystem fallback)
    sheet_to_folder = {
        'StoredProc Comparison': 'StoredProc',
        'Sequence Comparison': 'Sequence',
        'Trigger Comparison': 'Trigger',
        'Function Comparison': 'Function',
        'View Comparison': 'Views',
        'Views Comparison': 'Views',
        'Table Comparison': 'Tables',
        'Tables Comparison': 'Tables',
        'Job Comparison': 'Jobs',
        'Jobs Comparison': 'Jobs'
    }
    
    # Load the workbook
    wb = openpyxl.load_workbook(workbook_path)
    
    # Process each sheet
    for sheet_name in wb.sheetnames:
        if sheet_name not in sheet_to_csv:
            print(f"Skipping sheet: {sheet_name} (no corresponding ExportReport)")
            continue
        
        ws = wb[sheet_name]
        csv_file = os.path.join(export_reports_dir, sheet_to_csv[sheet_name])
        export_folder = os.path.join(export_reports_dir, sheet_to_folder[sheet_name])
        
        print(f"\nProcessing sheet: {sheet_name}")
        print(f"Using CSV: {csv_file}")
        
        # Load the Last Modified data from CSV
        last_modified_map = load_export_report_data(csv_file)
        print(f"Loaded {len(last_modified_map)} records from CSV")
        
        # Check if "Last Modified" column already exists
        header_row = list(ws.iter_rows(min_row=1, max_row=1, values_only=True))[0]
        if header_row and len(header_row) > 1 and header_row[1] == 'Last Modified':
            print(f"'Last Modified' column already exists at position 2. Updating values...")
            update_existing = True
        else:
            print(f"Inserting new 'Last Modified' column at position 2...")
            update_existing = False

            # Preserve hyperlinks before inserting column
            saved_hyperlinks = preserve_hyperlinks(ws)
            print(f"  Preserved {len(saved_hyperlinks)} hyperlinks")

            # Insert a new column at position B (index 2)
            ws.insert_cols(2)

            # Restore hyperlinks with shifted references
            if saved_hyperlinks:
                restore_hyperlinks(ws, saved_hyperlinks, col_shift=1, insert_col=2)
                print(f"  Restored {len(saved_hyperlinks)} hyperlinks with shifted references")
        
        # Get max row
        max_row = ws.max_row
        
        # Set header
        ws.cell(row=1, column=2).value = 'Last Modified'
        ws.cell(row=1, column=2).font = Font(bold=True)
        ws.cell(row=1, column=2).fill = PatternFill(start_color="D3D3D3", end_color="D3D3D3", fill_type="solid")
        
        # Populate Last Modified data for each row
        matched = 0
        not_matched = 0
        
        for row_idx in range(2, max_row + 1):
            # Get filename from column A (column 1)
            filename_cell = ws.cell(row=row_idx, column=1)
            filename = filename_cell.value
            
            if filename:
                filename = str(filename).strip()
                # Strip schema prefix from Excel filename too for lookup
                name_no_ext = filename.replace('.sql', '').replace('.SQL', '')
                parts = name_no_ext.split('.')
                stripped_name = parts[-1] + '.sql' if len(parts) >= 2 else filename
                
                # Look up Last Modified date - try multiple key variants
                last_modified = (
                    last_modified_map.get(filename) or
                    last_modified_map.get(filename.lower()) or
                    last_modified_map.get(stripped_name) or
                    last_modified_map.get(stripped_name.lower()) or
                    # Try adding .sql if missing
                    last_modified_map.get(filename + '.sql') or
                    last_modified_map.get(filename.lower() + '.sql') or
                    ''
                )
                
                # Fallback: read file's last modified time from filesystem
                if not last_modified and export_folder:
                    file_path = os.path.join(export_folder, filename)
                    if os.path.exists(file_path):
                        mtime = os.path.getmtime(file_path)
                        last_modified = datetime.fromtimestamp(mtime).strftime('%d-%b-%Y %H:%M')
                
                if last_modified:
                    ws.cell(row=row_idx, column=2).value = last_modified
                    matched += 1
                else:
                    ws.cell(row=row_idx, column=2).value = ''
                    not_matched += 1
                    if not_matched <= 20:  # Print first 20 unmatched for debugging
                        print(f"  NOT MATCHED: '{filename}'")
        
        if not_matched > 20:
            print(f"  ... and {not_matched - 20} more unmatched")
        print(f"Results: {matched} matched, {not_matched} not matched")
    
    # Save the workbook
    backup_path = workbook_path.replace('.xlsx', '_backup.xlsx')
    print(f"\nCreating backup: {backup_path}")
    wb.save(backup_path)
    
    print(f"Saving updated workbook: {workbook_path}")
    wb.save(workbook_path)
    print("Done!")

if __name__ == '__main__':
    # Paths
    base_dir = '/Users/animesh.singh/Documents/Unification_Scripts/Korea_Comparison/ProdDB_Comparison_Results'
    workbook_path = os.path.join(base_dir, 'ProdDB_Comparison.xlsx')
    export_reports_dir = '/Users/animesh.singh/Documents/Unification_Scripts/Korea_Comparison/Export'
    
    print("=" * 60)
    print("Adding Last Modified Column to ProdDB_Comparison.xlsx")
    print("=" * 60)
    
    add_last_modified_column(workbook_path, export_reports_dir)
