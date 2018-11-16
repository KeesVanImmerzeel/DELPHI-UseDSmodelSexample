unit uUseDSmodelSexample;

interface

uses
  Windows, Forms, SysUtils, StdCtrls, Controls, Classes, useModelSProgramSettings,
  uAlgRout, uDSModelS, uError;

type
  TMainForm = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Button2: TButton;
    Label2: TLabel;
    Button3: TButton;
    Label3: TLabel;
    Button4: TButton;
    Label4: TLabel;
    Button5: TButton;
    Label5: TLabel;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  DSDriverRoutineIndex = 1; {-Index of DSDriver routine (=Procedure 'DSDriver' in 'DSmodfor.dll')}
var
  MainForm: TMainForm;
  Hnd_to_DSmodfor: THandle;   {-Handle to 'DSmodfor.dll'}
  DSdriver: TDSDriver; {-Handle to DSDriverRoutine in 'DSmodfor.dll' }

var
  {-Parameters for interface with 'DSlink'}
  Settings, tTS, vTS, tResult, vResult: ^Real;
  Length_tTS_Array,
  Length_tResult_Array,
  nRP,        {-Aant. vlak-tijdreeksen die het model verwacht van de schil}
  nSQ,        {-Aant. punt-tijdreeksen die het model verwacht van de schil}
  nRQ,        {-Aant. lijn-tijdreeksen die het model verwacht van de schil}
  nResPar,    {-Aant. Aantal uitvoer-tijdreeksen}
  NrOfOutputTimes: Integer;
  Settings_Array, {-Model Settings in format of TDSDriver Procedure (ref. 'UdsModelS' and 'DSmodfor')}
  tTS_Array,
  vTS_Array,
  tResult_Array,
  vResult_Array: Array of Real;

  IErr: Integer;

implementation
{$R *.DFM}


procedure TMainForm.Button1Click(Sender: TObject);
var
  DSmodfor_FileName: String;
begin
  {-Create handle to 'DSmodfor.dll'}
  DSmodfor_FileName := AlgRootDir + 'DSmodfor.dll';
  Hnd_to_DSmodfor := LoadLibrary( PChar( DSmodfor_FileName ) );
  if Hnd_to_DSmodfor = 0 then begin
    Label1.Caption :='fout';
  end else begin
    Label1.Caption := 'goed';
  end;
end;

procedure TMainForm.Button2Click(Sender: TObject);

begin
  {-Create Handle to DSDriverRoutine in 'DSmodfor.dll' }
  @DSdriver := GetProcAddress( Hnd_to_DSmodfor, PChar( DSDriverRoutineIndex  ) );
  if ( @DSdriver = nil ) then begin
    Label2.Caption := 'fout';
  end else begin
    Label2.Caption := 'goed';
  end;
end;

procedure TMainForm.Button3Click(Sender: TObject);
begin
  Try
    FreeLibrary( Hnd_to_DSmodfor ); {-Drop handle to 'DSmodfor.dll'}
    Label3.Caption := 'goed';
  except
    Label3.Caption := 'fout';
  End;
end;

procedure TMainForm.Button4Click(Sender: TObject);
VAR
  i, IErr:   Integer;
begin
  {-Initialise Settings_Array}
  SetLength( Settings_Array, c_Length_Of_Settings_Array );
  for i:=0 to Length( Settings_Array )-1 do
    Settings_Array[ i ] := 0;

  Settings_Array[c_ModelID]      := 113;  {-Modelnr. dat de schil wil initialiseren (input)}
//  c_nRP         = 1;  {-Aantal RP-tijdreeksen dat het model van de schil
//                        verwacht(output)}
//  c_nSQ         = 2;  {-Aantal punt-tijdreeksen dat het model van de schil
//                        verwacht(output)}
//  c_nRQ         = 3;  {-Aantal lijn-tijdreeksen dat het model van de schil
//                        verwacht(output)}
//  c_nResPar     = 4;  {-Aantal stoffen waarmee wordt gerekend; wordt bepaald
//                        door boot-procedure in dsmodel*.dll (output)}
  Settings_Array[c_Request]  := cRQInitialise;  {-Type opdracht dat de schil wil uitvoeren (input,
//                        zie hieronder)}
//  c_MaxStp       = 6;  {-Max. aantal stappen voor integratie (input)
//                        HIERMEE WORDT NOG NIKS GEDAAN: de input vanuit het
//                        bestand *.EP0 wordt gebruikt}
//  c_Htry         = 7;  {-Initiele stapgrootte [tijd](input)
//                        HIERMEE WORDT NOG NIKS GEDAAN: de input vanuit het
//                        bestand *.EP0 wordt gebruikt}
//  c_Hmin         = 8;  {-Minimale stapgrootte [tijd](input)
//                        HIERMEE WORDT NOG NIKS GEDAAN: de input vanuit het
//                        bestand *.EP0 wordt gebruikt}
//  c_Eps          = 9;  {-Nauwkeurigheidscriterium(input)
//                        HIERMEE WORDT NOG NIKS GEDAAN: de input vanuit het
//                        bestand *.EP0 wordt gebruikt}
  Settings_Array[c_Area] := 1.0;
  new(Settings);
  Settings := @Settings_Array[0];

  New( tTS ); New( vTS ); New( tResult ); New( vResult );

  DSDriver( Settings^, tTS^, vTS^, tResult^, vResult^ ); {-Initialise model 113}

  IErr := Trunc( vResult^ ); Writeln( lf, 'IErr = ', IErr );
  if IErr = cNoError then begin
    Label4.Caption := 'Ready';
    {-Show resulting Settings_Array in log file (optional)}
    for i:=0 to Length( Settings_Array )-1 do begin
      writeln( lf, i, ' ', Settings_Array[ i ] );
    end;
  end else begin
    Label4.Caption := 'Not Ready'
  end;
end;

procedure TMainForm.Button5Click(Sender: TObject);
var
  i, j: Integer;
  S: String;
begin
    {-Fill tTS array with info from Settings_Array (stationary run)}
    nRP :=     trunc( Settings_Array[ c_nRP ] );     Writeln( lf, 'nRP= ', nRP );
    nSQ :=     trunc( Settings_Array[ c_nSQ ] );     Writeln( lf, 'nSQ= ', nSQ );
    nRQ :=     trunc( Settings_Array[ c_nRQ ] );     Writeln( lf, 'nRQ= ', nRQ );
    nResPar := trunc( Settings_Array[ c_nResPar ] ); Writeln( lf, 'nResPar= ', nResPar );

    Length_tTS_Array := nRP*2 + nSQ*2 + nRQ*2; {= Aantal invoertijdstippen bij stationaire run plus 1}
    SetLength( tTS_Array, Length_tTS_Array );
    for i := 0 to ( Length_tTS_Array div 2 ) - 1 do begin
      tTS_Array[ 2*i ]   := 1; {-Aantal tijdstippen}
      tTS_Array[ 2*i+1 ] := 0; {-Tijdstip}
    end;
    {-Fill vTS array (stationary run, model 113}
    SetLength( vTS_Array, Length_tTS_Array );
    {-RP-Values from shell for model 113}
    vTS_Array[ 0 ] := 1;   vTS_Array[ 1 ] := 1;   {Landgebruik: 1=Grasland; 2=Bouwland}
    vTS_Array[ 2 ] := 1;   vTS_Array[ 3 ] := 1;   {-Bodemtype 1-25, zie "help-tabellen 1987.xls"}
    vTS_Array[ 4 ] := 0.3; vTS_Array[ 5 ] := 0.3; {-GHG (m-mv)}
    vTS_Array[ 6 ] := 1.1; vTS_Array[ 7 ] := 1.1; {-GLG (m-mv)}

    {-Uitvoertijdstippen (stationaire run)}
    NrOfOutputTimes := 1; {-Stationary run}
    Length_tResult_Array := 1 + nResPar*NrOfOutputTimes;
    SetLength( tResult_Array, Length_tResult_Array );
    SetLength( vResult_Array, Length_tResult_Array );
    tResult_Array[ 0 ] := NrOfOutputTimes;
    vResult_Array[ 0 ] := cNoError;
    for i := 1 to nResPar do begin
      for j:= 1 to NrOfOutputTimes do begin
        tResult_Array[ (i-1)*NrOfOutputTimes + j ] := 0; {-Stationary run}
        vResult_Array[ (i-1)*NrOfOutputTimes + j ] := 0; {-Default result value}
      end;
    end;

    {-Run}
    tTS     := @tTS_Array[0];
    vTS     := @vTS_Array[0];
    tResult := @tResult_Array[0];
    vResult := @vResult_Array[0];
    Settings_Array[c_Request]  := cRQRun;

    DSDriver( Settings^, tTS^, vTS^, tResult^, vResult^ );

    {-Write results to log file (optional)}
    Writeln( lf, vResult_Array[0]  );
    IErr := Trunc( vResult^ );
    Writeln( lf, 'IErr of run with model ', trunc( Settings_Array[c_ModelID] ), ' =', IErr );
    for i := 1 to Length (tResult_Array)-1 do begin
      Writeln( lf, 'vResult_Array[ ', i, ']= ', vResult_Array[ i ]:10:2 );
    end;

    Str( IErr, S );
    Label5.Caption := S;

end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Caption :=  ChangeFileExt( ExtractFileName( Application.ExeName ), '' );
end;

end.
