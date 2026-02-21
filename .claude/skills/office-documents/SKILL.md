---
name: office-documents
description: "Create, edit, and analyze Office documents (.docx, .xlsx, .pdf, .pptx). DOCX: ZIP+XML structure, docx-js creation, tracked changes, comments. XLSX: openpyxl/SheetJS, formulas, charts. PDF: text extraction, table parsing, creation. PPTX: python-pptx, slide layouts, content insertion. Use when working with Word, Excel, PDF, or PowerPoint files."
---

# Office Documents

## Format Decision Tree

```
Input file type?
  |
  +-- .docx (Word)
  |     Read? --> pandoc / unpack XML
  |     Create? --> docx-js (JavaScript)
  |     Edit existing? --> unpack -> edit XML -> repack
  |
  +-- .xlsx (Excel)
  |     Read/analyze? --> pandas
  |     Create/edit with formulas? --> openpyxl
  |     Recalculate? --> scripts/recalc.py (LibreOffice)
  |
  +-- .pdf
  |     Extract text? --> pdfplumber / pypdf
  |     Extract tables? --> pdfplumber
  |     Create? --> reportlab
  |     Merge/split? --> pypdf / qpdf
  |     Fill forms? --> pypdf / pdf-lib
  |     OCR scanned? --> pytesseract + pdf2image
  |
  +-- .pptx (PowerPoint)
        Read? --> markitdown
        Edit from template? --> unpack/edit/repack
        Create from scratch? --> pptxgenjs (JavaScript)
```

---

## DOCX (Word)

### Core Tools
- **docx-js** (`npm install -g docx`): Create new documents
- **pandoc**: Text extraction with tracked changes support
- **unpack.py / pack.py**: Edit existing documents via XML manipulation

### Reading
```bash
pandoc --track-changes=all document.docx -o output.md   # With tracked changes
python scripts/office/unpack.py document.docx unpacked/  # Raw XML access
```

### Creating New (docx-js)
```javascript
const { Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
        ImageRun, Header, Footer, HeadingLevel, PageBreak,
        AlignmentType, BorderStyle, WidthType, ShadingType,
        LevelFormat, PageNumber, PageOrientation } = require('docx');

const doc = new Document({ sections: [{ children: [/* content */] }] });
Packer.toBuffer(doc).then(buf => fs.writeFileSync("out.docx", buf));
```

### Editing Existing (XML Pipeline)
```
unpack.py document.docx unpacked/  -->  Edit XML in unpacked/word/  -->  pack.py unpacked/ output.docx --original document.docx
```

### Critical Traps -- DOCX
- **Page size defaults to A4** -- set US Letter explicitly: `width: 12240, height: 15840` (DXA)
- **Landscape: pass portrait dimensions** -- docx-js swaps internally; set `orientation: PageOrientation.LANDSCAPE`
- **NEVER use `\n`** -- use separate Paragraph elements
- **NEVER use unicode bullets** -- use `LevelFormat.BULLET` with numbering config
- **PageBreak must be inside Paragraph** -- standalone creates invalid XML
- **ImageRun requires `type` param** -- always specify png/jpg/etc
- **Tables need dual widths** -- `columnWidths` on table AND `width` on each cell, both in DXA
- **NEVER use WidthType.PERCENTAGE** -- breaks in Google Docs, always use DXA
- **ShadingType.CLEAR not SOLID** -- SOLID causes black backgrounds
- **TOC requires HeadingLevel only** -- no custom styles on heading paragraphs
- **Tracked changes: replace entire `<w:r>` blocks** -- don't inject tags inside a run
- **Preserve `<w:rPr>` formatting** -- copy original run's formatting into tracked change runs
- **Smart quotes in XML** -- use entities: `&#x2018;` `&#x2019;` `&#x201C;` `&#x201D;`

---

## XLSX (Excel)

### Core Tools
- **openpyxl**: Create/edit with formulas and formatting
- **pandas**: Data analysis, bulk operations, simple export
- **scripts/recalc.py**: Formula recalculation via LibreOffice (MANDATORY after formula changes)

### Reading
```python
import pandas as pd
df = pd.read_excel('file.xlsx')                          # First sheet
all_sheets = pd.read_excel('file.xlsx', sheet_name=None) # All sheets as dict
```

### Creating/Editing
```python
from openpyxl import Workbook, load_workbook
from openpyxl.styles import Font, PatternFill, Alignment

wb = Workbook()  # or load_workbook('existing.xlsx')
sheet = wb.active
sheet['A1'] = 'Revenue'
sheet['B2'] = '=SUM(B3:B10)'  # ALWAYS use formulas, never hardcode calculations
wb.save('output.xlsx')
```

### Recalculation (MANDATORY)
```bash
python scripts/recalc.py output.xlsx   # Returns JSON with error details
```

### Critical Traps -- XLSX
- **ALWAYS use Excel formulas** -- never calculate in Python and hardcode results
- **Recalculate after every save** -- openpyxl writes formulas as strings without cached values
- **Zero formula errors** -- check recalc.py output for #REF!, #DIV/0!, #VALUE!, #NAME?
- **Cell indices are 1-based** -- row=1, column=1 = cell A1
- **data_only=True destroys formulas** -- if opened with this flag and saved, formulas are permanently lost
- **Years format as text** -- "2024" not "2,024"; use string formatting or explicit text type
- **Negative numbers** -- use parentheses `(123)` not minus `-123`
- **Financial models: blue text for inputs** -- RGB(0,0,255) for hardcoded values users will change
- **Column mapping verification** -- confirm column 64 = BL, not BK; off-by-one is common
- **Row offset** -- DataFrame row 5 = Excel row 6 (1-indexed + header)

---

## PDF

### Core Tools
- **pypdf**: Merge, split, rotate, metadata, password protection
- **pdfplumber**: Text extraction with layout, table extraction
- **reportlab**: Create new PDFs (Canvas for simple, Platypus for multi-page)
- **qpdf**: Command-line merge/split/decrypt

### Reading
```python
import pdfplumber
with pdfplumber.open("doc.pdf") as pdf:
    for page in pdf.pages:
        text = page.extract_text()
        tables = page.extract_tables()
```

### Creating
```python
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak
from reportlab.lib.styles import getSampleStyleSheet

doc = SimpleDocTemplate("report.pdf", pagesize=letter)
styles = getSampleStyleSheet()
story = [Paragraph("Title", styles['Title']),
         Spacer(1, 12),
         Paragraph("Body text here.", styles['Normal'])]
doc.build(story)
```

### Merge/Split
```python
from pypdf import PdfReader, PdfWriter
writer = PdfWriter()
for pdf_file in ["doc1.pdf", "doc2.pdf"]:
    for page in PdfReader(pdf_file).pages:
        writer.add_page(page)
with open("merged.pdf", "wb") as f:
    writer.write(f)
```

### Critical Traps -- PDF
- **NEVER use Unicode subscripts/superscripts** -- built-in fonts render them as black boxes; use `<sub>` / `<super>` tags in Paragraph objects
- **pdfplumber for tables, pypdf for manipulation** -- don't mix up their strengths
- **OCR requires image conversion first** -- `pdf2image.convert_from_path()` then `pytesseract`
- **reportlab Canvas vs Platypus** -- Canvas for precise positioning, Platypus for flowing documents
- **Password-protected PDFs** -- decrypt first with `qpdf --decrypt` before processing

---

## PPTX (PowerPoint)

### Core Tools
- **pptxgenjs** (`npm install -g pptxgenjs`): Create from scratch
- **markitdown**: Text extraction
- **thumbnail.py / unpack.py / pack.py**: Edit existing via XML

### Reading
```bash
python -m markitdown presentation.pptx
python scripts/thumbnail.py presentation.pptx   # Visual overview
```

### Creating from Scratch
Use pptxgenjs -- read `pptxgenjs.md` reference for full API.

### Editing Existing
```
unpack.py presentation.pptx unpacked/  -->  Edit slides  -->  pack.py unpacked/ output.pptx
```

### Design Principles
- **Pick topic-specific color palette** -- don't default to generic blue
- **Every slide needs a visual element** -- image, chart, icon, or shape; text-only slides are forgettable
- **Layout variety** -- two-column, icon+text rows, 2x2 grid, half-bleed image
- **Typography** -- header font with personality + clean body font; titles 36-44pt, body 14-16pt
- **0.5" minimum margins**, 0.3-0.5" between content blocks

### QA (MANDATORY)
```bash
python scripts/office/soffice.py --headless --convert-to pdf output.pptx
pdftoppm -jpeg -r 150 output.pdf slide
# Then visually inspect slide-01.jpg, slide-02.jpg, etc.
```

### Critical Traps -- PPTX
- **NEVER use accent lines under titles** -- hallmark of AI-generated slides
- **NEVER repeat the same layout** -- vary columns, cards, callouts across slides
- **NEVER skip visual QA** -- first render is almost never correct; use subagents for fresh eyes
- **Check for leftover placeholder text** -- grep for "xxxx", "lorem", "ipsum"
- **Text box padding affects alignment** -- set `margin: 0` when aligning shapes with text edges
- **Dark backgrounds need high-contrast text AND icons** -- light text on light bg is invisible

---

## Cross-Format Operations

| From | To | Tool |
|------|----|------|
| .doc -> .docx | soffice.py --convert-to docx | LibreOffice |
| .docx -> .pdf | soffice.py --convert-to pdf | LibreOffice |
| .pptx -> .pdf | soffice.py --convert-to pdf | LibreOffice |
| .pdf -> images | pdftoppm -jpeg -r 150 | Poppler |
| .xlsx -> recalc | scripts/recalc.py | LibreOffice |

## Dependencies Summary

| Package | Purpose | Install |
|---------|---------|---------|
| docx | DOCX creation | `npm install -g docx` |
| pandoc | DOCX text extraction | System package |
| openpyxl | XLSX create/edit | `pip install openpyxl` |
| pandas | XLSX data analysis | `pip install pandas` |
| pypdf | PDF manipulation | `pip install pypdf` |
| pdfplumber | PDF text/table extraction | `pip install pdfplumber` |
| reportlab | PDF creation | `pip install reportlab` |
| pptxgenjs | PPTX creation | `npm install -g pptxgenjs` |
| markitdown | PPTX text extraction | `pip install "markitdown[pptx]"` |
| LibreOffice | Conversion/recalc | System package |
| Poppler | PDF to images | System package (pdftoppm) |

## NEVER

- NEVER use `\n` in docx-js -- use separate Paragraph elements
- NEVER use unicode bullets in DOCX -- use LevelFormat.BULLET
- NEVER use WidthType.PERCENTAGE in DOCX tables -- use DXA
- NEVER hardcode calculated values in XLSX -- use Excel formulas
- NEVER open XLSX with data_only=True and then save -- destroys all formulas permanently
- NEVER use Unicode subscripts/superscripts in reportlab -- renders as black boxes
- NEVER skip recalc.py after modifying XLSX formulas
- NEVER skip visual QA for PPTX -- convert to images and inspect
- NEVER use ShadingType.SOLID in DOCX tables -- causes black backgrounds
- NEVER assume first render of PPTX is correct -- always verify
