#include <Binary.au3>
$Path = FileOpenDialog("Select BIN the file", @ScriptDir, "bin files (*.bin)",1)
If @error = 1 Then Exit
$File = fileopen($Path,16)
$Name = CompGetFileName($Path)
Dim $Text
FileSetPos($File,8,0)
$Files = _BinaryToInt32(FileRead($File,4))
$Hsize = _BinaryToInt32(FileRead($File,4))
$BaseOff = _BinaryToInt32(FileRead($File,4))+8
FileRead($File,$Hsize-12)
For $i = 1 to $Files
	FileRead($File,4)
	$Offset = _BinaryToInt32(FileRead($File,4)) + $BaseOff
	$pos = FileGetPos($File)
	FileSetPos($File,$Offset,0)
	$S = ""
	$Str = ""
	Do
		$Str &= BinaryToString($S)
		$S = FileRead($File, 1)
	Until $S = 0
	$Str = StringRegExpReplace($Str,@CRLF,"<cf>")
	$Str = StringRegExpReplace($Str,@LF,"<lf>")
	$Str = StringRegExpReplace($Str,@CR,"<cr>")
	$Text &= $Str & @CRLF
	FileSetPos($File,$pos,0)
Next
$hFile = FileOpen ($Name&".txt", 2)
FileWrite ($hFile, $Text)
FileClose ($hFile)
TrayTip ("Exporter", "Finish!", 3)
sleep (3000)
Func CompGetFileName($Path)
If StringLen($Path) < 4 Then Return -1
$ret = StringSplit($Path,"\",2)
If IsArray($ret) Then
Return $ret[UBound($ret)-1]
EndIf
If @error Then Return -1
EndFunc