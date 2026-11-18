---
name: portratt
description: Skriver ett porträtt av hur du arbetar med Claude Code, efter en fast mall med sex rubriker, som markdown och fristående HTML i ~/arbetssatt/. Läser repots instruktionsfiler, din Claude-uppsättning och antal skillstarter ur sessionsloggarna, ställer fyra frågor och tvättar bort det känsliga innan filen är klar. Skickar aldrig något.
disable-model-invocation: true
---

# Porträtt

Porträttet beskriver hur en person arbetar med Claude Code, i en fil som personen kan skicka
till någon annan. Två porträtt jämförs sedan rubrik för rubrik, och det fungerar bara om båda
har **exakt samma sex rubriker i samma ordning**. Mallen i steg 5 ändras därför aldrig: inga
rubriker döps om, flyttas, läggs till eller tas bort.

Det här gäller hela vägen:

- **Skillen skickar aldrig något.** Den skriver två filer i `~/arbetssatt/` och ändrar ingenting
  annat, varken i repot eller i Claude-uppsättningen. Personen skickar filen själv.
- **Inget gissas.** Allt i porträttet ska gå att peka på i något du har läst eller i personens
  svar. Saknas underlaget står det "finns inte" eller "gick inte att mäta".
- **Läsaren kan inte personens begrepp.** Ett internt ord, ett eget skillnamn eller en
  förkortning förklaras med vad den gör, eller ersätts med det.
- Porträttet skrivs på svenska.

## 1. Starta räkningen

Räkningen tar minuter när loggarna är stora, så starta den först, med Bash och i bakgrunden:

```sh
sh "${CLAUDE_PLUGIN_ROOT}/skills/portratt/rakna.sh"
```

Den skriver `antal namn`, en rad per skill eller kommando som har startats de senaste 30
dygnen, i alla repon på datorn. Skriptet skiljer personens egna `/kommandon` och Claudes
skillanrop från verktygssvar och citat som bär samma text, och räknar varje start en gång.

Öppna aldrig sessionsloggarna själv. Det enda som får följa med ut ur dem är antal per namn,
och bara skriptet räknar dem säkert. Går skriptet inte att köra, avslutas det med fel eller
skriver det ingenting, står det "gick inte att mäta" i porträttet. Skriv aldrig en uppskattning.

## 2. Läs underlaget

Läs medan räkningen går. Notera var varje uppgift kommer ifrån; historiken och reglerna behöver det.

**Repot**

- Alla instruktionsfiler på alla nivåer, inte bara den i roten:
  `git ls-files -- ':(glob)**/CLAUDE.md' ':(glob)**/AGENTS.md'`
- ADR:er (nedskrivna beslut), om de finns. De ligger oftast i en katalog som heter `adr` eller
  `decisions`.
- CI-flödena, till exempel `.github/workflows/`.
- Repots egen `.claude/`-katalog: inställningar, hooks, skills, agenter och kommandon.

**Claude-uppsättningen**

- De globala instruktionerna, `~/.claude/CLAUDE.md`.
- Inställningarna, `~/.claude/settings.json` och repots `.claude/settings.json` och
  `.claude/settings.local.json`: modell, hooks, påslagna plugins och behörigheter.
- Installerade plugins, `~/.claude/plugins/installed_plugins.json`, och deras skills, hooks och
  agenter. Egna skills i `~/.claude/skills/`. Sessionens egen skillista visar vad som är laddat.
- Kopplingar (MCP-servrar) i `~/.claude.json` och repots `.mcp.json`. Läs bara servrarnas namn
  och vad de kopplar till, aldrig deras värden: där ligger ofta nycklar.
- Minnena för det här repot, katalogen `memory/` under repots mapp i `~/.claude/projects/`.
  Inget annat i den mappen.

## 3. Historiken

Stommen är instruktionsfilernas git-historik. Kör, för varje instruktionsfil från steg 2:

```sh
git log --follow --name-status --date=short --format='%h %ad %s' -- <fil>
```

`--follow` följer namnbyten. Filer som har legat på en annan plats eller tagits bort fångas av:

```sh
git log --name-status --date=short --format='%h %ad %s' -- ':(glob)**/CLAUDE.md' ':(glob)**/AGENTS.md' .claude
```

Välj **högst femton vändpunkter**: när en regel, en skill eller en automatik kom till, och
varför. Skälet hämtas ur en ADR där det finns en, annars ur commit-meddelandet eller filen
själv. Står inget skäl nedskrivet, skriv "skälet står inte nedskrivet".

## 4. Frågorna

Ställ de fyra frågorna **en i taget**, i den här ordningen, och vänta på svaret innan nästa:

1. Vad är du mest nöjd med i hur du jobbar?
2. Vad skaver?
3. Vad skulle du helst bli av med?
4. Körs något automatiskt åt dig som inte bor i repot eller i Claude-uppsättningen, till exempel
   schemalagda jobb eller skript?

Behåll personens egna ord. Du får rätta språket, aldrig innebörden.

## 5. Skriv markdown-filen

Förnamnet är första ordet i `git config user.name`, med gemener. Saknas det, fråga personen.
Filen heter `~/arbetssatt/portratt-<förnamn>-<ÅÅÅÅ-MM-DD>.md` med dagens datum och ligger
utanför repot, så att den aldrig följer med i en commit. Skapa katalogen om den saknas. Finns
filen redan, fråga innan den skrivs över.

**Skriv aldrig in lösenord, nycklar eller tokens**, inte ens på väg till tvätten.

Mallen, exakt så här. En rubrik utan innehåll står kvar med "finns inte", eftersom även det är
något jämförelsen behöver veta.

```markdown
Porträtt av <förnamn>, <ÅÅÅÅ-MM-DD>. Skrivet med /arbetssatt:portratt.

## Verktygen

## Flödet

## Reglerna

## Automatiken

## Historiken

## Egen röst
```

Vad varje rubrik bär:

1. **Verktygen**: modellen, plugins, skills, hooks och kopplingar, var och en med vad den gör.
   Varje skill och kommando får sitt antal starter ur räkningen, med fönstret utskrivet
   ("12 starter de senaste 30 dygnen"). En skill som saknas i en lyckad räkning har 0 starter.
   Samma skill kan stå både med och utan pluginets prefix (`plugin:skill` och `skill`); slå
   ihop dem bara när ingen annan skill bär samma namn. Inbyggda kommandon samlas på en rad.
   Misslyckades räkningen står "Antal starter: gick inte att mäta." en gång.
2. **Flödet**: ett ärende från idé till merge, steg för steg, och vem som gör varje steg:
   personen, Claude eller automatiken.
3. **Reglerna**: vad Claude måste göra och vad Claude inte får göra, och varför. Står skälet
   inte nedskrivet, säg det.
4. **Automatiken**: det som sker utan att personen gör något: hooks, CI, schemalagda jobb och
   det personen svarade på fråga 4.
5. **Historiken**: vändpunkterna från steg 3, äldst först, en per rad:
   `- ÅÅÅÅ-MM-DD: vad som kom till, och varför.`
6. **Egen röst**: de fyra frågorna i fetstil, var och en följd av svaret. Inga underrubriker.

## 6. Tvätten

Filen är inte klar förrän tvätten är gjord.

**Lösenord, nycklar och tokens tas alltid bort, utan att du frågar.** Sök i filen med Grep:

```
(sk-[A-Za-z0-9_-]{16,}|gh[pousr]_[A-Za-z0-9]{20,}|github_pat_|AKIA[0-9A-Z]{16}|xox[abprs]-|AIza[0-9A-Za-z_-]{30,}|eyJ[A-Za-z0-9_-]{10,}\.|-----BEGIN [A-Z ]*PRIVATE KEY|(?i:password|passwd|lösenord|secret|token|api[_-]?key)\s*[:=]\s*\S+|[A-Za-z0-9+/_-]{32,})
```

Ta bort varje träff som är en nyckel, ett lösenord eller en token, och sök igen tills inget
sådant träffar. Den sista delen av mönstret fångar alla långa strängar, så en lång sökväg kan
också träffa; den får stå kvar. Leta också själv efter det mönstret inte fångar.

**Allt annat som ser känsligt ut listas**: kundnamn, namn på andra personer, värdnamn,
IP-adresser, e-postadresser, belopp och adresser. Visa listan numrerad, med raden och vad du
tror att det är:

```
1. «…» (e-postadress)
2. «…» (värdnamn)
```

Personen avgör rad för rad: **behåll**, **maska** (ersätt med en platshållare som `<kund>`,
`<värdnamn>` eller `<e-post>`) eller **stryk** (ta bort och skriv om meningen så att den
fortfarande går att läsa). Visa listan även när den är tom, med "inget som ser känsligt ut".

## 7. HTML-filen

Skriv sist `portratt-<förnamn>-<ÅÅÅÅ-MM-DD>.html` bredvid markdown-filen, utifrån den tvättade
markdown-filen och ingenting annat. Skriv den själv; använd inget konverteringsverktyg, eftersom
mottagarens dator inte ska behöva ha något extra installerat.

Filen är fristående och går att öppna utan internet: `<meta charset="utf-8">`, stilen inbäddad
i ett `<style>`-block, inga skript, typsnitt, bilder eller stilmallar utifrån. Rubrikerna är
desamma och i samma ordning som i markdown-filen.

Kontrollera med Grep att HTML-filen inte innehåller `src=`, `<link`, `@import` eller `url(`,
och kör tvättens nyckelsökning på den också.

## 8. Avsluta

Säg var de två filerna ligger, och att personen skickar dem själv när hen vill.
