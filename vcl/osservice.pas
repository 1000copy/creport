unit osservice;

interface

uses
   windows ,classes,SysUtils;

type
  WindowsOS = class
  private
  public
    function UnionRect(lprcSrc1, lprcSrc2: TRect): TRect;
    function IntersectRect(lprcSrc1, lprcSrc2: TRect): TRect;
    function Contains(Bigger, smaller: TRect):boolean;
  end;
  procedure CheckError(condition:Boolean ;msg :string);
implementation

{ WindowsOS }

function WindowsOS.UnionRect(lprcSrc1, lprcSrc2: TRect): TRect;
var
   r: TRect;
begin
  if not windows.UnionRect(Result,lprcSrc1,lprcSrc2)  then
    SetRectEmpty(result);

end;

function WindowsOS.IntersectRect(lprcSrc1, lprcSrc2: TRect): TRect;
var
   r: TRect;
begin
  if not windows.IntersectRect(Result,lprcSrc1,lprcSrc2)  then
    SetRectEmpty(result);

end;

function WindowsOS.Contains(Bigger, smaller: TRect): boolean;
var
  r :trect ;
begin
  r := self.IntersectRect(Bigger,smaller);
  Result := windows.EqualRect(r,smaller) ;
end;
procedure CheckError(condition:Boolean ;msg :string);
begin
  if condition then
    raise Exception.Create(msg);
end;

end.
