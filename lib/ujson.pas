//ref - https://stackoverflow.com/questions/17167398/json-parser-in-pascalscript

//--------------
unit ujson;
interface
uses classes,forms,sysutils,Contnrs;

type
  TJsonNumber = Double;
  TJsonString = WideString;
  TJsonChar = WideChar;
  TJsonWord = (JWUnknown, JWTrue, JWFalse, JWNull);
  TJsonValueKind = (JVKUnknown, JVKNumber, JVKString, JVKWord, JVKArray, JVKObject);
  TJsonValue = record
    Kind: TJsonValueKind;
    Index: Integer;
  end;
  TJsonArray = array of TJsonValue;
  TJsonPair = record
    Key: TJsonString;
    Value: TJsonValue;
  end;
  TJsonObject = array of TJsonPair;
  TJsonParserOutput = record
    Numbers: array of TJsonNumber;
    Strings: array of TJsonString;
    Words: array of TJsonWord;
    Arrays: array of TJsonArray;
    Objects: array of TJsonObject; // The root object is the first one
    Errors: array of TJsonString;
  end;
  TJsonParser = record
    At: Integer; // The index of the current character
    Ch: TJsonChar; // The current character
    Text: TJsonString;
    Output: TJsonParserOutput;
  end;
  TJsonValueParser = function (var JsonParser: TJsonParser): TJsonValue;
  procedure ClearJsonParser(var JsonParser: TJsonParser);
  procedure ParseJson(var JsonParser: TJsonParser; const Source: WideString);
procedure PrintJsonParserOutput(const Output: TJsonParserOutput; Lines: TStringList);
{ TStack }

type
  tstack = class(TObjectStack)

  end;

type Json = class
  private
    a : string;
    arr: TJsonArray;
    JsonParser: TJsonParser;
    output:TJsonParserOutput;
    currentObject:TJsonObject;
    FStack : Tstack ;
    procedure check;
public
    function _array(p: string): TJsonArray;
    function _int(p: string): Integer;
    function locateObject(index: integer): TJsonObject;
    procedure setCurrent(obj:TJSonObject);
    procedure locateArray(a:string);
    function getCurrentArray:TJsonArray;
    function getCurrentArrayLength: Integer;
    function _string(p: string): String;
    procedure push;
    procedure pop;
    procedure format(sl:Tstringlist);
  public
    constructor create(a:string);
    destructor Destroy;override;
    procedure parse;
end;

implementation
 function Json._int(p:string):Integer;
    var i : integer;obj:TJsonObject;
    begin
    obj:= currentObject;
    result := 0 ;
    for i:= 0 to length(obj)-1 do begin
        if (obj[i].key = p) and (obj[i].Value.Kind = JVKNumber) then begin
        result :=  trunc( output.Numbers[obj[i].value.Index]);
        break;
        end;
    end;
    end;
    function Json._string(p:string):String;
    var i : integer;obj:TJsonObject;
    begin
    obj:= currentObject;
    result := '' ;
    for i:= 0 to length(obj)-1 do begin
        if (obj[i].key = p) and (obj[i].Value.Kind = JVKString) then begin
        result :=  output.strings[obj[i].value.Index];
        break;
        end;
    end;
    end;
    function Json._array(p:string):TJsonArray;
    var i : integer;
    obj:TJsonObject;
    begin
    obj:= currentObject;
    result := nil ;
    for i:= 0 to length(obj)-1 do begin
        if (obj[i].key = p) and (obj[i].Value.Kind = JVKArray) then begin
        result :=  (output.Arrays[obj[i].value.Index]);
        break;
        end;
    end;
    end;
    function Json.getCurrentArray:TJsonArray;
begin
  result := self.arr;
end;
      function Json.getCurrentArrayLength:Integer;
begin
  result := length(self.arr);
end;
function Json.locateObject(index:integer):TJsonObject;
    var v : TJsonValue;
    begin
        result := nil ;
        v :=  arr[index];
        if v.kind = JVKObject then
            result := output.Objects[v.Index];
        setCurrent(result);
    end;
    procedure Json.setCurrent(obj: TJSonObject);
begin
  self.currentObject := obj;
end;
procedure Json.locateArray(a:string);
begin

  self.arr := _array(a);
end;

constructor Json.create(a:string);
begin
self.a := a;
self.FStack := TStack.create;
end;
destructor Json.destroy;
begin
  self.FStack.free;
  inherited;
end;

procedure Json.format(sl:TStringList);
begin
  PrintJsonParserOutput(self.JsonParser.output,sl);
end;

procedure Json.check;
var J : Integer;s : string;
begin
  for J := 0 to Length(JsonParser.Output.Errors) - 1 do
      s := s + JsonParser.Output.Errors[J];
  if s <> '' then
    raise Exception.create(s);
end;


procedure Json.parse;
var
  JsonParser: TJsonParser;
begin
  ClearJsonParser(JsonParser);
  ParseJson(JsonParser, a);
  check;
  self.JsonParser := JsonParser;
  self.output := self.JsonParser.Output;
  self.setCurrent(self.JsonParser.output.Objects[0]);
end;

procedure Json.pop;
begin
  self.currentObject := TJsonObject(self.FStack.pop);
  self.arr := TJsonArray(self.FStack.pop);
end;

procedure Json.push;
begin
  self.FStack.push(TObject(self.arr));
  self.FStack.push(TObject(self.currentobject));
end;

// Call error when something is wrong.
procedure Error(var JsonParser: TJsonParser; Msg: TJsonString);
var
  ErrorMsg: TJsonString;
  N: Integer;
begin
  ErrorMsg := Format('Error: "%s". Position: %d. Text: "%s"', [Msg, JsonParser.At, JsonParser.Text]);
  N := Length(JsonParser.Output.Errors);
  SetLength(JsonParser.Output.Errors, N + 1);
  JsonParser.Output.Errors[N] := ErrorMsg;
end;

function Next(var JsonParser: TJsonParser; C: TJsonChar): TJsonChar;
begin
  Result := #0;
  // If a non-#0 C parameter is provided, verify that it matches the current character.
  if (C <> #0) and (C <> JsonParser.Ch) then
  begin
    Error(JsonParser, 'Expected "' + C + '" instead of "' + JsonParser.Ch + '"');
    Exit;
  end;
  // Get the next character. When there are no more characters, return #0.
  if JsonParser.At > Length(JsonParser.Text) then
  begin
    JsonParser.Ch := #0;
    Exit;
  end;
  JsonParser.Ch := JsonParser.Text[JsonParser.At];
  Inc(JsonParser.At);
  Result := JsonParser.Ch;
end;

// Parse a number value.
function Number(var JsonParser: TJsonParser): Double;
var
  S: WideString;
begin
  Result := 0;
  S := '';
  if JsonParser.Ch = '-' then
  begin
    S := '-';
    Next(JsonParser, '-');
  end;
  while (JsonParser.Ch >= '0') and (JsonParser.Ch <= '9') do
  begin
    S := S + JsonParser.Ch;
    Next(JsonParser, #0);
  end;
  if JsonParser.Ch = '.' then
  begin
    S := S + '.';
    while (Next(JsonParser, #0) <> #0) and (JsonParser.Ch >= '0') and (JsonParser.Ch <= '9') do
      S := S + JsonParser.Ch;
  end;
  if (JsonParser.Ch = 'e') or (JsonParser.Ch = 'E') then
  begin
    S := S + JsonParser.Ch;
    Next(JSonParser, #0);
    if (JsonParser.Ch = '-') or (JsonParser.Ch = '+') then
    begin
      S := S + JsonParser.Ch;
      Next(JsonParser, #0);
    end;
    while (JsonParser.Ch >= '0') and (JsonParser.Ch <= '9') do
    begin
      S := S + JsonParser.Ch;
      Next(JsonParser, #0);
    end;
  end;
  if S = '' then
    Error(JsonParser, 'Bad number')
  else
    Result := StrToFloat(S);
end;

// Parse a string value.
function String_(var JsonParser: TJsonParser): TJsonString;
var
  HexDigit, HexValue: Integer;
  I: Integer;
  SpecChar: TJsonChar;
begin
  Result := '';
  // When parsing for string values, we must look for " and \ characters.
  if JsonParser.Ch = '"' then
  begin
    while Next(JsonParser, #0) <> #0 do
    begin
      if JsonParser.Ch = '"' then
      begin
        Next(JsonParser, #0);
        Exit;
      end;
      if JsonParser.Ch = '\' then
      begin
        Next(JsonParser, #0);
        if JsonParser.Ch = 'u' then
        begin
          HexValue := 0;
          for I := 1 to 4 do
          begin
            HexDigit := StrToInt('0x' + Next(JsonParser, #0));
            HexValue := HexValue * 16 + HexDigit;
          end;
          Result := Result + Chr(HexValue);
        end
        else
        begin
          case JsonParser.Ch of
            '"': SpecChar := '"';
            '\': SpecChar := '\';
            '/': SpecChar := '/';
            'b': SpecChar := #8;
            'f': SpecChar := #12;
            'n': SpecChar := #10;
            'r': SpecChar := #13;
            't': SpecChar := #9;
          else
            Break;
          end;
        end;
      end
      else 
        Result := Result + JsonParser.Ch;
    end;
  end;
  Error(JsonParser, 'Bad string');
end;

// Skip whitespace.
procedure White(var JsonParser: TJsonParser);
begin
  while (JsonParser.Ch <> #0) and (JsonParser.Ch <= ' ') do
    Next(JsonParser, #0);
end;

// true, false, or null.
function Word_(var JsonParser: TJsonParser): TJsonWord;
begin
  Result := JWUnknown;
  case JsonParser.Ch of
    't':
    begin
      Next(JsonParser, 't');
      Next(JsonParser, 'r');
      Next(JsonParser, 'u');
      Next(JsonParser, 'e');
      Result := JWTrue;
      Exit;
    end;
    'f':
    begin
      Next(JsonParser, 'f');
      Next(JsonParser, 'a');
      Next(JsonParser, 'l');
      Next(JsonParser, 's');
      Next(JsonParser, 'e');
      Result := JWFalse;
      Exit;
    end;
    'n':
    begin
      Next(JsonParser, 'n');
      Next(JsonParser, 'u');
      Next(JsonParser, 'l');
      Next(JsonParser, 'l');
      Result := JWNull;
      Exit;
    end;
  end;
  Error(JsonParser, 'Unexpected "' + JsonParser.Ch + '"');
end;

// Parse an array value.
function Array_(var JsonParser: TJsonParser; Value: TJsonValueParser): TJsonArray;
var
  N: Integer;
begin
  SetLength(Result, 0); // Empty array
  N := 0;
  if JsonParser.Ch = '[' then
  begin
    Next(JsonParser, '[');
    White(JsonParser);
    if JsonParser.Ch = ']' then
    begin
      Next(JsonParser, ']');
      Exit; // Return empty array
    end;
    while JsonParser.Ch <> #0 do
    begin
      Inc(N);
      SetLength(Result, N);
      Result[N - 1] := Value(JsonParser);
      White(JsonParser);
      if JsonParser.Ch = ']' then
      begin
        Next(JsonParser, ']');
        Exit;
      end;
      Next(JsonParser, ',');
      White(JsonParser);
    end;
  end;
  Error(JsonParser, 'Bad array');
end;

// Parse an object value.
function Object_(var JsonParser: TJsonParser; Value: TJsonValueParser): TJsonObject;
var
  Key: TJsonString;
  I, N: Integer;
begin
  SetLength(Result, 0); // Empty object
  N := 0;
  if JsonParser.Ch = '{' then
  begin
    Next(JsonParser, '{');
    White(JsonParser);
    if JsonParser.Ch = '}' then
    begin
      Next(JsonParser, '}');
      Exit; // Return empty object
    end;
    while JsonParser.Ch <> #0 do
    begin
      Key := String_(JsonParser);
      White(JsonParser);
      Next(JsonParser, ':');
      for I := 0 to N - 1 do
      begin
        if Key = Result[I].Key then
          Error(JsonParser, 'Duplicate key "' + Key + '"');
      end;
      Inc(N);
      SetLength(Result, N);
      Result[N - 1].Key := Key;
      Result[N - 1].Value := Value(JsonParser);
      White(JsonParser);
      if JsonParser.Ch = '}' then
      begin
        Next(JsonParser, '}');
        Exit;
      end;
      Next(JsonParser, ',');
      White(JsonParser);
    end;
  end;
  Error(JsonParser, 'Bad object');
end;

// Parse a JSON value. It could be a number, a string, a word, an array, or an object.
function Value(var JsonParser: TJsonParser): TJsonValue;
var
  N: Integer;
begin
  Result.Kind := JVKUnknown;
  Result.Index := -1;
  White(JsonParser);
  case JsonParser.Ch of
    '-', '0'..'9':
    begin
      N := Length(JsonParser.Output.Numbers);
      SetLength(JsonParser.Output.Numbers, N + 1);
      JsonParser.Output.Numbers[N] := Number(JsonParser);
      Result.Kind := JVKNumber;
      Result.Index := N;
    end;
    '"':
    begin
      N := Length(JsonParser.Output.Strings);
      SetLength(JsonParser.Output.Strings, N + 1);
      JsonParser.Output.Strings[N] := String_(JsonParser);
      Result.Kind := JVKString;
      Result.Index := N;
    end;
    't', 'f', 'n':
    begin
      N := Length(JsonParser.Output.Words);
      SetLength(JsonParser.Output.Words, N + 1);
      JsonParser.Output.Words[N] := Word_(JsonParser);
      Result.Kind := JVKWord;
      Result.Index := N;
    end;
    '[':
    begin
      N := Length(JsonParser.Output.Arrays);
      SetLength(JsonParser.Output.Arrays, N + 1);
      JsonParser.Output.Arrays[N] := Array_(JsonParser, @Value);
      Result.Kind := JVKArray;
      Result.Index := N;
    end;
    '{':
    begin
      N := Length(JsonParser.Output.Objects);
      SetLength(JsonParser.Output.Objects, N + 1);
      JsonParser.Output.Objects[N] := Object_(JsonParser, @Value);
      Result.Kind := JVKObject;
      Result.Index := N;
    end;
  else
    Error(JsonParser, 'Bad JSON value');
  end;
end;

procedure ParseJson(var JsonParser: TJsonParser; const Source: WideString);
begin
  if Source = '' then
    Exit;
  JsonParser.At := 1;
  JsonParser.Ch := ' ';
  JsonParser.Text := Source;
  Value(JsonParser);
  White(JsonParser);
  if JsonParser.Ch <> #0 then
    Error(JsonParser, 'Syntax error');
end;

procedure ClearJsonParser(var JsonParser: TJsonParser);
begin
  JsonParser.At := 0;
  JsonParser.Ch := #0;
  JsonParser.Text := '';
  SetLength(JsonParser.Output.Numbers, 0);
  SetLength(JsonParser.Output.Strings, 0);
  SetLength(JsonParser.Output.Words, 0);
  SetLength(JsonParser.Output.Arrays, 0);
  SetLength(JsonParser.Output.Objects, 0);
  SetLength(JsonParser.Output.Errors, 0);
end;

function IndentString(Indent: Integer): TJsonString;
var
  I: Integer;
begin
  for I := 1 to 4 * Indent do
    Result := Result + ' ';
end;

procedure PrintJsonObject(const Output: TJsonParserOutput; Index, Indent: Integer; Lines: TStringList; CommaAfter: TJsonString); forward;

procedure PrintJsonArray(const Output: TJsonParserOutput; Index, Indent: Integer; Lines: TStringList; CommaAfter: TJsonString);
var
  IS0, IS1: TJsonString;
  I: Integer;
  V: TJsonValue;
  S, Comma: TJsonString;
begin
  IS0 := IndentString(Indent);
  IS1 := IndentString(Indent + 1);
  Lines.Add(IS0 + '[');
  for I := 0 to Length(Output.Arrays[Index]) - 1 do
  begin
    if I < Length(Output.Arrays[Index]) - 1 then
      Comma := ','
    else
      Comma := '';
    V := Output.Arrays[Index][I];
    case V.Kind of
      JVKUnknown: Lines.Add(IS1 + '?kind?' + Comma);
      JVKNumber: Lines.Add(Format('%s%g' + Comma, [IS1, Output.Numbers[V.Index]]));
      JVKString: Lines.Add(IS1 + '"' + Output.Strings[V.Index] + '"' + Comma);
      JVKWord:
      begin
        case Output.Words[V.Index] of
          JWUnknown: S := '?word?';
          JWTrue: S := 'true';
          JWFalse: S := 'false';
          JWNull: S := 'null';
        end;
        Lines.Add(IS1 + S + Comma);
      end;
      JVKArray: PrintJsonArray(Output, V.Index, Indent + 1, Lines, Comma);
      JVKObject: PrintJsonObject(Output, V.Index, Indent + 1, Lines, Comma);
    end;
  end;
  Lines.Add(IS0 + ']' + CommaAfter);
end;

procedure PrintJsonObject(const Output: TJsonParserOutput; Index, Indent: Integer; Lines: TStringList; CommaAfter: TJsonString);
var
  IS0, IS1: TJsonString;
  I: Integer;
  K: TJsonString;
  V: TJsonValue;
  S, Comma: TJsonString;
begin
  IS0 := IndentString(Indent);
  IS1 := IndentString(Indent + 1);
  Lines.Add(IS0 + '{');
  for I := 0 to Length(Output.Objects[Index]) - 1 do
  begin
    if I < Length(Output.Objects[Index]) - 1 then
      Comma := ','
    else
      Comma := '';
    K := '"' + Output.Objects[Index][I].Key + '"';
    V := Output.Objects[Index][I].Value;
    case V.Kind of
      JVKUnknown: Lines.Add(IS1 + K + ': ?kind?' + Comma);
      JVKNumber: Lines.Add(Format('%s: %g' + Comma, [IS1 + K, Output.Numbers[V.Index]]));
      JVKString: Lines.Add(IS1 + K + ': "' + Output.Strings[V.Index] + '"' + Comma);
      JVKWord:
      begin
        case Output.Words[V.Index] of
          JWUnknown: S := '?word?';
          JWTrue: S := 'true';
          JWFalse: S := 'false';
          JWNull: S := 'null';
        end;
        Lines.Add(IS1 + K + ': ' + S + Comma);
      end;
      JVKArray:
      begin
        Lines.Add(IS1 + K + ':');
        PrintJsonArray(Output, V.Index, Indent + 1, Lines, Comma);
      end;
      JVKObject:
      begin
        Lines.Add(IS1 + K + ':');
        PrintJsonObject(Output, V.Index, Indent + 1, Lines, Comma);
      end;
    end;
  end;
  Lines.Add(IS0 + '}' + CommaAfter);
end;

procedure PrintJsonParserOutput(const Output: TJsonParserOutput; Lines: TStringList);
begin
  PrintJsonObject(Output, 0, 0, Lines, '');
end;
{ tstack }


end.

