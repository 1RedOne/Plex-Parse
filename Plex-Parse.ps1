<#
Chris' Plex Library Parsing Script
-----------------------------------
v0.1  -  Chris Hall    -  Apr 14
v0.2  -  John Stallan  -  Aug 14

See https://www.github.com/chall32/plex-parse
for details and usage guidelines
#>

Function get-epochdate ($epochdate) { 
    [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($epochdate)) 
    }

function Invoke-PlexParse{
    param($libraryName = ".\Library.xml", $outputFileName = ".\Library.csv")
    
    $results = @()
    [xml]$xmldata=(Get-Content -Path ($libraryName))
    $media = $xmldata.MediaContainer.Video
    foreach ($i in $media) {
            $out = new-object psobject
            $out | add-member noteproperty Title $i.title
            $out | add-member noteproperty "Year Released" $i.year
            $out | add-member noteproperty "Added to Plex" (get-epochdate ($i.addedAt))
            $out | add-member noteproperty "Updated by Plex" (get-epochdate ($i.updatedAt))
            $out | add-member noteproperty "Last Viewed At" ((get-epochdate ($i.lastViewedAt)) -replace "01/01/1970 00:00:00","Unwatched")
            $out | add-member noteproperty Duration (new-timespan -seconds ($i.Media.duration/1000))
            $out | add-member noteproperty Rating $i.contentRating
            $out | add-member noteproperty Resolution $i.Media.videoResolution
            $out | add-member noteproperty Container $i.Media.container
            $out | add-member noteproperty "Video Codec" $i.Media.videoCodec
            $out | add-member noteproperty "Audio Codec" $i.Media.audioCodec
            $out | add-member noteproperty Width $i.Media.width           
            $out | add-member noteproperty Height $i.Media.height
            $out | add-member noteproperty "File Size (GB)" ([System.Math]::Round($i.Media.Part.size/1GB,3))
            $out | add-member noteproperty "Summary" $i.summary
            $results += $out
            }
   
    Write-output "Publishing $($results.Count) items to file $outputFileName"
    $results | export-csv -path ($outputFileName) -notype
}
