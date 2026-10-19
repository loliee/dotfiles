#!/usr/bin/env bats
# Tests of .config/fish/conf.d/00-opx.lib.fish: op is never called, tests/bin/op stubs it

bats_require_minimum_version 1.5.0

setup() {
  export OPX_TEST_DIR="$BATS_TEST_TMPDIR"
  mkdir -p "$OPX_TEST_DIR/op" "$OPX_TEST_DIR/edits"
}

# Under --no-config fish has no universal variables: the set -U of opx-fetch lands in a global of this process
opx() {
  fish --no-config -C "source $BATS_TEST_DIRNAME/opx-harness.fish" -c "$1"
}

config() {
  cat >"$OPX_TEST_DIR/config.yml"
}

note() {
  cat >"$OPX_TEST_DIR/op/read"
}

document() {
  cat >"$OPX_TEST_DIR/op/document"
}

# __opx_expand_str

@test "expand_str expands HOME" {
  run opx "__opx_expand_str '\$HOME/.secrets/.foo'"
  [ "$status" -eq 0 ]
  [ "$output" = "$HOME/.secrets/.foo" ]
}

@test "expand_str expands ~" {
  run opx "__opx_expand_str '~/.secrets/.foo'"
  [ "$status" -eq 0 ]
  [ "$output" = "$HOME/.secrets/.foo" ]
}

@test "expand_str expands OPX_RAMDISK when set" {
  run opx "__opx_expand_str '\$OPX_RAMDISK/opx/foo'"
  [ "$status" -eq 0 ]
  [ "$output" = "$OPX_TEST_DIR/ramdisk/opx/foo" ]
}

@test "expand_str fails on OPX_RAMDISK when unset" {
  run opx "set -e OPX_RAMDISK; __opx_expand_str '\$OPX_RAMDISK/opx/foo'"
  [ "$status" -eq 1 ]
  [[ $output == *"cannot expand \$OPX_RAMDISK"* ]]
}

@test "expand_str leaves a plain path alone when OPX_RAMDISK is unset" {
  run opx "set -e OPX_RAMDISK; __opx_expand_str '\$HOME/.secrets/.foo'"
  [ "$status" -eq 0 ]
  [ "$output" = "$HOME/.secrets/.foo" ]
}

# __opx_check_config

@test "check_config accepts reference and value entries" {
  config <<-EOF
		secrets:
		  - reference: op://Private/FOO/file
		    dest: $OPX_TEST_DIR/foo
		  - value: plain
		    env_key: FOO
		    dest: $OPX_TEST_DIR/env.fish
		  - value: cGxhaW4K
		    as_file: true
		    base64_decode: true
		    dest: $OPX_TEST_DIR/bar
	EOF
  run opx "__opx_check_config"
  [ "$status" -eq 0 ]
}

@test "check_config accepts a note entry" {
  config <<-EOF
		secrets:
		  - note: "op://Private/INT - .envrc.secrets/notesPlain"
		    dest: $OPX_TEST_DIR/int.secrets
		    symlinks:
		      - $OPX_TEST_DIR/links/int.secrets
	EOF
  run opx "__opx_check_config"
  [ "$status" -eq 0 ]
}

@test "check_config accepts a document entry" {
  config <<-EOF
		secrets:
		  - document: jfslnfjsi827nsj
		    dest: $OPX_TEST_DIR/bar.txt
	EOF
  run opx "__opx_check_config"
  [ "$status" -eq 0 ]
}

@test "check_config accepts tags on entries and hooks" {
  config <<-EOF
		secrets:
		  - value: plain
		    env_key: FOO
		    dest: $OPX_TEST_DIR/env.fish
		    tags: [prd, stg]
		post_fetch_cmds:
		  - echo every env
		  - cmd: echo prd
		    tags: [prd]
	EOF
  run opx "__opx_check_config"
  [ "$status" -eq 0 ]
}

@test "check_config rejects a hook without cmd" {
  config <<-EOF
		secrets: []
		post_fetch_cmds:
		  - tags: [prd]
	EOF
  run opx "__opx_check_config"
  [ "$status" -eq 1 ]
}

@test "check_config rejects a note entry with env_key" {
  config <<-EOF
		secrets:
		  - note: op://Private/FOO/notesPlain
		    env_key: FOO
		    dest: $OPX_TEST_DIR/env.fish
	EOF
  run opx "__opx_check_config"
  [ "$status" -eq 1 ]
}

@test "check_config rejects an entry with neither reference nor value" {
  config <<-EOF
		secrets:
		  - env_key: FOO
		    dest: $OPX_TEST_DIR/env.fish
	EOF
  run opx "__opx_check_config"
  [ "$status" -eq 1 ]
  [[ $output == *"invalid configuration"* ]]
}

@test "check_config rejects an entry with both reference and value" {
  config <<-EOF
		secrets:
		  - reference: op://Private/FOO/password
		    value: plain
		    env_key: FOO
		    dest: $OPX_TEST_DIR/env.fish
	EOF
  run opx "__opx_check_config"
  [ "$status" -eq 1 ]
}

@test "check_config rejects an entry without dest" {
  config <<-EOF
		secrets:
		  - value: plain
		    env_key: FOO
	EOF
  run opx "__opx_check_config"
  [ "$status" -eq 1 ]
}

# __opx_fetch_one_secret

@test "fetch_one_secret writes a value to the env file without op" {
  config <<-EOF
		secrets:
		  - value: plain
		    env_key: FOO
		    dest: $OPX_TEST_DIR/env.fish
	EOF
  run opx "__opx_fetch_one_secret 0 $OPX_TEST_DIR/config.yml"
  [ "$status" -eq 0 ]
  [ "$(cat "$OPX_TEST_DIR/env.fish")" = "set -x FOO plain" ]
  [ ! -f "$OPX_TEST_DIR/op.log" ]
}

@test "fetch_one_secret writes a value as a base64-decoded file" {
  config <<-EOF
		secrets:
		  - value: cGxhaW4K
		    as_file: true
		    base64_decode: true
		    dest: $OPX_TEST_DIR/bar
	EOF
  run opx "__opx_fetch_one_secret 0 $OPX_TEST_DIR/config.yml"
  [ "$status" -eq 0 ]
  [ "$(cat "$OPX_TEST_DIR/bar")" = "plain" ]
  # GNU stat first: its -f is a valid option that succeeds with a wrong value, BSD stat has no -c
  [ "$(stat -c %a "$OPX_TEST_DIR/bar" 2>/dev/null || stat -f %Lp "$OPX_TEST_DIR/bar")" = "600" ]
}

@test "fetch_one_secret refuses a value without env_key or as_file" {
  config <<-EOF
		secrets:
		  - value: plain
		    dest: $OPX_TEST_DIR/bar
	EOF
  run opx "__opx_fetch_one_secret 0 $OPX_TEST_DIR/config.yml"
  [ "$status" -eq 1 ]
  [[ $output == *"'value' needs 'env_key' or 'as_file: true'"* ]]
  [ ! -f "$OPX_TEST_DIR/bar" ]
}

@test "fetch_one_secret reads a reference through op" {
  note <<-EOF
		s3cret
	EOF
  config <<-EOF
		secrets:
		  - reference: op://Private/FOO/password
		    env_key: FOO
		    dest: $OPX_TEST_DIR/env.fish
	EOF
  run opx "__opx_fetch_one_secret 0 $OPX_TEST_DIR/config.yml"
  [ "$status" -eq 0 ]
  [ "$(cat "$OPX_TEST_DIR/env.fish")" = "set -x FOO s3cret" ]
  grep -q "^op read op://Private/FOO/password$" "$OPX_TEST_DIR/op.log"
}

@test "fetch_one_secret hides the Connect and service account vars from op, not from the shell" {
  note <<-EOF
		s3cret
	EOF
  config <<-EOF
		secrets:
		  - reference: op://Private/FOO/password
		    env_key: FOO
		    dest: $OPX_TEST_DIR/env.fish
	EOF
  run opx "set -gx OP_CONNECT_HOST http://connect; set -gx OP_CONNECT_TOKEN t; set -gx OP_SERVICE_ACCOUNT_TOKEN s; \
    __opx_fetch_one_secret 0 $OPX_TEST_DIR/config.yml; echo shell keeps \$OP_CONNECT_HOST \$OP_CONNECT_TOKEN \$OP_SERVICE_ACCOUNT_TOKEN"
  [ "$status" -eq 0 ]
  grep -q "^op read op://Private/FOO/password$" "$OPX_TEST_DIR/op.log"
  [ ! -s "$OPX_TEST_DIR/op.vars" ]
  [[ $output == *"shell keeps http://connect t s"* ]]
}

@test "fetch_one_secret writes a note without its fences and type" {
  note <<-EOF
		\`\`\`yaml
		export FOO=bar
		export BAZ=qux
		\`\`\`
	EOF
  config <<-EOF
		secrets:
		  - note: "op://Private/INT - .envrc.secrets/notesPlain"
		    dest: $OPX_TEST_DIR/int.secrets
	EOF
  run opx "__opx_fetch_one_secret 0 $OPX_TEST_DIR/config.yml"
  [ "$status" -eq 0 ]
  grep -q "^op read op://Private/INT - .envrc.secrets/notesPlain$" "$OPX_TEST_DIR/op.log"
  [ "$(cat "$OPX_TEST_DIR/int.secrets")" = "$(printf 'export FOO=bar\nexport BAZ=qux')" ]
  [ "$(stat -c %a "$OPX_TEST_DIR/int.secrets" 2>/dev/null || stat -f %Lp "$OPX_TEST_DIR/int.secrets")" = "600" ]
}

@test "fetch_one_secret refuses a note reference with forbidden characters" {
  config <<-EOF
		secrets:
		  - note: "op://Private/[INT] .envrc.secrets/notesPlain"
		    dest: $OPX_TEST_DIR/foo
	EOF
  run opx "__opx_fetch_one_secret 0 $OPX_TEST_DIR/config.yml"
  [ "$status" -eq 1 ]
  [[ $output == *"invalid reference"* ]]
  [ ! -f "$OPX_TEST_DIR/op.log" ]
  [ ! -f "$OPX_TEST_DIR/foo" ]
}

@test "fetch_one_secret drops an opening fence without a closing one" {
  note <<-EOF
		\`\`\`
		export FOO=bar
	EOF
  config <<-EOF
		secrets:
		  - note: op://Private/FOO/notesPlain
		    dest: $OPX_TEST_DIR/foo
	EOF
  run opx "__opx_fetch_one_secret 0 $OPX_TEST_DIR/config.yml"
  [ "$status" -eq 0 ]
  [ "$(cat "$OPX_TEST_DIR/foo")" = "export FOO=bar" ]
}

@test "fetch_one_secret drops the fences of a note with blank lines and spaces around them" {
  printf "\n\n\`\`\`fish \nexport FOO=bar\n\`\`\` \n\n" | note
  config <<-EOF
		secrets:
		  - note: op://Private/FOO/notesPlain
		    dest: $OPX_TEST_DIR/foo
	EOF
  run opx "__opx_fetch_one_secret 0 $OPX_TEST_DIR/config.yml"
  [ "$status" -eq 0 ]
  [ "$(cat "$OPX_TEST_DIR/foo")" = "export FOO=bar" ]
}

@test "fetch_one_secret writes a note without fences as it is" {
  note <<-EOF
		export FOO=bar
		export BAZ=qux
	EOF
  config <<-EOF
		secrets:
		  - note: op://Private/FOO/notesPlain
		    dest: $OPX_TEST_DIR/foo
	EOF
  run opx "__opx_fetch_one_secret 0 $OPX_TEST_DIR/config.yml"
  [ "$status" -eq 0 ]
  [ "$(cat "$OPX_TEST_DIR/foo")" = "$(printf 'export FOO=bar\nexport BAZ=qux')" ]
}

@test "fetch_one_secret skips a note file already present" {
  echo "export FOO=old" >"$OPX_TEST_DIR/foo"
  config <<-EOF
		secrets:
		  - note: op://Private/FOO/notesPlain
		    dest: $OPX_TEST_DIR/foo
	EOF
  run opx "__opx_fetch_one_secret 0 $OPX_TEST_DIR/config.yml"
  [ "$status" -eq 0 ]
  [[ $output == *"Note file exists"* ]]
  [ "$(cat "$OPX_TEST_DIR/foo")" = "export FOO=old" ]
  [ ! -f "$OPX_TEST_DIR/op.log" ]
}

@test "fetch_one_secret saves a document through op" {
  document <<-EOF
		doc content
	EOF
  config <<-EOF
		secrets:
		  - document: jfslnfjsi827nsj
		    dest: $OPX_TEST_DIR/bar.txt
	EOF
  run opx "__opx_fetch_one_secret 0 $OPX_TEST_DIR/config.yml"
  [ "$status" -eq 0 ]
  grep -q "^op document get --force jfslnfjsi827nsj -o $OPX_TEST_DIR/bar.txt$" "$OPX_TEST_DIR/op.log"
  [ "$(cat "$OPX_TEST_DIR/bar.txt")" = "doc content" ]
  [ "$(stat -c %a "$OPX_TEST_DIR/bar.txt" 2>/dev/null || stat -f %Lp "$OPX_TEST_DIR/bar.txt")" = "600" ]
}

@test "fetch_one_secret reads a reference without op:// as a document, with a warning" {
  document <<-EOF
		doc content
	EOF
  config <<-EOF
		secrets:
		  - reference: jfslnfjsi827nsj
		    dest: $OPX_TEST_DIR/bar.txt
	EOF
  run opx "__opx_fetch_one_secret 0 $OPX_TEST_DIR/config.yml"
  [ "$status" -eq 0 ]
  [[ $output == *"prefer 'document:'"* ]]
  grep -q "^op document get --force jfslnfjsi827nsj -o $OPX_TEST_DIR/bar.txt$" "$OPX_TEST_DIR/op.log"
  [ "$(cat "$OPX_TEST_DIR/bar.txt")" = "doc content" ]
}

@test "fetch_one_secret skips a document already present" {
  echo "old" >"$OPX_TEST_DIR/bar.txt"
  config <<-EOF
		secrets:
		  - document: jfslnfjsi827nsj
		    dest: $OPX_TEST_DIR/bar.txt
	EOF
  run opx "__opx_fetch_one_secret 0 $OPX_TEST_DIR/config.yml"
  [ "$status" -eq 0 ]
  [[ $output == *"Document jfslnfjsi827nsj exists"* ]]
  [ "$(cat "$OPX_TEST_DIR/bar.txt")" = "old" ]
  [ ! -f "$OPX_TEST_DIR/op.log" ]
}

@test "fetch_one_secret refuses a reference with forbidden characters" {
  config <<-EOF
		secrets:
		  - reference: "op://Private/[INT] foo/password"
		    env_key: FOO
		    dest: $OPX_TEST_DIR/env.fish
	EOF
  run opx "__opx_fetch_one_secret 0 $OPX_TEST_DIR/config.yml"
  [ "$status" -eq 1 ]
  [[ $output == *"invalid reference"* ]]
  [ ! -f "$OPX_TEST_DIR/op.log" ]
  [ ! -f "$OPX_TEST_DIR/env.fish" ]
}

@test "fetch_one_secret skips an env key already present" {
  echo "set -x FOO old" >"$OPX_TEST_DIR/env.fish"
  config <<-EOF
		secrets:
		  - reference: op://Private/FOO/password
		    env_key: FOO
		    dest: $OPX_TEST_DIR/env.fish
	EOF
  run opx "__opx_fetch_one_secret 0 $OPX_TEST_DIR/config.yml"
  [ "$status" -eq 0 ]
  [ "$(cat "$OPX_TEST_DIR/env.fish")" = "set -x FOO old" ]
  [ ! -f "$OPX_TEST_DIR/op.log" ]
}

@test "fetch_one_secret creates the symlinks" {
  config <<-EOF
		secrets:
		  - value: plain
		    as_file: true
		    dest: $OPX_TEST_DIR/bar
		    symlinks:
		      - $OPX_TEST_DIR/links/one
		      - $OPX_TEST_DIR/links/two
	EOF
  run opx "__opx_fetch_one_secret 0 $OPX_TEST_DIR/config.yml"
  [ "$status" -eq 0 ]
  [ "$(readlink "$OPX_TEST_DIR/links/one")" = "$OPX_TEST_DIR/bar" ]
  [ "$(readlink "$OPX_TEST_DIR/links/two")" = "$OPX_TEST_DIR/bar" ]
}

# __opx_fetch_config

@test "fetch_config strips the yaml fences of the note" {
  note <<-EOF
		\`\`\`yaml
		secrets:
		  - value: plain
		    env_key: FOO
		    dest: $OPX_TEST_DIR/env.fish
		\`\`\`
	EOF
  run opx "__opx_fetch_config op://Private/testitem/notesPlain $OPX_TEST_DIR/config.yml"
  [ "$status" -eq 0 ]
  [ "$(yq -r '.secrets[0].env_key' "$OPX_TEST_DIR/config.yml")" = "FOO" ]
  run ! grep -q '```' "$OPX_TEST_DIR/config.yml"
}

@test "fetch_config keeps the previous config when the note is broken YAML" {
  echo "previous: true" >"$OPX_TEST_DIR/config.yml"
  note <<-EOF
		secrets:
		  - value: plain
		   env_key: FOO
	EOF
  run opx "__opx_fetch_config op://Private/testitem/notesPlain $OPX_TEST_DIR/config.yml"
  [ "$status" -eq 1 ]
  [[ $output == *"invalid YAML config file"* ]]
  [ "$(cat "$OPX_TEST_DIR/config.yml")" = "previous: true" ]
}

# opx-edit

edit_note() {
  note <<-EOF
		\`\`\`yaml
		secrets:
		  - reference: op://Private/FOO/password
		    env_key: FOO
		    dest: $OPX_TEST_DIR/env.fish
		\`\`\`
	EOF
  cat >"$OPX_TEST_DIR/op/item.json" <<-EOF
		{
		  "id": "abc123",
		  "title": "testitem",
		  "fields": [
		    { "id": "notesPlain", "purpose": "NOTES", "value": "old" },
		    { "id": "other", "value": "keep" }
		  ]
		}
	EOF
}

@test "opx-edit shows the note without its fences" {
  edit_note
  run opx "set -gx EDITOR cat; opx-edit"
  [ "$status" -eq 0 ]
  [[ $output == *"secrets:"* ]]
  [[ $output != *'```'* ]]
}

@test "opx-edit leaves the note alone when nothing changed" {
  edit_note
  run opx "opx-edit"
  [ "$status" -eq 0 ]
  [[ $output == *"no change"* ]]
  run ! grep -q "^op item edit" "$OPX_TEST_DIR/op.log"
  [ ! -f "$OPX_TEST_DIR/edit.yml" ]
  [ ! -f "$OPX_TEST_DIR/edit.orig.yml" ]
  [ ! -f "$OPX_TEST_DIR/edit.check.yml" ]
}

@test "opx-edit drops a broken edit when asked not to retry" {
  edit_note
  cat >"$OPX_TEST_DIR/edits/1" <<-EOF
		secrets:
		  - reference: op://Private/FOO/password
		   env_key: FOO
	EOF
  run opx "echo n | opx-edit"
  [ "$status" -eq 1 ]
  [[ $output == *"invalid YAML config file"* ]]
  run ! grep -q "^op item edit" "$OPX_TEST_DIR/op.log"
  [ ! -f "$OPX_TEST_DIR/edit.yml" ]
}

@test "opx-edit writes a fixed note back with its fences" {
  edit_note
  cat >"$OPX_TEST_DIR/edits/1" <<-EOF
		secrets:
		  - env_key: FOO
		    dest: $OPX_TEST_DIR/env.fish
	EOF
  cat >"$OPX_TEST_DIR/edits/2" <<-EOF
		secrets:
		  - value: plain
		    env_key: BAR
		    dest: $OPX_TEST_DIR/env.fish
	EOF
  run opx "echo y | opx-edit"
  [ "$status" -eq 0 ]
  [[ $output == *"Required field missing"* ]]
  [[ $output == *"updated, run opx-update to apply"* ]]
  grep -q "^op item edit testitem --vault Private$" "$OPX_TEST_DIR/op.log"
  notes="$(jq -r '.fields[] | select(.id == "notesPlain").value' "$OPX_TEST_DIR/op/edited.json")"
  [ "$(printf '%s\n' "$notes" | head -n 1)" = '```yaml' ]
  [ "$(printf '%s\n' "$notes" | tail -n 1)" = '```' ]
  [ "$(printf '%s\n' "$notes" | sed '1d;$d' | yq -r '.secrets[0].env_key')" = "BAR" ]
  [ "$(jq -r '.fields[] | select(.id == "other").value' "$OPX_TEST_DIR/op/edited.json")" = "keep" ]
  [ ! -f "$OPX_TEST_DIR/edit.yml" ]
}

# opx-fetch and opx-update

fetch_note() {
  note <<-EOF
		secrets:
		  - value: plain
		    env_key: FOO
		    dest: $OPX_TEST_DIR/env.fish
		post_fetch_cmds:
		  - echo hello from the hook
	EOF
}

@test "opx-fetch fetches the secrets then runs the post-fetch hooks" {
  fetch_note
  run opx "opx-fetch; and set -q OPX_INITIALIZED; and echo initialized"
  [ "$status" -eq 0 ]
  [ "$(cat "$OPX_TEST_DIR/env.fish")" = "set -x FOO plain" ]
  [[ $output == *"hello from the hook"* ]]
  [[ $output == *"initialized"* ]]
}

@test "opx-update --no-hooks fetches without the hooks" {
  fetch_note
  run opx "opx-update --no-hooks"
  [ "$status" -eq 0 ]
  [ "$(cat "$OPX_TEST_DIR/env.fish")" = "set -x FOO plain" ]
  [[ $output != *"hello from the hook"* ]]
}

@test "opx-update -H is the short form of --no-hooks" {
  fetch_note
  run opx "opx-update -H"
  [ "$status" -eq 0 ]
  [ "$(cat "$OPX_TEST_DIR/env.fish")" = "set -x FOO plain" ]
  [[ $output != *"hello from the hook"* ]]
}

@test "opx-update refuses an unknown option" {
  run opx "opx-update --bogus"
  [ "$status" -eq 1 ]
  [[ $output == *"opx-update: --bogus: unknown option"* ]]
}

# Environments

env_yaml() {
  cat <<-EOF
		secrets:
		  - value: p
		    env_key: PRD
		    dest: $OPX_TEST_DIR/prd.fish
		    tags: [prd]
		  - value: s
		    env_key: STG
		    dest: $OPX_TEST_DIR/stg.fish
		    tags: [stg]
		  - value: a
		    env_key: ALL
		    dest: $OPX_TEST_DIR/all.fish
		    tags: [all]
		  - value: n
		    env_key: NONE
		    dest: $OPX_TEST_DIR/none.fish
		post_fetch_cmds:
		  - echo fetch hook for every env
		  - cmd: echo fetch hook for prd
		    tags: [prd]
		  - cmd: echo fetch hook for stg
		    tags: [stg]
		  - cmd: echo fetch hook for all
		    tags: [all]
		pre_clean_cmds:
		  - echo clean hook for every env
		  - cmd: echo clean hook for prd
		    tags: [prd]
		  - cmd: echo clean hook for all
		    tags: [all]
	EOF
}

env_files() {
  for f in prd stg all none; do
    echo "set -x X x" >"$OPX_TEST_DIR/$f.fish"
  done
}

@test "opx-update prd fetches the entries tagged prd or all, with their hooks" {
  env_yaml | note
  run opx "opx-update prd"
  [ "$status" -eq 0 ]
  [ -f "$OPX_TEST_DIR/prd.fish" ]
  [ -f "$OPX_TEST_DIR/all.fish" ]
  [ ! -f "$OPX_TEST_DIR/stg.fish" ]
  [ ! -f "$OPX_TEST_DIR/none.fish" ]
  [[ $output == *"fetch hook for every env"* ]]
  [[ $output == *"fetch hook for prd"* ]]
  [[ $output == *"fetch hook for all"* ]]
  [[ $output != *"fetch hook for stg"* ]]
}

@test "opx-update prd stg fetches both environments" {
  env_yaml | note
  run opx "opx-update prd stg"
  [ "$status" -eq 0 ]
  [ -f "$OPX_TEST_DIR/prd.fish" ]
  [ -f "$OPX_TEST_DIR/stg.fish" ]
  [ -f "$OPX_TEST_DIR/all.fish" ]
  [ ! -f "$OPX_TEST_DIR/none.fish" ]
}

@test "opx-update without an environment fetches everything, tags ignored" {
  env_yaml | note
  run opx "opx-update"
  [ "$status" -eq 0 ]
  [ -f "$OPX_TEST_DIR/prd.fish" ]
  [ -f "$OPX_TEST_DIR/stg.fish" ]
  [ -f "$OPX_TEST_DIR/all.fish" ]
  [ -f "$OPX_TEST_DIR/none.fish" ]
  [[ $output == *"fetch hook for every env"* ]]
  [[ $output == *"fetch hook for prd"* ]]
  [[ $output == *"fetch hook for stg"* ]]
  [[ $output == *"fetch hook for all"* ]]
}

@test "opx-update refuses an environment name with other characters" {
  env_yaml | note
  run opx "opx-update 'prd; rm'"
  [ "$status" -eq 1 ]
  [[ $output == *"invalid environment"* ]]
  [ ! -f "$OPX_TEST_DIR/prd.fish" ]
}

@test "opx-clean prd shreds the entries tagged prd only, with the prd hooks only" {
  env_yaml | config
  env_files
  run opx "opx-clean prd"
  [ "$status" -eq 0 ]
  [ ! -f "$OPX_TEST_DIR/prd.fish" ]
  [ -f "$OPX_TEST_DIR/stg.fish" ]
  [ -f "$OPX_TEST_DIR/all.fish" ]
  [ -f "$OPX_TEST_DIR/none.fish" ]
  [[ $output == *"clean hook for prd"* ]]
  [[ $output != *"clean hook for every env"* ]]
  [[ $output != *"clean hook for all"* ]]
}

@test "opx-clean without an environment shreds everything, with every hook" {
  env_yaml | config
  env_files
  run opx "opx-clean"
  [ ! -f "$OPX_TEST_DIR/prd.fish" ]
  [ ! -f "$OPX_TEST_DIR/stg.fish" ]
  [ ! -f "$OPX_TEST_DIR/all.fish" ]
  [ ! -f "$OPX_TEST_DIR/none.fish" ]
  [[ $output == *"clean hook for every env"* ]]
  [[ $output == *"clean hook for prd"* ]]
  [[ $output == *"clean hook for all"* ]]
}

@test "envs lists the tags of the config but all" {
  env_yaml | config
  run opx "__opx_envs"
  [ "$status" -eq 0 ]
  [ "$output" = "$(printf 'prd\nstg')" ]
}

# opx-clean

clean_config() {
  echo "set -x FOO plain" >"$OPX_TEST_DIR/env.fish"
  config <<-EOF
		secrets:
		  - value: plain
		    env_key: FOO
		    dest: $OPX_TEST_DIR/env.fish
		pre_clean_cmds:
		  - echo hello from the pre-clean hook
		post_clean_cmds:
		  - echo hello from the post-clean hook
	EOF
}

# No status check: the final set -eU of opx-clean fails under --no-config, where nothing is universal
@test "opx-clean shreds the secrets between the clean hooks" {
  clean_config
  run opx "opx-clean"
  [ ! -f "$OPX_TEST_DIR/env.fish" ]
  [[ $output == *"hello from the pre-clean hook"* ]]
  [[ $output == *"hello from the post-clean hook"* ]]
}

@test "opx-clean -H shreds the secrets without the hooks" {
  clean_config
  run opx "opx-clean -H"
  [ ! -f "$OPX_TEST_DIR/env.fish" ]
  [[ $output != *"hook"* ]]
}

# __opx-exec

@test "exec runs an allowed command" {
  config <<-EOF
		post_fetch_cmds:
		  - echo hello
	EOF
  run opx "__opx-exec .post_fetch_cmds"
  [ "$status" -eq 0 ]
  [[ $output == *"hello"* ]]
}

@test "exec refuses a command outside the allowlist" {
  config <<-EOF
		post_fetch_cmds:
		  - rm -rf $OPX_TEST_DIR
	EOF
  run opx "__opx-exec .post_fetch_cmds"
  [ "$status" -eq 1 ]
  [[ $output == *"not allowed"* ]]
  [ -d "$OPX_TEST_DIR" ]
}

@test "exec refuses the fetch-only commands in a clean hook" {
  config <<-EOF
		pre_clean_cmds:
		  - sudo dscacheutil -flushcache
	EOF
  run opx "__opx-exec .pre_clean_cmds"
  [ "$status" -eq 1 ]
  [[ $output == *"not allowed"* ]]
}
