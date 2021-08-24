Push-Location ../../../modelsim/
$FailedTests = @()
$tests = @()
$files = Get-ChildItem ..\verif\Tests\
$TestStr = "Tests"
$IsGui = "False"
$Above = "above"
write-host ""`n""`n""`n""`n""
write-host "    ####################################################################    "
write-host "    ############~~ Adi & Saar GPC_4T Simulation TestBench ~~############    "
write-host "    ####################################################################    "`n""`n""
if ($args[0] -eq "All"){
    $tests = $files
    for ($i=0; $i -lt $tests.Count; $i++) {
    $tests[$i] = $tests[$i].Name
    }
}
elseif ($args[0] -eq "-G"){
    if ($args.Count -gt 2 ) {
        write-host ""`n"Only one test can be simulated with GUI"`n""
        Pop-Location
        exit
    }
    $IsGui = "True"
    $Above = "Was in The ModelSim GUI"
    $tests += $args[1]
    write-host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    write-host "     $($args[1]) Test will be simulated with ModelSim GUI"
    write-host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"`n""`n""
}
Else
{
    $tests = $args
    write-host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    write-host "        There are a total of $($tests.count) test entered"
    write-host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"`n""`n""
}


for ( $i = 0; $i -lt $tests.count; $i++ ) {
     write-host ""
     if ( $IsGui -eq "False" ){
        write-host "***********Compiling Test number $i : $($tests[$i]) test***********"`n""`n""}
     write-host "Initiate Compilation..."
     write-host "."`n"."`n"."`n""     
     if (Test-Path -Path ..\target\$($tests[$i])) {
    
     } else {
         mkdir ..\target\$($tests[$i])
     }
     vlog.exe +define+HPATH=$($tests[$i]) -f ..\source\gpc_4t\gpc_4t_list.f
     write-host "."`n"."`n""  
     write-host "Compilation Ended. Details above  "`n" "`n" "
     write-host "***********Simulating Test: $($tests[$i])***********"`n""
     write-host "Initiate Simulation..."`n"."`n"."`n"."
     if ( $IsGui -eq "False" ) {
        vsim.exe work.gpc_4t_tb -c -do 'run -all'}
     Else {
        vsim.exe -gui work.gpc_4t_tb   }
     write-host ""`n""`n"."`n"."`n""    
     write-host "Simulation Ended. Details $Above"`n""`n""   
     write-host "Initiate Verification..."`n"."`n"."`n"."
     $fileA = "..\verif\Tests\$($tests[$i])\golden_shrd_mem_snapshot.log"
     $fileB = "..\target\$($tests[$i])\shrd_mem_snapshot.log"
     write-host ""`n""`n""       
     if(Compare-Object -ReferenceObject $(Get-Content $fileA) -DifferenceObject $(Get-Content $fileB))
     
        {
         write-host "Verification for test $($tests[$i]) failed : Memory snapshot is different from Gloden Memory Snapshot"
         write-host "Differences: "`n""
         fc.exe $fileA $fileB | select -Skip 1
         #diff (cat $fileA) (cat $fileB)
         $FailedTests+=$tests[$i]
         }
     
     Else {
         "Verification Succeeded ! Memory snapshot match Gloden Memory Snapshot"
     }        
     write-host "."`n"."`n"Verification Ended. Details above"`n""`n""`n""
     write-host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"`n""       
     write-host "Test number $i has ended"`n""  
     write-host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"       
} 
write-host "__________________________________________________"`n""
write-host "GPC_4T Simulation TestBench Finished ! "`n""
if ( $FailedTests.count -gt 0 ){
    if ( $FailedTests.count -eq 1 ){ $TestStr = "Test"}
    write-host "$($FailedTests.count) $TestStr Failed Verification:"`n""
    for ( $j = 0; $j -lt $FailedTests.count; $j++ ) {
        write-host "$($FailedTests[$j])"`n""
    }
}
Else {
    write-host "All Tests Passed Verification !"`n""
}
write-host "__________________________________________________"`n""

Pop-Location




