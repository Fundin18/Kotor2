$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'verify-items.ps1') | Out-Null
$out = [Collections.Generic.List[string]]::new()
function Add([string]$Text='') { $out.Add($Text) }
function Section([string]$Title) {
    Add; Add ('='*68); Add $Title; Add ('='*68)
}
function ItemGroup([string]$Title,[string]$Pattern) {
    Section $Title
    foreach ($entry in $items.Values | Where-Object Code -match $Pattern | Sort-Object Code) {
        $name=($entry.Name -replace '^\{[^}]+\}','').Trim()
        if ($saberColors.ContainsKey($entry.Code)) { $name=$saberColors[$entry.Code]+' '+$name }
        Add ('{0,-29} - {1}' -f ('giveitem '+$entry.Code),$name)
    }
}
Add ('='*68); Add 'KOTOR 2 CONSOLE COMMANDS & ITEM REFERENCE'; Add ('='*68)
Add 'Item mappings checked against installed Steam game resources, 2026-10-21.'
Add 'Includes the installed TSLRCM global item override layer.'
Add 'Selected item categories and destinations; not every game resource.'
Add 'Resource mappings verified; commands have not been playtested.'
Add
Add 'ENABLE AND USE THE CONSOLE'
Add 'In swkotor2.ini, add EnableCheats=1 under [Game Options].'
Add 'Press the console key (` or ~ on a US keyboard); it is invisible.'
Add 'Type the command and press Enter. Do not type placeholder brackets.'
Add 'Example: giveitem w_blaste_02 gives an Ion Blaster.'
Add 'For commands below, replace [value] or [amount] with a number.'
Section 'CORE ENGINE & UTILITY COMMANDS'
Add 'heal                      - Restore health and Force points'
Add 'invulnerability           - Toggle invulnerability'
Add 'infiniteuses              - Toggle unlimited uses for limited-use items'
Add 'turbo                     - Toggle faster character movement'
Add 'revealmap                 - Reveal the current area map'
Add 'bright                    - Toggle full brightness'
Add 'whereami                  - Output coordinates to the invisible console'
Add 'restartminigame           - Restart the current minigame'
Section 'CHARACTER PROGRESSION & ALIGNMENT'
Add 'addexp [amount]           - Add the specified experience points'
Add 'addlevel                  - Add experience for the next level'
Add 'addlightside [amount]     - Add Light Side points'
Add 'adddarkside [amount]      - Add Dark Side points'
Add 'givecredits [amount]      - Add the specified credits'
Section 'ATTRIBUTE SETTERS'
foreach ($pair in @(@('strength','Strength'),@('dexterity','Dexterity'),@('constitution','Constitution'),@('intelligence','Intelligence'),@('wisdom','Wisdom'),@('charisma','Charisma'))) {
    Add ('{0,-26}- Set {1}' -f ('set'+$pair[0]+' [value]'),$pair[1])
}
Section 'SKILL SETTERS'
foreach ($pair in @(@('computeruse','Computer Use'),@('demolitions','Demolitions'),@('stealth','Stealth'),@('awareness','Awareness'),@('persuade','Persuade'),@('repair','Repair'),@('security','Security'),@('treatinjury','Treat Injury'))) {
    Add ('{0,-26}- Set {1}' -f ('set'+$pair[0]+' [value]'),$pair[1])
}
Section 'SUPPLY COMMANDS'
Add 'givemed                   - Give 100 medkits'
Add 'giverepair                - Give 100 advanced repair kits'
Add 'givecomspikes             - Give 100 computer spikes'
ItemGroup 'STANDARD LIGHTSABERS' '^g_w_lghtsbr\d+$'
ItemGroup 'SHORT LIGHTSABERS' '^g_w_shortsbr\d+$'
ItemGroup 'DOUBLE-BLADED LIGHTSABERS' '^g_w_dblsbr\d+$'
ItemGroup 'LIGHTSABER COLOR CRYSTALS' '^u_l_colo_\d+$'
Add 'Bronze exists as an item but is marked unused in the base game data.'
ItemGroup 'LIGHTSABER POWER CRYSTALS' '^u_l_crys_'
ItemGroup 'ROBES & JEDI ARMOR' '^a_robe_'
ItemGroup 'LIGHT ARMOR & CLOTHING' '^(a_light_|mineruniform$|g_danceroutfit$)'
ItemGroup 'MEDIUM ARMOR' '^a_medium_'
ItemGroup 'HEAVY ARMOR' '^a_heavy_'
ItemGroup 'LIGHTSABER EMITTERS' '^u_l_emit_'
ItemGroup 'LIGHTSABER LENSES' '^u_l_lens_'
ItemGroup 'LIGHTSABER ENERGY CELLS' '^u_l_cell_'
ItemGroup 'BLASTER PISTOLS' '^w_blaste_'
ItemGroup 'BLASTER RIFLES & HEAVY WEAPONS' '^w_brifle_'
ItemGroup 'MELEE WEAPONS' '^w_melee_'
ItemGroup 'BLASTER SCOPES' '^u_r_targ_'
ItemGroup 'BLASTER FIRING CHAMBERS' '^u_r_firi_'
ItemGroup 'BLASTER POWER CELLS' '^u_r_powe_'
ItemGroup 'BELTS' '^a_belt_'
ItemGroup 'HEADGEAR' '^a_helmet_'
ItemGroup 'GLOVES & GAUNTLETS' '^a_gloves_'
ItemGroup 'TIER 1 IMPLANTS (BASE CONSTITUTION 12+)' '^e_imp1_'
ItemGroup 'TIER 2 IMPLANTS (BASE CONSTITUTION 14+)' '^e_imp2_'
ItemGroup 'TIER 3 IMPLANTS (BASE CONSTITUTION 16+)' '^e_imp3_'
ItemGroup 'TIER 4 IMPLANTS (BASE CONSTITUTION 18+)' '^e_imp4_'
ItemGroup 'ENERGY SHIELDS & ARMBANDS' '^a_(shield_|band_)'
ItemGroup 'GRENADES & THERMAL DETONATORS' '^g_w_(fraggren|stungren|iongren|sonicgren|firegren|poisngren|cryobgren|adhsvgren|thermldet)'
ItemGroup 'MINES' '^g_i_trapkit\d+$'
ItemGroup 'MELEE WEAPON EDGES' '^u_m_edge_'
ItemGroup 'MELEE WEAPON GRIPS' '^u_m_grip_'
ItemGroup 'PAZAAK CARDS' '^g_i_pazcard_\d+$'
Section 'PLANET WARP MODULE CODES'
Add 'Use a separate save before warping: travel can bypass quest triggers.'
Add 'Repeated area names can represent different story variants.'
Add '004EBO is the Red Eclipse invasion variant; 511OND is an invasion area.'
Add
foreach ($planet in @('EBO','PER','HAR','TEL','DAN','NAR','DXN','OND','KOR','MAL')) {
    Add ('-- '+$planet+' --')
    $codes=@($audit | Where-Object { $_.Kind -eq 'warp' -and $_.Code -match ($planet+'$') } | ForEach-Object Code)
    if ($planet -eq 'HAR') { $codes=@('151HAR','152HAR','153HAR') }
    if ($planet -eq 'PER') { $codes=@($codes | Where-Object { $modules.ContainsKey($_) }) }
    $extras=@{TEL=@('207TEL','232TEL'); DXN=@('403DXN'); OND=@('506OND'); KOR=@('710KOR')}
    if ($extras.ContainsKey($planet)) { $codes += $extras[$planet] }
    foreach ($code in $codes | Sort-Object -Unique) {
        if (!$modules.ContainsKey($code)) { throw "Missing module $code" }
        Add ('{0,-29} - {1}' -f ('warp '+$code),$modules[$code])
    }
    Add
}
[IO.File]::WriteAllText((Join-Path $PSScriptRoot 'Kotor 2 Console Commands.txt'), (($out -join "`r`n").TrimEnd()+"`r`n"), [Text.UTF8Encoding]::new($false))
