fs = require 'fs'

program = require 'commander'
shell = require 'shelljs';

chalk = require 'chalk'

log = (wat) ->
  console.log wat

debug = (wat) ->
  console.log chalk.blue(wat) if program.verbose

warn = (wat) ->
  console.log chalk.yellow(wat)

error = (wat) ->
  console.log chalk.red(wat)

exec = (wat, autoThrow=true) ->
  opts =
    silent: true

  if program.verbose
    opts.silent = false

  debug "exec: `#{wat}` ->"
  ret = shell.exec wat, opts
  if autoThrow
    throw("exec `#{wat}` failed") if ret.code != 0

  return ret.output



program
  .version '0.0.1'
  # .option '-b, --base [branch name]', 'Base branch (defaults `develop`)', 'develop'
  # .option '-r, --remote [remote]', 'using remote', 'origin'
  .option '-p, --path [directory]', 'directory to check', process.cwd()
  .option '-q, --quick', 'skip fetch (for quicker debugging)'
  .option '-v, --verbose', 'verbose output'
  .parse process.argv

log "Finding lost branches:"
# log "  - from remote: `#{program.remote}`"
# log "  - base branch: `#{program.base}`"
log "  - using git folder: `#{program.path}`"
log "  - running it quickly!" if program.quick?
log ""

throw('This script requires git') unless shell.which('git')
throw("`#{program.path}` is not a directory") unless fs.lstatSync(program.path).isDirectory()

shell.cd(program.path)

unless program.quick
  debug "Fetching & pruning branches.. "
  exec("git fetch --all -p")


# Get all the remote branches
remoteBranches = exec 'git branch -r'
remoteBranches = remoteBranches.match(/([a-z0-9\/\-\_]+)/ig)

throw 'No remote branches found' unless remoteBranches.length
debug "remoteBranches: #{remoteBranches}"


astray = []

# Find the latest commit each branch
remoteBranches.forEach (branchName) ->
  latestCommit = exec("git log -r -n1 --pretty=oneline '#{branchName}'")
  latestCommitHash = latestCommit.split(' ')[0]


  # See if this commit is found (or referenced in the log of) the base
  debug "Finding commit #{latestCommit}"
  output = exec "git log -r --pretty=oneline | grep #{latestCommitHash}", false

  astray.push(branchName) unless output


log "Astray branches:"
unless astray.length
  log "  * No astray branches, woohoo!"
else
  astray.forEach (branchName) ->
    log "  * #{branchName}"
