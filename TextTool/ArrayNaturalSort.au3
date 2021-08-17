#include-once
#include <Array.au3>

; #FUNCTION# ;===============================================================================
;
; Name...........: _NaturalCompare
; Description ...: Compare two strings using Natural (Alphabetical) sorting.
; Syntax.........: _NaturalCompare($s1, $s2, $iCase = 0)
; Parameters ....: $s1, $s2 - Strings to compare
;                  $iCase   - Case sensitive or insensitive comparison
;                  |0 - Case insensitive (default)
;                  |1 - Case sensitive
; Return values .: Success - One of the following:
;                  |0  - Strings are equal
;                  |-1 - $s1 comes before $s2
;                  |1  - $s1 goes after $s2
;                  Failure - Returns -2 and Sets @Error:
;                  |1 - $s1 or $s2 is not a string
;                  |2 - $iCase is invalid
; Author ........: Erik Pilsits
; Modified.......:
; Remarks .......: Original algorithm by Dave Koelle
; Related .......: StringCompare
; Link ..........: http://www.davekoelle.com/alphanum.html
; Example .......: Yes
;
; ;==========================================================================================
Func _NaturalCompare($s1, $s2, $iCase = 0)
    If (Not IsString($s1)) Or (Not IsString($s2)) Then Return SetError(1, 0, -2)
    If $iCase <> 0 And $iCase <> 1 Then Return SetError(2, 0, -2)

    Local $n = 0, $iLen = 1
    Local $s1chunk, $s2chunk

    While $n = 0 ; get next chunk
        ; STRING 1
        $iLen = 1
        If StringIsDigit(StringLeft($s1, 1)) Then
            ; chunk of digits
            For $i = 2 To StringLen($s1)
                If StringIsDigit(StringMid($s1, $i, 1)) Then
                    $iLen += 1
                Else
                    ExitLoop
                EndIf
            Next
        Else
            ; chunk of letters
            For $i = 2 To StringLen($s1)
                If Not StringIsDigit(StringMid($s1, $i, 1)) Then
                    $iLen += 1
                Else
                    ExitLoop
                EndIf
            Next
        EndIf
        $s1chunk = StringLeft($s1, $iLen)

        ; STRING 2
        $iLen = 1
        If StringIsDigit(StringLeft($s2, 1)) Then
            ; chunk of digits
            For $i = 2 To StringLen($s2)
                If StringIsDigit(StringMid($s2, $i, 1)) Then
                    $iLen += 1
                Else
                    ExitLoop
                EndIf
            Next
        Else
            ; chunk of letters
            For $i = 2 To StringLen($s2)
                If Not StringIsDigit(StringMid($s2, $i, 1)) Then
                    $iLen += 1
                Else
                    ExitLoop
                EndIf
            Next
        EndIf
        $s2chunk = StringLeft($s2, $iLen)

        ; ran out of chunks, strings are the same, return 0
        If $s1chunk = "" And $s2chunk = "" Then Return 0

        ; remove chunks from strings
        $s1 = StringMid($s1, StringLen($s1chunk) + 1)
        $s2 = StringMid($s2, StringLen($s2chunk) + 1)

        ; Case 1: both chunks contain letters
        If (Not StringIsDigit($s1chunk)) And (Not StringIsDigit($s2chunk)) Then
            $n = StringCompare($s1chunk, $s2chunk, $iCase)
        Else
            ; Case 2: both chunks contain numbers
            If StringIsDigit($s1chunk) And StringIsDigit($s2chunk) Then
                Local $i1chunk = Int($s1chunk)
                Local $i2chunk = Int($s2chunk)
                If $i1chunk > $i2chunk Then
                    Return 1
                ElseIf $i1chunk < $i2chunk Then
                    Return -1
                EndIf
            Else
                ; Case 3: one chunk has letters, the other has numbers; or one is empty
                ; if we get here, this should be the last and deciding test, so return the result
                Return StringCompare($s1chunk, $s2chunk, $iCase)
            EndIf
        EndIf
    WEnd
    Return $n
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _ArrayNaturalSort
; Description ...: Sort a 1D or 2D array on a specific index using the quicksort/insertionsort algorithms.
; Syntax.........: _ArrayNaturalSort(ByRef $avArray[, $iDescending = 0[, $iStart = 0[, $iEnd = 0[, $iSubItem = 0]]]])
; Parameters ....: $avArray     - Array to sort
;                  $iDescending - [optional] If set to 1, sort descendingly
;                  $iStart      - [optional] Index of array to start sorting at
;                  $iEnd        - [optional] Index of array to stop sorting at
;                  $iSubItem    - [optional] Sub-index to sort on in 2D arrays
; Return values .: Success - 1
;                  Failure - 0, sets @error:
;                  |1 - $avArray is not an array
;                  |2 - $iStart is greater than $iEnd
;                  |3 - $iSubItem is greater than subitem count
;                  |4 - $avArray has too many dimensions
; Author ........: Jos van der Zande <jdeb at autoitscript dot com>
; Modified.......: LazyCoder - added $iSubItem option, Tylo - implemented stable QuickSort algo, Jos van der Zande - changed logic to correctly Sort arrays with mixed Values and Strings, Ultima - major optimization, code cleanup, removed $i_Dim parameter
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _ArrayNaturalSort(ByRef $avArray, $iDescending = 0, $iStart = 0, $iEnd = 0, $iSubItem = 0)
    If Not IsArray($avArray) Then Return SetError(1, 0, 0)

    Local $iUBound = UBound($avArray) - 1

    ; Bounds checking
    If $iEnd < 1 Or $iEnd > $iUBound Then $iEnd = $iUBound
    If $iStart < 0 Then $iStart = 0
    If $iStart > $iEnd Then Return SetError(2, 0, 0)

    ; Sort
    Switch UBound($avArray, 0)
        Case 1
            __ArrayNaturalQuickSort1D($avArray, $iStart, $iEnd)
            If $iDescending Then _ArrayReverse($avArray, $iStart, $iEnd)
        Case 2
            Local $iSubMax = UBound($avArray, 2) - 1
            If $iSubItem > $iSubMax Then Return SetError(3, 0, 0)

            If $iDescending Then
                $iDescending = -1
            Else
                $iDescending = 1
            EndIf

            __ArrayNaturalQuickSort2D($avArray, $iDescending, $iStart, $iEnd, $iSubItem, $iSubMax)
        Case Else
            Return SetError(4, 0, 0)
    EndSwitch

    Return 1
EndFunc   ;==>_ArrayNaturalSort

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __ArrayNaturalQuickSort1D
; Description ...: Helper function for sorting 1D arrays
; Syntax.........: __ArrayNaturalQuickSort1D(ByRef $avArray, ByRef $iStart, ByRef $iEnd)
; Parameters ....: $avArray - Array to sort
;                  $iStart  - Index of array to start sorting at
;                  $iEnd    - Index of array to stop sorting at
; Return values .: None
; Author ........: Jos van der Zande, LazyCoder, Tylo, Ultima
; Modified.......:
; Remarks .......: For Internal Use Only
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func __ArrayNaturalQuickSort1D(ByRef $avArray, ByRef $iStart, ByRef $iEnd)
    If $iEnd <= $iStart Then Return

    Local $vTmp

    ; InsertionSort (faster for smaller segments)
    If ($iEnd - $iStart) < 15 Then
        Local $i, $j, $vCur
        For $i = $iStart + 1 To $iEnd
            $vTmp = $avArray[$i]

            If IsNumber($vTmp) Then
                For $j = $i - 1 To $iStart Step -1
                    $vCur = $avArray[$j]
                    ; If $vTmp >= $vCur Then ExitLoop
                    If ($vTmp >= $vCur And IsNumber($vCur)) Or (Not IsNumber($vCur) And _NaturalCompare($vTmp, $vCur) >= 0) Then ExitLoop
                    $avArray[$j + 1] = $vCur
                Next
            Else
                For $j = $i - 1 To $iStart Step -1
                    If (_NaturalCompare($vTmp, $avArray[$j]) >= 0) Then ExitLoop
                    $avArray[$j + 1] = $avArray[$j]
                Next
            EndIf

            $avArray[$j + 1] = $vTmp
        Next
        Return
    EndIf

    ; QuickSort
    Local $L = $iStart, $R = $iEnd, $vPivot = $avArray[Int(($iStart + $iEnd) / 2)], $fNum = IsNumber($vPivot)
    Do
        If $fNum Then
            ; While $avArray[$L] < $vPivot
            While ($avArray[$L] < $vPivot And IsNumber($avArray[$L])) Or (Not IsNumber($avArray[$L]) And _NaturalCompare($avArray[$L], $vPivot) < 0)
                $L += 1
            WEnd
            ; While $avArray[$R] > $vPivot
            While ($avArray[$R] > $vPivot And IsNumber($avArray[$R])) Or (Not IsNumber($avArray[$R]) And _NaturalCompare($avArray[$R], $vPivot) > 0)
                $R -= 1
            WEnd
        Else
            While (_NaturalCompare($avArray[$L], $vPivot) < 0)
                $L += 1
            WEnd
            While (_NaturalCompare($avArray[$R], $vPivot) > 0)
                $R -= 1
            WEnd
        EndIf

        ; Swap
        If $L <= $R Then
            $vTmp = $avArray[$L]
            $avArray[$L] = $avArray[$R]
            $avArray[$R] = $vTmp
            $L += 1
            $R -= 1
        EndIf
    Until $L > $R

    __ArrayNaturalQuickSort1D($avArray, $iStart, $R)
    __ArrayNaturalQuickSort1D($avArray, $L, $iEnd)
EndFunc   ;==>__ArrayNaturalQuickSort1D

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __ArrayNaturalQuickSort2D
; Description ...: Helper function for sorting 2D arrays
; Syntax.........: __ArrayNaturalQuickSort2D(ByRef $avArray, ByRef $iStep, ByRef $iStart, ByRef $iEnd, ByRef $iSubItem, ByRef $iSubMax)
; Parameters ....: $avArray  - Array to sort
;                  $iStep    - Step size (should be 1 to sort ascending, -1 to sort descending!)
;                  $iStart   - Index of array to start sorting at
;                  $iEnd     - Index of array to stop sorting at
;                  $iSubItem - Sub-index to sort on in 2D arrays
;                  $iSubMax  - Maximum sub-index that array has
; Return values .: None
; Author ........: Jos van der Zande, LazyCoder, Tylo, Ultima
; Modified.......:
; Remarks .......: For Internal Use Only
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func __ArrayNaturalQuickSort2D(ByRef $avArray, ByRef $iStep, ByRef $iStart, ByRef $iEnd, ByRef $iSubItem, ByRef $iSubMax)
    If $iEnd <= $iStart Then Return

    ; QuickSort
    Local $i, $vTmp, $L = $iStart, $R = $iEnd, $vPivot = $avArray[Int(($iStart + $iEnd) / 2)][$iSubItem], $fNum = IsNumber($vPivot)
    Do
        If $fNum Then
            ; While $avArray[$L][$iSubItem] < $vPivot
            While ($iStep * ($avArray[$L][$iSubItem] - $vPivot) < 0 And IsNumber($avArray[$L][$iSubItem])) Or (Not IsNumber($avArray[$L][$iSubItem]) And $iStep * _NaturalCompare($avArray[$L][$iSubItem], $vPivot) < 0)
                $L += 1
            WEnd
            ; While $avArray[$R][$iSubItem] > $vPivot
            While ($iStep * ($avArray[$R][$iSubItem] - $vPivot) > 0 And IsNumber($avArray[$R][$iSubItem])) Or (Not IsNumber($avArray[$R][$iSubItem]) And $iStep * _NaturalCompare($avArray[$R][$iSubItem], $vPivot) > 0)
                $R -= 1
            WEnd
        Else
            While ($iStep * _NaturalCompare($avArray[$L][$iSubItem], $vPivot) < 0)
                $L += 1
            WEnd
            While ($iStep * _NaturalCompare($avArray[$R][$iSubItem], $vPivot) > 0)
                $R -= 1
            WEnd
        EndIf

        ; Swap
        If $L <= $R Then
            For $i = 0 To $iSubMax
                $vTmp = $avArray[$L][$i]
                $avArray[$L][$i] = $avArray[$R][$i]
                $avArray[$R][$i] = $vTmp
            Next
            $L += 1
            $R -= 1
        EndIf
    Until $L > $R

    __ArrayNaturalQuickSort2D($avArray, $iStep, $iStart, $R, $iSubItem, $iSubMax)
    __ArrayNaturalQuickSort2D($avArray, $iStep, $L, $iEnd, $iSubItem, $iSubMax)
EndFunc   ;==>__ArrayNaturalQuickSort2D