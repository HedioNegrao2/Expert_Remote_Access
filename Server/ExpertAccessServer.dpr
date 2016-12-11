program ExpertAccessServer;

uses
  Vcl.Forms,
  uFrmServidorPrincipal in 'uFrmServidorPrincipal.pas' {FormMainServer},
  uFrmVisualizadorPC in 'uFrmVisualizadorPC.pas' {FrmVisualizadorPC},
  uBiblioteca in '..\Common\uBiblioteca.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMainServer, FormMainServer);
  Application.Run;
end.
