Imports System.Text

Public Class TcpCameraConnection
    Inherits TcpConnection

    Public Sub SendAcknowledgement()
        Me.Send("OK") ' & Environment.NewLine)
    End Sub


    Private imgdata() As Byte = Nothing

    Public Function ReceiveImageData(ByVal maxLength As Integer) As Byte()

        Try


            'If Not Me.IsConnected Then Throw New InvalidOperationException("You should connect first")

            'receive any inbound messages
            If stream.DataAvailable Then 'already checked in call

                'load data into buffer
                Dim buffer(maxLength) As Byte 'was maxLength - 1, but TcpConnection used maxLength

                'length will tell how many bytes were actually retrieved
                Dim length As Integer = stream.Read(buffer, 0, buffer.Length)

                'If length <= 5 Then
                'Console.WriteLine(String.Format("[TcpCameraConnection]ReceiveImageData read ONLY {0} bytes from the stream ", length))
                'End If

                'Console.WriteLine(String.Format("[TcpCameraConnection]ReceiveImageData read  {0} bytes from the stream on time {1}m{2}s{3}", length, Now.Minute.ToString, Now.Second.ToString, Now.Millisecond.ToString))


                Dim offset As Integer
                If IsNothing(Me.imgdata) Then
                    'no data available from previous read, start new array
                    offset = 0
                    ReDim imgdata(length - 1)
                Else
                    'expand previously retrieved data and append buffer into it
                    offset = imgdata.Length
                    'ReDim Preserve imgdata(imgdata.Length + length - 1)
                    ReDim Preserve imgdata(offset + length - 1)
                End If

                System.Buffer.BlockCopy(buffer, 0, imgdata, offset, length) 'found out length, no 1
                'buffer = Nothing
#If ORGINEEL Then
        Array.ConstrainedCopy(buffer, 0, imgdata, offset, length - 1) 'should be equivalent with following loop

        'copy buffer into imgdata
        'For i As Integer = 0 To length - 1
        '    imgdata(offset + i) = buffer(i)
        'Next
#End If
                'at this point imgdata may contain a complete or a partial image
                'the first 5 bytes store the type (1 byte) and length (4 bytes)
                'so we need at least that to proceed
                If imgdata.Length > 5 AndAlso imgdata(1) < 127 Then

                    'read the image length from bytes 2 to 5

                    Dim imglength As Integer = CInt(imgdata(1) * 2 ^ 24) + CInt(imgdata(2) * 2 ^ 16) + CInt(imgdata(3) * 2 ^ 8) + CInt(imgdata(4) * 2 ^ 0)

                    'check if we have this image in full in imgdata
                    If imgdata.Length >= imglength + 5 Then

                        'ok we have it, so extract the relevant part
                        Dim curimg() As Byte = Nothing
                        Dim nxtimg() As Byte = Nothing

                        If imgdata.Length = imglength + 5 Then
                            curimg = imgdata
                            nxtimg = Nothing
                            'Console.WriteLine(String.Format("[TcpCameraConnection]ReceiveImageData finished with curimg  of  {0} bytes on time {1}m{2}s{3}", curimg.Length, Now.Minute.ToString, Now.Second.ToString, Now.Millisecond.ToString))


                        ElseIf imgdata.Length > imglength + 5 Then
                            ReDim curimg(imglength + 5 - 1)
                            'Array.ConstrainedCopy(imgdata, 0, curimg, 0, curimg.Length - 1) 'should be equivalent with following loop
                            System.Buffer.BlockCopy(imgdata, 0, curimg, 0, curimg.Length) 'found at in WSSconversation that this equivalent with loop

                            'For i As Integer = 0 To curimg.Length - 1
                            '    curimg(i) = imgdata(i)
                            'Next

                            ReDim nxtimg(imgdata.Length - curimg.Length - 1)
                            System.Buffer.BlockCopy(imgdata, curimg.Length, nxtimg, 0, nxtimg.Length) 'found at in WSSconversation that this equivalent with loop
                            'BlockCopy is faster, according to Jay B. Harlow: http://bytes.com/topic/visual-basic-net/answers/350031-copy-array-array
                            'Console.WriteLine(String.Format("[TcpCameraConnection]ReceiveImageData ready with curimg  of  {0} bytes and continues with nxtmig of {1} bytes on time {2}m{3}s{4}", curimg.Length, nxtimg.Length, Now.Minute.ToString, Now.Second.ToString, Now.Millisecond.ToString))

#If ORIGINAL Then
                        Array.ConstrainedCopy(imgdata, curimg.Length, nxtimg, 0, nxtimg.Length - 1) 'should be equivalent with following loop
#End If
                            'For i As Integer = 0 To nxtimg.Length - 1
                            '    nxtimg(i) = imgdata(curimg.Length + i)
                            'Next

                        End If
                        imgdata = Nothing
                        Me.imgdata = nxtimg
                        Return curimg

                    End If
                Else
                    'Console.WriteLine(String.Format("[TcpCameraConnection] IGNORE ReceiveImageData with length {0}", imgdata.Length))
                End If
            End If 'Stream.DataAvailable
        Catch ex As Exception
            Console.WriteLine(String.Format("[TcpCameraConnection] EXCEPTION in ReceiveImageData with maxLength {0}", maxLength))
            Console.WriteLine(ex)
        End Try

        Return Nothing

    End Function


End Class
