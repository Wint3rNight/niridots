# Your Neovim, from zero

This guide is for someone who has never used Neovim. It teaches YOUR setup
(`~/.config/nvim`), in the order you will actually need things. Read Part 1 and
Part 2 today. Come back for the rest when you hit the situation they describe.

The very end has every shortcut, sorted by how often you will press it.

---

## Part 1 — The five minutes that make everything else possible

### Modes: the one idea you must hold onto

Most editors have one state: you type, letters appear. Neovim has several states.
It calls them **modes**. Hold onto this word. Almost every confusion a beginner has
is "I am in the wrong mode".

- **Normal mode** is where you live. Keys are *commands*, not letters. Pressing `d`
  does not type a d, it starts a delete. You start in Normal mode.
- **Insert mode** is where typing works like any other editor. You enter it with `i`.
  You leave it with `Esc`.
- **Visual mode** is for selecting text. You enter it with `v`. `Esc` leaves it.
- **Command-line mode** is for typed commands. You enter it with `:`. You will see a
  small popup in the middle of the screen. Enter runs the command, `Esc` cancels.
- **Terminal mode** is when you are typing into a shell inside Neovim. `Esc Esc`
  (twice) gets you back out.

The habit that fixes 90% of problems: **when in doubt, press `Esc`.** It always
brings you back toward Normal mode. Pressing it too often costs nothing.

### The keys you cannot live without

| Keys | What it does |
|---|---|
| `i` | Start typing (Insert mode) at the cursor |
| `Esc` | Stop typing, back to Normal mode |
| `:w` then Enter | Save. (Your setup also has `Space w`.) |
| `:q` then Enter | Close the window. `:q!` throws away unsaved changes. |
| `u` | Undo. `Ctrl-r` redoes. |

If you ever feel stuck, the escape hatch is: press `Esc` a few times, then type
`:qa!` and Enter. That quits everything without saving.

### The Space key is your menu

Your **leader** key is **Space**. Most of your shortcuts start with it. When this
guide writes `<leader>ff` it means: press Space, then f, then f.

"But I will never remember all of these." You do not have to. **Press Space and
wait half a second.** A menu pops up listing every key that can follow, with a
description. Press one and the menu shows the next level. This menu is called
which-key, and it is how you learn the setup. Use it shamelessly.

### Moving around without the mouse

The mouse works. But the keyboard is faster once the following four keys are in
your fingers: `h` left, `j` down, `k` up, `l` right. They are on the home row, so
your hand never moves.

A few more that pay for themselves the first day:

| Keys | Moves the cursor to |
|---|---|
| `w` / `b` | Next word / previous word |
| `0` / `$` | Start of line / end of line |
| `gg` / `G` | Top of file / bottom of file |
| `Ctrl-d` / `Ctrl-u` | Half a page down / up (the cursor stays centred) |
| `/word` then Enter | The next "word" in the file. `n` finds the next one, `N` the previous. |
| `Esc` | (after a search) clears the yellow highlights |

Line numbers on the left are *relative*: the current line shows its real number,
the others show how far away they are. So `5j` means "five lines down" and you
can see the 5 on screen. That trick is called a **count**. Any movement can take one.

---

## Part 2 — The picture: a desk, a wall, and a filing cabinet

Here is the picture to keep in your head. It explains why fast Neovim users never
seem to click through folders.

- Every file you open becomes a **paper on your desk**. Neovim calls it a *buffer*.
  Closing the window does not throw the paper away. It stays on the desk.
- The four papers you are actually working on today get **taped to the wall** with
  a number. That is *Harpoon*. One keypress brings paper 1, 2, 3 or 4 in front of you.
- The whole project is the **filing cabinet** in the corner. That is the file tree.
  You open it to see how a repo is organised, not to fetch every file.
- To get any paper out of the cabinet you do not walk over. You ask an **assistant**:
  type three letters of the name and it is on your desk. That is the *picker*.
- When you need to reorganise the cabinet (rename, move, create files), you use
  **oil**: it shows a drawer as plain text, you edit the text, and the drawer changes.

Everything in Part 3 is one of those five things or a tool that sits on the desk.

### The daily loop (this is the whole "impressive setup")

1. In a terminal, go to the project folder and type `nvim .`
   The filing cabinet opens on the left. `Alt-l` moves you to the main window.
2. `Space Space` — the assistant. Type a few letters of a file name, press Enter.
   The paper is on your desk. Files you open often appear at the top automatically.
3. `Space a` — tape this paper to the wall. Do it for today's 3–4 files.
4. `Ctrl-h`, `Ctrl-t`, `Ctrl-n`, `Ctrl-s` — bring wall paper 1, 2, 3, 4 in front of you.
   This is the "how is he switching so fast" trick.
5. Edit. `i` to type, `Esc` to stop, `Space w` to save.
6. `Space m b` — build. If it fails, `]q` jumps to the first error inside the code.
7. `Ctrl-\` — a terminal pops up over everything. Run a test binary, check `git
   status`, whatever. `Ctrl-\` again and it is gone. You are exactly where you were.
8. `Space g g` — lazygit, a full git screen. Stage, write the commit, push, `q`.
9. Next morning: `nvim .` then `Space q s` — every window from yesterday comes back.

Do only this loop for the first week. Everything else is decoration until this is
automatic.

---

## Part 3 — Each tool: what it is, and the moment you reach for it

Each section starts with the situation. If the situation is not yours yet, skip it.

### 3.1 Editing text like a Neovim user (the part that feels like magic later)

The situation: you want to change a word, delete a line, copy a function.

Neovim commands are sentences: a **verb**, then a **thing**. The verbs are `d`
(delete), `c` (change: delete and start typing), `y` (yank, which means copy), and
`v` (select). The things are text objects.

| You want to | Press |
|---|---|
| Delete this line | `dd` |
| Copy this line | `yy`, then `p` to paste below |
| Change one word | `ciw` (change inner word) — the word vanishes, you type the new one |
| Delete everything inside the ( ) | `dib` (delete inside brackets) |
| Delete a whole function, body and all | `daf` (delete around function) |
| Copy a function's body only | `yif` |
| Change the text inside the quotes | `ciq` |
| Select an argument in a call | `via` |
| Select the git change under the cursor | `vih` |
| Delete a struct/class | `dac` |
| Select an if/loop block | `vao` |

The pattern is always the same. Verb, then `i` (inside) or `a` (around), then the
thing: `w` word, `f` function, `c` class, `o` block, `a` argument, `q` quotes,
`b` brackets, `h` git hunk, `d` a number, `g` the whole file. Learn `ciw` and `dif`
first. The rest follow the same grammar.

Two more habits:
- `.` repeats your last change. Change one variable name with `ciw`, move to the
  next one, press `.`.
- In Visual mode `>` and `<` indent, and the selection stays so you can press again.

**Surround** (wrapping things in quotes or brackets): `gsaiw"` puts quotes around
the word (say it as: surround, add, inner word, with "). `gsd"` deletes the
surrounding quotes. `gsr"'` replaces double quotes with single ones.

**Paste without losing your clipboard:** select something, then `Space p`. Plain `p`
over a selection swaps the clipboard for the text you replaced, which is a classic
"where did my copy go" moment.

**Move lines:** `Alt-Up` / `Alt-Down` move the current line or the selection.

**Comment out code:** `gcc` for one line, `gc` on a selection. It knows the right
comment style for C++, CMake, Lua and so on.

### 3.2 Jumping anywhere on the screen (flash)

The situation: you can see the spot you want, it is 20 lines down and halfway across.

Press `s` and type the two characters that start the spot. Every match on screen gets
a letter label. Press the label. You are there. It works across split windows too.
This replaces most scrolling. `S` does a related thing: it selects a code block
(function, if, loop) by structure, press it again to grow the selection.

Structured jumps for code: `]f` next function, `[f` previous, `]c` next class or
struct, `]a` next argument. `]]` jumps to the next use of the word under the cursor
(it understands the language, not just the letters).

### 3.3 The assistant: the picker (`Space f …`)

The situation: you need a file, a piece of text, a symbol, or "that thing I saw
yesterday".

`Space Space` is the one to learn. It searches file names, open buffers and recent
files at once and puts the likely answer first.

Inside any picker: keep typing to filter, `Ctrl-j`/`Ctrl-k` or the arrows to move,
Enter opens, `Ctrl-v` opens in a split beside the current file, `Esc` closes.
`Ctrl-q` sends every result into the quickfix list (see 3.7) so you can walk them
one by one with `]q`.

The pickers you will use most:

| Keys | Finds |
|---|---|
| `Space f s` | Text anywhere in the project. Type and results update live. |
| `Space f w` | The word under the cursor, project-wide. In Visual mode, the selection. |
| `Space f b` | Papers already on the desk (open buffers) |
| `Space f r` | Recently opened files |
| `Space f l` | A line in the current file |
| `Space f S` | A function or class anywhere in the project, by name |
| `Space f d` | Every error and warning in the project |
| `Space f u` | Your undo history as a list you can jump back into |
| `Space f R` | Reopen the last picker exactly where you left it |
| `Space f h` / `Space f k` | Help pages / your own keymaps (with descriptions) |

Tip: `Space f w` on a function name is the fastest "where is this used" that does
not need the language server.

### 3.4 The filing cabinet (tree) and oil

The situation: new repo, you need to see how it is laid out. Or you need to rename
or move files.

`Space e e` opens and closes the tree. `Space e f` opens it with the current file
highlighted, which is the usual way to ask "where am I". Inside the tree: `j`/`k`
move, Enter opens or folds, `a` creates a file (end the name with `/` for a
folder), `r` renames, `d` deletes, `?` shows all of its keys. `Alt-l` goes back to
the code.

For real reorganising use **oil**: press `-` and the current file's folder appears
as a text buffer. Rename a file by editing its line. Delete one with `dd`. Create one
by typing a name on a new line. Press `:w` and the folder changes to match. `-` again
goes to the parent folder, `q` closes. It feels strange for one minute and then it
is the only way you want to do it.

### 3.5 Code intelligence (the language server)

The situation: what is this function, where is it defined, who calls it, rename it
everywhere.

A **language server** is a program that understands your code. For C, C++ and CUDA
it is clangd. For shaders it is glsl_analyzer, for Rust rust-analyzer, for Lua
lua_ls. They start by themselves when you open a file.

| Keys | What it does |
|---|---|
| `gd` | Go to the definition. `Ctrl-o` goes back where you came from. |
| `grr` | Every reference (a picker; Enter jumps, `Ctrl-q` sends all to quickfix) |
| `K` | Show the documentation for the thing under the cursor. `K` again to scroll into it. |
| `grn` (or `Space r n`) | Rename the symbol everywhere in the project |
| `gra` (or `Space c a`) | Code action: "add the missing include", "fix this", etc. |
| `gO` | Outline of this file's functions and classes |
| `Alt-o` | Switch between the .cpp and its .h |
| `]d` / `[d` | Next / previous error or warning. `Ctrl-w d` shows the message in full. |
| `Space x x` | A panel listing every error in the project |
| `Space o h` | Turn inlay hints on/off (the grey parameter names inside calls) |

While typing inside a call, `Ctrl-s` shows the function's signature so you know
which argument you are on.

Objection you will have: "clangd says it cannot find my includes." That means
the repo has no `compile_commands.json` yet. That file tells clangd how each source
is compiled. Press `Space m g` once in that repo (it runs CMake generate) and the
file appears in `build/`. cccl already has one. For CUDA files the special flags are
already set in `~/.config/clangd/config.yaml`, matched to your GPU and CUDA 13.3.

### 3.6 Completion and snippets (blink)

The situation: you are typing and a menu appears.

Keep typing to narrow it. **Tab** moves down the list, **Shift-Tab** up, **Enter**
accepts the highlighted one. If nothing is highlighted, Enter is just a newline. So
the menu never steals an Enter from you. `Ctrl-Space` opens the menu on demand or
toggles the documentation, `Ctrl-e` hides it.

Snippets are in the same menu (for example `for` expands to a whole loop). After
accepting one, Tab jumps between its blanks.

The `:` command line and `/` search also complete as you type. Tab picks.

### 3.7 Build, errors, quickfix

The situation: you changed code and want to know whether it compiles.

All your repos are CMake projects. cmake-tools drives them:

| Keys | What it does |
|---|---|
| `Space m g` | Generate (configure). Do this once per repo. Also creates compile_commands.json. |
| `Space m s` | Pick which target to build (a picker) |
| `Space m b` | **Build it.** Output streams into a bottom terminal. |
| `Space m S` then `Space m r` | Pick a program to run, then run it in a floating terminal |
| `Space m d` | Run it under the debugger |
| `Space m t` | Switch between Debug and Release |
| `Space m m` | `:Make target` — a plain build for when you want to type the target |
| `Space m o` | The task list: every build you started, with output |

When a build fails the errors go into the **quickfix list**. Think of it as a
to-do list of locations. `]q` takes you to the next one inside your code, `[q` back.
`Space x q` shows the whole list in a panel. That panel is editable: `>` shows the
lines around each entry.

Search results can go in the same list (`Ctrl-q` in any picker), and so can
"every place this function is used". So the loop "list → `]q` → fix → `]q`" covers
builds, searches and references alike. Learn it once.

If a repo does not use `build/` (glslang uses `build-opt/`), drop a file called
`.nvim.lua` in its root with `vim.o.makeprg = "cmake --build build-opt --target $*"`.
Neovim asks you to trust the file the first time. It is ignored by git.

### 3.8 Tests

The situation: the project has tests (gtest, Catch2 or doctest through ctest) and you
want to run just the one you are looking at.

Build first (`Space m b`). Then `Space t r` runs the test under the cursor. A tick or
cross appears next to it. `Space t o` shows the output of the last run, `Space t s`
opens the summary tree of all tests, `Space t R` runs the whole file, `Space t a`
runs everything, `Space t d` runs the test under the cursor inside the debugger.

### 3.9 Debugging

The situation: it compiles, it runs, the number is wrong, and print statements are
not cutting it.

1. Put the cursor on a line and press `Space d b`. A red dot appears: a breakpoint.
2. `Space d c` (or `F5`). It asks for the executable, starting in `build/`. Pick it.
3. The program runs to your breakpoint and the debug screen opens: variables on the
   left, the call stack, a console. Values also appear at the end of each line.
4. `Space d o` steps over a line (`F10`), `Space d i` steps into the call (`F11`),
   `Space d O` steps out (`F12`), `Space d c` continues to the next breakpoint.
5. `Space d e` shows the value of the thing under the cursor. `Space d C` runs to
   where the cursor is. `Space d t` stops. `Space d l` re-runs the last session.

`Space d B` makes a breakpoint that only stops when a condition is true, for example
`i == 42`. Two debuggers are installed: gdb (default) and codelldb (an alternative
that is sometimes nicer with C++ containers). The picker on start lets you choose.

### 3.10 Git

The situation: you changed things and want to see, stage, commit, or understand history.

Changed lines are marked in the gutter automatically (green added, blue changed,
red removed).

| Keys | What it does |
|---|---|
| `Space g g` | **lazygit**: the full git screen. Space stages a file, `c` commits, `P` pushes, `q` leaves. |
| `]h` / `[h` | Jump to the next / previous change in this file |
| `Space g p` | Preview what changed in the hunk under the cursor |
| `Space g s` | Stage just that hunk (select lines first to stage part of it) |
| `Space g r` | Throw that hunk away (careful: this deletes your change) |
| `Space g u` | Un-stage the hunk |
| `Space g b` | Who wrote this line, with the commit message |
| `Space g v` | **Diffview**: every changed file side by side, old vs new |
| `Space g h` | The history of this file, each commit as a diff |
| `Space g q` | Close diffview |
| `Space g c` | A picker of changed files |
| `Space g o` | Open this file (or selected lines) on GitHub in your browser |

For a merge conflict, run `:DiffviewOpen`. It shows three columns: yours, theirs,
and the result. Inside it `Space c o` takes yours, `Space c t` takes theirs.

Your rule stays: Claude never commits for you. lazygit is where commits happen.

### 3.11 Formatting (and why it is deliberately careful)

The situation: you want tidy code, but you contribute to repos that reject
"reformatted the whole file" pull requests.

Lua and Rust format themselves on save. **C, C++ and CUDA do not**, on purpose.
llama.cpp says never reformat whole files. The Khronos repos want only the lines
you touched formatted. cccl formats whole files and has a `.nvim.lua` that turns
save-formatting on just there.

| Keys | What it does |
|---|---|
| `Space m h` | Format **only the lines you changed** — use this before every commit |
| `Space m p` | Format the whole file (or the selection) |
| `Space o f` | Turn save-formatting on/off for this buffer |

Tabs show as `»` and trailing spaces as `·`, so you see them before CI does.

### 3.12 Search and replace across the project

The situation: rename a thing that the language server cannot rename (a string, a
macro, a comment), in fifty files.

`Space s r` opens grug-far. Type what to find, what to replace, optionally which
files. Every match shows live. Press Enter on a match to open it, or run the
replace for all of them. For the current file only, the classic still works:
`:%s/old/new/g` — you see a live preview before pressing Enter.

### 3.13 Claude and Copilot

Copilot gives grey "ghost text" while you type. `Alt-l` accepts it, `Alt-Right`
accepts one word, `Alt-]` shows another suggestion, `Alt-e` dismisses. It hides
itself while the completion menu is open.

Claude Code lives in a right-hand split. `Space c c` opens or closes it. Select code
and press `Space c s` to send it. `Space c b` adds the whole current file to its
context. When Claude edits a file, the change appears as a diff in Neovim: read it,
`Space c y` accepts, `Space c n` rejects. `Alt-h` / `Alt-l` move between the Claude
window and your code, even while the cursor is inside Claude's terminal.

### 3.14 Terminals

`Ctrl-\` toggles a floating terminal (fish). `Space t t` toggles a second one at
the bottom. They are two different shells and keep their history. Inside one, keys
go to the shell. `Esc Esc` returns to Normal mode so you can scroll and copy
output. `Alt-h/j/k/l` moves between windows from anywhere, including terminals.

### 3.15 Sessions and switching repos

The situation: you work on six repositories and want to pick up exactly where you
left each one.

`Space f p` lists your repos. Pick one: Neovim changes into it and restores the
windows you had open there. `Space q s` restores the session for the current folder
by hand, `Space q l` the last session anywhere. Sessions save themselves when you
quit. They are never restored unless you ask.

### 3.16 Switches under `Space o`

On/off things live in one place. `Space o b` transparent background (remembered).
`Space o h` inlay hints. `Space o d` diagnostics. `Space o f` save-formatting.
`Space o m` markdown rendering. `Space o s` spell check. `Space o w` line wrap.
`Space o z` zen mode (one centred window, nothing else). `Space o D` dims every
block except the one you are in.

### 3.17 Windows and buffers

`Space s v` splits the screen vertically, `Space s h` horizontally, `Space s x`
closes a split, `Space s e` makes them equal. `Ctrl-Arrows` resize.
`Shift-h` / `Shift-l` cycle through the papers on the desk. `Space b d` takes a
paper off the desk without closing the window. `Space b b` flips to the last one.

---

## Part 4 — Workflow tips and tricks

1. **Never navigate to a file you have opened before.** `Space Space` and three
   letters. The tree is for looking, not for fetching.
2. **Tape four papers to the wall every morning.** `Space a` on the files of today's
   task, then `Ctrl-h/t/n/s` all day. Re-tape when the task changes.
3. **`Ctrl-o` is the back button.** After `gd`, `grr`, a search, or a flash jump,
   `Ctrl-o` returns you. `Ctrl-i` goes forward again.
4. **Let the quickfix list drive you.** Build errors, search hits, references: put
   them in the list, then `]q`, fix, `]q`, fix. Never hunt manually.
5. **Read the error, then `gra`.** Half of clangd's complaints (missing include,
   missing semicolon, wrong cast) have a one-key fix in the code-action menu.
6. **`.` is your macro for small edits.** `ciw` + new name, then `n` to the next
   match, then `.`. For bigger repeats, record one: `qq` starts recording into `q`,
   do the edit, `q` stops, `@q` replays it, `5@q` replays five times. The statusline
   shows "recording @q" while recording.
7. **`Space m h` before every commit** in the Khronos repos and llama.cpp. Formatted
   hunks, untouched everything else.
8. **Undo is a tree.** `u` walks back. If you undid too far and typed something,
   the old branch is not lost: `Space u` shows the tree, `Space f u` shows it as a list.
9. **Big files are fine.** Highlighting, folds and the language server switch off
   by themselves above a megabyte. If Neovim ever feels slow in a normal file,
   `Space o T` toggles treesitter and tells you whether that was the cause.
10. **`:Lazy sync` updates plugins; `:Lazy restore` undoes it** if something breaks.
    `Space L` opens that screen, `Space M` opens Mason (language servers and tools).
11. **`q` closes helper windows** (help, quickfix, test output, diagnostics panel).
    You do not need `:q` for those.
12. **Folds follow the code.** `za` folds or unfolds the function under the cursor,
    `zM` folds everything, `zR` opens everything. Handy in a 3000-line file.
13. **Lost? `Space f k`** searches your own keymaps by description. Type "stage" and
    it shows you `Space g s`.

---

## Part 5 — Every shortcut, by how often you will press it

### Tier 1 — every few minutes

| Keys | What it does |
|---|---|
| `i` / `Esc` | Start / stop typing |
| `h j k l`, `w b`, `0 $`, `gg G` | Move |
| `Ctrl-d` / `Ctrl-u` | Half page down / up |
| `/text` `n` `N`, `Esc` | Search forward, next, previous; clear highlight |
| `u` / `Ctrl-r` | Undo / redo |
| `dd` `yy` `p` | Delete line, copy line, paste |
| `ciw` `dif` `yaf` … | Verb + object edits (3.1) |
| `.` | Repeat last change |
| `Space w` | Save |
| `Space Space` | Find a file (smart) |
| `Space a`, `Ctrl-h/t/n/s` | Harpoon: pin, jump to pin 1–4 |
| `Ctrl-\` | Floating terminal |
| `s` + two chars | Flash jump |
| `gd`, `Ctrl-o` | Go to definition, go back |
| `K` | Docs for the symbol under the cursor |
| Tab / Enter (in the menu) | Pick / accept a completion |
| `Alt-h/j/k/l` | Move between windows |
| `Alt-l` | Accept Copilot suggestion |

### Tier 2 — several times an hour

| Keys | What it does |
|---|---|
| `Space f s` / `Space f w` | Grep the project / grep the word under the cursor |
| `Space f b` / `Space f r` | Open buffers / recent files |
| `grr` | References |
| `grn` / `Space r n` | Rename symbol |
| `gra` / `Space c a` | Code action |
| `]d` `[d` | Next / previous diagnostic |
| `]f` `[f`, `]c` `[c`, `]a` `[a` | Next / previous function, class, argument |
| `]]` `[[` | Next / previous use of the word under the cursor |
| `Space m b` | Build |
| `]q` `[q` | Next / previous quickfix item (build error, search hit) |
| `Space x x` | Diagnostics panel |
| `Alt-o` | Switch source / header |
| `]h` `[h`, `Space g p`, `Space g s` | Git hunks: next, preview, stage |
| `Space g g` | lazygit |
| `Space c c`, `Space c s` | Claude: toggle, send selection |
| `v` `V` `Ctrl-v` | Select characters / lines / a column block |
| `>` `<` (visual) | Indent / dedent |
| `gcc` / `gc` | Comment line / selection |
| `Space p` (visual) | Paste over selection, keep clipboard |
| `Alt-Up` / `Alt-Down` | Move line or selection |
| `Shift-h` / `Shift-l` | Previous / next buffer |
| `Space s v`, `Space s x` | Split vertically, close split |
| `Ctrl-q` (in a picker) | Send results to quickfix |
| `Esc Esc` (in a terminal) | Back to Normal mode |

### Tier 3 — a few times a day

| Keys | What it does |
|---|---|
| `Space e e` / `Space e f` | File tree / tree on the current file |
| `-` | Oil: edit the current folder as text |
| `Space f l`, `Space f S`, `Space f d` | Lines in file, project symbols, project diagnostics |
| `Space f p` | Switch repo (restores its session) |
| `Space q s` / `Space q l` | Restore this folder's session / the last session |
| `Space m g`, `Space m s`, `Space m r`, `Space m o` | CMake generate, pick target, run, task list |
| `Space m m` | `:Make target` |
| `Space t r`, `Space t o`, `Space t s` | Run test under cursor, show output, summary |
| `Space d b`, `Space d c` / `F5`, `Space d o` / `F10`, `Space d i` / `F11`, `Space d O` / `F12` | Debug: breakpoint, start/continue, step over, into, out |
| `Space d e`, `Space d t`, `Space d u` | Debug: evaluate, stop, toggle UI |
| `Space m h` / `Space m p` | Format changed hunks / whole file |
| `Space s r` | Search & replace across the project |
| `Space x q`, `Space x s` | Quickfix panel, symbol outline |
| `Space g v`, `Space g h`, `Space g q` | Diffview, file history, close |
| `Space g b`, `Space g d` | Blame line, diff against index |
| `Space g r`, `Space g u`, `Space g S`, `Space g R` | Reset hunk, undo stage, stage file, reset file |
| `Space g c`, `Space g l`, `Space g L`, `Space g B`, `Space g o` | Pickers: changed files, log, file log, branches; open on GitHub |
| `Space t t` | Bottom terminal |
| `Space b d`, `Space b o`, `Space b b` | Close buffer, close others, last buffer |
| `gsa`, `gsd`, `gsr` | Surround add / delete / replace |
| `S`, `R` | Flash: select by structure, treesitter search |
| `za`, `zR`, `zM` | Fold toggle, open all, close all |
| `qq` … `q`, `@q` | Record a macro, replay it |
| `Space c b`, `Space c y`, `Space c n`, `Space c f` | Claude: add file, accept diff, reject diff, focus |
| `Alt-Right`, `Alt-]`, `Alt-[`, `Alt-e` | Copilot: accept word, next, previous, dismiss |
| `Ctrl-s` (insert mode) | Signature help |
| `Ctrl-Space`, `Ctrl-e`, `Ctrl-b` / `Ctrl-f` | Completion: open/docs, hide, scroll docs |
| `]t` `[t`, `Space f t` | TODO comments: next / previous, list |
| `Space o h`, `Space o f`, `Space o m` | Toggle inlay hints, save-formatting, markdown rendering |

### Tier 4 — weekly, or when the situation comes up

| Keys | What it does |
|---|---|
| `Space u`, `Space f u` | Undo tree / undo list |
| `Space f h`, `Space f k`, `Space f c`, `Space f :` | Help, keymaps, commands, command history |
| `Space f g`, `Space f F` | Git-tracked files, files including hidden/ignored |
| `Space f j`, `Space f m`, `Space f R`, `Space f N`, `Space f n` | Jumps, marks, resume picker, notifications, message log |
| `Space f D`, `Space f T` | Buffer diagnostics, only TODO/FIX |
| `gD`, `gri`, `grt`, `gO` | Declaration, implementations, type definition, outline |
| `Space x X`, `Space x S`, `Space x l`, `Space x t` | Buffer diagnostics, LSP panel, location list, TODOs panel |
| `Space d B`, `Space d C`, `Space d l`, `Space d r`, `Space d h` | Conditional breakpoint, run to cursor, re-run, REPL, hover value |
| `Space m d`, `Space m S`, `Space m t`, `Space m c`, `Space m k`, `Space m M` | CMake debug, launch target, build type, clean; run any task, re-run last |
| `Space t R`, `Space t a`, `Space t d`, `Space t S`, `Space t O` | Tests: file, all, debug, stop, output panel |
| `Space q S`, `Space q d`, `Space q q` | Pick a session, don't save session, quit all |
| `Space o b`, `Space o d`, `Space o s`, `Space o w`, `Space o l`, `Space o L`, `Space o T`, `Space o z`, `Space o D` | Toggles: transparency, diagnostics, spell, wrap, relative numbers, numbers, treesitter, zen, dim |
| `Space s h`, `Space s e`, `Ctrl-Arrows` | Horizontal split, equalise, resize |
| `Space g t` | Inline blame on every line |
| `Space e r` | Refresh the tree |
| `Space L`, `Space M` | Lazy (plugins), Mason (tools) |
| `Ctrl-e` | Harpoon: edit the pin list |
| `gsf`, `gsF`, `gsh`, `gsn` | Surround: find, find left, highlight, change line count |
| `:FormatDisable` / `:FormatEnable` | Save-formatting off / on (add `!` for this buffer only) |
| `:ClangdAST`, `:ClangdSymbolInfo`, `:ClangdTypeHierarchy`, `:ClangdMemoryUsage` | clangd extras |
| `:DiffviewOpen` | Merge-conflict view |
| `:Lazy sync` / `:Lazy restore` | Update plugins / roll back |

---

## Part 6 — A learning plan that will not drown you

**Week 1.** Modes, `Esc`, `i`, `Space w`, `hjkl`, `dd yy p u`. The daily loop only:
`Space Space`, `Space a`, `Ctrl-h/t/n/s`, `Ctrl-\`, `Space m b`, `]q`, `Space g g`.
Open the Space menu whenever you are lost.

**Week 2.** Verb + object editing: `ciw`, `dif`, `via`, `.`. Flash `s`. `gd`, `Ctrl-o`,
`grr`, `K`, `gra`. `]f` / `[f`.

**Week 3.** The debugger (`Space d b`, `F5`, `F10`). Tests (`Space t r`). Search and
replace (`Space s r`). Diffview (`Space g v`). Sessions (`Space f p`, `Space q s`).
Surround and macros.

After that, skim Tier 4 once a month and adopt whatever solves a problem you had
that week.

---

## Part 7 — When something is off

- **Nothing happens when I type.** You are in Normal mode. Press `i`.
- **Letters are being eaten / weird things happen.** You are in Normal mode and your
  keys are commands. `Esc`, then `u` a few times to undo whatever happened.
- **I cannot leave the terminal window.** `Esc Esc`, then `Alt-h`.
- **clangd shows red everywhere in a working project.** No `compile_commands.json`
  yet. `Space m g`. In glslang, also see the note in 3.7 about `build-opt/`.
- **A key does nothing.** `Space f k` and search for it. If it is missing, tell
  Claude. The config lives in `~/.config/nvim/lua/plugins/` (one file per topic).
- **A plugin update broke something.** `:Lazy restore` puts every plugin back to
  the last known-good version.
- **Neovim asks "trust .nvim.lua?"** when opening a repo. Yes. It is the per-repo
  settings file (cccl has one).
- Everything before the 2026-08-24 rebuild is backed up in
  `~/.local/state/nvim-config-backups/2026-08-24/`.

## Part 8 — What is installed (the map)

- `init.lua` loads `lua/config/{options,keymaps,autocmds}` then `lua/plugins/*` through **lazy.nvim** (the plugin manager).
- `plugins/snacks.lua` — the picker (assistant), notifications, big-file guard, `Space o` toggles, buffer delete, open-on-GitHub.
- `plugins/completion.lua` — blink.cmp completion, friendly-snippets, lazydev (Lua docs for the config itself).
- `plugins/lsp.lua` — Mason (installs tools) + clangd (system 22.1.8), rust-analyzer (rustup), lua_ls, glsl_analyzer, clangd extras.
- `plugins/treesitter.lua` — syntax highlighting, indentation, folds; `]f`-style motions; language-aware comments.
- `plugins/editing.lua` — flash, mini.ai / mini.surround / mini.pairs, TODO comments, Trouble panels, editable quickfix, grug-far.
- `plugins/explorer.lua` — the tree (nvim-tree) and oil.
- `plugins/build.lua` — overseer (`:Make`, task list), cmake-tools, neotest + ctest adapter.
- `plugins/debugging.lua` — nvim-dap with gdb and codelldb, the debug UI, inline values.
- `plugins/formatting.lua` — conform; the policy lives in `lua/util/format.lua`.
- `plugins/git.lua` — gitsigns (gutter, hunks), diffview.
- `plugins/workflow.lua` — toggleterm + lazygit, which-key (the Space menu), Copilot, Claude Code, markdown rendering, sessions.
- `plugins/prime.lua` — Harpoon (the wall), Undotree.
- `plugins/ui.lua` — catppuccin-mocha colours, lualine statusline, indent guides, noice (the centred command popup).
- `~/.config/clangd/config.yaml` — CUDA flags for clangd. nvim writes it on first run from `extras/clangd-config.yaml` (it detected your GPU as sm_86 and CUDA at /opt/cuda).
- Copilot login is done. Claude uses your `claude` CLI login. Neovim 0.12.5 is out; update with pacman when it lands in the repo.
