Attribute VB_Name = "Involved_Clipboard"
Option Explicit
'##############################################################################################################################
'
'   クリップボード関連（RPA時専用関数）
'   使用するには、「Microsoft Forms 2.0 Object Library」を参照設定します。
'
'   新規作成日 : 2017/08/30
'   最終更新日 : 2017/08/31
'
'   新規作成エクセルバージョン : Office Professional Plus 2010 , 14.0.7145.5000(32ビット)
'   最終更新エクセルバージョン : Office Professional Plus 2010 , 14.0.7145.5000(32ビット)
'
'##############################################################################################################################

'==============================================================================================================================
'   クリップボードに文字列を設定する。
'
'   text : クリップボードにアップするテキスト情報
'==============================================================================================================================
Public Function SetClipboard_Text(ByVal Text As String)
    If StrComp(Text, "", vbBinaryCompare) = 0 Then Exit Function
    With New MSForms.DataObject
        .SetText Text
        .PutInClipboard
    End With
End Function

'==============================================================================================================================
'   クリップボードから文字列を取得する。
'==============================================================================================================================
Public Function GetClipboard_Text() As String
    Dim Text As String: Text = ""
    With New MSForms.DataObject
        .GetFromClipboard
        Text = .GetText
    End With
    GetText = Text
End Function
