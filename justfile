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
test: && bump
  -julia --project=. --startup-file=no --eval 'import Pkg; Pkg.test()'

# workflow reminders when tests are done
bump:
  @echo
  @echo "Before tagging remember to update the SemVer version number in Project.toml"
  @echo "NEXT:"
  @echo "    update version"
  @echo "    commit changes"
  @echo "    tag commit and push"
