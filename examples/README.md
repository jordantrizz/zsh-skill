# Examples

This directory contains practical Zsh script examples organized by category.

## Directory Structure

| Directory | Contents |
|-----------|----------|
| [`basic/`](basic/) | Beginner-friendly examples covering core Zsh concepts |
| [`advanced/`](advanced/) | Advanced scripting techniques and patterns |
| [`functions/`](functions/) | Reusable function libraries |
| [`config/`](config/) | Configuration file examples (`.zshrc`, `.zshenv`, etc.) |

## Basic Examples

| File | Description |
|------|-------------|
| [`basic/hello_world.zsh`](basic/hello_world.zsh) | Variables, output, string operations |
| [`basic/file_operations.zsh`](basic/file_operations.zsh) | File checks, glob patterns, listing |
| [`basic/control_flow.zsh`](basic/control_flow.zsh) | If/else, loops, case statements |
| [`basic/arrays_and_maps.zsh`](basic/arrays_and_maps.zsh) | Indexed and associative arrays |

## Advanced Examples

| File | Description |
|------|-------------|
| [`advanced/async_jobs.zsh`](advanced/async_jobs.zsh) | Background jobs, parallel execution, timeouts |
| [`advanced/advanced_globbing.zsh`](advanced/advanced_globbing.zsh) | Glob qualifiers, extended globs, sorting |
| [`advanced/error_handling.zsh`](advanced/error_handling.zsh) | Traps, strict mode, pipeline errors |

## Function Libraries

| File | Description |
|------|-------------|
| [`functions/function_library.zsh`](functions/function_library.zsh) | String, file, logging, validation, system utilities |
| [`functions/prompt_helpers.zsh`](functions/prompt_helpers.zsh) | Color output, spinners, progress bars, prompts |

## Configuration Examples

| File | Description |
|------|-------------|
| [`config/zshrc_example.zsh`](config/zshrc_example.zsh) | Full `.zshrc` with history, completion, prompt, aliases |
| [`config/zshenv_example.zsh`](config/zshenv_example.zsh) | `.zshenv` with PATH, XDG dirs, tool settings |

## Running Examples

```zsh
# Make executable and run
chmod +x examples/basic/hello_world.zsh
./examples/basic/hello_world.zsh

# Or run with zsh directly
zsh examples/basic/hello_world.zsh

# Source a library to use its functions
source examples/functions/function_library.zsh
log_info "Library loaded"
```

## See Also

- [`sources/zsh-basics.md`](../sources/zsh-basics.md) — Core concepts
- [`sources/zsh-advanced.md`](../sources/zsh-advanced.md) — Advanced features
- [`sources/zsh-scripting-patterns.md`](../sources/zsh-scripting-patterns.md) — Common patterns
- [`sources/zsh-best-practices.md`](../sources/zsh-best-practices.md) — Best practices
