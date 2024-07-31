uses Graph, Crt;
const
     BRICK_WIDTH = 49;
     BRICK_HEIGHT = 10;
     BRICK_Y_OFFSET = 100;
     BRICK_COUNT = 10;

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
    RBrick = record
           x, y: integer;
           width, height: integer;
           isVisible: boolean;
    end;
    ABricks = array [1..10] of RBrick;
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

procedure MouseInit; assembler;
asm
   mov ax, 1
   int 33h
end;


procedure MouseInfo(VAR x: integer); assembler;
asm
	mov	ax,$0003
	int	$33
	les	si,x
	mov	[es:si],cx
	{les	si,y
	mov	[es:si],dx

	mov	ax,bx
	and	al,1
	les	si,lb
	mov	[es:si],al
	shr	bl,1
	and	bl,1
	les	si,rb
	mov	[es:si],bl}
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

procedure InitBricks(var bricks: ABricks);
var i: integer;
begin
     for i := 1 to BRICK_COUNT do begin
         bricks[i].x := i * BRICK_WIDTH + 1;
         bricks[i].y := BRICK_Y_OFFSET;
         bricks[i].width := BRICK_WIDTH;
         bricks[i].height := BRICK_HEIGHT;
         bricks[i].isVisible := true;
     end;
end;

procedure DrawBricks(var bricks: ABricks);
var i: integer;
begin
     for i := 1 to BRICK_COUNT do begin
         if bricks[i].isVisible = true then begin
            rectangle(
              bricks[i].x, bricks[i].y,
              bricks[i].x + bricks[i].width, bricks[i].y + bricks[i].height
            );
         end;
     end;
end;


procedure GameLoop;
var
  b: RBall;
  v: RVaus;
  bricks: ABricks;
  i: integer;
  mousex: integer;
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

     InitBricks(bricks);

     while true do begin
           NoSound;
           SetColor(Black);
           circle(b.x, b.y, b.radius);
           line(v.x, v.y, v.x + v.width, v.y);
           DrawBricks(bricks);

           if KeyPressed then begin
              case GetPressedKey of
                   Esc: break;
                   {
                   ArrowLeft: if v.x - v.v >= 0 then dec(v.x, v.v);
                   ArrowRight: if v.x + v.width + v.v <= GetMaxX then inc(v.x, v.v);
                   }
              end;
           end;

           MouseInfo(mousex);
           v.x := mousex;

           if (b.x + b.vx >= GetMaxX) or (b.x + b.vx <= 0) then begin
              b.vx := -b.vx;
              sound(100);
           end;
           if b.y + b.vy <= 0 then begin
              b.vy := -b.vy;
              sound(100);
           end;

           if abs(v.y - b.y) < 3 then begin
             if (v.x <= b.x) and (b.x <= v.x + v.width) then begin
                b.vy := -b.vy;
                sound(100);
             end;
           end;

           if (BRICK_Y_OFFSET <= b.y) and (b.y <= BRICK_Y_OFFSET + BRICK_HEIGHT) then begin
              for i := 1 to BRICK_COUNT do begin
                  if bricks[i].isVisible = false then continue;
                  if (bricks[i].x <= b.x) and (b.x <= bricks[i].x + bricks[i].width) then begin
                     bricks[i].isVisible := false;
                     b.vy := -b.vy;
                     sound(1000);
                  end;
              end;
           end;

           if b.y + b.vy >= GetMaxY then break; { game over }
           inc(b.x, b.vx);
           inc(b.y, b.vy);

           SetColor(White);
           circle(b.x, b.y, b.radius);
           line(v.x, v.y, v.x + v.width, v.y);
           DrawBricks(bricks);

           delay(10);
     end;
end;



begin
     if GraphOn then begin
        GameLoop;
        CloseGraph;
     end;
end.

