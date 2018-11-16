program UseDSmodelSexample;

  { Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  ShareMem,
  Forms,
  Sysutils,
  Dialogs,
  uUseDSmodelSexample in 'uUseDSmodelSexample.pas' {MainForm},
  System.UITypes,
  useModelSProgramSettings in 'useModelSProgramSettings.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Try
    Try
      if ( Mode = Interactive ) then begin
        Application.Run;
      end else begin
        {MainForm.GoButton.Click;}
      end;
    Except
      Try Writeln( lf, Format( 'Error in application: [%s].', [Application.ExeName] ) ); except end;
      MessageDlg( Format( 'Error in application: [%s].', [Application.ExeName] ), mtError, [mbOk], 0);
    end;
  Finally
  end;

end.
