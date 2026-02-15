# cli-organize

A collection of CLI file-organizer tools — the **same functionality** implemented in multiple programming languages. Each implementation sorts files in a directory into category-based sub-folders by extension.

This serves as a playground for exploring agentic coding patterns across languages while maintaining a consistent user-facing specification.

## Implementations

| Language | Directory | Status | CLI Framework |
|---|---|---|---|
| Go | [cli-organize-go](./cli-organize-go/) | Active | [Cobra](https://github.com/spf13/cobra) |
| Python | [cli-organize-py](./cli-organize-py/) | Active | [argparse](https://docs.python.org/3/library/argparse.html) |

> Want to add a new language? See [STANDARD.md § Adding a New Language](./STANDARD.md#10-adding-a-new-language).

## Quick Start

```bash
# Clone with all submodules
git clone --recurse-submodules https://github.com/<your-username>/cli-organize.git
cd cli-organize

# Try the interactive demo (works with any implementation)
./demo.sh
```

## Specification

All implementations follow a shared standard defined in **[STANDARD.md](./STANDARD.md)**. This covers:

- CLI arguments and flags
- Default category mappings (10 categories, 60+ extensions)
- Output format and summary tables
- Conflict resolution behavior
- Testing requirements
- Project structure conventions

## Demo Script

The root [`demo.sh`](./demo.sh) script provides an interactive way to test any implementation:

1. **Seed** — Generate random files across all supported extensions
2. **Clean** — Remove seed/organized directories
3. **Tree** — View directory structure
4. **Run** — Execute the organizer against seeded files
5. **Dry Run** — Simulate without changes
6. **Verify** — Check output matches expected categories

```bash
# Use with Go implementation
./demo.sh --bin ./cli-organize-go/cli-organize-go

# Use with Python implementation
./demo.sh --bin "poetry -C ./cli-organize-py run organize"
```

## Repository Structure

```
cli-organize/
├── README.md          # This file
├── STANDARD.md        # The specification all implementations must follow
├── demo.sh            # Universal demo/test script
├── LICENSE            # MIT License
├── cli-organize-go/   # Go implementation (git submodule)
└── cli-organize-py/   # Python implementation (git submodule)
```

## How It Works

Each implementation:

1. Scans the top-level files in a source directory
2. Determines a category for each file based on its extension
3. Creates category folders (e.g., `Documents/`, `Images/`, `Code/`)
4. Moves (or copies) files into the appropriate folder
5. Prints a summary table

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
```

## License

[MIT](./LICENSE)
