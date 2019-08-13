unit uObjProp;
interface
uses jp;
type ObjProp = class
  private
    JsonParser: TJsonParser;
    output:TJsonParserOutput;
    currentObject:TJsonObject;
//    function getArrayLength(p: string): Integer;
public
    function _array(p: string): TJsonArray;
    function _int(p: string): Integer;
    function objFrom(index: integer; obj: TJsonArray): TJsonObject;
    procedure setCurrent(obj:TJSonObject);
  public
    constructor create(JsonParser: TJsonParser);
end;
implementation

    function ObjProp._int(p:string):Integer;
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

    function ObjProp._array(p:string):TJsonArray;
    var i : integer;v : TJsonValue;
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
    function ObjProp.objFrom(index:integer;obj:TJsonArray):TJsonObject;
    var i : integer;v : TJsonValue;
    begin
        result := nil ;
        v :=  obj[index];
        if v.kind = JVKObject then
            result := output.Objects[v.Index];
    end;
    procedure ObjProp.setCurrent(obj: TJSonObject);
begin
  self.currentObject := obj;
end;
constructor ObjProp.create(JsonParser: TJsonParser);
begin
  self.JsonParser := JsonParser;
  self.output := self.JsonParser.Output;
end;



end.
