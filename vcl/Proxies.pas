
unit Proxies;
 
interface
 
function IsProxyClass(ComponentClass: TClass): Boolean;

implementation

function IsProxyClass(ComponentClass: TClass): Boolean;
begin
  Result := True;
end;
end.

