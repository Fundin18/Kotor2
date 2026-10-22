param(
    [string]$GamePath = 'C:\Program Files (x86)\Steam\steamapps\common\Knights of the Old Republic II',
    [string]$WorkshopPath = 'C:\Program Files (x86)\Steam\steamapps\workshop\content\208580\485537937'
)
$ErrorActionPreference = 'Stop'
$enc = [Text.Encoding]::GetEncoding(1252)
function U32([byte[]]$Bytes, [int]$At) { [BitConverter]::ToUInt32($Bytes, $At) }
function U16([byte[]]$Bytes, [int]$At) { [BitConverter]::ToUInt16($Bytes, $At) }
function Str([byte[]]$Bytes, [int]$At, [int]$Length) { $enc.GetString($Bytes, $At, $Length).TrimEnd([char]0) }
$tlks = @{}
function Read-Tlk([string]$Path) {
    if (!$tlks.ContainsKey($Path)) { $tlks[$Path] = [IO.File]::ReadAllBytes($Path) }
    return ,$tlks[$Path]
}
function Localized([byte[]]$Gff, [string]$Label, [byte[]]$Tlk) {
    if ((Str $Gff 4 4) -ne 'V3.2') { throw 'Unexpected GFF version' }
    $structAt = U32 $Gff 8
    $fieldAt = U32 $Gff 16
    $labelAt = U32 $Gff 24
    $dataAt = U32 $Gff 32
    $indicesAt = U32 $Gff 40
    $count = U32 $Gff ($structAt + 8)
    $rootIndex = U32 $Gff ($structAt + 4)
    for ($j = 0; $j -lt $count; $j++) {
        if ($count -eq 1) { $index = $rootIndex } else { $index = U32 $Gff ($indicesAt + $rootIndex + 4*$j) }
        $at = $fieldAt + 12*$index
        $name = Str $Gff ($labelAt + 16*(U32 $Gff ($at+4))) 16
        if ($name -ne $Label) { continue }
        if ((U32 $Gff $at) -ne 12) { throw "Unexpected type for $Label" }
        $loc = $dataAt + (U32 $Gff ($at+8))
        $ref = U32 $Gff ($loc+4)
        if ($ref -ne [uint32]::MaxValue) {
            if ($ref -ge (U32 $Tlk 12)) { return "[unresolved stringref $ref]" }
            $entry = 20 + 40*$ref
            return Str $Tlk ((U32 $Tlk 16)+(U32 $Tlk ($entry+28))) (U32 $Tlk ($entry+32))
        }
        if ((U32 $Gff ($loc+8)) -gt 0) { return Str $Gff ($loc+20) (U32 $Gff ($loc+16)) }
        return '[empty localized name]'
    }
    return '[no localized name]'
}
$baseTlk = Read-Tlk (Join-Path $GamePath 'dialog.tlk')
$modTlk = $baseTlk
if (Test-Path (Join-Path $WorkshopPath 'dialog.tlk')) { $modTlk = Read-Tlk (Join-Path $WorkshopPath 'dialog.tlk') }
$key = [IO.File]::ReadAllBytes((Join-Path $GamePath 'chitin.key'))
if ((Str $key 0 8) -ne 'KEY V1  ') { throw 'Unexpected KEY header' }
$bifs = @()
for ($i=0; $i -lt (U32 $key 8); $i++) {
    $at = (U32 $key 16)+12*$i
    $bifs += Join-Path $GamePath (Str $key (U32 $key ($at+4)) (U16 $key ($at+8)))
}
$items = @{}
$upcrystals = $null
$streams = @{}
try {
    for ($i=0; $i -lt (U32 $key 12); $i++) {
        $at = (U32 $key 20)+22*$i
        $code = Str $key $at 16
        $resourceType = U16 $key ($at+16)
        if ($resourceType -ne 2025 -and !($resourceType -eq 2017 -and $code -eq 'upcrystals')) { continue }
        $id = U32 $key ($at+18)
        $bifIndex = $id -shr 20
        $resIndex = $id -band 0xFFFFF
        if (!$streams.ContainsKey($bifIndex)) { $streams[$bifIndex] = [IO.BinaryReader]::new([IO.File]::OpenRead($bifs[$bifIndex])) }
        $r = $streams[$bifIndex]
        $r.BaseStream.Position = 16
        $table = $r.ReadUInt32()
        $r.BaseStream.Position = $table+16*$resIndex
        $null = $r.ReadUInt32()
        $offset = $r.ReadUInt32()
        $size = $r.ReadUInt32()
        if ($r.ReadUInt32() -ne $resourceType) { throw "Unexpected resource type: $code" }
        $r.BaseStream.Position = $offset
        $gff = $r.ReadBytes($size)
        if ($resourceType -eq 2017) { $upcrystals=$gff; continue }
        $items[$code] = [pscustomobject]@{Code=$code; Name=(Localized $gff 'LocalizedName' $baseTlk); Source='base BIF'; BaseName=''}
    }
} finally { foreach ($r in $streams.Values) { $r.Dispose() } }
foreach ($layer in @(
    @{Path=(Join-Path $GamePath 'override'); Tlk=$baseTlk; Source='game override'},
    @{Path=(Join-Path $WorkshopPath 'override'); Tlk=$modTlk; Source='workshop 485537937 override'}
)) {
    if (!(Test-Path $layer.Path)) { continue }
    foreach ($file in Get-ChildItem -LiteralPath $layer.Path -Filter '*.uti' -File) {
        $code = $file.BaseName
        $baseName = ''
        if ($items.ContainsKey($code)) { $baseName = $items[$code].Name }
        $items[$code] = [pscustomobject]@{Code=$code; Name=(Localized ([IO.File]::ReadAllBytes($file.FullName)) 'LocalizedName' $layer.Tlk); Source=$layer.Source; BaseName=$baseName}
    }
}
$saberColors = @{}
if ($upcrystals) {
    $pos = 9
    $columnEnd = [Array]::IndexOf($upcrystals,[byte]0,$pos)
    $columns = (Str $upcrystals $pos ($columnEnd-$pos)).TrimEnd("`t").Split("`t")
    $pos=$columnEnd+1
    $rowCount=U32 $upcrystals $pos
    $pos+=4
    for ($row=0; $row -lt $rowCount; $row++) { $pos=[Array]::IndexOf($upcrystals,[byte]9,$pos)+1 }
    $cellAt=$pos
    $stringAt=$cellAt+2*$rowCount*$columns.Count+2
    for ($row=0; $row -lt $rowCount; $row++) {
        $values=@{}
        for ($col=0; $col -lt $columns.Count; $col++) {
            $offset=$stringAt+(U16 $upcrystals ($cellAt+2*($row*$columns.Count+$col)))
            $end=[Array]::IndexOf($upcrystals,[byte]0,$offset)
            $values[$columns[$col]]=Str $upcrystals $offset ($end-$offset)
        }
        $colorCode=$values['template']
        if ($colorCode -and $items.ContainsKey($colorCode)) {
            $color=($items[$colorCode].Name -replace '^\{[^}]+\}','' -replace '^Crystal,\s*','').Trim()
            foreach ($column in @('shortmdlvar','longmdlvar','doublemdlvar')) {
                if ($values[$column] -and $values[$column] -ne '****') { $saberColors[$values[$column]]=$color }
            }
        }
    }
}
function Normalize([string]$Name) {
    $Name=$Name -replace '^\{[^}]+\}','' -replace '\s*\([^)]*\)\s*$',''
    $Name=$Name -replace '^Crystal,\s*(.*)$','$1 Crystal' -replace ' Color Crystal$',' Crystal'
    $Name=$Name -replace '^Standard Clothing$','Clothing' -replace '^Peragus Mining Uniform$','Miner Uniform'
    $Name=$Name -replace '^Deflection Emitter Mark I$','Deflection Emitter' -replace '^Fencing Emitter Mark I$','Fencing Emitter'
    $Name=$Name -replace '^Plus/Minus ([1-6]) Card$','Pazaak Card +/-$1' -replace '^Plus ([1-6]) Card$','Pazaak Card +$1' -replace '^Minus ([1-6]) Card$','Pazaak Card -$1'
    return ($Name.ToLowerInvariant() -replace '[^a-z0-9]','')
}
$modules = @{}
foreach ($file in Get-ChildItem -LiteralPath (Join-Path $GamePath 'Modules') -Filter '*.rim' -File) {
    if ($file.BaseName -match '_s$') { continue }
    $rim = [IO.File]::ReadAllBytes($file.FullName)
    $areaNames = @()
    for ($j=0; $j -lt (U32 $rim 12); $j++) {
        $at = (U32 $rim 16)+32*$j
        if ((U32 $rim ($at+16)) -ne 2012) { continue }
        $offset = U32 $rim ($at+24)
        $size = U32 $rim ($at+28)
        $gff = [byte[]]::new($size)
        [Array]::Copy($rim,$offset,$gff,0,$size)
        $areaNames += Localized $gff 'Name' $baseTlk
    }
    $modules[$file.BaseName] = $areaNames -join '; '
}
$exe = $enc.GetString([IO.File]::ReadAllBytes((Join-Path $GamePath 'swkotor2.exe')))
$lines = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Kotor 2 Console Commands.txt')
$audit = for ($i=0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^giveitem\s+(\S+)\s+-\s+(.+)$') {
        $code = $Matches[1]; $claimed = $Matches[2]
        $entry = $items[$code]
        $status = 'RESOURCE NOT FOUND'
        $actual = ''; $source = ''; $baseName = ''
        if ($entry) {
            $actual = ($entry.Name -replace '^\{[^}]+\}','').Trim(); $source = $entry.Source; $baseName = $entry.BaseName
            $status = 'WRONG ITEM LABEL'
            if ($saberColors.ContainsKey($code)) { $actual=$saberColors[$code]+' '+$actual }
            if ((Normalize $claimed) -eq (Normalize $actual)) { $status = 'MATCH' }
            if ($code -match '^g_w_dblsbr' -and (Normalize ($claimed -replace 'Double Lightsaber','Double-Bladed Lightsaber')) -eq (Normalize $actual)) { $status='MATCH' }
        }
        [pscustomobject]@{Line=$i+1; Kind='item'; Code=$code; Claimed=$claimed; Actual=$actual; Status=$status; Source=$source; BaseName=$baseName}
    } elseif ($lines[$i] -match '^warp\s+(\S+)\s+-\s+(.+)$') {
        $code = $Matches[1]; $claimed = $Matches[2]
        $status = 'REVIEW DESTINATION LABEL'
        if ((Normalize $claimed) -eq (Normalize $modules[$code])) { $status='MATCH' }
        if (!$modules.ContainsKey($code)) { $status = 'MODULE NOT FOUND' }
        [pscustomobject]@{Line=$i+1; Kind='warp'; Code=$code; Claimed=$claimed; Actual=$modules[$code]; Status=$status; Source='base module ARE Name'; BaseName=''}
    } elseif ($lines[$i] -match '^(\w+)(?:\s+.*?)?\s+-\s+(.+)$') {
        $code = $Matches[1]; $claimed = $Matches[2]
        $status = 'TOKEN NOT FOUND IN EXE'
        if ($exe.Contains(([char]0)+$code+([char]0))) { $status = 'TOKEN PRESENT; BEHAVIOR NOT TESTED' }
        [pscustomobject]@{Line=$i+1; Kind='command'; Code=$code; Claimed=$claimed; Actual=''; Status=$status; Source='executable strings'; BaseName=''}
    }
}
$audit | Export-Csv -LiteralPath (Join-Path $PSScriptRoot 'console-command-audit.csv') -NoTypeInformation -Encoding UTF8
$items.Values | Sort-Object Code | Export-Csv -LiteralPath (Join-Path $PSScriptRoot 'installed-item-index.csv') -NoTypeInformation -Encoding UTF8
$audit | Group-Object Kind,Status | Select-Object Count,Name | Format-Table -AutoSize
'ITEM RESOURCES: '+$items.Count
'BASE MODULES: '+$modules.Count
$audit | Where-Object Kind -eq command | Format-Table Line,Code,Status -AutoSize
$audit | Where-Object { $_.Kind -eq 'item' -and $_.Status -eq 'RESOURCE NOT FOUND' } | Format-Table Line,Code,Claimed -AutoSize
$audit | Where-Object Kind -eq warp | Format-Table Line,Code,Actual,Status -AutoSize
