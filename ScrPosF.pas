unit ScrPosF;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.Samples.Spin;

type
  TScrPosFrame = class(TFrame)
    LeftLbl: TLabel;
    TopLbl: TLabel;
    HeightLbl: TLabel;
    WidthLbl: TLabel;
    SpinEditLeft: TSpinEdit;
    SpinEditTop: TSpinEdit;
    SpinEditHeight: TSpinEdit;
    SpinEditWidth: TSpinEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

end.
