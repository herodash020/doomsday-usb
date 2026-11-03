$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[Windows.Forms.Application]::EnableVisualStyles()
function Get-Drives { @(Get-CimInstance Win32_LogicalDisk -Filter "DriveType=2" | Where-Object {$_.DeviceID -match '^[A-Z]:$'} | Sort-Object DeviceID) }
function Err($m){[void][Windows.Forms.MessageBox]::Show($m,'Doomsday USB','OK','Error')}
$f=New-Object Windows.Forms.Form
$f.Text='Doomsday USB - Alpha v0.2';$f.Size='720,650';$f.StartPosition='CenterScreen';$f.Font='Segoe UI,9';$f.BackColor=[Drawing.Color]::FromArgb(245,247,250)
function Label($t,$x,$y,$w,$h,$sz=9){$c=New-Object Windows.Forms.Label;$c.Text=$t;$c.Location=New-Object Drawing.Point($x,$y);$c.Size=New-Object Drawing.Size($w,$h);$c.Font=New-Object Drawing.Font('Segoe UI',$sz);$f.Controls.Add($c)}
Label 'DOOMSDAY USB' 25 18 640 40 21
Label 'Choose what to copy from your master USB.' 28 62 650 25
Label 'MASTER USB (SOURCE)' 28 105 250 22
$s=New-Object Windows.Forms.ComboBox;$s.Location='28,130';$s.Size='640,30';$s.DropDownStyle='DropDownList';$f.Controls.Add($s)
Label 'DESTINATION USB' 28 175 250 22
$d=New-Object Windows.Forms.ComboBox;$d.Location='28,200';$d.Size='640,30';$d.DropDownStyle='DropDownList';$f.Controls.Add($d)
$n=New-Object Windows.Forms.RadioButton;$n.Text='Normal install - copy everything';$n.Location='30,250';$n.Size='320,25';$n.Checked=$true;$f.Controls.Add($n)
$c=New-Object Windows.Forms.RadioButton;$c.Text='Custom install - choose the wikis';$c.Location='360,250';$c.Size='300,25';$f.Controls.Add($c)
Label 'Select offline wiki / knowledge archives (.zim):' 30 285 620 22
$w=New-Object Windows.Forms.CheckedListBox;$w.Location='30,310';$w.Size='638,190';$w.CheckOnClick=$true;$w.Enabled=$false;$f.Controls.Add($w)
Label 'Custom mode copies all non-wiki system files plus only the checked archives.' 30 510 640 25
$r=New-Object Windows.Forms.Button;$r.Text='Refresh drives';$r.Location='30,550';$r.Size='120,34';$f.Controls.Add($r)
$b=New-Object Windows.Forms.Button;$b.Text='Install';$b.Location='540,550';$b.Size='128,34';$b.BackColor=[Drawing.Color]::FromArgb(30,90,160);$b.ForeColor=[Drawing.Color]::White;$f.Controls.Add($b)
$script:ds=@();$script:z=@()
function LoadZ {
 $w.Items.Clear();$script:z=@()
 if($s.SelectedIndex -ge 0){$root=$script:ds[$s.SelectedIndex].DeviceID+'\';$script:z=@(Get-ChildItem -LiteralPath $root -Filter '*.zim' -File -Recurse -Force -ErrorAction SilentlyContinue | Where-Object {!($_.Attributes -band [IO.FileAttributes]::ReparsePoint)} | Sort-Object FullName);foreach($x in $script:z){[void]$w.Items.Add(('{0} ({1:N2} GB)' -f $x.Name,($x.Length/1GB)))}}
 $c.Enabled=($script:z.Count -gt 0);if(!$c.Enabled){$n.Checked=$true;$c.Checked=$false};$w.Enabled=$c.Checked -and $c.Enabled
}
function RefreshD {
 $script:ds=Get-Drives;$s.Items.Clear();$d.Items.Clear()
 foreach($x in $script:ds){$label=if($x.VolumeName){$x.VolumeName}else{'No label'};$v='{0}\  {1} | {2:N1} GB free / {3:N1} GB' -f $x.DeviceID,$label,($x.FreeSpace/1GB),($x.Size/1GB);[void]$s.Items.Add($v);[void]$d.Items.Add($v)}
 if($s.Items.Count -gt 0){$s.SelectedIndex=0};if($d.Items.Count -gt 1){$d.SelectedIndex=1};LoadZ
}
$r.Add_Click({try{RefreshD}catch{Err $_.Exception.Message}})
$s.Add_SelectedIndexChanged({try{LoadZ}catch{Err $_.Exception.Message}})
$n.Add_CheckedChanged({$w.Enabled=$c.Checked -and $script:z.Count -gt 0})
$c.Add_CheckedChanged({$w.Enabled=$c.Checked -and $script:z.Count -gt 0})
$b.Add_Click({
 try{
  if($script:ds.Count -lt 2 -or $s.SelectedIndex -lt 0 -or $d.SelectedIndex -lt 0){throw 'Connect two removable USB drives and select both.'}
  $src=$script:ds[$s.SelectedIndex];$dst=$script:ds[$d.SelectedIndex];if($src.DeviceID -eq $dst.DeviceID){throw 'Source and destination must be different.'}
  $root=$src.DeviceID+'\';$target=Join-Path ($dst.DeviceID+'\') 'DOOMSDAY_USB_COPY';if(Test-Path -LiteralPath $target){throw "Destination folder already exists: $target. Nothing was overwritten."}
  $chosen=@();if($c.Checked){for($i=0;$i -lt $w.Items.Count;$i++){if($w.GetItemChecked($i)){$chosen+=$script:z[$i]}};if(!$chosen.Count){throw 'Select at least one wiki archive or choose Normal install.'}}
  $mode=if($c.Checked){'Custom install'}else{'Normal install'}
  $nl=[Environment]::NewLine
  $msg='Mode: '+$mode+$nl+'Source: '+$root+$nl+'Destination: '+$target+$nl+'This copies files only; it will not format or erase the destination.'+$nl+'Continue?'
  if([Windows.Forms.MessageBox]::Show($msg,'Confirm','YesNo','Warning') -ne 'Yes'){return}
  $f.Enabled=$false
  New-Item -ItemType Directory -Path $target | Out-Null
  $log=Join-Path $target 'doomsday-usb-copy.log'
  $ra=@($root,$target,'/E','/COPY:DAT','/DCOPY:DAT','/R:2','/W:2','/XJ','/FFT','/NP','/TEE','/LOG:'+$log,'/XD',(Join-Path $root 'System Volume Information'),(Join-Path $root '$RECYCLE.BIN'))
  if($c.Checked){$excluded=@($script:z | ForEach-Object {$_.FullName});if($excluded.Count){$ra+=@('/XF')+$excluded}}
  & robocopy @ra;$rc=$LASTEXITCODE;if($rc -ge 8){throw "Robocopy failed ($rc). Partial copy left in place. Log: $log"}
  if($c.Checked){foreach($x in $chosen){$rel=$x.FullName.Substring($root.Length);$out=Join-Path $target $rel;New-Item -ItemType Directory -Force -Path (Split-Path -Parent $out) | Out-Null;Copy-Item -LiteralPath $x.FullName -Destination $out}}
  @"
DOOMSDAY USB ALPHA v0.2
Completed: $(Get-Date)
Mode: $mode
Source: $root
Destination: $target
Selected wiki archives: $(if($c.Checked){$chosen.Count}else{'All'})
Robocopy exit code: $rc
File-level copy only. Review the log for skipped files.
"@ | Set-Content -LiteralPath (Join-Path $target 'COPY-REPORT.txt') -Encoding UTF8
  [void][Windows.Forms.MessageBox]::Show("Copy completed. Review log: $log",'Doomsday USB','OK','Information');$f.Close()
 }catch{$f.Enabled=$true;Err $_.Exception.Message}
})
RefreshD
[void]$f.ShowDialog()
