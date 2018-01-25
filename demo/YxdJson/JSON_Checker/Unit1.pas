unit Unit1;

interface

uses
  YxdJson, YxdStr, ShellAPI,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, SynEdit, SynMemo;

type
  TForm1 = class(TForm)
    Splitter1: TSplitter;
    Panel1: TPanel;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Button1: TButton;
    CheckBox3: TCheckBox;
    Label2: TLabel;
    Edit1: TEdit;
    CheckBox4: TCheckBox;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    CheckBox5: TCheckBox;
    Memo1: TSynMemo;
    Memo2: TSynMemo;
    chkR: TCheckBox;
    chkW: TCheckBox;
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure CheckBox5Click(Sender: TObject);
  private
    { Private declarations }
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  Json: JSONBase;
  T: Cardinal;
  I, J, M: Integer;
  B: Boolean;
  S, V: string;
begin
  J := StrToIntDef(Edit1.Text, 1);
  M := 0;
  if not CheckBox3.Checked then
    M := 4;
  B := CheckBox4.Checked;
  V := Memo1.Text;
  S := '';    
  try
    Json := nil;
    T := 0;
    try
      if chkR.Checked and chkW.Checked then begin
      
        T := GetTickCount;
        for I := 0 to J - 1 do begin
          Json := JSONBase.Parser(V);
          S := Json.ToString(M, B);
          FreeAndNil(Json);
        end;
        T := GetTickCount - T;

      end else if chkR.Checked then begin

        T := GetTickCount;
        for I := 0 to J - 1 do begin
          FreeAndNil(Json);
          Json := JSONBase.Parser(V);
        end;
        T := GetTickCount - T;
        S := Json.ToString(M, B);

      end else begin

        Json := JSONBase.Parser(V);
        T := GetTickCount;
        for I := 0 to J - 1 do
          S := Json.ToString(M, B);
        T := GetTickCount - T;

      end;
    finally
      FreeAndNil(Json);
      StatusBar1.Panels.Items[1].Text := Format('��ʱ: %dms', [T]);
      Memo2.Lines.Text := S;
    end;
  except
    MessageBox(Handle, PChar(Exception(ExceptObject).Message), '����', 48);
  end;
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  YxdJson.StrictJson := TCheckBox(Sender).Checked;
end;

procedure TForm1.CheckBox2Click(Sender: TObject);
begin
  if TCheckBox(Sender).Checked then
    YxdJson.JsonDateFormatStyle := jdsJsonTime
  else
    YxdJson.JsonDateFormatStyle := jdsNormal;
end;

procedure TForm1.CheckBox5Click(Sender: TObject);
begin
  JsonNameAfterSpace := CheckBox5.Checked;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  DragAcceptFiles(Handle, True);
  JsonNameAfterSpace := True;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  O: TSynMemo;
begin
  if Memo1.Focused then
    O := Memo1
  else if Memo2.Focused then
    O := Memo2
  else
    Exit;
  StatusBar1.Panels.Items[0].Text := Format('��: %d ��ǰѡ��%d', [O.CaretX, O.SelLength]);
end;

procedure TForm1.WMDropFiles(var Msg: TWMDropFiles);
var
  i, iNumberDropped: Integer;
  FileNameA: array[0..MAX_PATH - 1] of AnsiChar;
  Point: TPoint;
  S: string;
  V: TFileStream;
begin
  iNumberDropped := DragQueryFile(THandle(Msg.Drop), Cardinal(-1), nil, 0);
  DragQueryPoint(THandle(Msg.Drop), Point);
  for i := 0 to iNumberDropped - 1 do begin
    DragQueryFileA(THandle(Msg.Drop), i, FileNameA, sizeof(FileNameA));
    S := string(FileNameA);
    V := TFileStream.Create(S, 0);
    try
      S := YxdStr.LoadTextA(V);
      Memo1.Lines.Text := S;
    finally
      V.Free;
    end;
    Break;
  end;
end;

end.