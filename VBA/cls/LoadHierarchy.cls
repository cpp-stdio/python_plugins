VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "LoadHierarchy"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'==============================================================================================================================
'
'   �t�H���_�̊K�w�ǂݍ���
'
'==============================================================================================================================
Private Type Access
    name As String             '���O���i�[����
    createdDay As String       '�쐬�����i�[����
    lastAccessedDay As String  '�ŏI�A�N�Z�X�����i�[����
    lastModifiedDay As String  '�ŏI�X�V�����i�[����
    size As Single             '�f�[�^�T�C�Y(byte�P��)
End Type

Dim FileLength As Long   '�t�@�C���p
Dim File() As Access     '�t�@�C���p
Dim FolderLength As Long '�t�H���_�[�p
Dim Folder()  As Access  '�t�H���_�[�p
'------------------------------------------------------------------------------------------------------------------------------
'   �R���X�g���N�^�[
'------------------------------------------------------------------------------------------------------------------------------
Private Sub Class_Initialize()
    Call CloseData
End Sub
'------------------------------------------------------------------------------------------------------------------------------
'   �f�X�g���N�^�[
'------------------------------------------------------------------------------------------------------------------------------
Private Sub Class_Terminate()
    Call CloseData
End Sub
'------------------------------------------------------------------------------------------------------------------------------
'   �K�w�ǂݍ���(�{��) : �t�H���_��t�@�C���Ƀ��b�N���������Ă�����͓̂ǂݍ��߂Ȃ��̂Œ���
'   �߂�l(Boolean�^) : ����(True) , �G���[(False)
'
'   FolderHierarchy   : �t�H���_�[�̊K�w��ǂݍ��ރp�X��
'   DeepFolder        : ����ɐ[���K�w���ǂ��܂œǂނ̂��B���̐��͖�����A0�͂��̏�̂�
'   FullPathFlag      : �t���p�X�Ŏ擾���邪�B     �͂�(True) ������(False)�F�����l(True)
'------------------------------------------------------------------------------------------------------------------------------
Public Function Search(ByVal FolderHierarchyPath As String, Optional ByVal DeepFolder As Long = -1, Optional ByVal FullPathFlag As Boolean = True) As Boolean
    Search = False '�܂��͎��s����O��Řb��i�߂�B
    
    '����������Ă��Ȃ���Ԃ̓G���[�Ƃ���B
    If StrComp(FolderHierarchyPath, "", vbTextCompare) = 0 Then Exit Function
    
    Dim FSO As Object
    Set FSO = CreateObject("Scripting.FileSystemObject")
     
    '�t�H���_�����݂��邩�ǂ����H
    If Not FSO.FolderExists(FolderHierarchyPath) Then
        Set FSO = Nothing
        Exit Function
    End If
    
    Dim obj As Object
    '���̃p�X�ɑ��݂��邷�ׂẴt�H���_�[�����擾����B
    For Each obj In FSO.getFolder(FolderHierarchyPath).Files
        ReDim Preserve File(FileLength)
        If FullPathFlag Then
            File(FileLength).name = FolderHierarchyPath + "\" + obj.name
        Else
            File(FileLength).name = obj.name
        End If
        File(FileLength).createdDay = CStr(obj.DateCreated)
        File(FileLength).lastModifiedDay = CStr(obj.DateLastModified)
        File(FileLength).lastAccessedDay = CStr(obj.DateLastAccessed)
        File(FileLength).size = obj.size
        FileLength = FileLength + 1
    Next obj
    
     '���̃p�X�ɑ��݂��邷�ׂẴt�H���_�[�����擾���A�ċN�������s��
    For Each obj In FSO.getFolder(FolderHierarchyPath).SubFolders
        ReDim Preserve Folder(FolderLength)
        Folder(FolderLength).name = CStr(obj.Path)
        Folder(FolderLength).createdDay = CStr(obj.DateCreated)
        Folder(FolderLength).lastModifiedDay = CStr(obj.DateLastModified)
        Folder(FolderLength).lastAccessedDay = CStr(obj.DateLastAccessed)
        Folder(FolderLength).size = obj.size
        FolderLength = FolderLength + 1
        '�ċN�����J�n
        If DeepFolder >= 0 Then
            If Not DeepFolder = 0 Then
                Call Search(CStr(obj.Path), DeepFolder - 1, FullPathFlag)
            End If
        Else
            Call Search(CStr(obj.Path), -1, FullPathFlag)
        End If
    Next obj
    
    Set obj = Nothing
    Set FSO = Nothing
    Search = True '�Ō�܂ŗ����̂Ő����Ƃ݂Ȃ��B
End Function
'------------------------------------------------------------------------------------------------------------------------------
'   ����̊g���q�ɍi�荞�� ����Search���Ɏ��s���ĂȂ��ƈӖ��Ȃ��B(���O�ɃR�s�[���邱�Ƃ��������߂���)
'   �����̊֐��ɐ��������ꍇ�A�t�H���_�[�̏��͑S�č폜�����B
'   �߂�l(Boolean�^) : ����(True) , �G���[(False)
'
'   ExtensionName : ��.�e�L�X�g(.txt)�̏ꍇ"txt"�Ɠ��͂��āB�ŏ��̃h�b�g�͕s�v
'------------------------------------------------------------------------------------------------------------------------------
Public Function ExtensionSearch(ByVal ExtensionName As String) As Boolean
    ExtensionSearch = False
    '�f�[�^���Ȃ��ꍇ�͏����ł��Ȃ�
    If FileLength = 0 Then Exit Function
    
    Dim i As Long
    Dim count As Long: count = 0
    Dim Temporary() As Access
    
    For i = 0 To FileLength - 1
        '��ԍŌオ�g���q
        Dim extension As Variant
        extension = Split(File(i).name, ".")
        'OS�̎d�l��A�啶���������͓����g���q
        If StrComp(UCase(ExtensionName), UCase(extension(UBound(extension))), vbBinaryCompare) = 0 Then
            ReDim Preserve Temporary(count)
            Temporary(count) = File(i)
            count = count + 1
        End If
    Next i
    '���̊g���q���Ȃ��ꍇ�͍č\�z�͂��Ȃ�
    If count <= 0 Then
        Exit Function
    End If
    
    '�f�[�^�̍č\�z
    Call CloseData
    FileLength = count
    ReDim File(FileLength - 1)
    File = Temporary
    ExtensionSearch = True
End Function
'------------------------------------------------------------------------------------------------------------------------------
'   �N���[�Y
'------------------------------------------------------------------------------------------------------------------------------
Public Function CloseData()
    FileLength = 0
    FolderLength = 0
    ReDim File(FileLength)
    ReDim Folder(FolderLength)
End Function
'==============================================================================================================================
'   �t�@�C���Q�b�^�[
'==============================================================================================================================
Public Function getFileLength() As Long
    getFileLength = FileLength - 1 'For�����~�߂��
End Function
'�t�@�C�������擾����
Public Function getFileName(ByVal Index As Long) As String
    If Index >= 0 And Index <= getFileLength() Then
        getFileName = File(Index).name
    Else
        getFileName = "" '�\���p
    End If
End Function
'�쐬�����擾����
Public Function getFileCreatedDay(ByVal Index As Long) As String
    If Index >= 0 And Index <= getFileLength() Then
        getFileCreatedDay = File(Index).createdDay
    Else
        getFileCreatedDay = "" '�\���p
    End If
End Function
'�ŏI�X�V�����擾����
Public Function getFileLastModifiedDay(ByVal Index As Long) As String
    If Index >= 0 And Index <= getFileLength() Then
        getFileLastModifiedDay = File(Index).lastModifiedDay
    Else
        getFileLastModifiedDay = "" '�\���p
    End If
End Function
'�ŏI�A�N�Z�X�����擾����
Public Function getFileLastAccessedDay(ByVal Index As Long) As String
    If Index >= 0 And Index <= getFileLength() Then
        getFileLastAccessedDay = File(Index).lastAccessedDay
    Else
        getFileLastAccessedDay = "" '�\���p
    End If
End Function
'�o�C�g�����擾����
Public Function getFileByteSize(ByVal Index As Long) As Single
    If Index >= 0 And Index <= getFileLength() Then
        getFileByteSize = File(Index).size
    Else
        getFileByteSize = 0
    End If
End Function
'==============================================================================================================================
'   �t�H���_�Q�b�^�[
'==============================================================================================================================
Public Function getFolderLength() As Long
    getFolderLength = FolderLength - 1 'For�����~�߂��
End Function
'�t�@�C�������擾����
Public Function getFolderName(ByVal Index As Long) As String
    If Index >= 0 And Index <= getFolderLength() Then
        getFolderName = Folder(Index).name
    Else
        getFolderName = "" '�\���p
    End If
End Function
'�쐬�����擾����
Public Function getFolderCreatedDay(ByVal Index As Long) As String
    If Index >= 0 And Index <= getFolderLength() Then
        getFolderCreatedDay = Folder(Index).createdDay
    Else
        getFolderCreatedDay = "" '�\���p
    End If
End Function
'�ŏI�X�V�����擾����
Public Function getFolderLastModifiedDay(ByVal Index As Long) As String
    If Index >= 0 And Index <= getFolderLength() Then
        getFolderLastModifiedDay = Folder(Index).lastModifiedDay
    Else
        getFolderLastModifiedDay = "" '�\���p
    End If
End Function
'�ŏI�A�N�Z�X�����擾����
Public Function getFolderLastAccessedDay(ByVal Index As Long) As String
    If Index >= 0 And Index <= getFolderLength() Then
        getFolderLastAccessedDay = Folder(Index).lastAccessedDay
    Else
        getFolderLastAccessedDay = "" '�\���p
    End If
End Function
'�o�C�g�����擾����
Public Function getFolderByteSize(ByVal Index As Long) As Single
    If Index >= 0 And Index <= getFolderLength() Then
        getFolderByteSize = Folder(Index).size
    Else
        getFolderByteSize = 0
    End If
End Function