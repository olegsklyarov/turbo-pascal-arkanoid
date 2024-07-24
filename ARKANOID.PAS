uses Graph, Crt;
type
    RBall = record
          x, y, radius: integer;
          vx, vy: integer;
    end;
    RVaus = record
          x, y, width: integer;
          v: integer; { move vaus pixels }
          bottomOffset: integer;
    end;
    EKey = (Esc, ArrowLeft, ArrowRight);


function GraphOn: boolean;
var grDriver, grMode, ErrCode: Integer;
begin
     grDriver := Detect;
     InitGraph(grDriver, grMode, '');
     ErrCode := GraphResult;
     if ErrCode = grOk then
        GraphOn := true
     else begin
          Writeln('Graphics error:', GraphErrorMsg(ErrCode));
          GraphOn := false;
     end;
end;


function GetPressedKey: EKey;
var key: char;
begin
     key := ReadKey;
     case ord(key) of
          27: GetPressedKey := Esc;
          0: begin
                  key := ReadKey;
                  case ord(key) of
                       75: GetPressedKey := ArrowLeft;
                       77: GetPressedKey := ArrowRight;
                  end;
             end;
     end;
end;


procedure GameLoop;
var
  b: RBall;
  v: RVaus;
begin
     b.x := GetMaxX div 2;
     b.y := GetMaxY div 2;
     b.radius := 5;
     b.vx := 3;
     b.vy := -3;

     v.width := 100;
     v.bottomOffset := 20;
     v.x := (GetMaxX div 2) - (v.width div 2);
     v.y := GetMaxY - v.bottomOffset;
     v.v := 20;

     while true do begin
           SetColor(Black);
           circle(b.x, b.y, b.radius);
           line(v.x, v.y, v.x + v.width, v.y);

           if KeyPressed then begin
              case GetPressedKey of
                   Esc: break;
                   ArrowLeft: if v.x - v.v >= 0 then dec(v.x, v.v);
                   ArrowRight: if v.x + v.width + v.v <= GetMaxX then inc(v.x, v.v);
              end;
           end;

           if (b.x + b.vx >= GetMaxX) or (b.x + b.vx <= 0) then begin
              b.vx := -b.vx;
           end;
           if b.y + b.vy <= 0 then begin
              b.vy := -b.vy;
           end;

           if abs(v.y - b.y) < 3 then begin
             if (v.x <= b.x) and (b.x <= v.x + v.width) then begin
                b.vy := -b.vy;
             end;
           end;

           if b.y + b.vy >= GetMaxY then break; { game over }
           inc(b.x, b.vx);
           inc(b.y, b.vy);




           SetColor(White);
           circle(b.x, b.y, b.radius);
           line(v.x, v.y, v.x + v.width, v.y);

           delay(10);
     end;
end;



begin
     if GraphOn then begin
        GameLoop;
        CloseGraph;
     end else begin

     end;
end.

