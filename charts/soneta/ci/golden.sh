#!/usr/bin/env bash
# Golden and behaviour checks for the layered envs/volumes/args values.
# usage: ci/golden.sh <base-chart-dir> <new-chart-dir>   (base = previous release, e.g. git worktree of 0.6.0)
# Needs helm on PATH. Exits non-zero if any check fails.
set -u
BASE=${1:?base chart dir}
NEW=${2:?new chart dir}
V="$(cd "$(dirname "$0")" && pwd)/values"
OUT=$(mktemp -d)
trap 'rm -rf "$OUT"' EXIT
FAILS=0
# The baseline is rendered with the NEW chart version: the version label changes the length of the
# embedded pod text, which moves YAML line folds. Everything else must be byte-identical.
NEWV=$(sed -n 's/^version: //p' "$NEW/Chart.yaml")
mkdir -p "$OUT/basechart" && cp -r "$BASE/." "$OUT/basechart/" && sed -i "s/^version: .*/version: $NEWV/" "$OUT/basechart/Chart.yaml"
BASE="$OUT/basechart"
pass() { echo "PASS $*"; }
fail() { echo "FAIL $*"; FAILS=$((FAILS + 1)); }

# render CHART NAME [helm template args...] -> $OUT/NAME.yaml, $OUT/NAME.err; returns helm's exit code
render() {
  local chart=$1 name=$2
  shift 2
  helm template rel "$chart" "$@" >"$OUT/$name.yaml" 2>"$OUT/$name.err"
}

# has FILE TEXT LABEL / hasnot FILE TEXT LABEL: fixed-string checks on a rendered file
rendered() { [ -s "$1" ] || { fail "$2: render produced no output"; return 1; }; }
has() { rendered "$1" "$3" || return; if grep -qF -- "$2" "$1"; then pass "$3"; else fail "$3 (missing: $2)"; fi; }
hasnot() { rendered "$1" "$3" || return; if grep -qF -- "$2" "$1"; then fail "$3 (unexpected: $2)"; else pass "$3"; fi; }

# golden NAME [helm args...]: base and new render the same legacy values, identical output, empty stderr from new
golden() {
  local name=$1
  shift
  render "$BASE" "base-$name" "$@"
  local b=$?
  render "$NEW" "new-$name" "$@"
  local n=$?
  if [ $b -ne 0 ] || [ $n -ne 0 ]; then
    fail "golden $name: helm exit base=$b new=$n"
    return
  fi
  if ! diff "$OUT/base-$name.yaml" "$OUT/new-$name.yaml" >"$OUT/diff-$name.txt"; then
    fail "golden $name: output differs"
    head -40 "$OUT/diff-$name.txt"
    return
  fi
  if [ -s "$OUT/new-$name.err" ]; then
    fail "golden $name: new chart wrote to stderr"
    head -5 "$OUT/new-$name.err"
    return
  fi
  pass "golden $name ($(wc -l <"$OUT/new-$name.yaml") lines identical, stderr empty)"
}

golden defaults -f "$V/base.yaml"
golden legacy-full -f "$V/base.yaml" -f "$V/legacy-full.yaml"
golden orchestrator -f "$V/base.yaml" -f "$V/legacy-full.yaml" -f "$V/orch.yaml"
golden orchestrator-inprocess-off -f "$V/base.yaml" -f "$V/legacy-full.yaml" -f "$V/orch.yaml" -f "$V/orch-out.yaml"
golden framework -f "$V/base.yaml" -f "$V/legacy-full.yaml" --set image.tag=2610.0.1-framework --set image.webTagPostfix= --set image.serverTagPostfix=
golden admin -f "$V/base.yaml" -f "$V/legacy-full.yaml" --set adminMode=true

# map equivalence: legacy list form and map form of the same (sorted, duplicate-free) values render identically
render "$BASE" eq-base-legacy -f "$V/base.yaml" -f "$V/legacy-eq.yaml" -f "$V/orch.yaml"
render "$NEW" eq-new-map -f "$V/base.yaml" -f "$V/map-eq.yaml" -f "$V/orch.yaml"
render "$NEW" eq-new-legacy -f "$V/base.yaml" -f "$V/legacy-eq.yaml" -f "$V/orch.yaml"
if diff "$OUT/eq-base-legacy.yaml" "$OUT/eq-new-map.yaml" >"$OUT/eq.diff" && diff "$OUT/eq-new-legacy.yaml" "$OUT/eq-new-map.yaml" >/dev/null; then
  pass "map equivalence (base list == new map == new list)"
else
  fail "map equivalence differs"; head -40 "$OUT/eq.diff"
fi

# layering: server and web deployments (-s renders one template)
render "$NEW" lay-server -f "$V/base.yaml" -f "$V/layer-base.yaml" -f "$V/layer-overlay.yaml" -s templates/deployment-server.yaml
render "$NEW" lay-web -f "$V/base.yaml" -f "$V/layer-base.yaml" -f "$V/layer-overlay.yaml" -s templates/deployment-web.yaml
S="$OUT/lay-server.yaml"; W="$OUT/lay-web.yaml"
has "$S" "value: UTC" "server: same-level-level override from later file wins (TZ=UTC)"
hasnot "$S" "Europe/Warsaw" "server: overridden all-level TZ is gone"
has "$S" "name: KEEP" "server: untouched all-level item kept"
hasnot "$S" "name: GONE" "server: cross-level null deletes all-level item"
has "$S" "name: SAME" "server: overlay with equal value replaces in place"
has "$S" "name: NEWSRV" "server: new key added"
hasnot "$S" "name: SRVONLY" "server: same-level null deletes item"
hasnot "$S" "name: DELME" "server: same-level null deletes item (2)"
hasnot "$S" "--a=1" "server: args null deletes all-level arg"
has "$S" "--b" "server: args kept from server level"
has "$S" "--c" "server: args added"
has "$S" 'mountPath: "/auth-server"' "server: volume mountPath replaced (shallow)"
has "$S" "emptyDir" "server: volume spec kept when only mountPath overridden"
hasnot "$S" "/logs" "server: null deletes volume mount"
has "$W" "Europe/Warsaw" "web: all-level TZ untouched by server overrides"
hasnot "$W" "name: GONE" "web: cross-level delete applies to all components"
has "$W" "--a=1" "web: all-level arg kept"
has "$W" "/logs" "web: volume kept where not deleted"
has "$W" 'mountPath: "/auth"' "web: all-level volume mount"
hasnot "$W" "/auth-server" "web: server-level volume override does not leak"

# list base + map overlay at another level: upsert/delete by name
render "$NEW" mixed -f "$V/base.yaml" -f "$V/list-base-map-overlay.yaml" -f "$V/list-base-map-overlay2.yaml" -s templates/deployment-server.yaml
has "$OUT/mixed.yaml" "value: UTC" "list base + map overlay (other level): upserts TZ"
hasnot "$OUT/mixed.yaml" "Europe/Warsaw" "list base + map overlay: replaced legacy item"
hasnot "$OUT/mixed.yaml" "name: KEEP" "list base + map overlay: null deletes legacy item"

# list base + map at the SAME level: Helm replaces the list wholesale
render "$NEW" samelevel -f "$V/base.yaml" -f "$V/list-base-map-overlay.yaml" -f "$V/list-same-level.yaml" -s templates/deployment-server.yaml
has "$OUT/samelevel.yaml" "name: X" "same level list->map: map applies"
hasnot "$OUT/samelevel.yaml" "name: TZ" "same level list->map: list replaced wholesale (documented)"

# --set forms
render "$NEW" setforms -f "$V/base.yaml" --set envs.all.TZ=UTC --set 'envs.all.My\.Key=v' --set envs.all.NUM=5 --set-string envs.all.STR=5 --set envs.server.TZ=null --set-json 'envs.web.J={"valueFrom":{"fieldRef":{"fieldPath":"metadata.name"}}}' -s templates/deployment-server.yaml
hasnot "$OUT/setforms.yaml" "name: TZ" "--set null deletes inherited env"
has "$OUT/setforms.yaml" "name: My.Key" "--set dotted key kept"
has "$OUT/setforms.yaml" 'value: "5"' "--set number becomes quoted string"
has "$OUT/setforms.yaml" 'value: "5"' "--set-string value"
render "$NEW" setforms-web -f "$V/base.yaml" --set envs.all.TZ=UTC --set-json 'envs.web.J={"valueFrom":{"fieldRef":{"fieldPath":"metadata.name"}}}' -s templates/deployment-web.yaml
has "$OUT/setforms-web.yaml" "name: J" "--set-json valueFrom"

# numbers and empty strings in map form
render "$NEW" numbers -f "$V/base.yaml" -f "$V/map-eq.yaml" -s templates/deployment-server.yaml
has "$OUT/numbers.yaml" 'value: "1000000"' "numeric map value keeps digits (no 1e+06)"
has "$OUT/numbers.yaml" 'value: ""' "empty string stays an empty value"

# negative cases
render "$NEW" neg-valuefrom -f "$V/base.yaml" --set-json 'envs.all.FROM={"value":"x","valueFrom":{"fieldRef":{"fieldPath":"metadata.name"}}}'
if [ $? -ne 0 ] && grep -q "both value and valueFrom" "$OUT/neg-valuefrom.err"; then pass "negative: value + valueFrom fails"; else fail "negative: value + valueFrom should fail"; fi
render "$NEW" neg-scalar --set envs.all=oops
if [ $? -ne 0 ] && grep -q "envs.all" "$OUT/neg-scalar.err"; then pass "negative: scalar level fails (schema)"; else fail "negative: scalar level should fail"; fi
render "$NEW" neg-scalar-tpl --skip-schema-validation --set envs.all=oops
if [ $? -ne 0 ] && grep -q "envs.all must be a map (preferred) or a list (deprecated)" "$OUT/neg-scalar-tpl.err"; then pass "negative: scalar level fails (template message)"; else fail "negative: template message missing"; fi

# NOTES.txt warning only for non-empty list levels
helm install rel "$NEW" --dry-run=client -f "$V/base.yaml" -f "$V/legacy-full.yaml" >"$OUT/notes-legacy.txt" 2>&1
helm install rel "$NEW" --dry-run=client -f "$V/base.yaml" -f "$V/map-eq.yaml" >"$OUT/notes-map.txt" 2>&1
has "$OUT/notes-legacy.txt" "WARNING: deprecated list values found" "NOTES warns for legacy lists"
hasnot "$OUT/notes-map.txt" "WARNING: deprecated list values" "NOTES silent for maps"

# secrets, pvcs, tolerations: the map form renders exactly like the list form; null deletes a single item
render "$NEW" sec-legacy -f "$V/base.yaml" -f "$V/sec-legacy.yaml"
render "$NEW" sec-map -f "$V/base.yaml" -f "$V/sec-map.yaml"
if diff "$OUT/sec-legacy.yaml" "$OUT/sec-map.yaml" >"$OUT/sec.diff"; then pass "secrets/pvcs/tolerations: map == list"; else fail "secrets/pvcs/tolerations: map differs from list"; head -20 "$OUT/sec.diff"; fi
render "$NEW" sec-null -f "$V/base.yaml" -f "$V/sec-map.yaml" -f "$V/sec-null.yaml"
hasnot "$OUT/sec-null.yaml" "name: empty-secret" "null deletes a secret"
hasnot "$OUT/sec-null.yaml" "name: extra" "null deletes a pvc"
hasnot "$OUT/sec-null.yaml" "tolerationSeconds: 300" "null deletes a toleration"
has "$OUT/sec-null.yaml" "name: afs-secret" "secret kept when another is deleted"
has "$OUT/sec-null.yaml" "effect: NoSchedule" "dedicated toleration kept"
render "$NEW" sec-setfmt -f "$V/base.yaml" --set secrets.afs.data.k=v --set-json 'tolerations.t1={"key":"a","operator":"Exists"}' --set pvcs.p.spec.resources.requests.storage=1Gi --set-json 'pvcs.p.spec.accessModes=["ReadWriteOnce"]'
has "$OUT/sec-setfmt.yaml" "name: afs" "--set secret map entry"
has "$OUT/sec-setfmt.yaml" "k: dg==" "--set secret data value (base64 of v)"
has "$OUT/sec-setfmt.yaml" "key: a" "--set-json toleration"
render "$NEW" neg-secrets --skip-schema-validation --set secrets=oops
if [ $? -ne 0 ] && grep -q "secrets must be a map (preferred) or a list (deprecated)" "$OUT/neg-secrets.err"; then pass "negative: scalar secrets fails"; else fail "negative: scalar secrets should fail"; fi
render "$NEW" neg-tol --skip-schema-validation --set tolerations=oops
if [ $? -ne 0 ] && grep -q "tolerations must be a map" "$OUT/neg-tol.err"; then pass "negative: scalar tolerations fails"; else fail "negative: scalar tolerations should fail"; fi

# nodeSelector (intentional fix, shown separately from the golden set): labels are rendered as the pod's nodeSelector,
# not the whole root values dump that 0.6.0 emitted (`toYaml $` inside `with`)
render "$NEW" nodeselector -f "$V/base.yaml" --set nodeSelector.disktype=ssd -s templates/deployment-server.yaml
has "$OUT/nodeselector.yaml" "disktype: ssd" "nodeSelector map is rendered on pods"
hasnot "$OUT/nodeselector.yaml" "dblist:" "nodeSelector renders labels only (no root values dump)"

helm install rel "$NEW" --dry-run=client -f "$V/base.yaml" -f "$V/sec-legacy.yaml" >"$OUT/notes-sec.txt" 2>&1
helm install rel "$NEW" --dry-run=client -f "$V/base.yaml" -f "$V/sec-map.yaml" >"$OUT/notes-secmap.txt" 2>&1
has "$OUT/notes-sec.txt" "deprecated list values found: secrets, pvcs, tolerations" "NOTES warns for legacy secrets/pvcs/tolerations"
hasnot "$OUT/notes-secmap.txt" "WARNING: deprecated" "NOTES silent for secrets/pvcs/tolerations maps"

# lint
# the chart requires dblist (or listaBazDanych) in every render, so every lint run includes base.yaml
for f in "$V/base.yaml" "$V/legacy-full.yaml" "$V/map-eq.yaml"; do
  if helm lint --strict "$NEW" -f "$V/base.yaml" -f "$f" >"$OUT/lint.txt" 2>&1; then pass "helm lint --strict $(basename "$f")"; else fail "helm lint --strict $(basename "$f")"; cat "$OUT/lint.txt"; fi
done
if helm lint --strict "$NEW" -f "$V/base.yaml" -f "$V/layer-base.yaml" -f "$V/layer-overlay.yaml" >"$OUT/lint.txt" 2>&1; then pass "helm lint --strict layering"; else fail "helm lint --strict layering"; cat "$OUT/lint.txt"; fi

echo "== $FAILS failing check(s)"
[ "$FAILS" -eq 0 ]
