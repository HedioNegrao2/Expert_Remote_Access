program ExpertAccessClient;

uses
  Vcl.Forms,
  uFormPrinciapalCliente in 'uFormPrinciapalCliente.pas' {FormPrincipalCliente},
  uBiblioteca in '..\Common\uBiblioteca.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormPrincipalCliente, FormPrincipalCliente);
  Application.Run;
end.
