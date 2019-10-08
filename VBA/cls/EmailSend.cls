VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "EMailSend"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'==============================================================================================================================
'   Outlook���g�p���A���[���𑗐M����B
'   �ŏI�`�F�b�Nver : Outlook2010{14,0,7145,5000(32�r�b�g)}
'==============================================================================================================================
Option Explicit
Dim OutlookApplication As Object
Dim OutlookMailItem As Object

Dim StartingFlag As Boolean
Const SilentMode = True '������True�ɕς��Ă͂Ȃ��
'------------------------------------------------------------------------------------------------------------------------------
'   �R���X�g���N�^
'------------------------------------------------------------------------------------------------------------------------------
Private Sub Class_Initialize()
    StartingFlag = True
    Set OutlookMailItem = Nothing
    'Outlook�̋N�����m�F
    On Error GoTo ErrorHandler '���L�ŃG���[���������邽��
    Set OutlookApplication = GetObject(, "Outlook.Application")
ErrorHandler:
    If OutlookApplication Is Nothing Then
        StartingFlag = False
        '�N�����Ă��Ȃ����ߋN��������B
        Dim Namespace As Object
        Set OutlookApplication = CreateObject("Outlook.Application")
        'Set Namespace = OutlookApplication.GetNamespace("MAPI")
        'Namespace.GetDefaultFolder(6).Display 'olFolderInbox
        Set Namespace = Nothing
    End If
End Sub
'------------------------------------------------------------------------------------------------------------------------------
'   �f�X�g���N�^
'------------------------------------------------------------------------------------------------------------------------------
Private Sub Class_Terminate()
    '�N�����ĂȂ�������I��
    If StartingFlag Then
        OutlookApplication.Quit
    End If
    Set OutlookApplication = Nothing
    Set OutlookMailItem = Nothing
End Sub
'------------------------------------------------------------------------------------------------------------------------------
'   Outlook��MSG�t�@�C���I�[�v�� : �J����(True)�J���Ȃ�����(False)
'------------------------------------------------------------------------------------------------------------------------------
Public Function OpenFile(FileName As String) As Boolean
    '�t�@�C�����Ȃ��ꍇ��...
    If Not Dir(FileName) <> "" Then
        OpenFile = False
        Exit Function
    End If
    '���L�A�C�e�����[�h�ŊJ��
    Set OutlookMailItem = OutlookApplication.Session.OpenSharedItem(FileName)
    OpenFile = True
End Function
'------------------------------------------------------------------------------------------------------------------------------
' ���[���A�h���X���ǂ����̔���
'------------------------------------------------------------------------------------------------------------------------------
Private Function IsMailAddress(Address As String) As Boolean
    If Address Like "*@*" Then
        IsMailAddress = True
    Else
        IsMailAddress = False
    End If
End Function
'------------------------------------------------------------------------------------------------------------------------------
' ���M
'------------------------------------------------------------------------------------------------------------------------------
Public Function Send() As Boolean
    If Not SilentMode Then
        OutlookMailItem.Display
    Else
        Dim path As String: path = ActiveWorkbook.path + "\provisional.msg"
        OutlookMailItem.SaveAs path
        Application.Wait Now + TimeValue("0:00:03")  '�O�̂��ߕۑ�����������܂ő҂�
        'Outlook�����ׂċ����I��������B
        Dim Explorer As Object
        For Each Explorer In OutlookApplication.Explorers
            Explorer.Application.Quit
        Next
        Application.Wait Now + TimeValue("0:00:03")  '�O�̂��ߏI������܂ő҂�
        Set OutlookApplication = Nothing
        Set OutlookMailItem = Nothing
        'Outlook�I�u�W�F�N�g���Ď擾
        Set OutlookApplication = CreateObject("Outlook.Application")
        Set OutlookMailItem = OutlookApplication.Session.OpenSharedItem(path)
        OutlookMailItem.Send
        Application.Wait Now + TimeValue("0:00:03") '�O�̂��ߑ��M���鎞�ԑ҂�
        StartingFlag = False                        '�N�����Ă�������������������
        '��قǕۑ��������[���t�@�C�����폜
        Dim FSO As Object
        Set FSO = CreateObject("Scripting.FileSystemObject")
        Call FSO.DeleteFile(path, True)
        Set FSO = Nothing
        Application.Wait Now + TimeValue("0:00:03")  '�O�̂��ߍ폜����������܂ő҂�
    End If
End Function
'------------------------------------------------------------------------------------------------------------------------------
'
' �{����ύXor�g���������Ȃ�...
'
'------------------------------------------------------------------------------------------------------------------------------
Public Function GetBody() As String
    If OutlookMailItem.BodyFormat = 1 Then
        GetBody = OutlookMailItem.Body     '�ȒP���[�h
    Else
        GetBody = OutlookMailItem.HTMLBody '�S�{���[�h
    End If
End Function
Public Function SetBody(Text As String) As String
    If OutlookMailItem.BodyFormat = 1 Then
        OutlookMailItem.Body = Text     '�ȒP���[�h
    Else
        OutlookMailItem.HTMLBody = Text '�S�{���[�h
    End If
End Function
'------------------------------------------------------------------------------------------------------------------------------
'
' ������ύXor�g���������Ȃ�...
'
'------------------------------------------------------------------------------------------------------------------------------
Public Function GetSubject() As String
    GetSubject = OutlookMailItem.Subject
End Function
Public Function SetSubject(Subject As String) As String
    OutlookMailItem.Subject = Subject
End Function

'�����̐����� �� http://outlook-navi.com/vbs/vbs11.htm
Public Function GetBodyFormat() As Long
    GetBodyFormat = OutlookMailItem.BodyFormat
End Function