########   JULIA COMMANDS   ########
####################################

# every just command will export the .env variables into the environment
set dotenv-load := true

# Julia package justfile commands list
default:
  @just --list --unsorted

# info for developing/testing this package
info:
  @echo "Optional on setup:"
  @echo "  cd prefect/; just init"
  @echo "  * this intalls poetry package and get prefect local server running"
  @echo
  @echo "Typical dev workflow:"
  @echo "  git checkout -b issue-3/s3-read-write"
  @echo "  just repl; ] instantiate; add PKGS # as neeeded"
  @echo "  * code, write/edit tests *"
  @echo "  just build - this runs the server, tests, doctest, builds docs"
  @echo "  * now debug until its clean *"
  @echo "  git commit 'closes #3: s3 read/write'"
  @echo "  ... git merge"
  @echo "  vim Project.toml -> bump version number, commit."

# pass thru command
run *args:
  {{args}}

# julia --project=. --startup-file=no
repl:
  julia --project=. --startup-file=no

# activate julia package and initiate test/runtests.jl in test environment
test:
  -julia --project=. --startup-file=no --eval 'import Pkg; Pkg.test()'

# workflow reminders when tests are done
docs:
  @echo "Building docs"
  julia --startup-file=no --project=docs --color=yes docs/make.jl
  open ./docs/build/index.html

# launch service from prefect/ folder
launch:
  just --justfile=prefect/justfile launch

# kill service from prefect/ folder
kill:
  just --justfile=prefect/justfile kill

# full cycle of launch server, test, docs, kill server
build: launch test docs kill
