# CLI-Organize Standard Specification

> Every language implementation **must** conform to this specification to be included in the cli-organize collection.

## 1. Purpose

A command-line tool that organizes files in a directory by sorting them into category-based sub-folders according to their file extension.

---

## 2. CLI Interface

Direct invocation (no subcommands):

```
organize <source> [flags]
```

### Arguments & Flags

| Argument / Flag | Type | Required | Default | Description |
|---|---|---|---|---|
| `source` | positional | **yes** | — | Source directory to scan |
| `--destination`, `-d` | string | no | same as source | Output base directory for organized files |
| `--dry-run` | bool flag | no | `false` | Simulate the organization without making changes |
| `--move` | bool flag | no | `true` | Move files; when set to `false`, copy instead |
| `--ignore` | string list | no | `[]` | Glob patterns to exclude (e.g., `"*.log,temp_*"`) |
| `--map-file` | string | no | — | Path to a custom JSON category-mapping file |
| `--verbose`, `-v` | bool flag | no | `false` | Print detailed per-file actions |

### Exit Codes

| Code | Meaning |
|---|---|
| `0` | Success |
| `1` | Error (invalid args, missing directory, I/O failure, etc.) |

---

## 3. Default Category Map

All implementations must ship with this exact default mapping. Extensions are matched **case-insensitively** and **without the leading dot** in the map (implementations may store them with or without dots internally, but must match the same set).

| Category | Extensions |
|---|---|
| Documents | txt, doc, docx, pdf, odt, rtf, tex, wpd, log, md |
| Images | jpg, jpeg, png, gif, bmp, tiff, webp, heic, raw, svg, ico |
| Videos | mp4, mov, avi, mkv, flv, wmv, webm, mpeg |
| Audio | mp3, wav, aac, flac, ogg, wma, m4a |
| Archives | zip, tar, gz, rar, 7z, bz2, xz, z |
| Spreadsheets | xls, xlsx, csv, ods |
| Presentations | ppt, pptx, odp |
| Executables | exe, msi, dmg, app |
| Code | py, js, html, css, java, c, cpp, h, go, json, xml, rs, ts, rb |
| Others | Everything not listed above |

---

## 4. Custom Map File Format

The `--map-file` flag accepts a JSON file in this format:

```json
{
  "category_name": ["ext1", "ext2", "ext3"],
  "another_category": ["ext4"]
}
```

When a custom map is provided, it **replaces** the default map entirely.

---

## 5. Behavior Rules

1. **Top-level only** — Scan only immediate files in the source directory (not recursive).
2. **Skip dotfiles** — Files starting with `.` (e.g., `.bashrc`, `.gitignore`) are skipped.
3. **Plain directory names** — Category folders use plain names (`Documents`, `Images`, etc.) with **no numeric prefix**.
4. **Conflict resolution** — If a file with the same name already exists in the target category folder, **skip** the file and log a warning. No interactive prompts.
5. **Move by default** — Files are moved (not copied) unless `--move=false` is passed, in which case they are copied.
6. **Dry-run safety** — With `--dry-run`, no filesystem changes are made. All actions are logged with a `[DRY RUN]` prefix.
7. **Ignore patterns** — Files matching any `--ignore` glob pattern (checked against the filename) are excluded from processing.
8. **No-extension files** — Files without an extension are mapped to the `Others` category.
9. **Empty source** — If the source directory contains no organizable files, print a message and exit with code `0`.

---

## 6. Output Format

### Summary Table (always shown on success)

```
Organization Complete!

+-----------------+-------+-----------+
| Category        | Files | Size      |
+-----------------+-------+-----------+
| Archives        | 3     | 1.2 MB    |
| Code            | 7     | 45.3 KB   |
| Documents       | 5     | 320.0 KB  |
| Images          | 12    | 8.7 MB    |
+-----------------+-------+-----------+
| Total           | 27    | 10.3 MB   |
+-----------------+-------+-----------+

Successfully moved 27 files into 4 categories.
```

### Verbose Mode (`--verbose`)

Log each file action:

```
Moving 'photo.jpg' -> 'Images/photo.jpg'
Moving 'report.pdf' -> 'Documents/report.pdf'
Skipping 'notes.txt' (conflict: file already exists)
```

### Dry-Run Mode (`--dry-run`)

```
[DRY RUN] Would move 'photo.jpg' -> 'Images/photo.jpg'
[DRY RUN] Would move 'report.pdf' -> 'Documents/report.pdf'
```

---

## 7. Project Structure

Every implementation must follow this directory layout:

```
cli-organize-{lang}/
├── README.md              # Language-specific setup, usage, testing
├── .gitignore             # Must ignore demo/ and build artifacts
├── conductor/             # Agentic coding docs (DO NOT EDIT)
├── demo/                  # Gitignored — used by demo.sh for testing
│   ├── seed/              # Random files generated for testing
│   └── organized/         # Output of an organize run
├── <source-code>/         # Language-specific source
└── <tests>/               # Language-specific tests
```

---

## 8. README Convention

Every implementation's `README.md` must include:

1. **Description** — What this implementation is and what language/framework it uses.
2. **Prerequisites** — Runtime, package manager, and version requirements.
3. **Installation** — Step-by-step to build or install.
4. **Usage** — CLI usage with examples for all flags.
5. **Testing** — How to run the test suite.
6. **Standard Compliance** — Link back to this `STANDARD.md` in the parent repo.

---

## 9. Testing Requirements

### Minimum Unit Tests

| Area | What to test |
|---|---|
| Extension parsing | Basic extensions, no extension, dotfiles, multi-dot |
| Category mapping | All 10 categories + Others fallback |
| Directory creation | New, existing, nested directories |
| File move/copy | Successful move, successful copy, verify content |
| Conflict handling | Skip behavior, warning output |
| Ignore patterns | Matching globs, non-matching, empty patterns |
| Dry-run | No filesystem changes, correct log output |
| Custom map | Loading JSON, using custom categories |
| Summary report | Empty report, report with data |

### Minimum Integration Tests

| Scenario | Description |
|---|---|
| Full dry-run | Multiple file types, verify no changes, verify output |
| Full organize (no conflicts) | Move files, verify source clean + dest populated |
| Full organize (with conflicts) | Pre-existing file in dest, verify skip behavior |
| Custom map file | Organize using custom JSON mapping |

### Test Rules

- All tests must use **temporary directories** (no reliance on external state).
- Tests must be runnable with a single standard command (`go test ./...`, `pytest`, etc.).
- Tests must **not** require network access.

---

## 10. Adding a New Language

To add a new language implementation:

1. Create a new repo named `cli-organize-{lang}` (e.g., `cli-organize-rs` for Rust).
2. Implement all behavior defined in this specification.
3. Pass all minimum test requirements.
4. Include a `README.md` following the convention above.
5. Add the repo as a git submodule to the parent `cli-organize` repo.
6. Update the parent `README.md` implementation table.

---

## 11. Versioning

This standard follows [Semantic Versioning](https://semver.org/):

- **Current version:** `1.0.0`
- Breaking behavior changes require a major version bump.
- New optional features require a minor version bump.
