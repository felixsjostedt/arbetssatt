#!/bin/sh
# Kör: sh test/rakna.test.sh. Bygger en låtsashemkatalog med äkta starter och brus,
# och kräver att bara de äkta räknas, en gång var.
set -eu
hem=$(mktemp -d)
trap 'rm -rf "$hem"' EXIT
mkdir -p "$hem/projects/p/s/subagents"
ny='"timestamp":"2999-01-01T00:00:00.000Z"'
gammal='"timestamp":"2000-01-01T00:00:00.000Z"'

cat > "$hem/projects/p/a.jsonl" <<EOF
{"parentUuid":null,"isSidechain":false,"type":"user","message":{"role":"user","content":"<command-name>/x:ett</command-name>\n<command-message>x:ett</command-message>\n<command-args></command-args>"},"uuid":"u1",$ny}
{"parentUuid":"u1","isSidechain":false,"type":"user","message":{"role":"user","content":"<command-message>x:ett</command-message>\n<command-name>/x:ett</command-name>\n<command-args>\"citat\"</command-args>"},"uuid":"u2",$ny}
{"parentUuid":"u2","isSidechain":false,"type":"user","message":{"role":"user","content":"<command-name>/x:ett</command-name>"},"uuid":"u3",$gammal}
{"parentUuid":"u3","isSidechain":false,"message":{"model":"m","id":"msg_1","type":"message","role":"assistant","content":[{"type":"tool_use","id":"toolu_1","name":"Skill","input":{"skill":"x:tva"},"caller":{"type":"direct"}}]},"type":"assistant","uuid":"u4",$ny}
{"parentUuid":"u4","isSidechain":false,"type":"user","message":{"role":"user","content":[{"tool_use_id":"toolu_1","type":"tool_result","content":"<command-name>/x:ett</command-name> \"name\":\"Skill\",\"input\":{\"skill\":\"x:tva\""}]},"uuid":"u5",$ny}
{"parentUuid":"u5","isSidechain":false,"message":{"model":"m","id":"msg_2","type":"message","role":"assistant","content":[{"type":"tool_use","id":"toolu_2","name":"Bash","input":{"command":"grep '\"name\":\"Skill\",\"input\":{\"skill\":\"x:tva\"'"}}]},"type":"assistant","uuid":"u6",$ny}
{"type":"api-request-blob","sessionId":"s","message":{"role":"assistant","content":[{"type":"tool_use","id":"toolu_9","name":"Skill","input":{"skill":"x:tva"}}]},$ny}
{"type":"api-request-blob","sessionId":"s","message":{"role":"user","content":"<command-name>/x:ett</command-name>"},$ny}
EOF
# En återupptagen session kopierar raderna; en subagent startar samma skill på nytt.
head -n 1 "$hem/projects/p/a.jsonl" > "$hem/projects/p/b.jsonl"
sed -n 4p "$hem/projects/p/a.jsonl" >> "$hem/projects/p/b.jsonl"
sed -n 4p "$hem/projects/p/a.jsonl" | sed 's/toolu_1/toolu_3/' > "$hem/projects/p/s/subagents/agent-1.jsonl"

fatt=$(CLAUDE_CONFIG_DIR="$hem" sh "$(dirname "$0")/../skills/portratt/rakna.sh")
vantat='2 x:ett
2 x:tva'
[ "$fatt" = "$vantat" ] || { printf 'FEL\nväntat:\n%s\nfått:\n%s\n' "$vantat" "$fatt"; exit 1; }
echo OK
