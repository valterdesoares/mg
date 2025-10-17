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
    FCodEmp: Integer;
    FParametro2: string;
    function IsLista: Boolean;
    procedure SetParametro2(const Value: string);
    function GetParametro2:string;
    class function ResolveCodEmp(const ACodEmp: Integer = -1): Integer; static;
    class function DefaultCodEmp: Integer; static;
  public

    constructor Create(AArgumento :string = '';
                       ASubArgumento :string = '';
                       AParametroAdicional :string  = '';
                       AdescrParametro :string = '';
                       ACodEmp: Integer = -1);overload;
    destructor Destroy(); override;
    property Parametro2 :string read GetParametro2 write SetParametro2;
    class function RetornaParametro(FArgumento, FSubArgumento:string): string;
    class function RetornaParametroDef(FArgumento, FSubArgumento, FDefault:string): string;
  end;

{ TParametrosRepository }

class constructor TParametrosRepository.Create;
begin
  FCache := TDictionary<string, TParametroRegistro>.Create;
  FListaCache := TDictionary<string, string>.Create;
  FLock := TObject.Create;
end;

class destructor TParametrosRepository.Destroy;
begin
  FCache.Free;
  FListaCache.Free;
  FLock.Free;
end;

class function TParametrosRepository.CacheKey(const ACodEmp: Integer;
  const AArgumento, ASubArgumento: string): string;
begin
  Result := IntToStr(ACodEmp) + '|' + UpperCase(AArgumento) + '|' + UpperCase(ASubArgumento);
end;

class function TParametrosRepository.CacheKeyPrefix(const ACodEmp: Integer;
  const AArgumento: string): string;
begin
  Result := IntToStr(ACodEmp) + '|' + UpperCase(AArgumento) + '|';
end;

class function TParametrosRepository.ListaKey(const ACodEmp: Integer;
  const AArgumento: string): string;
begin
  Result := IntToStr(ACodEmp) + '|' + UpperCase(AArgumento);
end;

class function TParametrosRepository.AcquireRegistroLocked(
  const ACodEmp: Integer; const AArgumento, ASubArgumento: string;
  out ARegistro: TParametroRegistro): Boolean;
begin
  FillChar(ARegistro, SizeOf(ARegistro), 0);
  with DM.QParametros2 do
  begin
    Close;
    SQL.Clear;
    SQL.Add('select Trim(A.PARAMETRO) as PARAMETRO,');
    SQL.Add('       Trim(coalesce(A.PARAMETRO2, '''')) as PARAMETRO2,');
    SQL.Add('       Trim(coalesce(A.DESCRPAR, '''')) as DESCRPAR');
    SQL.Add('  from PARAMETROS2 A');
    SQL.Add(' where (A.COD_EMP = :COD_EMP)');
    SQL.Add('   and (A.ARGUMENTO = :ARGUMENTO)');
    SQL.Add('   and (A.SUBARGUM = :SUBARGUM)');
    ParamByName('COD_EMP').AsInteger := ACodEmp;
    ParamByName('ARGUMENTO').AsString := AArgumento;
    ParamByName('SUBARGUM').AsString := ASubArgumento;
    Open;
    try
      Result := not IsEmpty;
      if Result then
      begin
        ARegistro.Valor := Trim(Fields[0].AsString);
        ARegistro.ParametroAdicional := Trim(Fields[1].AsString);
        ARegistro.Descricao := Trim(Fields[2].AsString);
      end
      else
      begin
        ARegistro.Valor := '';
        ARegistro.ParametroAdicional := '';
        ARegistro.Descricao := '';
      end;
    finally
      Close;
    end;
  end;
end;

class function TParametrosRepository.AcquireListaLocked(
  const ACodEmp: Integer; const AArgumento: string; out AValor: string): Boolean;
var
  LItens: TStringList;
begin
  with DM.QParametros2 do
  begin
    Close;
    SQL.Clear;
    SQL.Add('select Trim(A.PARAMETRO) as PARAMETRO');
    SQL.Add('  from PARAMETROS2 A');
    SQL.Add(' where (A.COD_EMP = :COD_EMP)');
    SQL.Add('   and (A.ARGUMENTO = :ARGUMENTO)');
    SQL.Add(' order by A.SUBARGUM');
    ParamByName('COD_EMP').AsInteger := ACodEmp;
    ParamByName('ARGUMENTO').AsString := AArgumento;
    Open;
    LItens := TStringList.Create;
    try
      while not Eof do
      begin
        LItens.Add(Trim(Fields[0].AsString));
        Next;
      end;
      Result := LItens.Count > 0;
      AValor := LItens.Text;
    finally
      LItens.Free;
      Close;
    end;
  end;
end;

class procedure TParametrosRepository.StoreRegistroLocked(
  const ACodEmp: Integer; const AArgumento, ASubArgumento, AValor,
  AAdicional, ADescricao: string);
begin
  with DM.QInsParam2 do
  begin
    Close;
    SQL.Clear;
    SQL.Add('update or insert into PARAMETROS2 (COD_EMP, ARGUMENTO, SUBARGUM, PARAMETRO, DESCRPAR, PARAMETRO2) ');
    SQL.Add('values (:COD_EMP, :ARGUMENTO, :SUBARGUM, :PARAMETRO, :DESCRPAR, :PARAMETRO2) ');
    SQL.Add('matching (COD_EMP, ARGUMENTO, SUBARGUM) ');
    ParamByName('COD_EMP').AsInteger := ACodEmp;
    ParamByName('ARGUMENTO').AsString := AArgumento;
    ParamByName('SUBARGUM').AsString := ASubArgumento;
    ParamByName('PARAMETRO').AsString := AValor;
    ParamByName('PARAMETRO2').AsString := AAdicional;
    ParamByName('DESCRPAR').AsString := ADescricao;
    try
      ExecSQL;
    except
      on E: Exception do
        raise Exception.Create('Erro ao inserir parametro' + sLineBreak +
                               'Argumento: ' + AArgumento + sLineBreak +
                               'SubArgumento: ' + ASubArgumento + sLineBreak +
                               'Parametro: ' + AValor + sLineBreak +
                               E.Message);
    end;
  end;
end;

class procedure TParametrosRepository.RemoveArgumentCachesLocked(
  const ACodEmp: Integer; const AArgumento: string);
var
  LPrefix: string;
  LKey: string;
  LKeys: TArray<string>;
begin
  LPrefix := CacheKeyPrefix(ACodEmp, AArgumento);
  LKeys := FCache.Keys.ToArray;
  for LKey in LKeys do
    if Pos(LPrefix, LKey) = 1 then
      FCache.Remove(LKey);
  FListaCache.Remove(ListaKey(ACodEmp, AArgumento));
end;

class function TParametrosRepository.ObterValor(const ACodEmp: Integer;
  const AArgumento, ASubArgumento: string; out AAdicional: string): string;
var
  LRegistro: TParametroRegistro;
  LKey: string;
begin
  LKey := CacheKey(ACodEmp, AArgumento, ASubArgumento);
  TMonitor.Enter(FLock);
  try
    if not FCache.TryGetValue(LKey, LRegistro) then
    begin
      AcquireRegistroLocked(ACodEmp, AArgumento, ASubArgumento, LRegistro);
      FCache.AddOrSetValue(LKey, LRegistro);
    end;
  finally
    TMonitor.Exit(FLock);
  end;
  AAdicional := LRegistro.ParametroAdicional;
  Result := LRegistro.Valor;
end;

class function TParametrosRepository.ObterLista(const ACodEmp: Integer;
  const AArgumento: string; AAdicionarTodos: Boolean): string;
var
  LKey: string;
  LBase: string;
  LItens: TStringList;
begin
  LKey := ListaKey(ACodEmp, AArgumento);
  TMonitor.Enter(FLock);
  try
    if not FListaCache.TryGetValue(LKey, LBase) then
    begin
      if not AcquireListaLocked(ACodEmp, AArgumento, LBase) then
        LBase := '';
      FListaCache.AddOrSetValue(LKey, LBase);
    end;
  finally
    TMonitor.Exit(FLock);
  end;

  if AAdicionarTodos then
  begin
    LItens := TStringList.Create;
    try
      LItens.Text := LBase;
      LItens.Insert(0, 'TODOS');
      Result := LItens.Text;
    finally
      LItens.Free;
    end;
  end
  else
    Result := LBase;
end;

class procedure TParametrosRepository.GravarValor(const ACodEmp: Integer;
  const AArgumento, ASubArgumento, AValor, AAdicional, ADescricao: string);
var
  LRegistro: TParametroRegistro;
  LKey: string;
begin
  LKey := CacheKey(ACodEmp, AArgumento, ASubArgumento);
  TMonitor.Enter(FLock);
  try
    AcquireRegistroLocked(ACodEmp, AArgumento, ASubArgumento, LRegistro);
    if (LRegistro.Valor = AValor) and
       (LRegistro.ParametroAdicional = AAdicional) and
       (LRegistro.Descricao = ADescricao) then
      Exit;

    StoreRegistroLocked(ACodEmp, AArgumento, ASubArgumento, AValor, AAdicional, ADescricao);

    LRegistro.Valor := AValor;
    LRegistro.ParametroAdicional := AAdicional;
    LRegistro.Descricao := ADescricao;
    FCache.AddOrSetValue(LKey, LRegistro);
    FListaCache.Remove(ListaKey(ACodEmp, AArgumento));
  finally
    TMonitor.Exit(FLock);
  end;
end;

class procedure TParametrosRepository.GravarLista(const ACodEmp: Integer;
  const AArgumento: string; const AValores: TStrings);
var
  I: Integer;
begin
  TMonitor.Enter(FLock);
  try
    DM.ExecutaSQL('DELETE FROM PARAMETROS2 WHERE COD_EMP = ' + IntToStr(ACodEmp) +
      ' AND ARGUMENTO = ' + QuotedStr(AArgumento));

    for I := 0 to AValores.Count - 1 do
      StoreRegistroLocked(ACodEmp, AArgumento, IntToStr(I), AValores[I], '', '');

    RemoveArgumentCachesLocked(ACodEmp, AArgumento);
    if AValores.Count > 0 then
      FListaCache.AddOrSetValue(ListaKey(ACodEmp, AArgumento), AValores.Text)
    else
      FListaCache.Remove(ListaKey(ACodEmp, AArgumento));
  finally
    TMonitor.Exit(FLock);
  end;
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

uses
  System.Generics.Collections,
  System.SyncObjs,
  UDM;

type
  TParametroRegistro = record
    Valor: string;
    ParametroAdicional: string;
    Descricao: string;
  end;

  TParametrosRepository = class sealed
  strict private
    class var FCache: TDictionary<string, TParametroRegistro>;
    class var FListaCache: TDictionary<string, string>;
    class var FLock: TObject;
    class constructor Create;
    class destructor Destroy;
    class function CacheKey(const ACodEmp: Integer; const AArgumento, ASubArgumento: string): string; static;
    class function CacheKeyPrefix(const ACodEmp: Integer; const AArgumento: string): string; static;
    class function ListaKey(const ACodEmp: Integer; const AArgumento: string): string; static;
    class function AcquireRegistroLocked(const ACodEmp: Integer; const AArgumento, ASubArgumento: string; out ARegistro: TParametroRegistro): Boolean; static;
    class function AcquireListaLocked(const ACodEmp: Integer; const AArgumento: string; out AValor: string): Boolean; static;
    class procedure StoreRegistroLocked(const ACodEmp: Integer; const AArgumento, ASubArgumento, AValor, AAdicional, ADescricao: string); static;
    class procedure RemoveArgumentCachesLocked(const ACodEmp: Integer; const AArgumento: string); static;
  public
    class function ObterValor(const ACodEmp: Integer; const AArgumento, ASubArgumento: string; out AAdicional: string): string; static;
    class function ObterLista(const ACodEmp: Integer; const AArgumento: string; AAdicionarTodos: Boolean): string; static;
    class procedure GravarValor(const ACodEmp: Integer; const AArgumento, ASubArgumento, AValor, AAdicional, ADescricao: string); static;
    class procedure GravarLista(const ACodEmp: Integer; const AArgumento: string; const AValores: TStrings); static;
  end;

function RetornaParam2(aArgumento :string; aSubArgumento :String; aDefault:string = ''): string;
var
  LAdicional: string;
begin
  Result := Trim(TParametrosRepository.ObterValor(TParametros2.DefaultCodEmp, aArgumento, aSubArgumento, LAdicional));
  if (Result = '') and (aDefault <> '') then
    Result := aDefault;
end;

function RetornaParam2EmpZero(aArgumento :string; aSubArgumento :String; aDefault:string): string;
var
  LAdicional: string;
begin
  Result := Trim(TParametrosRepository.ObterValor(0, aArgumento, aSubArgumento, LAdicional));
  if Result = '' then
    Result := aDefault;
end;


function RetornaParamComEmp(aCod_emp :Integer; aArgumento :string; aSubArgumento :String; aDefault:string): string;
var
  LAdicional: string;
begin
  Result := Trim(TParametrosRepository.ObterValor(aCod_emp, aArgumento, aSubArgumento, LAdicional));
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
constructor TParametros2.Create(AArgumento: string; ASubArgumento: string;
  AParametroAdicional: string; AdescrParametro: string; ACodEmp: Integer);
begin
  Argumento := AArgumento;
  Subargumento := ASubArgumento;
  ParametroAdicional := AParametroAdicional;
  DescrParametro := AdescrParametro;
  FCodEmp := ResolveCodEmp(ACodEmp);
  OpcaoLista := opNaoAdicionarPalavraTodos;
end;

destructor TParametros2.Destroy;
begin
  inherited;
end;

class function TParametros2.ResolveCodEmp(const ACodEmp: Integer): Integer;
begin
  if ACodEmp >= 0 then
    Exit(ACodEmp);
  Result := iEmp;
  if Result = 0 then
    Result := iemp;
end;

class function TParametros2.DefaultCodEmp: Integer;
begin
  Result := ResolveCodEmp(-1);
end;

function TParametros2.IsLista: Boolean;
begin
  Result := Subargumento = '';
end;

function TParametros2.GetParametro2: string;
var
  LAdicional: string;
begin
  if IsLista then
    Result := TParametrosRepository.ObterLista(FCodEmp, Argumento, OpcaoLista = opAdicionarPalavraTodos)
  else
  begin
    Result := TParametrosRepository.ObterValor(FCodEmp, Argumento, Subargumento, LAdicional);
    ParametroAdicional := LAdicional;
  end;
  FParametro2 := Result;
end;

class function TParametros2.RetornaParametro(FArgumento,
  FSubArgumento: string): string;
var
  LAdicional: string;
begin
  Result := TParametrosRepository.ObterValor(DefaultCodEmp, FArgumento, FSubArgumento, LAdicional);
end;

class function TParametros2.RetornaParametroDef(FArgumento, FSubArgumento,
  FDefault: string): string;
begin
  Result := RetornaParametro(FArgumento, FSubArgumento);
  if Result = '' then
    Result := FDefault;
end;

procedure TParametros2.SetParametro2(const Value: string);
var
  LItens: TStringList;
begin
  FParametro2 := Value;
  if IsLista then
  begin
    LItens := TStringList.Create;
    try
      LItens.Text := Value;
      TParametrosRepository.GravarLista(FCodEmp, Argumento, LItens);
    finally
      LItens.Free;
    end;
  end
  else
    TParametrosRepository.GravarValor(FCodEmp, Argumento, Subargumento, Value, ParametroAdicional, DescrParametro);
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

