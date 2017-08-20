Attribute VB_Name = "excel������CAD"

Public Sub ExcelTabletoCAD()

    'Excel���CAD
    'On Error Resume Next
    '��AutoCAD���������ã��������£�������'��ͷ�����Ϊע�ͣ���
    Dim acadApp   As Object '����AutoCADӦ�ó���������

    Dim circleObj As Object, textObj As Object '����AutoCAD�еĶ������,Բ,�ı�

    Dim lineobj   As Object, layerObj As Object '����AutoCAD�еĶ������,ֱ��,ͼ��

    'On Error Resume Next
    Set acadApp = GetObject(, "AutoCAD.Application") '��AutoCAD�������������Ķ���ʵ��
    '        If Err Then  '���AutoCADû������
    '            Err.Clear
    '            Set acadApp = CreateObject("AutoCAD.Application") '����AutoCADӦ�ó������ʵ��
    '                If Err Then  '��û�а�װAutoCAD
    '                MsgBox Err.Description
    '                Exit Sub
    '                End If
    '        End If
    acadApp.Visible = True '��Excel�еġ����㡱���ж�ȡ�����ߵ�����꣬��AutoCAD��չ�㣬�������£� '������ͼ��,����"��",����ɫΪ��ɫ,����Ϊ��ǰ��

    Dim acadDoc As AcadDocument

    Set acadDoc = acadApp.ActiveDocument
    '  AcadApp.ActiveDocument.ActiveSpace = acModelSpace
    '**********ѡ��cad�еĶ����
    
    ' ����ExcelӦ�ó���
    Dim xlApp As Excel.Application

    Set xlApp = GetObject(, "Excel.Application")

    If Err Then
        MsgBox " Excel Ӧ�ó���û�����С������� Excel ���������г���"
        Exit Sub

    End If

    Dim xlSheet As Worksheet

    Set xlSheet = xlApp.ActiveSheet
    
    ' �������ǽ�������ɿ�ķ�ʽ�����Ը�����Ҫȡ�ᡣ
    'Dim iPt(0 To 2) As Double
    'iPt(0) = 0: iPt(1) = 0: iPt(2) = 0
    Dim BlockObj As AcadBlock

    Set BlockObj = acadDoc.Blocks("*Model_Space")

    Dim iPt As Variant

    iPt = acadDoc.Utility.GetPoint(, "ָ�����Ĳ����: ")

    If IsEmpty(iPt) Then Exit Sub

    Dim xlRange As Range

    Debug.Print xlSheet.UsedRange.Address

    For Each xlRange In xlSheet.UsedRange

        AddLine BlockObj, iPt, xlRange
        AddText BlockObj, iPt, xlRange
    Next
    Set xlRange = Nothing
    Set xlSheet = Nothing
    Set xlApp = Nothing

End Sub

'�߿�������ϸ
Function LineWidth(ByVal xlBorder As Border) As Double

    Select Case xlBorder.Weight

        Case xlThin
            LineWidth = 0

        Case xlMedium
            LineWidth = 0.35

        Case xlThick
            LineWidth = 0.7

        Case Else
            LineWidth = 0

    End Select

End Function

'�߿�������ɫ���������ɫ��ȫ�����Լ����
Function LineColor(ByVal xlBorder As Border) As Integer

    Select Case xlBorder.ColorIndex

        Case xlAutomatic
            LineColor = acByLayer

        Case 3
            LineColor = acRed

        Case 4
            LineColor = acGreen

        Case 5
            LineColor = acBlue

        Case 6
            LineColor = acYellow

        Case 8
            LineColor = acCyan

        Case 9
            LineColor = acMagenta

        Case Else
            LineColor = acByLayer

    End Select

End Function

'���Ʊ߿�
Sub AddLine(ByRef BlockObj As AcadBlock, ByVal iPt As Variant, ByVal xlRange As Range)

    If xlRange.Borders(xlEdgeLeft).LineStyle = xlNone And xlRange.Borders(xlEdgeBottom).LineStyle = xlNone And xlRange.Borders(xlEdgeRight).LineStyle = xlNone And xlRange.Borders(xlEdgeTop).LineStyle = xlNone Then Exit Sub

    Dim rl As Double

    Dim rt As Double

    Dim rw As Double

    Dim rh As Double

    rl = PToM(xlRange.Left)
    rt = PToM(xlRange.Top)
    rw = PToM(xlRange.Width)
    rh = PToM(xlRange.Height)

    Dim pPt(0 To 3) As Double

    Dim pLineObj    As AcadLWPolyline
        
    ' ��߿�Ĵ�������һ�в�������
    If xlRange.Borders(xlEdgeLeft).LineStyle <> xlNone And xlRange.Column = 1 Then
        pPt(0) = iPt(0) + rl: pPt(1) = iPt(1) - rt
        pPt(2) = iPt(0) + rl: pPt(3) = iPt(1) - (rt + rh)
        Set pLineObj = BlockObj.AddLightWeightPolyline(pPt)
        pLineObj.ConstantWidth = LineWidth(xlRange.Borders(xlEdgeLeft))
        pLineObj.color = LineColor(xlRange.Borders(xlEdgeLeft))

    End If
        
    ' �±߿�Ĵ������ںϲ���Ԫ��ֻ�������һ�С�
    If xlRange.Borders(xlEdgeBottom).LineStyle <> xlNone And (xlRange.Row = xlRange.MergeArea.Row + xlRange.MergeArea.Rows.Count - 1) Then
        pPt(0) = iPt(0) + rl: pPt(1) = iPt(1) - (rt + rh)
        pPt(2) = iPt(0) + rl + rw: pPt(3) = iPt(1) - (rt + rh)
        Set pLineObj = BlockObj.AddLightWeightPolyline(pPt)
        pLineObj.ConstantWidth = LineWidth(xlRange.Borders(xlEdgeBottom))
        pLineObj.color = LineColor(xlRange.Borders(xlEdgeBottom))

    End If
        
    ' �ұ߿�Ĵ������ںϲ���Ԫ��ֻ�������һ�С�
    If xlRange.Borders(xlEdgeRight).LineStyle <> xlNone And (xlRange.Column >= xlRange.MergeArea.Column + xlRange.MergeArea.Columns.Count - 1) Then
        pPt(0) = iPt(0) + rl + rw: pPt(1) = iPt(1) - (rt + rh)
        pPt(2) = iPt(0) + rl + rw: pPt(3) = iPt(1) - rt
        Set pLineObj = BlockObj.AddLightWeightPolyline(pPt)
        pLineObj.ConstantWidth = LineWidth(xlRange.Borders(xlEdgeRight))
        pLineObj.color = LineColor(xlRange.Borders(xlEdgeRight))

    End If
        
    ' �ϱ߿�Ĵ�������һ�в�������
    If xlRange.Borders(xlEdgeTop).LineStyle <> xlNone And xlRange.Row = 1 Then
        pPt(0) = iPt(0) + rl + rw: pPt(1) = iPt(1) - rt
        pPt(2) = iPt(0) + rl: pPt(3) = iPt(1) - rt
        Set pLineObj = BlockObj.AddLightWeightPolyline(pPt)
        pLineObj.ConstantWidth = LineWidth(xlRange.Borders(xlEdgeTop))
        pLineObj.color = LineColor(xlRange.Borders(xlEdgeTop))

    End If

    Set pLineObj = Nothing

End Sub
    
'�����ı�
    
Sub AddText(ByRef BlockObj As AcadBlock, _
            ByVal InsertionPoint As Variant, _
            ByVal xlRange As Range)

    '��AutoCAD���������ã��������£�������'��ͷ�����Ϊע�ͣ���
    Dim acadApp   As Object '����AutoCADӦ�ó���������

    Dim circleObj As Object, textObj As Object '����AutoCAD�еĶ������,Բ,�ı�

    Dim lineobj   As Object, layerObj As Object '����AutoCAD�еĶ������,ֱ��,ͼ��

    'On Error Resume Next
    Set acadApp = GetObject(, "AutoCAD.Application") '��AutoCAD�������������Ķ���ʵ��
    '        If Err Then  '���AutoCADû������
    '            Err.Clear
    '            Set acadApp = CreateObject("AutoCAD.Application") '����AutoCADӦ�ó������ʵ��
    '                If Err Then  '��û�а�װAutoCAD
    '                MsgBox Err.Description
    '                Exit Sub
    '                End If
    '        End If
    acadApp.Visible = True '��Excel�еġ����㡱���ж�ȡ�����ߵ�����꣬��AutoCAD��չ�㣬�������£� '������ͼ��,����"��",����ɫΪ��ɫ,����Ϊ��ǰ��

    Dim acadDoc As AcadDocument

    Set acadDoc = acadApp.ActiveDocument
    '  AcadApp.ActiveDocument.ActiveSpace = acModelSpace
    '**********ѡ��cad�еĶ����
        
    If xlRange.text = "" Then Exit Sub

    Dim rl As Double

    Dim rt As Double

    Dim rw As Double

    Dim rh As Double

    rl = PToM(xlRange.Left)
    rt = PToM(xlRange.Top)
    rw = PToM(xlRange.MergeArea.Width)
    rh = PToM(xlRange.MergeArea.Height)

    Dim i As Integer

    Dim s As String

    For i = 1 To Len(xlRange.text) '��EXCEL�Ļ��з��滻��P��ע�������R2002���Ͽ�ʹ��Replace������

        If Asc(Mid(xlRange.text, i, 1)) = 10 Then
            s = s & "P"
        Else
            s = s & Mid(xlRange.text, i, 1)

        End If

    Next

    Dim iPt(0 To 2) As Double

    iPt(0) = InsertionPoint(0) + rl: iPt(1) = InsertionPoint(1) - rt: iPt(2) = 0

    Dim mTextObj As AcadMText

    Set mTextObj = BlockObj.AddMText(iPt, rw, s) '"{f" & xlRange.Font.Name & ";" & s & "}")
    mTextObj.LineSpacingFactor = 0.75
    mTextObj.Height = PToM(xlRange.Font.Size)
        
    ' �������ֵĶ��뷽ʽ
    Dim tPt As Variant

    If xlRange.VerticalAlignment = xlTop And (xlRange.HorizontalAlignment = xlLeft Or xlRange.HorizontalAlignment = xlGeneral) Then
        mTextObj.AttachmentPoint = acAttachmentPointTopLeft
        tPt = iPt
    ElseIf xlRange.VerticalAlignment = xlTop And xlRange.HorizontalAlignment = xlCenter Then
        mTextObj.AttachmentPoint = acAttachmentPointTopCenter
        tPt = acadDoc.Utility.PolarPoint(iPt, 0, rw / 2)
    ElseIf xlRange.VerticalAlignment = xlTop And xlRange.HorizontalAlignment = xlRight Then
        mTextObj.AttachmentPoint = acAttachmentPointTopRight
        tPt = acadDoc.Utility.PolarPoint(iPt, 0, rw)
    ElseIf xlRange.VerticalAlignment = xlCenter And (xlRange.HorizontalAlignment = xlLeft Or xlRange.HorizontalAlignment = xlGeneral) Then
        mTextObj.AttachmentPoint = acAttachmentPointMiddleLeft
        tPt = acadDoc.Utility.PolarPoint(iPt, -1.5707963, rh / 2)
    ElseIf xlRange.VerticalAlignment = xlCenter And xlRange.HorizontalAlignment = xlCenter Then
        mTextObj.AttachmentPoint = acAttachmentPointMiddleCenter
        tPt = acadDoc.Utility.PolarPoint(iPt, -1.5707963, rh / 2)
        tPt = acadDoc.Utility.PolarPoint(tPt, 0, rw / 2)
    ElseIf xlRange.VerticalAlignment = xlCenter And xlRange.HorizontalAlignment = xlRight Then
        mTextObj.AttachmentPoint = acAttachmentPointMiddleRight
        tPt = acadDoc.Utility.PolarPoint(iPt, -1.5707963, rh / 2)
        tPt = acadDoc.Utility.PolarPoint(tPt, 0, rw / 2)
    ElseIf xlRange.VerticalAlignment = xlBottom And (xlRange.HorizontalAlignment = xlLeft Or xlRange.HorizontalAlignment = xlGeneral) Then
        mTextObj.AttachmentPoint = acAttachmentPointBottomLeft
        tPt = acadDoc.Utility.PolarPoint(iPt, -1.5707963, rh)
    ElseIf xlRange.VerticalAlignment = xlBottom And xlRange.HorizontalAlignment = xlCenter Then
        mTextObj.AttachmentPoint = acAttachmentPointBottomCenter
        tPt = acadDoc.Utility.PolarPoint(iPt, -1.5707963, rh)
        tPt = acadDoc.Utility.PolarPoint(tPt, 0, rw / 2)
    ElseIf xlRange.VerticalAlignment = xlBottom And xlRange.HorizontalAlignment = xlRight Then
        mTextObj.AttachmentPoint = acAttachmentPointBottomRight
        tPt = acadDoc.Utility.PolarPoint(iPt, -1.5707963, rh)
        tPt = acadDoc.Utility.PolarPoint(tPt, 0, rw)

    End If

    mTextObj.InsertionPoint = tPt
    Set mTextObj = Nothing

End Sub
    
' ������ɺ���
    
' ע�����岻��ת���ĳߴ���ƫ�����Լ��趨һ��ת������
    
Function PToM(ByVal Points As Double) As Double
    PToM = Points * 0.3527778

End Function

