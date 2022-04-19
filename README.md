<div align ="center">

# scalaimport

Scala Importing done the opinionated way. Grouping, Sorting, Merging

[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
[![Neovim](https://img.shields.io/badge/Neovim%200.5+-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io)

</div>

## WIP
This isn't near completed. There's room for improvement,so if you have suggestions or feedback -- make an issue!

## Organize Imports
Organize the imports of your current buffer by using the `organize_imports` command

```lua
lua require("scalaimport").organize_imports()
```

This will organize the top of your file with all imports with no indentations

Before `organize_import`:
```scala
// empty line
package com.austinito

import a.A
import a.B
import a.C

import b._
import b.A
```
After:
```scala
package com.austinito

import a.{A, B, C}
import b.{A, _}
```
