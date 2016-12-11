unit uUtility;

interface

uses
  System.SysUtils, IdBaseComponent, IdContext, IdComponent, IdTCPConnection, IdTCPClient, System.Generics.Collections,
  IdGlobal, Classes;
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

  TUtility =  class

  private

  public
   class function SendBuffer(AClient: TIdTCPClient; ABuffer: TIdBytes): Boolean; overload;
   class function SendBuffer(AClient: TIdContext; ABuffer: TIdBytes): Boolean; overload;
   class function ReceiveBuffer(AContext: TIdContext; var ABuffer: TIdBytes) : Boolean; overload;
   class function ReceiveBuffer(AClient: TIdTCPClient; var ABuffer: TIdBytes) : Boolean; overload;
 //  class function ByteArrayComandod<TComando>(ABuffer: TBytes):TComando;
  // class function ComandoToByteArray<TComando>(aRecord: TComando): TBytes;
  class function SendStream(AContext: TIdTCPClient; AStream: TStream): Boolean; overload;
  function ReceiveStream(AContext: TIdContext; var AStream: TStream)  : Boolean; overload;
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

class function TUtility.ReceiveBuffer(AContext: TIdContext; var ABuffer: TIdBytes): Boolean;
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

class function TUtility.ReceiveBuffer(AClient: TIdTCPClient; var ABuffer: TIdBytes): Boolean;
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

function TUtility.ReceiveStream(AContext: TIdContext; var AStream: TStream): Boolean;
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

class function TUtility.SendBuffer(AClient: TIdTCPClient; ABuffer: TIdBytes): Boolean;
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

class function TUtility.SendBuffer(AClient: TIdContext; ABuffer: TIdBytes): Boolean;
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

class function TUtility.SendStream(AContext: TIdTCPClient; AStream: TStream): Boolean;
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
