# KOTOR 2 Console Reference

A console command and item-code reference for **Star Wars: Knights of the Old Republic II — The Sith Lords**. Item mappings were checked against installed Steam game data, including the installed TSLRCM item overrides.

## Files

- [Console reference](Kotor%202%20Console%20Commands.txt): commands, item spawn codes, and warp destinations.
- [Verification report](Verification%20report.md): findings, corrections, and verification limits.
- [Command audit](console-command-audit.csv): checks for each entry in the reference.
- [Item index](installed-item-index.csv): global item codes and names extracted from the installed game.
- [Verification script](verify-items.ps1): reads game resources and regenerates the audit and item index.
- [Reference generator](repair-reference.ps1): rebuilds the TXT reference from the extracted resources.

## Using the reference

Add `EnableCheats=1` under `[Game Options]` in `swkotor2.ini`. In game, open the invisible console with the console key (usually backtick or tilde), type a command, and press Enter. For example:

```text
giveitem w_blaste_02
```

This gives an Ion Blaster. Replace bracketed placeholders in the reference with actual values; do not type the brackets.

## Verification

The scripts require Windows PowerShell and a local game installation. Their default paths target the Steam installation and TSLRCM Workshop folder used for this reference; adjust the paths for your setup.

This reference covers selected categories, not every game resource. Resource mappings were verified, but commands were not playtested. Mods can change mappings, and warping can bypass quest triggers, so keep a separate save.
