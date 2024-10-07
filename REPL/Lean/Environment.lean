import REPL.Util.Pickle
import REPL.Lean.Replay

open System (FilePath)

namespace Lean.Environment

/--
Pickle an `Environment` to disk.

We only store:
* the list of imports
* the new constants from `Environment.constants`
and when unpickling, we build a fresh `Environment` from the imports,
and then add the new constants.
-/
def pickle (env : Environment) (path : FilePath) : IO Unit :=
  _root_.pickle path (env.header.imports, env.constants.map₂)

unsafe def unpickleAux (path : FilePath) : IO (Environment × CompactedRegion) := do
  let ((imports, map₂), region) ← _root_.unpickle (Array Import × PHashMap Name ConstantInfo) path
  let env ← importModules imports {} 0
  return (← env.replay (HashMap.ofList map₂.toList), region)

/--
Unpickle an `Environment` from disk.

We construct a fresh `Environment` with the relevant imports,
and then replace the new constants.
-/
@[implemented_by unpickleAux]
opaque unpickle (path : FilePath) : IO (Environment × CompactedRegion)

end Lean.Environment
