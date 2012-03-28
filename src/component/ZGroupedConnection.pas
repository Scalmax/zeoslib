{*********************************************************}
{                                                         }
{                 Zeos Database Objects                   }
{              Database Connection Component              }
{                                                         }
{        Originally written by Sergey Seroukhov           }
{                                                         }
{              modification by una.bicicleta              }
{*********************************************************}

unit ZGroupedConnection;

interface
{$I ZComponent.inc}

uses
  Types, SysUtils, Messages, Classes, ZDbcIntfs, DB,Forms,
  ZCompatibility, ZAbstractConnection, ZSequence, Dialogs,
  ZConnectionGroup {$IFDEF FPC}, LMessages{$ENDIF};

{$IFNDEF FPC}
 const  CM_ZCONNECTIONGROUPCHANGED = WM_USER + 100;
 const  CM_ZCONNECTIONGROUPCHANGE  = WM_USER + 101;
{$ELSE}
const  CM_ZCONNECTIONGROUPCHANGED = LM_USER + 100;
const  CM_ZCONNECTIONGROUPCHANGE  = LM_USER + 101;
{$ENDIF}

type
  TMsgZDbConnecitionChange = record
    Msg: Cardinal;
    Sender: TComponent;
    ZConnectionGroup: TZConnectionGroup;
    Result: Longint;
  end;

type
  TZGroupedConnection  = class(tZAbstractConnection)
  protected
    FZConnectionGroup: TZConnectionGroup;
    FZConnectionGroupLink: TZConnectionGroupLink;
    procedure SetConnectionGroup(Value: TZConnectionGroup);
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;
  private
    function getUser: string;
    function getPassword: string;
    function getHostName: string;
    function getDatabase: string;
    //function getCatalog: string;
    procedure DoZConnectionGroupChange(Sender: TObject);
    procedure ParentZConnectionGroupChange(var Msg: TMessage);
  published
    property ConnectionGroup: TZConnectionGroup read FZConnectionGroup write SetConnectionGroup;

    //property User: string read getUser;
    //property Protocol: string read getProtocol ;
    //property Password: string read getPassword ;
    //property HostName: string read getHostName ;
    //property Database: string read getDatabase ;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

procedure InternalZConnectionGroupChanged(AControl: TComponent; AZConnectionGroup: TZConnectionGroup);
var
  Msg: TMsgZDbConnecitionChange;
begin
  Msg.Msg := CM_ZCONNECTIONGROUPCHANGED;
  Msg.Sender := AControl;
  Msg.ZConnectionGroup := AZConnectionGroup;
  Msg.Result := 0;
  //AControl.Broadcast(Msg);
end;

// === { TZGroupedConnection  } =============================================
constructor TZGroupedConnection .Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FZConnectionGroupLink := TZConnectionGroupLink.Create;
  FZConnectionGroupLink.OnChange := DoZConnectionGroupChange;
end;

destructor TZGroupedConnection .Destroy;
begin
  FZConnectionGroupLink.Free;
  inherited Destroy;
end;

procedure TZGroupedConnection .DoZConnectionGroupChange(Sender: TObject);
begin
  if (Sender is TZConnectionGroup) then
  begin
    FURL.UserName := (Sender as TZConnectionGroup).User;
    FURL.Protocol := (Sender as TZConnectionGroup).Protocol;
    FURL.Password := (Sender as TZConnectionGroup).Password;
    FURL.HostName := (Sender as TZConnectionGroup).HostName;
    FURL.Database := (Sender as TZConnectionGroup).Database;
  end;
end;

procedure TZGroupedConnection .ParentZConnectionGroupChange(var Msg: TMessage);
begin
  InternalZConnectionGroupChanged(Self, FZConnectionGroup);
end;

procedure TZGroupedConnection .Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if (Operation = opRemove) then
  begin
    if (AComponent is TDataset) then
      UnregisterDataSet(TDataset(AComponent));
    if (AComponent is TZSequence) then
      UnregisterSequence(TZSequence(AComponent));
    if (AComponent = FZConnectionGroup) then
      FZConnectionGroup := nil;
  end;
end;

procedure TZGroupedConnection .SetConnectionGroup(Value: TZConnectionGroup);
begin
  if FZConnectionGroup<>nil then
    FZConnectionGroup.UnRegisterChanges(FZConnectionGroupLink);

  FZConnectionGroup := Value;
  if Value <> nil then
  begin
    FZConnectionGroup.RegisterChanges(FZConnectionGroupLink);
    FURL.UserName := FZConnectionGroup.User;
    FURL.Protocol := FZConnectionGroup.Protocol;
    FURL.Password := FZConnectionGroup.Password;
    FURL.HostName := FZConnectionGroup.HostName;
    FURL.Database := FZConnectionGroup.Database;
  end;
  InternalZConnectionGroupChanged(Self, Value);
end;

function TZGroupedConnection .getUser: string;
begin
  if FZConnectionGroup <> nil then
  begin
    FURL.UserName := FZConnectionGroup.User;
    Result := FURL.UserName;
  end
  else
    FURL.UserName := '';
end;

{
function TZGroupedConnection .getProtocol: string;
begin
  if FZConnectionGroup <> nil then
  begin
    FProtocol := FZConnectionGroup.Protocol;
    Result := FProtocol;
  end
  else
    FProtocol := '';
end;
}

function TZGroupedConnection .getPassword: string;
begin
  if FZConnectionGroup <> nil then
  begin
    FURL.Password := FZConnectionGroup.Password;
    Result := FURL.Password;
  end
  else
    FURL.Password := '';
end;

function TZGroupedConnection .getHostName: string;
begin
  if FZConnectionGroup <> nil then
  begin
    FURL.HostName := FZConnectionGroup.HostName;
    Result := FURL.HostName;
  end
  else
    FURL.HostName := '';
end;

function TZGroupedConnection .getDatabase: string;
begin
  if FZConnectionGroup <> nil then
  begin
    FURL.Database := FZConnectionGroup.Database;
    Result := FURL.Database;
  end
  else
    FURL.Database := '';
end;

{
function TZGroupedConnection .getCatalog: string;
begin
  if FZConnectionGroup <> nil then
  begin
    FCatalog := FZConnectionGroup.Catalog;
    Result := FCatalog;
  end
  else
    FCatalog := '';
end;
}

end.
