unit uBiblioteca;

interface

uses
  System.SysUtils, IdBaseComponent, IdContext, IdComponent, IdTCPConnection, IdTCPClient, System.Generics.Collections,
  IdGlobal, Classes, Windows,Graphics, Vcl.Forms;
type
  TTipoComando = (tpTeclado, tpMouse, tpDesktop, tpArquivo, tpTexto);
  TComando = record
    TipoComando: TTipoComando;
    Texto: string[255];
    Numero: integer;
  end;
  TEventoMouse = (mMove, mDown, mUp, mCliqueDuplo, mClique);

  TComandoMouse = record
    x: Integer;
    y: Integer;
    BotaoDireito: Boolean;
    TipoEvento: TEventoMouse;
    Alterado: Boolean;
  end;
  TComandoTeclado =  record
    CodigoTecla: word;
    TeclaAuxiliar: TShiftState;
  end;

  TBliblioteca =  class

  private

  public
   class function SendBuffer(AClient: TIdTCPClient; ABuffer: TIdBytes): Boolean; overload;
   class function SendBuffer(AClient: TIdContext; ABuffer: TIdBytes): Boolean; overload;
   class function ReceiveBuffer(AContext: TIdContext; var ABuffer: TIdBytes) : Boolean; overload;
   class function ReceiveBuffer(AClient: TIdTCPClient; var ABuffer: TIdBytes) : Boolean; overload;
  class function SendStream(AContext: TIdTCPClient; AStream: TStream): Boolean; overload;
  class function ReceiveStream(AContext: TIdContext; var AStream: TStream)  : Boolean; overload;
  class procedure GetScreenToBmp(DrawCur:Boolean;Var StreamName:TMemoryStream);
  class procedure CompareStream(MyFirstStream,MySecondStream,MyCompareStream:TMemorystream);
  class procedure ResumeStream(MyFirstStream,MySecondStream,MyCompareStream:TMemorystream);
  class function ScreenShot: TBitmap;
  class function PegarBMP(DrawCur:Boolean): TMemoryStream;
  end;





implementation



{ TComando }



{ TUtility }
{
class function TUtility.ByteArrayComando<TComando>(ABuffer: TBytes): TComando;
var
  LDest: PAnsiChar;
begin
  LDest := PAnsiChar(@Result);
  Move(ABuffer[0], LDest[0], SizeOf(TComando));
end;

class function TUtility.ComandoToByteArray<TComando>(aRecord: TComando): TBytes;
  var
  LSource: PAnsiChar;
begin
  LSource := PAnsiChar(@aRecord);
  SetLength(Result, SizeOf(TComando));
  Move(LSource[0], Result[0], SizeOf(TComando));
end; }

class function TBliblioteca.ReceiveBuffer(AContext: TIdContext; var ABuffer: TIdBytes): Boolean;
var
  LSize: LongInt;
begin
  Result := True;
  try
    LSize := AContext.Connection.IOHandler.ReadLongInt();
    AContext.Connection.IOHandler.ReadBytes(ABuffer, LSize, False);
  except
    Result := False;
  end;
end;

class procedure TBliblioteca.CompareStream(MyFirstStream, MySecondStream, MyCompareStream: TMemorystream);
var
  I: Integer;

  P1, P2, P3: ^AnsiChar;

begin
  MyCompareStream.Clear;
  P1 := MyFirstStream.Memory;
  P2 := MySecondStream.Memory;
  MyCompareStream.SetSize(MyFirstStream.Size);
  P3 := MyCompareStream.Memory;

  for I := 0 to MyFirstStream.Size - 1 do
  begin
    if P1^ = P2^ then
      P3^ := '0'
    else
      P3^ := P2^;
    Inc(P1);
    Inc(P2);
    Inc(P3);
  end;
  MyCompareStream.Position := 0;
end;

class procedure TBliblioteca.GetScreenToBmp(DrawCur: Boolean; var StreamName: TMemoryStream);
var
  Mybmp:Tbitmap;
  Cursorx, Cursory: integer;
  dc: hdc;
  Mycan: Tcanvas;
  R: TRect;
  DrawPos: TPoint;
  MyCursor: TIcon;
  hld: hwnd;
  Threadld: dword;
  mp: tpoint;
  pIconInfo: TIconInfo;
begin
  Mybmp := Tbitmap.Create;
  Mycan := TCanvas.Create;
  dc := GetWindowDC(0);
  try
    Mycan.Handle := dc;
    R := Rect(0, 0,  GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN));
    Mybmp.Width := R.Right;
    Mybmp.Height := R.Bottom;
    Mybmp.Canvas.CopyRect(R, Mycan, R);
  finally
    releaseDC(0, DC);
  end;
  Mycan.Handle := 0;
  Mycan.Free;

  if DrawCur then
  begin
    GetCursorPos(DrawPos);
    MyCursor := TIcon.Create;
    getcursorpos(mp);
    hld := WindowFromPoint(mp);
    Threadld := GetWindowThreadProcessId(hld, nil);
    AttachThreadInput(GetCurrentThreadId, Threadld, True);
    MyCursor.Handle := Getcursor();
    AttachThreadInput(GetCurrentThreadId, threadld, False);
    GetIconInfo(Mycursor.Handle, pIconInfo);
    cursorx := DrawPos.x - round(pIconInfo.xHotspot);
    cursory := DrawPos.y - round(pIconInfo.yHotspot);
    Mybmp.Canvas.Draw(cursorx, cursory, MyCursor);
    DeleteObject(pIconInfo.hbmColor);
    DeleteObject(pIconInfo.hbmMask);
    Mycursor.ReleaseHandle;
    MyCursor.Free;
  end;
  Mybmp.PixelFormat:=pf8bit;
  Mybmp.SaveToStream(StreamName);
  Mybmp.Free;
end;

class function TBliblioteca.PegarBMP(DrawCur: Boolean): TMemoryStream;
begin
  try
    result := TMemoryStream.Create;
   GetScreenToBmp(DrawCur,result);
  except
      on e : Exception do
      raise Exception.Create('erro ao copiar desktop' + e.message);
  end;
end;

class function TBliblioteca.ReceiveBuffer(AClient: TIdTCPClient; var ABuffer: TIdBytes): Boolean;
var
  LSize: LongInt;
begin
  Result := True;
  try
    LSize := AClient.IOHandler.ReadLongInt();
    AClient.IOHandler.ReadBytes(ABuffer, LSize, False);
  except
    Result := False;
  end;
end;

class function TBliblioteca.ReceiveStream(AContext: TIdContext; var AStream: TStream): Boolean;
var
  LSize: LongInt;
begin
  Result := True;
  try
    LSize := AContext.Connection.IOHandler.ReadLongInt();
    AContext.Connection.IOHandler.ReadStream(AStream, LSize, False);
  except
    Result := False;
  end;
end;

class procedure TBliblioteca.ResumeStream(MyFirstStream, MySecondStream, MyCompareStream: TMemorystream);
var
  I: Integer;
  P1, P2, P3: ^AnsiChar;
begin
  MyFirstStream.Position := 0;
  MyCompareStream.Position := 0;
  P1 := MyFirstStream.Memory;
  MySecondStream.SetSize(MyFirstStream.Size);
  MySecondStream.Position :=0;

  P2 := MySecondStream.Memory;
  P3 := MyCompareStream.Memory;

  for I := 0 to MyFirstStream.Size - 1 do
  begin
    if P3^ = '0' then
      P2^ := p1^
    else
      P2^ := P3^;
    Inc(P1);
    Inc(P2);
    Inc(P3);
  end;
end;

class function TBliblioteca.SendBuffer(AClient: TIdTCPClient; ABuffer: TIdBytes): Boolean;
begin
  try
    Result := True;
    try
      AClient.IOHandler.Write(LongInt(Length(ABuffer)));
      AClient.IOHandler.WriteBufferOpen;
      AClient.IOHandler.Write((ABuffer), LongInt(Length(ABuffer)));
      AClient.IOHandler.WriteBufferFlush;
    finally
      AClient.IOHandler.WriteBufferClose;
    end;
  except
    Result := False;
  end;
end;

class function TBliblioteca.ScreenShot: TBitmap;
var
dc: hdc;
cv: TCanvas;
begin
  Result :=  TBitmap.Create;
  Result.Width := Screen.Width;
  Result.Height := Screen.Height;
  dc := GetDC(0);
  cv := TCanvas.Create;
  cv.Handle := dc;
  Result.Canvas.CopyRect(
    Rect( 0,0 ,Screen.Width, Screen.Height),
    cv,
    Rect(0,0,Screen.Width, Screen.Height)
  );
  cv.Free;
  ReleaseDC(0,dc);
end;

class function TBliblioteca.SendBuffer(AClient: TIdContext; ABuffer: TIdBytes): Boolean;
begin
  try
    Result := True;
    try
      AClient.Connection.IOHandler.Write(LongInt(Length(ABuffer)));
      AClient.Connection.IOHandler.WriteBufferOpen;
      AClient.Connection.IOHandler.Write((ABuffer), LongInt(Length(ABuffer)));
      AClient.Connection.IOHandler.WriteBufferFlush;
    finally
      AClient.Connection.IOHandler.WriteBufferClose;
    end;
  except
    Result := False;
  end;
end;

class function TBliblioteca.SendStream(AContext: TIdTCPClient; AStream: TStream): Boolean;
var
  StreamSize: LongInt;
begin
  try
    Result := True;
    try
      StreamSize := (AStream.Size);

      // AStream.Seek(0, soFromBeginning);

      AContext.IOHandler.Write(LongInt(StreamSize));
      AContext.IOHandler.WriteBufferOpen;
      AContext.IOHandler.Write(AStream, 0, False);
      AContext.IOHandler.WriteBufferFlush;
    finally
      AContext.IOHandler.WriteBufferClose;
    end;
  except
    Result := False;
  end;
end;

end.
