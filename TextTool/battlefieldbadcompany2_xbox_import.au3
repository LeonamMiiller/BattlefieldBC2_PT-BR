#include <File.au3>
#include <Binary.au3> ;Binary UDF, https://www.autoitscript.com/forum/topic/131037-binary-udf/
Dim $NEWdata, $pos = 35, $Offset = 0
$TxtPath = FileOpenDialog("Select the TXT file", @ScriptDir, "text files (*.txt)",1)
If @error = 1 Then Exit
_FileReadToArray($TxtPath,$NEWdata)
$Name = StringTrimRight(CompGetFileName($TxtPath),4)
$File = FileOpen ($Name, 0+16)
If $File = -1 Then
MsgBox(0,"Error","Can't open "&$Name&" file.")
Exit
EndIf
FileSetPos($File,8,0)
$Files = FileRead($File,4)
$Hsize = _BinaryToInt32(FileRead($File,4))+13
$BaseOff = _BinaryToInt32(FileRead($File,4))
FileSetPos($File,0,0)
$Newfile = FileRead($File,$BaseOff+8)
$Newfiletext = Binary("0x00")
For $i = 1 To $Files
	$NEWdata[$i] = StringRegExpReplace($NEWdata[$i],"<cf>",@CRLF)
	$NEWdata[$i] = StringRegExpReplace($NEWdata[$i],"<lf>",@LF)
	$NEWdata[$i] = StringRegExpReplace($NEWdata[$i],"<cr>",@CR)
	$Newtext = StringToBinary($NEWdata[$i]) & Binary("0x00")
	$Len = BinaryLen($Newtext)
	$Newfiletext &= $Newtext
	$Newfile = _BinaryPoke($Newfile,$Hsize,$Offset,"dword")
	$Hsize += 8
	$Offset += $Len
Next
$Pad = 4-Mod($Offset,4)
If $Pad < 4 Then
	$Newfiletext &= Binary("0x" & Hex(0,$Pad*2))
	$Offset += $Pad
EndIf
$Newfile = _BinaryPoke($Newfile,5,$BaseOff+$Offset,"dword")
$hNewfile = FileOpen("NEW_"&$Name, 2+16)
FileWrite($hNewfile, $Newfile & BinaryMid($Newfiletext,2))
FileClose($hNewfile)
TrayTip("Importer", "Finish!", 3)
sleep(3000)
Func CompGetFileName($Path)
If StringLen($Path) < 4 Then Return -1
$ret = StringSplit($Path,"\",2)
If IsArray($ret) Then
Return $ret[UBound($ret)-1]
EndIf
If @error Then Return -1
EndFunc