# JeFTeX: LaTeX and MathType add-in for Word

A Word task pane that converts equations between LaTeX and MathType, with a menu bar of commonly used math constructs.

> **Warning: this is a vibe-coded project.**
> Most of the code was written with an AI assistant and has not had a thorough human code review or a full test suite. It has only been tested in a limited way, and not everything has been verified in Word with MathType (see "Tested" below). Bugs are likely. Always work on a copy of your document, check converted equations visually, and do not rely on it for important documents without verifying the result.

Human here: in my experience, it works pretty well. Cheers!

## Features

### Inserting LaTeX equations
- **Insert**: inserts the LaTeX from the text box as a picture (SVG with a PNG fallback), places the cursor after it, and clears the text box. The equation is visible in Word but cannot be edited in MathType.
- **Editing an equation**: click it once. Its LaTeX appears in the text box. This works for plugin equations, MathType equations (read from the MathType data) and Word's own equations. Edit the LaTeX and press **Insert** (or **Insert as MathType**) to replace the equation. To insert a new equation instead, first click in the text where it should go, so no equation is selected.
  - Word equations: select the equation, or put the cursor in a display equation that is alone in its paragraph. An inline equation inside running text has to be selected.
  - Replacing a display equation keeps it centered.
- **Insert as MathType**: inserts the formula as a real MathType object (`Equation.DSMT4`) and clears the text box. Click it once to load its LaTeX into the text box; double-click it to open it in MathType.
- A live preview of the formula appears below the text box. Selecting another plugin equation replaces the text box content with that equation's LaTeX.

### MathType → LaTeX
- **Selection**: converts the MathType objects in the selection into plugin equations you can edit.
- **Whole document**: converts all MathType objects in the document. Check the result on a copy first.

### Word equation → LaTeX
- **Whole document**: converts all of Word's own equations (inline and display) into plugin equations. Display equations stay centered. Check the result on a copy first.
- Supported: fractions, roots, sub- and superscripts, sums and integrals with limits, brackets, matrices, cases, functions (`sin`, `lim`, ...), accents, bars, Greek letters, and common symbols. Unknown constructs are converted as far as possible. Check the result visually.

### LaTeX → MathType
- **Selection**: converts the plugin equations in the selection into MathType objects.
- **Whole document**: converts all plugin equations in the document.

### Symbol menu bar
Six tabs, each with a grid of buttons showing a rendered preview:

| Tab | Contents |
|---|---|
| Structures | fraction, superscript, subscript, root, brackets, overline, vector arrow, hat, text |
| Calculus | sum, product, integral, limit, derivatives, partial derivative, nabla, infinity |
| Matrices | 2×2 and 3×3 matrices, determinant, column vector |
| Greek | lowercase and uppercase Greek letters |
| Symbols | relations, operators, arrows, logic symbols |
| Functions | sin, cos, log, lim, det and other function names |

Click a button to insert its LaTeX into the text box. If you have text selected, it is placed where `§` appears in the template.

### Math font
Below the preview there is a **Font** menu. It sets the font used for the preview, the palette buttons and every newly inserted equation (the picture, and the preview picture of MathType objects).

| Font | Looks like |
|---|---|
| MathJax TeX (classic) | the original MathJax font (default) |
| New Computer Modern, Latin Modern | Computer Modern (LaTeX default) |
| Termes, STIX Two | Times |
| Pagella | Palatino |
| Bonum | Bookman |
| Schola | Century Schoolbook |
| Asana | Asana Math |
| Fira | Fira (sans-serif) |

- The choice is remembered (localStorage). Changing it reloads the pane; the text box and the open tab are kept.
- Equations already in the document keep their font until they are inserted again. The LaTeX stored in them is not changed.
- Every font is set at the same size (1 em = 12 pt). The fonts are drawn as outlines inside the picture, so the font does not have to be installed on the reader's computer.
- If a font cannot be loaded (for example, no internet), the pane falls back to the default font and says so.
- The font applies to the picture only. A MathType object that you open in MathType uses MathType's own fonts.

### Rendering
- Fractions (and binomials) are always rendered at full size, so nested fractions do not shrink. The equation simply becomes larger. Sub- and superscripts remain smaller, as is standard. The LaTeX stored in the equation is not changed, so conversion to MathType still sees `\frac`.
- The pane header shows the logo (`logo_big.png`, served next to `taskpane.html`), at most 64 px high with the width in proportion. The ribbon button uses `icon.png`.
- Equations are vector graphics: every picture contains an SVG (smooth at any zoom, also in PDF export) plus a 300 dpi PNG (`PNGDPI` in `taskpane.html`) that Word only uses if it cannot show the SVG. To check, click an equation: with a working SVG, Word shows a **Graphics Format** tab, and you can zoom in without the shapes getting blurry. The SVG is simplified for Word (no nested `<svg>`, no MathJax accessibility metadata); it looks identical to MathJax's own output.
- SVG pictures need Word for Microsoft 365 or Word 2019 or later. Word 2016 (non-subscription) and some Word-on-the-web situations only show the PNG.
- Each equation picture has a nearly invisible background rectangle with a few pixels of padding, so clicking in the white space around a formula still selects it.
- Equations inserted before build 11 keep their old look until they are inserted again. Build 12 moved to MathJax 4 and sizes equations by the em instead of the x-height, so equations in the default font are about 1.5% smaller than before.

## Installation

1. Host `taskpane.html` at an HTTPS address. In this project that is GitHub Pages: `https://binnej.github.io/jeftex/taskpane.html`.
2. In `manifest.xml`, set the `SourceLocation` and the `bt:Url` entries to that address.
3. Load the manifest in Word:
   - **Windows**: Insert > Add-ins > My Add-ins > Shared Folder (or "Upload My Add-in").
   - **Mac**: Insert > Add-ins > My Add-ins > Upload My Add-in.
4. Open the add-in from the Home tab.

## Versioning and cache

Word caches add-ins. To see a new version:

1. Commit `taskpane.html` to GitHub and wait for GitHub Pages to finish. Check that the live page contains the new code.
2. Increase the version number and the `?v=` parameter in `manifest.xml` so Word loads the new page.
3. Close Word and clear the cache:
   - **Windows**: `%LOCALAPPDATA%\Microsoft\Office\16.0\Wef\`
   - **Mac**: the `Wef` folder under `~/Library/Containers/com.microsoft.Word/`
4. Reopen Word.

The current build appears at the bottom of the pane ("build 14"), so you can see which version is running.

## Requirements

- Word 2016 or later (Windows or Mac), or Word on the web.
- Internet access for the external libraries (Office.js, MathJax 4.1.3 with its font packages, and cfb 1.2.2 from jsDelivr).
- MathType 6.x or later to edit the objects. Testing was done with `Equation.DSMT` objects.

## Support and limitations

### MathType → LaTeX
- Supported: MathType 4 and later (MTEF v5), i.e. `Equation.DSMT` objects.
- Not supported: the old Equation Editor 3.0 (`Equation.3`). It reports "Unsupported MTEF version".
- Incomplete: some rare constructs are approximated. Check the result visually.

### LaTeX → MathType
- Supported: letters, digits, operators, Greek letters, symbols, fractions, roots, sub- and superscripts, brackets with `\left`/`\right`, matrices (`pmatrix`, `bmatrix`, `vmatrix`, `matrix`), accents over a single symbol, `\text`, `\mathrm`, `\mathbf`, `\overline`, `\underline`, `\sum`, `\int`, `\prod`, `\lim`, and function names.
- Not supported: `cases`, `aligned`, `\binom`, `\stackrel`, and most other environments. The plugin reports which construct it cannot convert.
- Large operators (`\sum`, `\int`) are written as a symbol with limits, not as a MathType template with limits above and below.
- `\qquad` becomes a tab, and `\,` is dropped.

### Tested
- MathType → LaTeX → MathType on a document with three formulas: the binary content of the MathType objects is byte-for-byte identical to what MathType itself wrote.
- All 108 palette buttons render without errors.
- **Not yet tested** in Word with MathType: whether Word displays and edits the new objects correctly.

## Files

| File | Purpose |
|---|---|
| `taskpane.html` | The complete add-in: interface, conversion and palette in one file |
| `logo_big.png` | Logo shown at the top of the pane |
| `icon.png` | Icon for the ribbon button |
| `manifest.xml` | Word manifest with the web address and version |
| `README.md` | This file |

## Technical notes

- The binary MathType format (MTEF v5) is read and written by `mtefToTex` and `texToMtef`, both included in `taskpane.html`.
- Word's equation format (OMML) is converted by `ommlToTex`.
- The OLE container is read and written with cfb.
- The LaTeX preview is rendered with MathJax 4.1.3 (SVG). The font is chosen with `output.font`; the font files come from `@mathjax/mathjax-*-font`, pinned to the same version. Inline line breaking is switched off so that a formula is always one picture. The PNG fallback is produced via a canvas.
- The manifest uses `?v=` in the URL to bypass the cache.

## Known issues

- Word on the web does not support all OLE objects. Test in Word for Windows or Mac first.
- The PNG preview of an inserted MathType object may look different from MathType's own rendering.
- The add-in does not work offline, because all libraries load from external servers.
