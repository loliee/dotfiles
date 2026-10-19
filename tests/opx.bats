#!/usr/bin/env bats
# Tests of .config/fish/conf.d/00-opx.lib.fish: op is never called, tests/opx-harness.fish stubs it

bats_require_minimum_version 1.5.0

setup() {
  export OPX_TEST_DIR="$BATS_TEST_TMPDIR"
  mkdir -p "$OPX_TEST_DIR/op" "$OPX_TEST_DIR/edits"
}

opx() {
  fish --no-config -C "source $BATS_TEST_DIRNAME/opx-harness.fish" -c "$1"
}

config() {
  cat >"$OPX_TEST_DIR/config.yml"
}

note() {
  cat >"$OPX_TEST_DIR/op/read"
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
  [ "$(stat -f %Lp "$OPX_TEST_DIR/bar" 2>/dev/null || stat -c %a "$OPX_TEST_DIR/bar")" = "600" ]
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
