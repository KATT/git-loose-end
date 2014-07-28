program = require 'commander'

program
  .version '0.0.1'
  .option '-b, --base [branch name]', 'Base branch (defaults `develop`)', 'develop'
  .option '-r, --remote [remote]', 'using remote', 'origin'
  .option '-i, --ignore [pattern]', 'ignore branches matching pattern', null
  .option '-p, --path [absolute git path]', 'absolute git path', process.cwd() + '/.git'
  .parse process.argv


console.log "Finding lost branches:"
console.log "  - from remote: `#{program.remote}`"
console.log "  - base branch: `#{program.base}`"
console.log "  - using git folder: `#{program.path}`"
console.log "  - ignoring `#{program.ignore}`" if program.ignore?
