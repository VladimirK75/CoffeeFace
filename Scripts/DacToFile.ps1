param($DataBaseList = 'QORT_CACHE_DB,QORT_DDM,GRDBServices,QORT_TDB_PROD,QORT_DB_PROD')

$git = 'C:\bat\PortableGit\cmd\git.exe'
$RootPath = 'C:\bat\PortableGit\LocalRep'

#&$git clone https://dev.azure.com/rencap/_git/backQORT C:\bat\PortableGit\LocalRep
cd $RootPath
&$git checkout master 2>$null
&$git pull 2>$null

foreach($DataBase in $DataBaseList.split(","))
{
cd $RootPath
$dacpacPath = $RootPath+'\QORT_OFFSHORE\'+$DataBase
If (!(Test-Path $dacpacPath))
{
   New-Item -ItemType "Directory" -Path $dacpacPath
}
$dacpac = $DataBase+'.dacpac'
$dacpacFile = $dacpacPath+'\'+$dacpac
$SQLPACK="C:\Program Files\Microsoft SQL Server\150\DAC\bin\SqlPackage.exe"
&$SQLPACK /a:Extract /ssn:qort_dma\qort_dma /sdn:$DataBase /tf:$dacpacFile
add-type -path 'C:\Program Files\Microsoft SQL Server\150\DAC\bin\Microsoft.SqlServer.Dac.Extensions.dll' 
cd $dacpacPath 
$model =[Microsoft.SqlServer.Dac.Model.TSqlModel]::new(((get-item $dacpacFile).fullname)) 
$queryScopes = [Microsoft.SqlServer.Dac.Model.DacQueryScopes]::All 
$returnObjects = $model.GetObjects([Microsoft.SqlServer.Dac.Model.DacQueryScopes]::All) 
$s = '' 

if ( (test-path "$dacpacPath\dbo")) 
{
    Get-ChildItem "$dacpacPath\dbo" -recurse | Remove-Item -Force -Recurse 
}
if ( (test-path "$dacpacPath\Publication")) 
{
    Get-ChildItem "$dacpacPath\Publication" -recurse | Remove-Item -Force -Recurse
}

foreach($r in $returnObjects) 
{ 
   if ($r.TryGetScript([ref]$s) -and $r.ObjectType.Name -match '(.*Function|Procedure|Table|Trigger)' -and $r.ObjectType.Name -notmatch '(.*/$/$)' -and  $r.Name.Parts[0] -match '(.*dbo|Publication)' ) 
   { 
    $objectTypeName = $r.ObjectType.Name;
    $objectTypeName = $objectTypeName -replace '.*Trigger', 'Trigger'
    $objectTypeName = $objectTypeName -replace '.*Function', 'Functions'
    $objectTypeName = $objectTypeName -replace 'Procedure', 'Stored Procedures'
    $objectTypeName = $objectTypeName -replace 'Table', 'Tables'
    $sh = $r.Name.Parts[0]
    $d = "$dacpacPath\$sh\$objectTypeName"
    if(!(test-path $d )) 
    { 
        new-item $d -ItemType Directory 
    } 
    $filename = "$d\$($r.Name.Parts[1]).sql"
    #$filename
         
        if (! (test-path $filename)) 
        { 
            Try 
            { 
                new-item $filename -ItemType File -ErrorAction Stop -Force 
            } 
            Catch 
            { 
                $url = "$($r.Name.Parts[1])" 
                if ([system.uri]::IsWellFormedUriString($url, [system.urikind]::Absolute)) 
                { 
                    $u = ([uri]"$url").Segments[-1] 
                    $filename = "$d\$u.sql" 
                    #new-item $filename -ItemType File -ErrorAction Stop -Force 
                } 
                 
            } 
        } 
        $s | out-file  $filename -Force 
    write-output $filename 
   } 
} 

Remove-Item $dacpacFile -Force
}

Get-ChildItem $RootPath  *.sql -Recurse | Where-Object {$_.Name -like '*$$*'} | ForEach-Object `
{
  Remove-Item $_.FullName -Force
}

cd $RootPath
&$git add .
&$git commit -a -m "daily update" 2>$null
&$git push origin master 2>$null
&$git push 2>$null
