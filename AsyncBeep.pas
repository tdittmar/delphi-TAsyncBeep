{ **************************************************************************** }
{ AsyncBeep.pas                  Copyright © 2001 DithoSoft Software Solutions }
{ Version 1.0                                          http://www.dithosoft.de }
{                                                         support@dithosoft.de }
{ ---------------------------------------------------------------------------- }
{ This component wraps the Windows API beep function so that it can be used    }
{ asynchronously.                                                              }
{ **************************************************************************** }
unit AsyncBeep;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TAsyncBeep  = class;

  { The thread that checks of queued beeps }
  TBeepThread = class(TThread)
  protected
    FAsyncBeep: TAsyncBeep;
    procedure Execute; override;
    procedure DeleteFirstBeep;
  end;

  { The asynchronous beep component }
  TAsyncBeep = class(TComponent)
  private
    FBeepQueue: TList;
    FBeepThread: TBeepThread;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure   DoBeep(Pitch, Duration: Integer);
  end;

procedure Register;

implementation

uses typinfo;

resourcestring
  SPitchError    = 'Pitch must be between 37 and 32767';
  SDurationError = 'Duration must be greater than 0';

type
  { An object that holds the information about the beep }
  TBeepObject = class
  private
    FPitch: Integer;
    FDuration: Integer;
  public
    constructor Create(Pitch, Duration: Integer);
    property Pitch: Integer read FPitch;
    property Duration: Integer read FDuration;
  end;

{
  Create
  Creates a new beep information object.
}
constructor TBeepObject.Create(Pitch, Duration: Integer);
begin
  FPitch := Pitch;
  FDuration := Duration;
end;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

{
  Create
  Creates a new AsyncBeep component.
}
constructor TAsyncBeep.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FBeepQueue             := TList.Create;
  FBeepThread            := TBeepThread.Create(True);
  FBeepThread.FAsyncBeep := self;
  FBeepThread.Resume;
end;

{
  Destroy
  Destroy the AsyncBeep component.
}
destructor TAsyncBeep.Destroy;
var
  i: Integer;
begin
  // Destroy the thread first (this waits until an active beep is finished)
  FBeepThread.Free;

  // Now we remove all pending beeps and destroy the list
  try
    for i := FBeepQueue.Count-1 downto 0 do TBeepObject(FBeepQueue[i]).Free;
  finally
    FBeepQueue.Free;
    inherited;
  end;
end;

{
  DoBeep
  Queues a beep sound and returns.
}
procedure TAsyncBeep.DoBeep(Pitch, Duration: Integer);
begin
  // Check if pitch and duration are within valid bounds
  if (Pitch < 37) or (Pitch > 32767) then raise EPropertyError.Create(SPitchError);
  if (Duration < 0) then raise EPropertyError.Create(SDurationError);

  // If so, add a new item to the beep queue
  FBeepQueue.Add(TBeepObject.Create(Pitch,Duration));
end;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

{
  Execute
  The thread's execution loop.
}
procedure TBeepThread.Execute;
var
  aBeep: TBeepObject;
begin
  // Loop until the thread is terminated
  while not Terminated do
  begin
    // If there are beep objects in the queue
    if Assigned(FAsyncBeep) and (FAsyncBeep.FBeepQueue.Count > 0) then
    begin
      // Get the object, remove it and do the beep
      aBeep := TBeepObject(FAsyncBeep.FBeepQueue[0]);
      Synchronize(DeleteFirstBeep);
      Windows.Beep(aBeep.Pitch,aBeep.Duration);
      aBeep.Free;
    end;
  end;
end;

{
  DeleteFirstBeep
  Removes the first object in the BeepQueue
}
procedure TBeepThread.DeleteFirstBeep;
begin
  // Remove the first beep object from the queue
  if Assigned(FAsyncBeep) and (FAsyncBeep.FBeepQueue.Count > 0) then
    FAsyncBeep.FBeepQueue.Delete(0);
end;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

{
  Register
  Registers the component with the Delphi IDE.
}
procedure Register;
begin
  RegisterComponents('Freeware', [TAsyncBeep]);
end;

end.
