unit uFrmServidorPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls, IdContext, IdBaseComponent, IdComponent,
  IdCustomTCPServer, IdTCPServer, Vcl.StdCtrls, Vcl.Buttons, uFrmVisualizadorPC, IdAntiFreezeBase, Vcl.IdAntiFreeze, uBiblioteca,
  System.Contnrs;

type

  TFormMainServer = class(TForm)
    pnl1: TPanel;
    pnl2: TPanel;
    lvClientes: TListView;
    idTCPServidor: TIdTCPServer;
    mmoLog: TMemo;
    pnl3: TPanel;
    edtIP: TEdit;
    stat: TStatusBar;
    edtPorta: TEdit;
    btnAtivar: TBitBtn;
    procedure btnAtivarClick(Sender: TObject);
    procedure idTCPServidorStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
    procedure idTCPServidorExecute(AContext: TIdContext);
    procedure idTCPServidorConnect(AContext: TIdContext);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure idTCPServidorDisconnect(AContext: TIdContext);
    procedure lvClientesClick(Sender: TObject);
  private
    { Private declarations }
    FLista: TobjectList;
    FId: Integer;
  public
    { Public declarations }
    procedure Ajustar;
  end;

var
  FormMainServer: TFormMainServer;

implementation

uses
  IdSocketHandle, IdSync, IdGlobal;

{$R *.dfm}

procedure TFormMainServer.Ajustar;
begin

end;

procedure TFormMainServer.btnAtivarClick(Sender: TObject);
var
  baindSocket: TIdSocketHandle;
begin
  if btnAtivar.Caption = 'Ativar' then
  begin
    idTCPServidor.Active := False;
    idTCPServidor.Bindings.Clear;
    baindSocket := idTCPServidor.Bindings.Add;
    baindSocket.IP := edtIP.Text;
   // baindSocket.IP :=  '127.0.0.1';
    baindSocket.Port := StrToInt(edtPorta.Text);
    idTCPServidor.Active := True;
    btnAtivar.Caption := 'Desativar';
  end
  else
  begin
    idTCPServidor.Active := False;
    btnAtivar.Caption := 'Ativar'
  end;
end;

procedure TFormMainServer.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i : integer;
begin
  idTCPServidor.OnDisconnect := nil;
  for I := 0 to FLista.Count -1 do
  begin
    TFrmVisualizadorPC(FLista[i]).Close;

  end;
end;

procedure TFormMainServer.FormCreate(Sender: TObject);
begin
  FLista := TobjectList.Create(False);
  FId := 0;
end;

procedure TFormMainServer.idTCPServidorConnect(AContext: TIdContext);
var
  frmVisualizador: TFrmVisualizadorPC;
  texto,comando: string;
  id,i: Integer;
  item: TListItem;
begin
  mmoLog.Lines.Add('Conectado...');
  mmoLog.Lines.Add(AContext.Binding.PeerIP + ' : ' + AContext.Binding.Port.ToString + '   ' +
  AContext.Binding.PeerPort.ToString);
  texto := AContext.Connection.IOHandler.ReadLn;
  if texto.Contains('Desktop|') then
  begin
    frmVisualizador := TFrmVisualizadorPC.Create(Self);
    frmVisualizador.ContextoDesktop := AContext;
    inc(FId);
    frmVisualizador.Id := FId;
    FLista.Add(frmVisualizador);
    item := lvClientes.Items.Add;
    item.Caption := Fid.ToString;
    item.SubItems.Add( copy(texto,pos('|',texto), texto.Length )) ;
    item.SubItems.Add(FormatDateTime('dd/mm/yyyy hh:mm:ss', now));
    lvClientes.Columns[0].Width := 50;
    lvClientes.Columns[0].Width := 200;
    lvClientes.Columns[0].Width := 80;

    AContext.Connection.IOHandler.WriteLn(IntToStr(FId));
    frmVisualizador.Iniciar;
  end
  else
  if  texto.Contains('Teclado|') then
  begin
    comando :=Copy(texto,pos('|',texto)+1,texto.Length );
    id:= StrToInt( comando);
    for I := 0 to FLista.Count -1 do
    begin
      if TFrmVisualizadorPC(FLista[i]).Id = id then
        TFrmVisualizadorPC(FLista[i]).ContextoTeclado := AContext;
    end;
  end
  else
  if  texto.Contains('Mouse|') then
  begin
    comando :=Copy(texto,pos('|',texto)+1,texto.Length );
    id:= StrToInt( comando);
    for I := 0 to FLista.Count -1 do
    begin
      if TFrmVisualizadorPC(FLista[i]).Id = id then
        TFrmVisualizadorPC(FLista[i]).ContextoMause := AContext;
    end;
  end;
  application.ProcessMessages;
end;

procedure TFormMainServer.idTCPServidorDisconnect(AContext: TIdContext);
var
  i: Integer;
begin
  for i := 0 to FLista.Count-1 do
  begin
    if Assigned( FLista[i]) then
    begin
     { for vContador := 0 to FrmPrincipal.ListView1.Items.Count - 1 do begin
        if FrmPrincipal.ListView1.Items.Item[vContador].Caption = ´Cadastro de fornecedor´ then begin
        FrmPrincipal.ListView1.Items.Delete(vContador);
        Break;
        end;
      end;}
      FLista.Delete(i);
    end;

  end;
end;

procedure TFormMainServer.idTCPServidorExecute(AContext: TIdContext);
var
  LLine: String;
begin
  Sleep(5);
end;

procedure TFormMainServer.idTCPServidorStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
begin

  mmoLog.Lines.Add( 'Situacao :' + AStatusText);


end;

procedure TFormMainServer.lvClientesClick(Sender: TObject);
var
  i, ID: Integer;
begin
  if lvClientes.ItemIndex = -1 then
    exit;
 
  TFrmVisualizadorPC(FLista[lvClientes.ItemIndex]).WindowState := wsNormal;
  TFrmVisualizadorPC(FLista[lvClientes.ItemIndex]).BringToFront;
end;



{ ThreadMain }




end.
