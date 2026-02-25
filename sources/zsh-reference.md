# Zsh Quick Reference

## Built-in Commands

| Command | Description | Example |
|---------|-------------|---------|
| `cd` | Change directory | `cd /tmp` |
| `pushd` | Push directory onto stack | `pushd /var/log` |
| `popd` | Pop directory from stack | `popd` |
| `dirs` | Display directory stack | `dirs -v` |
| `echo` | Print text | `echo "Hello $USER"` |
| `print` | Extended print (Zsh) | `print -P "%F{red}error%f"` |
| `printf` | Formatted print | `printf "%s: %d\n" "count" 42` |
| `read` | Read input | `read -r line < file.txt` |
| `source` / `.` | Execute in current shell | `source ~/.zshrc` |
| `export` | Set environment variable | `export PATH="/bin:$PATH"` |
| `unset` | Remove variable/function | `unset MY_VAR` |
| `typeset` | Declare variable with attributes | `typeset -i count=0` |
| `local` | Declare local variable | `local name="value"` |
| `readonly` | Make variable read-only | `readonly PI=3.14159` |
| `alias` | Define alias | `alias ll='ls -lah'` |
| `unalias` | Remove alias | `unalias ll` |
| `function` | Define function | `function greet { echo "Hi $1" }` |
| `autoload` | Mark function for autoload | `autoload -Uz compinit` |
| `zmodload` | Load Zsh module | `zmodload zsh/mathfunc` |
| `bindkey` | Bind keys in ZLE | `bindkey '^R' history-incremental-search-backward` |
| `setopt` | Set shell options | `setopt AUTO_CD` |
| `unsetopt` | Unset shell options | `unsetopt BEEP` |
| `compinit` | Initialize completion system | `compinit` |
| `compdef` | Define completion | `compdef _git git` |
| `zle` | Zsh line editor | `zle reset-prompt` |
| `emulate` | Emulate another shell | `emulate -L sh` |
| `zparseopts` | Parse options | `zparseopts -D -E h=help v=verbose` |
| `zcompile` | Compile Zsh files | `zcompile ~/.zshrc` |
| `zprof` | Profile Zsh startup | `zprof` |
| `whence` | Where a command comes from | `whence -v ls` |
| `where` | All locations of command | `where python` |
| `which` | Path to command | `which git` |
| `hash` | Manage command hash table | `hash -r` |
| `times` | Print process times | `times` |
| `wait` | Wait for background job | `wait $!` |
| `jobs` | List background jobs | `jobs -l` |
| `fg` | Bring job to foreground | `fg %1` |
| `bg` | Send job to background | `bg %1` |
| `disown` | Remove job from table | `disown %1` |
| `kill` | Send signal to process | `kill -TERM $pid` |
| `trap` | Set signal handler | `trap 'cleanup' EXIT` |
| `eval` | Evaluate string as command | `eval "$cmd"` |
| `exec` | Replace shell with command | `exec zsh` |
| `exit` | Exit shell | `exit 0` |
| `return` | Return from function | `return 1` |
| `break` | Exit loop | `break` |
| `continue` | Skip to next iteration | `continue` |
| `shift` | Shift positional parameters | `shift 2` |
| `getopts` | Parse options (POSIX) | `getopts "hv" opt` |
| `test` / `[` | Test conditions | `test -f file` |
| `true` / `false` | Return exit codes | `true` |
| `colon` / `:` | Null command | `: "${VAR:=default}"` |
| `noglob` | Disable globbing | `noglob find . -name "*.txt"` |
| `nocorrect` | Disable spell correction | `nocorrect mkdir MyDir` |
| `nohup` | Ignore hangup signal | `nohup ./server &` |

## Option Flags Reference

### Changing Directories
| Option | Description |
|--------|-------------|
| `AUTO_CD` | Automatically `cd` when typing a directory name |
| `AUTO_PUSHD` | `cd` pushes old directory onto stack |
| `PUSHD_IGNORE_DUPS` | Don't push duplicate directories |
| `PUSHD_MINUS` | Swap `+` and `-` for `pushd` |
| `CDABLE_VARS` | Allow `cd var` where `var` is a path variable |

### Completion
| Option | Description |
|--------|-------------|
| `AUTO_MENU` | Show menu on second tab press |
| `AUTO_PARAM_SLASH` | Add `/` after directory completion |
| `COMPLETE_IN_WORD` | Complete from both ends of cursor |
| `ALWAYS_TO_END` | Move cursor to end after completion |
| `MENU_COMPLETE` | Cycle through completions on tab |
| `LIST_ROWS_FIRST` | List completions across, not down |
| `NO_CASE_GLOB` | Case-insensitive globbing |

### Expansion and Globbing
| Option | Description |
|--------|-------------|
| `EXTENDED_GLOB` | Enable extended glob patterns (`^`, `#`, `~`) |
| `GLOB_DOTS` | Include dotfiles in glob matches |
| `NULL_GLOB` | Remove pattern if no match (no error) |
| `NOMATCH` | Error if glob has no matches (default on) |
| `GLOB_COMPLETE` | Generate completions from glob patterns |
| `KSH_GLOB` | KSH-style globbing |
| `NUMERIC_GLOB_SORT` | Sort numeric filenames numerically |

### History
| Option | Description |
|--------|-------------|
| `SHARE_HISTORY` | Share history between sessions |
| `APPEND_HISTORY` | Append to history file, don't overwrite |
| `INC_APPEND_HISTORY` | Append immediately, not on exit |
| `HIST_IGNORE_DUPS` | Don't record duplicate commands |
| `HIST_IGNORE_SPACE` | Don't record commands starting with space |
| `HIST_REDUCE_BLANKS` | Remove extra blanks from history |
| `HIST_VERIFY` | Show history substitution before executing |
| `EXTENDED_HISTORY` | Save timestamp in history |

### Input/Output
| Option | Description |
|--------|-------------|
| `CORRECT` | Spell correction for commands |
| `CORRECT_ALL` | Spell correction for all words |
| `DVORAK` | Use Dvorak keyboard for correction |
| `FLOW_CONTROL` | Disable flow control (`^S`/`^Q`) |
| `IGNORE_EOF` | Don't exit on `^D` |
| `INTERACTIVE_COMMENTS` | Allow comments in interactive shell |
| `PRINT_EXIT_VALUE` | Print non-zero exit codes |

### Job Control
| Option | Description |
|--------|-------------|
| `MONITOR` | Enable job control |
| `NOTIFY` | Report job status immediately |
| `CHECK_JOBS` | Check for running jobs before exit |
| `LONG_LIST_JOBS` | Print job notifications in long format |
| `BG_NICE` | Run background jobs at lower priority |
| `HUP` | Send HUP to jobs when shell exits |

### Scripting
| Option | Description |
|--------|-------------|
| `ERR_EXIT` | Exit on non-zero return code |
| `NO_UNSET` | Error on use of undefined variables |
| `PIPE_FAIL` | Return exit code of rightmost failed pipe |
| `XTRACE` | Print commands before execution (debug) |
| `VERBOSE` | Print lines before execution |
| `LOCAL_OPTIONS` | `setopt` in function is local to function |
| `LOCAL_TRAPS` | `trap` in function is local to function |
| `WARN_CREATE_GLOBAL` | Warn when creating globals in functions |
| `FUNCTION_ARGZERO` | Set `$0` to function/script name |

### Prompting
| Option | Description |
|--------|-------------|
| `PROMPT_SUBST` | Parameter/command expansion in prompts |
| `PROMPT_BANG` | `!` in prompt is replaced by history number |
| `PROMPT_CR` | Print `\r` before prompt |
| `TRANSIENT_RPROMPT` | Only show RPROMPT on current line |

## Special Parameters Reference

| Parameter | Description | Example |
|-----------|-------------|---------|
| `$0` | Name of current script or shell | `echo $0` |
| `$1` ... `$9` | Positional parameters | `echo $1` |
| `$#` | Number of positional parameters | `echo $#` |
| `$@` | All positional parameters (quoted, each separate) | `"$@"` |
| `$*` | All positional parameters (as single string) | `"$*"` |
| `$?` | Exit status of last command | `echo $?` |
| `$$` | PID of current shell | `echo $$` |
| `$!` | PID of last background command | `cmd & ; wait $!` |
| `$-` | Current option flags | `echo $-` |
| `$_` | Last argument of last command | `echo $_` |
| `$ARGC` | Number of elements in argument array | `echo $ARGC` |
| `$argv` | Array of positional parameters (Zsh) | `echo $argv[1]` |
| `$status` | Exit status of last command (alias `$?`) | `echo $status` |
| `$pipestatus` | Array of pipeline exit codes | `echo $pipestatus` |
| `$LINENO` | Current line number in script | `echo $LINENO` |
| `$FUNCNAME` | Name of current function (bash compat) | `echo $funcstack[1]` |
| `$funcstack` | Array of function call stack | `echo $funcstack` |
| `$functrace` | Array of function trace info | `echo $functrace` |
| `$EPOCHSECONDS` | Current Unix timestamp (needs zsh/datetime) | `echo $EPOCHSECONDS` |
| `$EPOCHREALTIME` | Unix timestamp with fractional seconds | `echo $EPOCHREALTIME` |
| `$RANDOM` | Random integer 0-32767 | `echo $RANDOM` |
| `$SECONDS` | Seconds since shell started | `echo $SECONDS` |
| `$IFS` | Internal field separator | `IFS=':'` |
| `$OLDPWD` | Previous working directory | `echo $OLDPWD` |
| `$PWD` | Current working directory | `echo $PWD` |
| `$HOME` | Home directory | `echo $HOME` |
| `$PATH` | Command search path | `echo $PATH` |
| `$FPATH` | Function autoload search path | `echo $FPATH` |
| `$CDPATH` | Search path for `cd` | `export CDPATH=.:~:~/projects` |
| `$HISTFILE` | Path to history file | `echo $HISTFILE` |
| `$HISTSIZE` | Max history events in memory | `HISTSIZE=10000` |
| `$SAVEHIST` | Max history events saved to file | `SAVEHIST=10000` |
| `$PROMPT` / `$PS1` | Primary prompt | `PROMPT='%% '` |
| `$RPROMPT` / `$RPS1` | Right-side prompt | `RPROMPT='%~'` |
| `$PROMPT2` / `$PS2` | Secondary prompt (continuation) | `PROMPT2='> '` |
| `$PROMPT3` / `$PS3` | Select prompt | `PROMPT3='Choose: '` |
| `$PROMPT4` / `$PS4` | Trace prompt (xtrace) | `PROMPT4='+%N:%i> '` |
| `$TERM` | Terminal type | `echo $TERM` |
| `$COLUMNS` | Width of terminal | `echo $COLUMNS` |
| `$LINES` | Height of terminal | `echo $LINES` |
| `$EDITOR` | Default text editor | `export EDITOR=vim` |
| `$VISUAL` | Default visual editor | `export VISUAL=code` |
| `$PAGER` | Default pager | `export PAGER=less` |
| `$LANG` | Default locale | `export LANG=en_US.UTF-8` |

## Keyboard Shortcuts Reference

### Line Editing (Emacs Mode — default)

| Shortcut | Action |
|----------|--------|
| `Ctrl+A` | Move to beginning of line |
| `Ctrl+E` | Move to end of line |
| `Ctrl+B` | Move back one character |
| `Ctrl+F` | Move forward one character |
| `Alt+B` | Move back one word |
| `Alt+F` | Move forward one word |
| `Ctrl+D` | Delete character forward (or EOF if line empty) |
| `Ctrl+H` | Delete character backward |
| `Ctrl+W` | Delete word backward |
| `Alt+D` | Delete word forward |
| `Ctrl+K` | Kill (cut) from cursor to end of line |
| `Ctrl+U` | Kill from beginning of line to cursor |
| `Ctrl+Y` | Yank (paste) killed text |
| `Ctrl+T` | Transpose characters |
| `Alt+T` | Transpose words |
| `Ctrl+_` | Undo last change |
| `Ctrl+L` | Clear screen |
| `Ctrl+C` | Cancel current line |
| `Ctrl+Z` | Suspend current process |
| `Ctrl+R` | Reverse history search |
| `Ctrl+S` | Forward history search (if flow control disabled) |
| `Ctrl+P` | Previous history entry |
| `Ctrl+N` | Next history entry |
| `Tab` | Complete word |
| `Alt+?` | List possible completions |
| `Alt+*` | Insert all possible completions |
| `Alt+.` | Insert last argument of previous command |
| `Alt+_` | Insert last argument of previous command |

### Line Editing (Vi Mode)

```zsh
# Enable vi mode
bindkey -v

# Common normal mode commands
# h/l       - move left/right
# w/b/e     - move by word
# 0/$       - beginning/end of line
# x         - delete character
# dw/db     - delete word forward/backward
# D         - delete to end of line
# dd        - delete entire line
# u         - undo
# /pattern  - search forward
# n/N       - next/previous match
# i/a/I/A   - enter insert mode

# Custom vi mode status indicator
function zle-line-init zle-keymap-select {
    case $KEYMAP in
        vicmd)      PROMPT_INDICATOR='[N] ' ;;
        viins|main) PROMPT_INDICATOR='[I] ' ;;
    esac
    zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select
```

### History Expansion

| Shortcut | Expansion | Description |
|----------|-----------|-------------|
| `!!` | Last command | `sudo !!` |
| `!$` | Last argument of last command | `vim !$` |
| `!^` | First argument of last command | `echo !^` |
| `!*` | All arguments of last command | `sudo !*` |
| `!n` | Command number `n` in history | `!42` |
| `!-n` | `n`th previous command | `!-2` |
| `!string` | Last command starting with `string` | `!git` |
| `!?string` | Last command containing `string` | `!?deploy` |
| `^old^new` | Replace `old` with `new` in last command | `^typo^fix` |

### Special Completions

| Shortcut | Description |
|----------|-------------|
| `~Tab` | Complete username |
| `$Tab` | Complete variable name |
| `@Tab` | Complete hostname |
| `=Tab` | Complete command in PATH |
| `<Tab>Tab` | Complete filename for redirection |

## Parameter Expansion Quick Reference

```zsh
${var}              # Basic expansion
${var:-default}     # Use default if unset or empty
${var:=default}     # Set and use default if unset or empty
${var:?error}       # Error if unset or empty
${var:+alternate}   # Use alternate if set and non-empty
${#var}             # Length of string / number of array elements
${var:offset}       # Substring from offset
${var:offset:len}   # Substring with length
${var#pattern}      # Remove shortest match from start
${var##pattern}     # Remove longest match from start
${var%pattern}      # Remove shortest match from end
${var%%pattern}     # Remove longest match from end
${var/pat/rep}      # Replace first match
${var//pat/rep}     # Replace all matches
${var/#pat/rep}     # Replace match at start
${var/%pat/rep}     # Replace match at end

# Zsh-specific flags
${(L)var}           # Convert to lowercase
${(U)var}           # Convert to uppercase
${(C)var}           # Capitalize each word
${(s:sep:)var}      # Split on separator
${(j:sep:)array}    # Join array with separator
${(o)array}         # Sort array ascending
${(O)array}         # Sort array descending
${(u)array}         # Unique elements
${(r:N:)var}        # Right-pad to width N
${(l:N:)var}        # Left-pad to width N
${(q)var}           # Quote for reuse in shell
${(Q)var}           # Remove one level of quoting
${(k)assoc}         # Keys of associative array
${(v)assoc}         # Values of associative array
${(kv)assoc}        # Keys and values of associative array
```

## Resources
- Zsh Manual: https://zsh.sourceforge.io/Doc/Release/
- Options Index: https://zsh.sourceforge.io/Doc/Release/Options-Index.html
- Parameter Expansion: https://zsh.sourceforge.io/Doc/Release/Expansion.html#Parameter-Expansion
- ZLE: https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html
