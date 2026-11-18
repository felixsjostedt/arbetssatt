#!/bin/sh
# Räknar hur många gånger varje skill och kommando har startats de senaste 30 dygnen,
# ur Claude Codes sessionsloggar. Utdata: "antal namn", en rad per namn, flest först.
# Det enda som lämnar loggarna är antal per namn.
#
# Två sorters rader räknas, inga andra:
#   - personen skrev /namn: en user-rad vars innehåll är en sträng som börjar med <command-
#   - Claude startade en skill: en assistant-rad vars tool_use heter Skill
# Verktygssvar och citat bär samma text, men där är citattecknen escapade eller innehållet
# en lista. Rader som börjar med något annat än "parentUuid" (api-request-blob och
# liknande kopior av samtalet) hoppas över. Varje start räknas en gång, också när en
# återupptagen session har kopierat raden till en ny fil.
set -eu

rot="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects"
[ -d "$rot" ] || { echo "hittar inga sessionsloggar i $rot" >&2; exit 1; }
grans=$(date -u -d '-30 days' +%Y-%m-%dT%H:%M:%S 2>/dev/null || date -u -v-30d +%Y-%m-%dT%H:%M:%S)

find "$rot" -name '*.jsonl' -mtime -31 -exec grep -h -F \
  -e '"type":"user","message":{"role":"user","content":"<command-' \
  -e '"name":"Skill","input":{"skill":"' {} + |
awk -v grans="$grans" '
  # Första "nyckel":"värde" på raden. Nycklar inne i strängar är escapade och träffas inte.
  function varde(nyckel,   s) {
    if (!match($0, "\"" nyckel "\":\"[^\"]+\"")) return ""
    s = substr($0, RSTART, RLENGTH)
    return substr(s, length(nyckel) + 5, RLENGTH - length(nyckel) - 5)
  }
  index($0, "{\"parentUuid\":") != 1 { next }
  varde("timestamp") < grans { next }
  match($0, /"role":"assistant","content":\[\{"type":"tool_use","id":"[^"]+","name":"Skill","input":\{"skill":"[^"]+"/) {
    s = substr($0, RSTART, RLENGTH)
    i = index(s, "\"id\":\""); j = index(s, "\",\"name\":\"Skill\"")
    k = index(s, "{\"skill\":\"")
    rakna(substr(s, i + 6, j - i - 6), substr(s, k + 10, length(s) - k - 10))
    next
  }
  match($0, /"type":"user","message":\{"role":"user","content":"<command-(name>|[^"]*<command-name>)\/[^<]+</) {
    s = substr($0, RSTART, RLENGTH)
    i = index(s, "<command-name>/")
    rakna(varde("uuid"), substr(s, i + 15, length(s) - i - 15))
  }
  function rakna(id, namn) {
    if (id == "" || (id in sett)) return
    sett[id] = 1; antal[namn]++
  }
  END { for (n in antal) print antal[n], n }
' | sort -k1,1nr -k2,2
