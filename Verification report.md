# KOTOR 2 console reference audit

Updated 2026-10-21: the TXT has now been corrected and expanded with all 30 global armor underlays (Mark I-V) and all 30 global armor overlays (Mark I-IV). The regenerated audit CSV reports 616 matching item mappings, 50 matching warp destinations, and 30 command rows whose names are present in the executable. No item or warp lookup failures remain. Commands have not been tested in a running game.

The findings and original TXT line numbers below describe the version before correction. The CSV now describes the corrected file; its line numbers supersede these historical references. GitHub and Git history have not been changed.

## Original audit findings

Checked 2026-10-21. The original cheat sheet was substantially inaccurate and incomplete.

All 455 giveitem entries were compared with installed global item resources:

| Result | Entries |
| --- | ---: |
| Correct mapping, including equivalent wording | 86 |
| Existing code with an incorrect or misleading label | 324 |
| Code absent from the global templates checked | 45 |

[The complete audit CSV](console-command-audit.csv) contains all listed item, command, and warp rows with original line numbers, claimed descriptions, extracted names, and results. Its Actual column identifies what the existing code points to. [The installed item index](installed-item-index.csv) provides additional codes. [The script](verify-items.ps1) reproduces the extraction and comparison.

## Examples of incorrect mappings

| TXT line | Code | TXT claim | Actual mapping |
| --- | --- | --- | --- |
| 69 | g_w_lghtsbr07 | Viridian Lightsaber | Bronze Lightsaber |
| 70 | g_w_lghtsbr08 | Silver Lightsaber | Orange Lightsaber |
| 107 | u_l_colo_02 | Red crystal | Green crystal |
| 120 | u_l_crys_01 | Ankarres Sapphire | Adegan crystal |
| 138 | u_l_crys_19 | Qixoni crystal | Upari crystal |
| 164 | a_robe_08 | Arca Jeth's Robe | Jedi Robe |
| 278 | u_l_lens_01 | Vibration Lens Mark I | Synthesized Kunda Lens |
| 313 | w_blaste_02 | Heavy Blaster Pistol | Ion Blaster |
| 332 | w_blaste_21 | Mira's Wrist Rocket Launcher | Aratech Ionmaster |
| 333 | w_blaste_22 | Hanharr's Bowcaster Pistol | Onasi Blaster |
| 360 | w_melee_01 | Vibroblade | Short Sword |
| 579 | e_imp4_04 | Bao-Dur's Cybernetic Arm | Enhancement D-Package |
| 703 | g_i_pazcard_020 | Flip 3 & 4 Card | Pazaak Card Double |

The headgear codes 01-26 and ordinary Pazaak cards 001-018 are correctly mapped; equivalent formatting is not counted as an error.

## Codes absent from global templates

- g_w_lghtsbr06, g_w_shortsbr06, g_w_dblsbr006: orange uses suffix 08/008; suffix 11/011 is Viridian.
- All ten g_w_grenade01-10 entries: actual codes include g_w_fraggren01 (Frag), g_w_stungren01 (Concussion), g_w_iongren01 (Ion), g_w_sonicgren01 (Sonic), g_w_firegren001 (Plasma), g_w_poisngren01 (Poison), g_w_cryobgren001 (CryoBan), g_w_adhsvgren001 (Adhesive), and g_w_thermldet01 (Thermal Detonator). No globally available Flashbang Grenade was found.
- All fifteen g_i_mine01-15 entries: actual mines use g_i_trapkit001-025 in a different order. For example, 001 is Minor Flash Mine and 004 is Minor Frag Mine.
- a_robe_31-34, a_gloves_03, a_shield_08-11, a_armband_01-05, and g_i_pazcard_024-026.

Absence means absent from the checked base global resources and override folders. Module-local templates and other mods may contain additional names.

## Commands

All 32 command rows were checked for exact null-delimited tokens in the installed executable. Sixteen rows match tokens; sixteen do not. Token presence corroborates the name, not complete behavior.

- Lines 28-33: setattribute is absent. Use setstrength, setdexterity, setconstitution, setintelligence, setwisdom, or setcharisma followed by the desired value.
- Lines 36-43: setskill is absent. Use setcomputeruse, setdemolitions, setstealth, setawareness, setpersuade, setrepair, setsecurity, or settreatinjury followed by the desired value.
- Line 49: givesitharmor is absent; givesitharmour is present. This does not validate the Taris quest description in KOTOR 2.
- Line 18: dance_dance_revan is absent; its claimed ending transformation is unverified. A secondary cheat site repeats the claim, so it should not be treated as established solely from that source.
- Line 22: documented syntax is addlevel without a level-count argument. The claim that a number adds that many levels is unsupported by the checked references. addexp accepts an XP amount.
- Line 16: whereami is documented to print coordinates to the console, which is invisible in KOTOR 2. Writing to logs was not verified.
- Lines 46-48: references describe givemed as 100 medkits, giverepair as 100 advanced repair kits, and givecomspikes as 100 computer spikes.

The individual attribute/skill command names and givesitharmour were independently found in the executable. No commands were executed in a running game; numeric limits, targeting, and side effects remain untested.

## Warps

All 45 listed warps were checked against base module filenames and ARE display names. Three module codes are absent, ten descriptions are wrong or misleading, and the other 32 identify the corresponding area using descriptive wording.

| TXT line(s) | Entry | Correction |
| --- | --- | --- |
| 718 | 004EBO / Red Cliff | Red Eclipse invasion variant |
| 727-729 | 151PER, 152PER, 153PER | Use 151HAR, 152HAR, 153HAR for the Harbinger |
| 732 | 201TEL / Entertainment | Dock Module |
| 733 | 202TEL / Cantina | Entertainment; separate Cantina is 207TEL |
| 735 | 204TEL / Residential East | Residential 082 West |
| 736 | 221TEL / Underground Base | Citadel Station Suburban; Underground Base is 232TEL |
| 737 | 222TEL / Base tunnels | Entertainment Module 081 |
| 743 | 602DAN / Administrative Plains | Khoonda interior |
| 757 | 402DXN / Mandalorian camp | Jungle; camp/Mandalorian Ruins is 403DXN |
| 762 | 511OND / Royal Palace | Merchant Quarter invasion; Royal Palace is 506OND |
| 767 | 711KOR / Shyrack Cave / Tomb | Secret Tomb; Shyrack Cave is 710KOR |

601DAN is more precisely Khoonda Plains. Shared module display names do not encode every story variant. Variant labels were cross-checked with the linked warp reference. Warps were not executed or tested for quest progression.

## Completeness

The claims of complete sequential ranges are false. Omitted codes in the categories already covered include w_blaste_26-30, w_brifle_16-30, g_w_shortsbr11, g_w_dblsbr011, u_l_emit_12-13, u_l_lens_09-13, u_l_cell_10-13, and u_m_grip_10-15. Missing u_l_crys_21, u_l_crys_21x, and u_l_crys_x23 are Solari, Qixoni, and Hurrikaine respectively.

## Evidence and limits

Primary evidence came directly from the installed Steam game under C:\Program Files (x86)\Steam\steamapps\common\Knights of the Old Republic II:

1. Resolve global UTI templates through chitin.key and indexed BIF entries.
2. Read GFF LocalizedName fields and resolve dialog.tlk strings.
3. Remove internal {...} sorting/debug prefixes for comparison; retain originals in the item index.
4. Resolve saber colors through upcrystals.2da because saber display names omit color.
5. Read base RIM module filenames and ARE Name fields.
6. Check exact command tokens in swkotor2.exe.

The game override folder and installed Workshop folder 485537937 (TSLRCM) were also checked. The script assumes that Workshop override layer applies when present; runtime activation was not independently verified. The index contains 994 distinct global item codes and 82 base RIM modules. This audit does not enumerate module-local UTI templates, unpack Workshop module replacements, inspect every mod subscription, or run the game.

Secondary references cross-check command syntax and story-specific module labels:

- [Commands.gg command reference](https://commands.gg/kotor)
- [Commands.gg warp reference](https://commands.gg/kotor/warp)
- [LiveAbout item reference](https://www.liveabout.com/kotor-2-sith-item-codes-pc-3401978)

The web item reference has errors of its own, including its regular lightsaber 08 label, so extracted game data takes precedence. Game files were left unchanged. The TXT was subsequently corrected as described at the top of this report.
