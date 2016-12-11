unit uFrmVisualizadorPC;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, uBiblioteca,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdContext, IdBaseComponent, IdAntiFreezeBase, Vcl.IdAntiFreeze,
  Vcl.ExtCtrls;

type
  TFrmVisualizadorPC = class;
  TWiewPc = class(TThread)

   private
     FContexto : TIdContext;
     Fform: TFrmVisualizadorPC;
     FLinha: string;
     FPrimeiroBMP : TMemoryStream;
     FSegundoBMP : TMemoryStream;
     FDiferencaBMP : TMemoryStream;

     procedure Adicianar();
    public

    constructor Create(aSocket: TIdContext; form: TFrmVisualizadorPC);
    procedure Execute; override;
    destructor Destroy;

  end;

  TFrmVisualizadorPC = class(TForm)
    lblTeste: TLabel;
    tmrMonitoraTeclado: TTimer;
    scrlbx1: TScrollBox;
    imgDesktop: TImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure imgDesktopMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure imgDesktopMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure imgDesktopMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure imgDesktopDblClick(Sender: TObject);
    procedure tmrMonitoraTecladoTimer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure imgDesktopClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

  private
    FContexto: TIdContext;
    FThreadPC: TWiewPc;
    Fx: Integer;
    FY: Integer;
    FContextoMause: TIdContext;
    FContextoTeclado: TIdContext;
    FId: Integer;
    procedure SetContexto(const Value: TIdContext);
    procedure Setx(const Value: Integer);
    procedure SetY(const Value: Integer);
    procedure SetContextoMause(const Value: TIdContext);
    procedure SetContextoTeclado(const Value: TIdContext);
    procedure SetId(const Value: Integer);
    procedure EnviaDadosMouse(var pComandoMouse: TComandoMouse);

    procedure EnviarDadoTeclado( pComandoTeclado: TComandoTeclado);
    function GetShiftState: TShiftState;


    { Private declarations }
  public
    { Public declarations }
    property Id: Integer read FId write SetId;
    property cx: Integer read Fx write Setx;
    property cY: Integer read FY write SetY;
    property ContextoDesktop: TIdContext read FContexto write SetContexto;
    property ContextoTeclado: TIdContext read FContextoTeclado write SetContextoTeclado;
    property ContextoMause: TIdContext read FContextoMause write SetContextoMause;
    function Descomprimir(pDado: TMemoryStream):boolean;
    procedure Iniciar;
    procedure Ajustar;
  end;


var
  FrmVisualizadorPC: TFrmVisualizadorPC;

implementation

uses
  IdGlobal, ZLib;

{$R *.dfm}

{ TWiewPc }

procedure TWiewPc.Adicianar;
begin
   Application.ProcessMessages;
end;

constructor TWiewPc.Create(aSocket: TIdContext; form: TFrmVisualizadorPC);
begin
  inherited Create(True);
  FContexto := aSocket;
  Fform := form;
   FPrimeiroBMP := TMemoryStream.Create;
    FSegundoBMP := TMemoryStream.Create;
    FDiferencaBMP := TMemoryStream.Create;
end;

destructor TWiewPc.Destroy;
begin
  inherited;
  FPrimeiroBMP.Free;
  FSegundoBMP.Free;
  FDiferencaBMP.Free;
end;

procedure TWiewPc.Execute;
var
  LSize: LongInt;
begin
  inherited;

  if not Assigned(FContexto)  then
    Exit;
  if not   Assigned( FContexto.Connection) then
    Exit;

  while (not Self.Terminated) and FContexto.Connection.Connected do
  begin
    if not FContexto.Connection.IOHandler.InputBufferIsEmpty  then
    begin
      FDiferencaBMP.Clear;
      FDiferencaBMP.Clear;
      LSize := FContexto.Connection.IOHandler.ReadLongInt();
      FContexto.Connection.IOHandler.ReadStream(TStream(FDiferencaBMP), LSize, False);
      try
        Fform.Descomprimir(FDiferencaBMP);
        if FPrimeiroBMP.Size = 0 then
        begin
          Fform.imgDesktop.Picture.Bitmap.LoadFromStream(FDiferencaBMP) ;
          FDiferencaBMP.Position := 0;
          FPrimeiroBMP.CopyFrom(FDiferencaBMP,0);

        end
        else
        begin
          TBliblioteca.ResumeStream(FPrimeiroBMP,FSegundoBMP,FDiferencaBMP);
          Fform.imgDesktop.Picture.Bitmap.LoadFromStream(FSegundoBMP);

          FSegundoBMP.Position :=0;
          FPrimeiroBMP.CopyFrom(FSegundoBMP,0);
          FSegundoBMP.Clear;

        end;

      except
        // Fform.img1.Picture.Bitmap.Free;
      end;
      Fform.Width := Fform.imgDesktop.Width+80;
      Fform.Height := Fform.imgDesktop.Height+80;
      Fform.cX := Fform.imgDesktop.Width;
      Fform.cY := Fform.imgDesktop.Height;
      Synchronize(Fform.Ajustar);
    end;
      FSegundoBMP.Clear;
      FDiferencaBMP.Clear;
    Sleep(2);
  end;
end;

{ TFormViewPC }

procedure TFrmVisualizadorPC.Ajustar;
begin
  lblTeste.Caption := DateToStr(now);
  Application.ProcessMessages;
 end;

function TFrmVisualizadorPC.Descomprimir(pDado: TMemoryStream): boolean;
var
  InputStream,OutputStream :TMemoryStream;
  inbuffer,outbuffer :Pointer;
  count,outcount :longint;
begin
  result := false;
  if not assigned(pDado) then
    exit;

  InputStream := TMemoryStream.Create;
  OutputStream := TMemoryStream.Create;
  try
    InputStream.LoadFromStream(pDado);
    count := inputstream.Size;
    getmem(inbuffer,count);
    Inputstream.ReadBuffer(inbuffer^,count);
    zdecompress(inbuffer,count,outbuffer,outcount);
    outputstream.Write(outbuffer^,outcount);
    pDado.Clear;
    pDado.LoadFromStream(OutputStream);
    result :=true;
  finally
    InputStream.Free;
    OutputStream.Free;
    FreeMem(inbuffer, count);
    FreeMem(outbuffer, outcount);
  end;
end;

procedure TFrmVisualizadorPC.EnviaDadosMouse(var pComandoMouse: TComandoMouse);
  var
  LBuffer: TIdBytes;
begin

   if not Assigned(FContextoMause)  then
    Exit;
  if not   Assigned( FContextoMause.Connection) then
    Exit;

  try
    if FContextoMause.Connection.Connected then
    begin
      pComandoMouse.Alterado := True;
      LBuffer := RawToBytes(pComandoMouse, SizeOf(pComandoMouse));
      TBliblioteca.SendBuffer(FContextoMause,LBuffer);
    end;
   except
    on e: exception do
      raise Exception.Create('Erro ao enviar comando do Mouse' +sLineBreak + E.Message);
   end;
end;


procedure TFrmVisualizadorPC.EnviarDadoTeclado( pComandoTeclado: TComandoTeclado);
var
  LBuffer: TIdBytes;
begin
   if not Assigned(FContextoTeclado)  then
    Exit;
  if not   Assigned( FContextoTeclado.Connection) then
    Exit;
  try
    if FContextoTeclado.Connection.Connected then
    begin
      LBuffer := RawToBytes(pComandoTeclado, SizeOf(pComandoTeclado));
      TBliblioteca.SendBuffer(FContextoTeclado,LBuffer);
    end;
   except
    on e: exception do
      raise Exception.Create('Erro ao enviar comando do Mouse' +sLineBreak + E.Message);
   end;
   Application.ProcessMessages;

end;

procedure TFrmVisualizadorPC.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  tmrMonitoraTeclado.Enabled :=  False;
  FThreadPC.Terminate;
  FThreadPC.WaitFor;
  FThreadPC.Free;
  if Assigned(FContexto) and FContexto.Connection.Connected then
    FContexto.Connection.Disconnect;
  Action := caFree;
  Self := nil;
end;

procedure TFrmVisualizadorPC.FormCreate(Sender: TObject);
begin

 // ShowMessage('Iniciando');
end;

procedure TFrmVisualizadorPC.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  var
  comandoTeclado: TComandoTeclado;
begin
   if not Assigned(FContextoTeclado)  then
    Exit;
  if not   Assigned( FContextoTeclado.Connection) then
    Exit;

  if FContextoTeclado.Connection.Connected  then
  begin
    comandoTeclado.CodigoTecla := Key;
    comandoTeclado.TeclaAuxiliar := Shift;
    EnviarDadoTeclado(comandoTeclado);
  end;
end;





procedure TFrmVisualizadorPC.FormResize(Sender: TObject);
begin
   imgDesktop.left := trunc((scrlbx1.width - imgDesktop.width) / 2);
  imgDesktop.top := trunc((scrlbx1.height - imgDesktop.height) / 2);
end;


function TFrmVisualizadorPC.GetShiftState: TShiftState;
begin
  Result := [];
  if GetKeyState(VK_SHIFT) < 0 then
  Include(Result, ssShift);
  if GetKeyState(VK_CONTROL) < 0 then
  Include(Result, ssCtrl);
  if GetKeyState(VK_MENU) < 0 then
  Include(Result, ssAlt);
end;

procedure TFrmVisualizadorPC.imgDesktopClick(Sender: TObject);
var
  enventoMose: TComandoMouse;
begin
  if Active = false then
    exit;
  enventoMose.TipoEvento := mClique;
  EnviaDadosMouse(enventoMose);
end;

procedure TFrmVisualizadorPC.imgDesktopDblClick(Sender: TObject);
var
  enventoMose: TComandoMouse;
begin
  if Active = false then
    exit;
  enventoMose.TipoEvento := mCliqueDuplo;
  EnviaDadosMouse(enventoMose);
end;

procedure TFrmVisualizadorPC.imgDesktopMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  enventoMose: TComandoMouse;
begin
  if Active = false then
    exit;
  enventoMose.x := (X * cX) div imgDesktop.Width;
  enventoMose.y := (Y * cY) div imgDesktop.Height;
  enventoMose.TipoEvento := mDown;
  if Button = mbRight then
    enventoMose.BotaoDireito := True
  else
    enventoMose.BotaoDireito := False;

   EnviaDadosMouse(enventoMose);
end;

procedure TFrmVisualizadorPC.imgDesktopMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  enventoMose: TComandoMouse;
begin
  if Active = false then
    exit;
  enventoMose.x := (X * cX) div imgDesktop.Width;
  enventoMose.y := (Y * cY) div imgDesktop.Height;
  enventoMose.TipoEvento := mMove;
  EnviaDadosMouse(enventoMose);
end;

procedure TFrmVisualizadorPC.imgDesktopMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  enventoMose: TComandoMouse;
begin
  if Active = false then
    exit;
  enventoMose.x := (X * cX) div imgDesktop.Width;
  enventoMose.y := (Y * cY) div imgDesktop.Height;
  enventoMose.TipoEvento := mUp;
  if Button = mbRight then

    enventoMose.BotaoDireito := True
  else
    enventoMose.BotaoDireito := false;

  EnviaDadosMouse(enventoMose);

end;

procedure TFrmVisualizadorPC.Iniciar;
begin
 FThreadPC.Start;
 Self.ShowModal;
end;

procedure TFrmVisualizadorPC.SetContexto(const Value: TIdContext);
begin
  FContexto := Value;
  if not Assigned(FThreadPC) then
  begin
     FThreadPC := TWiewPc.Create(FContexto, self);
  end;
end;

procedure TFrmVisualizadorPC.SetContextoMause(const Value: TIdContext);
begin
  FContextoMause := Value;
end;

procedure TFrmVisualizadorPC.SetContextoTeclado(const Value: TIdContext);
begin
  FContextoTeclado := Value;
  tmrMonitoraTeclado.Enabled :=  true;
end;

procedure TFrmVisualizadorPC.SetId(const Value: Integer);
begin
  FId := Value;
end;

procedure TFrmVisualizadorPC.Setx(const Value: Integer);
begin
  Fx := Value;
end;

procedure TFrmVisualizadorPC.SetY(const Value: Integer);
begin
  FY := Value;
end;

procedure TFrmVisualizadorPC.tmrMonitoraTecladoTimer(Sender: TObject);
var
  i : byte;
  comandoTeclado: TComandoTeclado;
begin
// Movido para evento on key press;

 {  if not Assigned(FContextoTeclado)  then
    Exit;
  if not   Assigned( FContextoTeclado.Connection) then
    Exit;
  if FContextoTeclado.Connection.Connected  then
  begin
    try
      for i:=8 To 222 do
      begin
        if GetAsyncKeyState(i)<> 0 then
        begin
          comandoTeclado.CodigoTecla := i;
          comandoTeclado.TeclaAuxiliar := GetShiftState;
          EnviarDadoTeclado(comandoTeclado);
        end;
      end;
    except
      exit;
    end;
  end; }
end;










end.
