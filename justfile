########   JULIA COMMANDS   ########
####################################

# every just command will export the .env variables into the environment
set dotenv-load := true

# Julia package justfile commands list
default:
  @just --list --unsorted

# pass thru command
run *args:
  {{args}}

# julia --project=. --startup-file=no
julia:
  julia --project=. --startup-file=no

# activate julia package and initiate test/runtests.jl in test environment
test:
  -julia --project=. --startup-file=no --eval 'import Pkg; Pkg.test()'

# workflow reminders when tests are done
docs:
  @echo "Building docs"
  julia --startup-file=no --project=docs --color=yes docs/make.jl
  open ./docs/build/index.html

launch:
  just --justfile=prefect/justfile launch

kill:
  just --justfile=prefect/justfile kill

build: launch test docs kill
