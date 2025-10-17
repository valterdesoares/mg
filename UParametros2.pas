unit UParametros2;

interface

uses
  System.SysUtils, AlignEdit, Vcl.StdCtrls, Vcl.Mask, vcl.Wwdbcomb, vcl.Wwdbedit, Vcl.ComCtrls, data.db,
  System.Classes, rxCurrEdit, Vcl.Samples.Spin, AdvDateTimePicker, vcl.extctrls, wwDBDateTimePicker;


type TOpcaoParaLista = (opAdicionarPalavraTodos, opNaoAdicionarPalavraTodos);

function RetornaParam2(aArgumento :string; aSubArgumento :String; aDefault:string = ''): string;
function RetornaParam2EmpZero(aArgumento :string; aSubArgumento :String; aDefault:string = ''): string;
function RetornaParamComEmp(aCod_emp :Integer; aArgumento :string; aSubArgumento :String; aDefault:string = ''): string;

type iParametros_Factory = interface
  ['{BEB2BB15-4045-4881-A098-A9A6E7B1070C}']
  function Argumento(value :string):iParametros_Factory;
  function SubArgumento(value :string):iParametros_Factory;
  function Parametro(value :string):iParametros_Factory;
  function ParametroAdicional(value :string):iParametros_Factory;overload;
  function ParametroAdicional:iParametros_Factory;overload;
  function DescrParametro(value :string):iParametros_Factory;
  procedure Gravar;
  function AsString:string;
end;

type
  TParametros2 = class
  Argumento, Subargumento, ParametroAdicional, DescrParametro :string;
  OpcaoLista :TOpcaoParaLista;

  private
    FParametro2: string;
    FParametroItems: TStrings;
//    CONST iEmp :Integer = 1;
    procedure SetParametro2(const Value: string);
    procedure InserirParametroNoBanco;
  public

    constructor Create(AArgumento :string = '';
                       ASubArgumento :string = '';
                       AParametroAdicional :string  = '';
                       AdescrParametro :string = '');overload;
    destructor Destroy(); override;
    function GetParametro2:string;
    property Parametro2 :string read GetParametro2 write SetParametro2;
    class function RetornaParametro(FArgumento, FSubArgumento:string): string;
    class function RetornaParametroDef(FArgumento, FSubArgumento, FDefault:string): string;
  end;

type TParametros_Factory = class(TInterfacedObject, iParametros_Factory)
  private
  FClassParametros :TParametros2;
  FArgumento,
  FParametro,
  FSubargumento,
  FParametroAdicional,
  FDescrParametro :string;
  fRetornaParamAdicional :Boolean;
  public
  function Argumento(value :string):iParametros_Factory;
  function SubArgumento(value :string):iParametros_Factory;
  function Parametro(value :string):iParametros_Factory;
  function ParametroAdicional(value :string):iParametros_Factory;overload;
  function ParametroAdicional:iParametros_Factory;overload;
  function DescrParametro(value :string):iParametros_Factory;
  procedure Gravar;
  function AsString:string;
  constructor create;
  destructor destroy;override;
  class function New:iParametros_Factory;
end;

type
  TAlignEditP = class helper for TAlignEdit
    procedure BuscarParametro2(FArgumento, FSubArgumento: string);
    procedure SalvarParametro2(FArgumento, FSubArgumento: string;
        FParametroAdicional :string = ''; FDescrParametro :string = '');
  end;

type
  TEditP = class helper for TCustomEdit
    procedure BuscarParametro2(FArgumento, FSubArgumento: string; fValorPadrao :String = '');
    procedure SalvarParametro2(FArgumento, FSubArgumento: string; FParametroAdicional :string = ''; FDescrParametro :string = '');
  end;

type
  TwwdbdatetimepickerP = class helper for Twwdbdatetimepicker
    procedure BuscarParametro2(FArgumento, FSubArgumento: string);
    procedure SalvarParametro2(FArgumento, FSubArgumento: string; FParametroAdicional :string = ''; FDescrParametro :string = '');
  end;

type
  TSpinEditP = class helper for TspinEdit
    procedure BuscarParametro2(FArgumento, FSubArgumento: string);
    procedure SalvarParametro2(FArgumento, FSubArgumento: string; FParametroAdicional :string = ''; FDescrParametro :string = '');
  end;

type
  TCurrencyEditP = class helper for TCurrencyEdit
    procedure BuscarParametro2(FArgumento, FSubArgumento: string);
    procedure SalvarParametro2(FArgumento, FSubArgumento: string; FParametroAdicional :string = ''; FDescrParametro :string = '');
  end;

type
  TMemoP = class helper for TMemo
    procedure BuscarParametro2(FArgumento :string; FSubArgumento: string = '');
    procedure SalvarParametro2(FArgumento :string; FSubArgumento: string = '';
      FParametroAdicional :string = ''; FDescrParametro :string = '');
  end;

type
  TRichEditP = class helper for TRichEdit
    procedure BuscarParametro2(FArgumento, FSubArgumento: string);
    procedure SalvarParametro2(FArgumento, FSubArgumento: string; FParametroAdicional :string = ''; FDescrParametro :string = '');
  end;

type
  TCheckBoxP = class helper for TCheckBox
    procedure BuscarParametro2(FArgumento, FSubArgumento: string; Verdadeiro :string = 'S');
    procedure BuscarParametro2EmpZero(FArgumento, FSubArgumento: string; Verdadeiro :string = 'S');
    procedure SalvarParametro2(FArgumento, FSubArgumento: string;
                               FParametroAdicional :string = '';
                               FDescrParametro :string = '';
                               Verdadeiro :string = 'S';
                               Falso :string = 'N');
    procedure SalvarParametro2EmpZero(FArgumento, FSubArgumento: string);
  end;

type
  TComboBoxP = class helper for TComboBox
    procedure BuscarParametro2(FArgumento: string; FSubArgumento: string = '');
    procedure SalvarParametro2(FArgumento :string; FSubArgumento: string = ''; FParametroAdicional :string = ''; FDescrParametro :string = '');
    procedure BuscarParametro2Index(FArgumento: string; FSubArgumento: string = '');
    procedure SalvarParametro2Index(FArgumento, FSubArgumento: string; FParametroAdicional :string = ''; FDescrParametro :string = '');
  end;

type
  TMaskEditP = class helper for TMaskEdit
    procedure BuscarParametro2(FArgumento, FSubArgumento: string; Mascara :string = '');
    procedure SalvarParametro2(FArgumento, FSubArgumento: string; FParametroAdicional :string = ''; FDescrParametro :string = '');
  end;

type
  TWwdbComboBoxP = class helper for TwwDBComboBox
   procedure BuscarParametro2(FArgumento, FSubArgumento: string; aDefault :String = '');
   procedure SalvarParametro2(FArgumento, FSubArgumento: string; FParametroAdicional :string = ''; FDescrParametro :string = '');
   procedure SalvarParametroVazio(FArgumento, FSubArgumento: string);
  end;

type
  TWwdbEditP = class helper for TwwDBEdit
    procedure BuscarParametro2(FArgumento, FSubArgumento: string);
    procedure SalvarParametro2(FArgumento, FSubArgumento: string; FParametroAdicional :string = ''; FDescrParametro :string = '');
  end;

type
  TListBoxP = class helper for TListBox
    procedure BuscarParametro2(FArgumento :string; FSubArgumento: string = '');
    procedure SalvarParametro2(FArgumento :string; FSubArgumento: string = '';
      FParametroAdicional :string = ''; FDescrParametro :string = '');
  end;

type
  TRadioGroupP = class helper for TRadioGroup
    procedure BuscarParametro2(FArgumento :string; FSubArgumento: string = '');
    procedure SalvarParametro2(FArgumento :string; FSubArgumento: string = '';
      FParametroAdicional :string = ''; FDescrParametro :string = '');
  end;

type
  TStringListP = class helper for TStringList
    procedure BuscarParametro2(FArgumento :string; FSubArgumento: string = '');
    procedure SalvarParametro2(FArgumento :string; FSubArgumento: string = '';
      FParametroAdicional :string = ''; FDescrParametro :string = '');
  end;

implementation

uses UDM;

function RetornaParam2(aArgumento :string; aSubArgumento :String; aDefault:string = ''): string;
begin
 Result := Trim(TParametros2.RetornaParametroDef(aArgumento, aSubArgumento, aDefault));
end;

function RetornaParam2EmpZero(aArgumento :string; aSubArgumento :String; aDefault:string): string;
begin
  Result := DM.RetornaStringTabela(
               'select Trim(A.PARAMETRO) ' +
               'from PARAMETROS2 A ' +
               'where (A.COD_EMP = :COD_EMP) ' +
               'and (A.ARGUMENTO = :ARGUMENTO) ' +
               'and (A.SUBARGUM = :SUBARGUM) ',
               [0, aArgumento, aSubArgumento],
               [ftInteger, ftString, ftString]);
  if Result = '' then
   Result := aDefault;
end;


function RetornaParamComEmp(aCod_emp :Integer; aArgumento :string; aSubArgumento :String; aDefault:string): string;
begin
  Result := DM.RetornaStringTabela(
               'select Trim(A.PARAMETRO) ' +
               'from PARAMETROS2 A ' +
               'where (A.COD_EMP = :COD_EMP) ' +
               'and (A.ARGUMENTO = :ARGUMENTO) ' +
               'and (A.SUBARGUM = :SUBARGUM) ',
               [aCod_emp, aArgumento, aSubArgumento],
               [ftInteger, ftString, ftString]);
  if Result = '' then
   Result := aDefault;
end;

{ TAlignEditP }

procedure TAlignEditP.BuscarParametro2(FArgumento, FSubArgumento: string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento);
  try
    Text := FParametros.Parametro2;
  finally
    FParametros.Free;
  end;
end;

procedure TAlignEditP.SalvarParametro2(FArgumento, FSubArgumento,
  FParametroAdicional, FDescrParametro: string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento, FParametroAdicional, FDescrParametro);
  try
    FParametros.Parametro2 := Text;
  finally
    FParametros.Free;
  end;
end;



{ TParametros2 }
constructor TParametros2.Create(AArgumento :string; ASubArgumento :string;
      AParametroAdicional :string;AdescrParametro :string);
begin

  Argumento := AArgumento;
  Subargumento := ASubArgumento;
  ParametroAdicional :=AParametroAdicional;
  DescrParametro := AdescrParametro;
  OpcaoLista := opNaoAdicionarPalavraTodos;
end;

destructor TParametros2.Destroy;
begin
  inherited;

end;

function TParametros2.GetParametro2:string;
var
  FITems :TStringList;
  sFiltro :string;
begin
  if not DM.QParametros2.Active then
    DM.QParametros2.Open;
  DM.QParametros2.Filtered := False;
  if iEmp = 0 then
   iEmp := iemp;
  sFiltro := ' COD_EMP = ' + IntToStr(iEmp) +
    ' and ARGUMENTO = ' + QuotedStr(Self.Argumento);
  if Self.SubArgumento <> '' then
  begin
    sFiltro := sFiltro + ' and SUBARGUM = ' + QuotedStr(Self.Subargumento);
    DM.QParametros2.Filter := sFiltro;
    DM.QParametros2.Filtered := True;
    Result := DM.QParametros2PARAMETRO.AsString;
    ParametroAdicional := DM.QParametros2PARAMETRO2.AsString;
  end
  else
  begin
    DM.QParametros2.Filter := sFiltro;
    DM.QParametros2.Filtered := True;
    DM.QParametros2.First;
    FITems := TStringList.Create;
    if OpcaoLista = opAdicionarPalavraTodos then
    FITems.Add('TODOS');
    try
      while not DM.QParametros2.Eof do
      begin
        FITems.Add(DM.QParametros2PARAMETRO.AsString);
        DM.QParametros2.Next;
      end;
      Result := FITems.Text;
    finally
      FITems.Free;
    end;
  end;
  DM.QParametros2.Filtered := False;
end;

procedure TParametros2.InserirParametroNoBanco;
begin
  DM.QInsParam2.Close;
  DM.QInsParam2.SQL.Clear;
  DM.QInsParam2.SQL.Add('update or insert into PARAMETROS2 (COD_EMP, ARGUMENTO, SUBARGUM, PARAMETRO, DESCRPAR, PARAMETRO2) ');
  DM.QInsParam2.SQL.Add('values (:COD_EMP, :ARGUMENTO, :SUBARGUM, :PARAMETRO, :DESCRPAR, :PARAMETRO2) ');
  DM.QInsParam2.SQL.Add('matching (COD_EMP, ARGUMENTO, SUBARGUM) ');

  DM.QInsParam2.ParamByName('COD_EMP').AsInteger := iEmp;
  DM.QInsParam2.ParamByName('ARGUMENTO').AsString := Self.Argumento;
  DM.QInsParam2.ParamByName('SUBARGUM').AsString := Self.Subargumento;
  DM.QInsParam2.ParamByName('PARAMETRO').AsString := FParametro2;
  DM.QInsParam2.ParamByName('PARAMETRO2').AsString := Self.ParametroAdicional;
  DM.QInsParam2.ParamByName('DESCRPAR').AsString := Self.DescrParametro;
  try
    DM.QInsParam2.ExecSQL;
   except on e: Exception do
     raise Exception.Create('Erro ao inserir parametro' +
               'Argumento:'    + Self.Argumento + sLineBreak +
               'SubArgumento:' + Self.Argumento + sLineBreak +
               'Parametro:'    + Self.Argumento + sLineBreak +
               e.Message);
  end;

end;

class function TParametros2.RetornaParametroDef(FArgumento, FSubArgumento,
  FDefault: string): string;
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento);
  try
    Result := FParametros.Parametro2;
    if Result = '' then
    Result := FDefault;
  finally
    FParametros.Free;
  end;
end;

class function TParametros2.RetornaParametro(FArgumento,
  FSubArgumento: string): string;
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento);
  try
    Result := FParametros.Parametro2;
  finally
    FParametros.Free;
  end;
end;

procedure TParametros2.SetParametro2(const Value: string);
var FItems :TStringList;
  I:Integer;
  sFiltro, sParam :string;

begin
  FParametro2 := Value;
  if not DM.QParametros2.Active then
    DM.QParametros2.Open;
  DM.QParametros2.Filtered := False;
  sFiltro := ' COD_EMP = ' + IntToStr(iEmp) + ' and ARGUMENTO = ' + QuotedStr(Self.Argumento);
  if Self.SubArgumento <> '' then
  begin
    sFiltro := sFiltro + ' and SUBARGUM = ' + QuotedStr(Self.Subargumento);
    DM.QParametros2.Filter := sFiltro;
    DM.QParametros2.Filtered := True;
    if (Self.FParametro2 <> DM.QParametros2PARAMETRO.AsString) or
       (Self.ParametroAdicional <> DM.QParametros2PARAMETRO2.AsString) then
      InserirParametroNoBanco;
  end
  else
  begin
    FItems := TStringList.Create;
    DM.ExecutaSQL('DELETE FROM PARAMETROS2 WHERE  COD_EMP = ' + IntToStr(iEmp)
      + ' AND ARGUMENTO = ' + QuotedStr(Self.Argumento));
    try
      FItems.Text := Value;
      for I := 0 to FItems.Count - 1 do
      begin
        FParametro2 := FItems[I];
        Subargumento := IntToStr(I);
        InserirParametroNoBanco;
      end;
    finally
      FItems.Free;
    end;
  end;
end;

{ TEditP }

procedure TEditP.BuscarParametro2(FArgumento, FSubArgumento: string; fValorPadrao :String = '');
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento);
  try
    if FParametros.Parametro2 <> '' then
     Text := FParametros.Parametro2
    else
     Text := fValorPadrao;
  finally
    FParametros.Free;
  end;
end;

procedure TEditP.SalvarParametro2(FArgumento, FSubArgumento,
  FParametroAdicional, FDescrParametro: string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento, FParametroAdicional, FDescrParametro);
  try
    FParametros.Parametro2 := Text;
  finally
    FParametros.Free;
  end;
end;

{wwdbdatetimepicker}

procedure TwwdbdatetimepickerP.BuscarParametro2(FArgumento, FSubArgumento: string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento);
  try
    Text := FParametros.Parametro2;
  finally
    FParametros.Free;
  end;
end;

procedure TwwdbdatetimepickerP.SalvarParametro2(FArgumento, FSubArgumento,
  FParametroAdicional, FDescrParametro: string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento, FParametroAdicional, FDescrParametro);
  try
    FParametros.Parametro2 := Text;
  finally
    FParametros.Free;
  end;
end;

{ TspinEditP }

procedure TSpinEditP.BuscarParametro2(FArgumento, FSubArgumento: string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento);
  try
    Text := FParametros.Parametro2;
  finally
    FParametros.Free;
  end;
end;

procedure TSpinEditP.SalvarParametro2(FArgumento, FSubArgumento,
  FParametroAdicional, FDescrParametro: string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento, FParametroAdicional, FDescrParametro);
  try
    FParametros.Parametro2 := Text;
  finally
    FParametros.Free;
  end;
end;

{ TCurrencyEditP }

procedure TCurrencyEditP.BuscarParametro2(FArgumento, FSubArgumento: string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento);
  try
    Text := FParametros.Parametro2;
  finally
    FParametros.Free;
  end;
end;

procedure TCurrencyEditP.SalvarParametro2(FArgumento, FSubArgumento,
  FParametroAdicional, FDescrParametro: string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento, FParametroAdicional, FDescrParametro);
  try
    FParametros.Parametro2 := Text;
  finally
    FParametros.Free;
  end;
end;

{ TCheckBoxP }

procedure TCheckBoxP.BuscarParametro2(FArgumento, FSubArgumento: string; Verdadeiro :string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento);
  try
    Checked := FParametros.Parametro2 = Verdadeiro;
  finally
    FParametros.Free;
  end;
end;

procedure TCheckBoxP.BuscarParametro2EmpZero(FArgumento, FSubArgumento, Verdadeiro: string);
var aResult : String;
begin
  aResult := RetornaParam2EmpZero(FArgumento, FSubArgumento);
  Checked := aResult = Verdadeiro;
end;

procedure TCheckBoxP.SalvarParametro2(FArgumento, FSubArgumento, FParametroAdicional,
  FDescrParametro, Verdadeiro: string; Falso :string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento, FParametroAdicional, FDescrParametro);
  try
   if Checked then
    FParametros.Parametro2 := Verdadeiro
   else
    FParametros.Parametro2 := Falso;
  finally
    FParametros.Free;
  end;
end;

procedure TCheckBoxP.SalvarParametro2EmpZero(FArgumento, FSubArgumento: string);
begin
  FalseBoolStrs := ['N']; TrueBoolStrs := ['S'];
  DM.FdConBanco.ExecSQL(
   'update or insert into PARAMETROS2 (COD_EMP, ' +
   'ARGUMENTO, ' +
   'SUBARGUM, ' +
   'PARAMETRO) ' +
   'values (:COD_EMP, ' +
   ':ARGUMENTO, ' +
   ':SUBARGUM, ' +
   ':PARAMETROO) ' +
   'matching (COD_EMP, ARGUMENTO, SUBARGUM) ',
   [0,         FArgumento, FSubArgumento, BoolToStr(Checked, True)],
   [ftInteger, ftString,   ftString,      ftString]);

  DM.FdConBanco.Commit;
end;

{ TWwdbComboBoxP }

procedure TWwdbComboBoxP.BuscarParametro2(FArgumento, FSubArgumento: string; aDefault :String);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento);
  try
    if (FParametros.Parametro2 = '') and (aDefault <> '') then
     Value := aDefault
    else
     Value := FParametros.Parametro2;
  finally
    FParametros.Free;
  end;
end;

procedure TWwdbComboBoxP.SalvarParametro2(FArgumento, FSubArgumento,
  FParametroAdicional, FDescrParametro: string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento, FParametroAdicional, FDescrParametro);
  try
    FParametros.Parametro2 := Value;
  finally
    FParametros.Free;
  end;
end;

procedure TWwdbComboBoxP.SalvarParametroVazio(FArgumento,
  FSubArgumento: string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento);
  try
    FParametros.Parametro2 := '';
  finally
    FParametros.Free;
  end;
end;

{ TMemoP }

procedure TMemoP.BuscarParametro2(FArgumento, FSubArgumento: string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento);
  try
    Text := FParametros.Parametro2;
  finally
    FParametros.Free;
  end;
end;

procedure TMemoP.SalvarParametro2(FArgumento, FSubArgumento,
  FParametroAdicional, FDescrParametro: string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento, FParametroAdicional, FDescrParametro);
  try
    FParametros.Parametro2 := Text;
  finally
    FParametros.Free;
  end;
end;

{ TMaskEditP }

procedure TMaskEditP.BuscarParametro2(FArgumento, FSubArgumento,
  Mascara: string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento);
  try
    Text := FParametros.Parametro2;
    EditMask := Mascara;
  finally
    FParametros.Free;
  end;
end;

procedure TMaskEditP.SalvarParametro2(FArgumento, FSubArgumento,
  FParametroAdicional, FDescrParametro: string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento, FParametroAdicional, FDescrParametro);
  try
    FParametros.Parametro2 := Text;
  finally
    FParametros.Free;
  end;
end;

{ TComboBoxP }

procedure TComboBoxP.BuscarParametro2(FArgumento, FSubArgumento: string);
var
  FParametros :TParametros2;
  I:Integer;
  AParametro :string;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento);
  try
    if FSubArgumento = '' then
      Items.Text := FParametros.Parametro2
    else
    begin
      AParametro := FParametros.Parametro2;
      for I := 0 to Items.Count - 1 do
      begin
        if Items[I] = AParametro then
        begin
          ItemIndex := I;
          Exit;
        end;
      end;
    end;
  finally
    FParametros.Free;
  end;
end;

procedure TComboBoxP.BuscarParametro2Index(FArgumento, FSubArgumento: string);
var
  FParametros :TParametros2;
  I:Integer;
  AParametro :string;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento);
  try
    ItemIndex := StrToIntDef(FParametros.Parametro2,-1);
  finally
    FParametros.Free;
  end;
end;

procedure TComboBoxP.SalvarParametro2(FArgumento :string;FSubArgumento :string;
  FParametroAdicional, FDescrParametro: string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento, FParametroAdicional, FDescrParametro);
  try
   if FSubArgumento <> '' then
    FParametros.Parametro2 := Text
   else
    FParametros.Parametro2 := Self.Items.Text;
  finally
    FParametros.Free;
  end;
end;

procedure TComboBoxP.SalvarParametro2Index(FArgumento, FSubArgumento,
  FParametroAdicional, FDescrParametro: string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento, FParametroAdicional, FDescrParametro);
  try
    FParametros.Parametro2 := IntToStr(ItemIndex);
  finally
    FParametros.Free;
  end;
end;

{ TWwdbEditP }

procedure TWwdbEditP.BuscarParametro2(FArgumento, FSubArgumento: string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento);
  try
    Text := FParametros.Parametro2;
  finally
    FParametros.Free;
  end;
end;

procedure TWwdbEditP.SalvarParametro2(FArgumento, FSubArgumento,
  FParametroAdicional, FDescrParametro: string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento, FParametroAdicional, FDescrParametro);
  try
    FParametros.Parametro2 := Text;
  finally
    FParametros.Free;
  end;
end;

{ TRichEditP }

procedure TRichEditP.BuscarParametro2(FArgumento, FSubArgumento: string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento);
  try
    Text := FParametros.Parametro2;
  finally
    FParametros.Free;
  end;
end;

procedure TRichEditP.SalvarParametro2(FArgumento, FSubArgumento,
  FParametroAdicional, FDescrParametro: string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento, FParametroAdicional, FDescrParametro);
  try
    FParametros.Parametro2 := Text;
  finally
    FParametros.Free;
  end;
end;

{ TListBoxP }

procedure TListBoxP.BuscarParametro2(FArgumento, FSubArgumento: string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento);
  try
    Items.Text := FParametros.Parametro2;
  finally
    FParametros.Free;
  end;
end;

procedure TListBoxP.SalvarParametro2(FArgumento, FSubArgumento,
  FParametroAdicional, FDescrParametro: string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento, FParametroAdicional, FDescrParametro);
  try
    FParametros.Parametro2 := Items.Text;
  finally
    FParametros.Free;
  end;
end;

{ TStringListP }

procedure TStringListP.BuscarParametro2(FArgumento, FSubArgumento: string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento);
  try
    Text := FParametros.Parametro2;
  finally
    FParametros.Free;
  end;
end;

procedure TStringListP.SalvarParametro2(FArgumento, FSubArgumento,
  FParametroAdicional, FDescrParametro: string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento, FParametroAdicional, FDescrParametro);
  try
    FParametros.Parametro2 := Text;
  finally
    FParametros.Free;
  end;
end;

{ TParametros_Factory }

function TParametros_Factory.Argumento(value: string): iParametros_Factory;
begin
 FArgumento := value;
 Result := Self;
end;

function TParametros_Factory.AsString: string;
begin
  FClassParametros.Argumento := FArgumento;
  FClassParametros.Subargumento := FSubArgumento;
 if not fRetornaParamAdicional then
  Result := FClassParametros.Parametro2
 else
  Result := FClassParametros.ParametroAdicional;
end;

constructor TParametros_Factory.create;
begin
 FClassParametros := TParametros2.Create;
 fRetornaParamAdicional := false;
end;

function TParametros_Factory.DescrParametro(value: string): iParametros_Factory;
begin
 FDescrParametro := value;
 Result := Self;
end;

destructor TParametros_Factory.destroy;
begin
 FClassParametros.Free;
  inherited;
end;

procedure TParametros_Factory.Gravar;
begin
 FClassParametros.Argumento := FArgumento;
 FClassParametros.Subargumento := FSubargumento;
 FClassParametros.ParametroAdicional := FParametroAdicional;
 FClassParametros.DescrParametro := FDescrParametro;
 FClassParametros.Parametro2 := FParametro;
end;

class function TParametros_Factory.New: iParametros_Factory;
begin
 Result := TParametros_Factory.create;
end;

function TParametros_Factory.Parametro(value: string): iParametros_Factory;
begin
 FParametro := value;
 Result := Self;
end;

function TParametros_Factory.ParametroAdicional: iParametros_Factory;
begin
 fRetornaParamAdicional := True;
 Result := Self;
end;

function TParametros_Factory.ParametroAdicional(
  value: string): iParametros_Factory;
begin
 FParametroAdicional := value;
 Result := Self;
end;

function TParametros_Factory.SubArgumento(value: string): iParametros_Factory;
begin
 FSubargumento := value;
 Result := Self;
end;


{ TRadioButtonP }

procedure TRadioGroupP.BuscarParametro2(FArgumento, FSubArgumento: string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento);
  try
    ItemIndex := StrToIntDef(FParametros.Parametro2, -1);
  finally
    FParametros.Free;
  end;
end;

procedure TRadioGroupP.SalvarParametro2(FArgumento, FSubArgumento, FParametroAdicional, FDescrParametro: string);
var
  FParametros :TParametros2;
begin
  FParametros := TParametros2.Create(FArgumento, FSubArgumento, FParametroAdicional, FDescrParametro);
  try
    FParametros.Parametro2 := IntToStr(ItemIndex);
  finally
    FParametros.Free;
  end;
end;

end.

