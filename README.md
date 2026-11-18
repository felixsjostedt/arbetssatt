# arbetssatt
Två skills för Claude Code: beskriv ditt arbetssätt efter en fast mall, byt porträtt med någon och se vad ni kan låna av varandra.

## Installera

```
/plugin marketplace add felixsjostedt/arbetssatt
/plugin install arbetssatt@arbetssatt
```

## Använd

Kör `/arbetssatt:portratt` inne i ett repo. Skillen läser repots instruktionsfiler och din
Claude-uppsättning, räknar hur ofta dina skills har startats de senaste 30 dygnen, ställer fyra
frågor och tvättar bort det känsliga. Porträttet hamnar som markdown och fristående HTML i
`~/arbetssatt/`, utanför repot. Skillen skickar aldrig något; det gör du själv.

## Utveckla

`sh test/rakna.test.sh` testar räkningen ur sessionsloggarna.
