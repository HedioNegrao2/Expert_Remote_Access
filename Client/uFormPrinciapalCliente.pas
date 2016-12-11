
unit uFormPrinciapalCliente;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, IdThreadSafe,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, uBiblioteca, Vcl.Buttons, IdAntiFreezeBase, Vcl.IdAntiFreeze,
  IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdIOHandlerStream;

type
  TEnvioDesktop = class(TThread)
    private
      FTCPDesktop: TIdTCPClient;
      FPrimeiroBMP : TMemoryStream;
      FSegundoBMP : TMemoryStream;
      FDiferencaoBMP : TMemoryStream;
    public
      constructor Create( pTCPCliente: TIdTCPClient);
      procedure Execute; override;
  end;

  TReceberMouse = class(TThread)
    private
      FTCPMouse: TIdTCPClient;
      FComandoMouse: TComandoMouse;

      procedure ProcesarComandoMouse;

      procedure Terminar(sender: TObject);
    public
      constructor Create( pMouse: TIdTCPClient);

      procedure Execute; override;
  end;

  TReberTeclado = class(TThread)
     private
      FTCPTeclado2: TIdTCPClient;
      FComandoTeclado: TComandoTeclado;
      procedure ProcessarComandoTeclado;
      public
      procedure Execute; override;

     constructor Create( pTeclado: TIdTCPClient);
  end;





  TFormPrincipalCliente = class(TForm)
    mmo1: TMemo;
    pnl1: TPanel;
    btnConectar: TButton;
    edtIP: TEdit;
    edtPorta: TEdit;
    idtcpclntDesktop: TIdTCPClient;
    btnInicial: TBitBtn;
    idtcpclntTeclado: TIdTCPClient;
    idtcpclntMouse: TIdTCPClient;
    procedure btnConectarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnInicialClick(Sender: TObject);
    procedure idhndlrstck1Status(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);

    procedure idtcpclntDesktopDisconnected(Sender: TObject);
    procedure idtcpclntMouseDisconnected(Sender: TObject);
    procedure idtcpclntTecladoDisconnected(Sender: TObject);
  private
    { Private declarations }
    FId: Integer;
    FEnviaoDesktop: TEnvioDesktop;
    FReceberMouse: TReceberMouse;
    FReceberTeclado: TReberTeclado;
    function Comprimir(pDados: TMemoryStream):boolean;


  public



    { Public declarations }
  end;

var
  FormPrincipalCliente: TFormPrincipalCliente;

implementation

uses
  IdGlobal, ZLib;

{$R *.dfm}

procedure TFormPrincipalCliente.btnInicialClick(Sender: TObject);
begin
  if not FEnviaoDesktop.Started then
    FEnviaoDesktop.Start;
  FReceberMouse.Start;
  FReceberTeclado.Start;
end;

procedure TFormPrincipalCliente.btnConectarClick(Sender: TObject);
var
  linha: string;
  lpBuffer : PChar;
nSize : DWord;
const Buff_Size = MAX_COMPUTERNAME_LENGTH + 1;
begin
  try
    nSize := Buff_Size;
    lpBuffer := StrAlloc(Buff_Size);
    GetComputerName(lpBuffer,nSize);
    idtcpclntDesktop.Host :=  edtIP.Text;
    //idtcpclntDesktop.Host := '127.0.0.1';
    idtcpclntDesktop.Port := StrToInt(edtPorta.Text);
    idtcpclntDesktop.Connect;
    idtcpclntDesktop.Socket.WriteLn('Desktop|' +String(lpBuffer));
    linha := idtcpclntDesktop.IOHandler.ReadLn();
    FId :=  StrToIntDef(linha,0);
    StrDispose(lpBuffer);
    idtcpclntTeclado.Host := idtcpclntDesktop.Host;
    idtcpclntTeclado.port := idtcpclntDesktop.Port;
    idtcpclntTeclado.Connect;
    idtcpclntTeclado.Socket.WriteLn('Teclado|'+InttoSTR(FId));

    idtcpclntMouse.Host := idtcpclntDesktop.Host;
    idtcpclntMouse.port := idtcpclntDesktop.Port;
    idtcpclntMouse.Connect;
    idtcpclntMouse.Socket.WriteLn('Mouse|'+InttoSTR(FId));
  except
    on e : Exception do
    raise Exception.Create('Não foi possível estabelecer conmunicação com o servidor' + sLineBreak + e.Message);
  end
end;

function TFormPrincipalCliente.Comprimir(pDados: TMemoryStream): boolean;
  var
  InputStream,OutputStream :TMemoryStream;
  inbuffer,outbuffer :Pointer;
  count,outcount :longint;
begin
  try
    result := false;
    if not assigned(pDados) then exit;
      InputStream := TMemoryStream.Create;
      OutputStream := TMemoryStream.Create;
    try
      InputStream.LoadFromStream(pDados);
      count := inputstream.Size;
      getmem(inbuffer,count);
      Inputstream.ReadBuffer(inbuffer^,count);
      zcompress(inbuffer,count,outbuffer,outcount,zcMax);
      outputstream.Write(outbuffer^,outcount);
      pDados.Clear;
      pDados.LoadFromStream(OutputStream);
      result :=true;
    finally
      InputStream.Free;
      OutputStream.Free;
      FreeMem(inbuffer, count);
      FreeMem(outbuffer, outcount);
    end;
  except
  raise Exception.Create('Erro a compactar');
  end

end;

procedure TFormPrincipalCliente.FormCreate(Sender: TObject);
begin

  FEnviaoDesktop := TEnvioDesktop.Create(idtcpclntDesktop);
  FReceberMouse := TReceberMouse.Create( idtcpclntMouse);
  FReceberTeclado := TReberTeclado.Create(idtcpclntTeclado);

end;

procedure TFormPrincipalCliente.idhndlrstck1Status(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
begin
  mmo1.Lines.Add(AStatusText) ;
end;

procedure TFormPrincipalCliente.idtcpclntDesktopDisconnected(Sender: TObject);
begin
  FEnviaoDesktop.Terminate;
  FEnviaoDesktop.WaitFor;
  FEnviaoDesktop.Free;
end;

procedure TFormPrincipalCliente.idtcpclntMouseDisconnected(Sender: TObject);
begin
  FReceberMouse.Terminate;
  FReceberMouse.WaitFor;
  FReceberMouse.Free;
end;

procedure TFormPrincipalCliente.idtcpclntTecladoDisconnected(Sender: TObject);
begin
  FReceberTeclado.Terminate;
  FReceberTeclado.WaitFor;
  FReceberTeclado.Free;
end;



{ TManipulador }

constructor TEnvioDesktop.Create(pTCPCliente: TIdTCPClient);
begin
  inherited Create(True);
  FTCPDesktop :=  pTCPCliente;
  FreeOnTerminate := False;

  FPrimeiroBMP := TMemoryStream.Create;
  FSegundoBMP := TMemoryStream.Create;
  FDiferencaoBMP := TMemoryStream.Create;

end;

procedure TEnvioDesktop.Execute;
begin
  inherited;
   try
      while not Self.Terminated and  FTCPDesktop.Connected  do
      begin
        try
          if FPrimeiroBMP.Size > 0 then
          begin
            try
              Synchronize(
              procedure
                begin
                  FSegundoBMP := TBliblioteca.PegarBMP(True);
                  TBliblioteca.CompareStream(FPrimeiroBMP, FSegundoBMP, FDiferencaoBMP);
                  FormPrincipalCliente.Comprimir(FDiferencaoBMP);
                  TBliblioteca.SendStream(FTCPDesktop,TStream(FDiferencaoBMP));
                  FSegundoBMP.Position :=0;
                  FPrimeiroBMP.Clear;
                  FPrimeiroBMP.CopyFrom(FSegundoBMP,0) ;
                  FDiferencaoBMP.Clear;
                  FSegundoBMP.Free;
                end);

            finally

            end;

          end
          else
          begin
            Synchronize(
              procedure
                begin
                  FPrimeiroBMP := TBliblioteca.PegarBMP(false);
                  FDiferencaoBMP.CopyFrom(FPrimeiroBMP,0);
                  FormPrincipalCliente.Comprimir(FDiferencaoBMP);
                  TBliblioteca.SendStream(FTCPDesktop,TStream(FDiferencaoBMP));
                  FDiferencaoBMP.Clear;
                end);

          end;
        except
          on e : Exception do
           ShowMessage(e.Message);
        end;
        Sleep(3);
      end;
   except
      raise Exception.Create('Eerro a executar thread');
   end;
end;

{ TRecebeTecladoMousep }

constructor TReceberMouse.Create( pMouse: TIdTCPClient);
begin
  inherited  Create(True);
  FTCPMouse := pMouse;
  FreeOnTerminate := False;
  OnTerminate := Terminar;
end;

procedure TReceberMouse.Execute;
var
  LBuffer: TIdBytes;
  comando: TComandoMouse;
begin
  inherited;
  while not Self.Terminated and FTCPMouse.Connected  do
  begin
    try
      if not FTCPMouse.IOHandler.InputBufferIsEmpty  then
      begin
        if  TBliblioteca.ReceiveBuffer(FTCPMouse, LBuffer) then
        begin
          BytesToRaw(LBuffer, comando, SizeOf(comando));
          FComandoMouse :=  comando;
          if comando.Alterado then
          Synchronize(ProcesarComandoMouse);
        end;
      end;
    except
      on e:Exception do
        raise Exception.Create(e.Message);
    end;
    Sleep(2);
  end;
end;

procedure TReceberMouse.ProcesarComandoMouse;
begin
  try
    case FComandoMouse.TipoEvento of
      mDown:
      begin
        SetCursorPos(FComandoMouse.x, FComandoMouse.y);
        if FComandoMouse.BotaoDireito then
          mouse_event(MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0)
        else
          mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
      end;
      mUp:
      begin
        SetCursorPos(FComandoMouse.x, FComandoMouse.y);
        if FComandoMouse.BotaoDireito then
           mouse_event(MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0)
        else
           mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
      end;
      mMove: SetCursorPos(FComandoMouse.x, FComandoMouse.y);
      mCliqueDuplo:
      begin
        mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
        Sleep(10);
        mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
        Sleep(10);
        mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
        Sleep(10);
        mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
      end;
      mClique :
      begin
       mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
        Sleep(10);
        mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
        Sleep(10);
      end;

    end;
  except
   raise Exception.Create('Erro ao processar comando mouse');
  end;

end;

procedure TReceberMouse.Terminar(sender: TObject);
begin
  ShowMessage('TErminando');
end;

{ TReberTeclado }

constructor TReberTeclado.Create(pTeclado: TIdTCPClient);
begin
  inherited  Create(True);
  FTCPTeclado2 :=  pTeclado;
end;

procedure TReberTeclado.Execute;
var
  LBuffer: TIdBytes;
  comando: TComandoTeclado;
begin
  inherited;
  while not Self.Terminated and FTCPTeclado2.Connected  do
  begin
    try
      if not FTCPTeclado2.IOHandler.InputBufferIsEmpty  then
      begin
        if  TBliblioteca.ReceiveBuffer(FTCPTeclado2, LBuffer) then
        begin
          BytesToRaw(LBuffer, comando, SizeOf(comando));
          FComandoTeclado :=  comando;
          Synchronize( ProcessarComandoTeclado );
        end;
      end;
    except
      on e:Exception do
        raise Exception.Create(e.Message);
    end;
    Sleep(2);
  end;

end;


procedure TReberTeclado.ProcessarComandoTeclado;
begin
  if  ssShift in FComandoTeclado.TeclaAuxiliar then
  begin
    keybd_event(VK_SHIFT,0,0,0 );
    keybd_event(FComandoTeclado.CodigoTecla,0,0,0 );
    keybd_event(FComandoTeclado.CodigoTecla,0,KEYEVENTF_KEYUP,0 );
    keybd_event(VK_SHIFT,0,KEYEVENTF_KEYUP,0 );
  end
  else
  begin
    keybd_event(FComandoTeclado.CodigoTecla,0,0,0 );
    keybd_event(FComandoTeclado.CodigoTecla,0,KEYEVENTF_KEYUP,0 );
  end;
end;

end.
