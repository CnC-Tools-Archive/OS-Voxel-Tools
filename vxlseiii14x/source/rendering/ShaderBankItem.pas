unit ShaderBankItem;

interface

uses BasicFunctions, BasicMathsTypes, BasicDataTypes, dglOpenGL, SysUtils, Classes;

type
   TShaderBankItem = class
      private
         Counter: longword;
         IsAuthorized,IsVertexCompiled,IsFragmentCompiled,IsLinked, IsRunning : boolean;
         ProgramID, VertexID, FragmentID : GLUInt;
         Attributes: AString;
         AttributeLocation: array of TGLInt;
         Uniforms: AString;
         UniformLocation: array of TGLInt;
      public
         // Constructor and Destructor
         constructor Create(const _VertexFilename, _FragmentFilename: string); overload;
         destructor Destroy; override;
         // Gets
         function GetID : GLInt;
         function IsProgramLinked: boolean;
         function IsVertexShaderCompiled: boolean;
         function IsFragmentShaderCompiled: boolean;
         // Sets
         procedure SetAuthorization(_value: boolean);
         // Uses
         procedure UseProgram;
         procedure DeactivateProgram;
         // Adds
         procedure AddAttribute(const _name: string);
         procedure AddUniform(const _name: string);
         // Counter
         function GetCount : integer;
         procedure IncCounter;
         procedure DecCounter;
         // OpenGL
         procedure glSendAttribute2f(_AttributeID: integer; const _Value: TVector2f);
         procedure glSendAttribute3f(_AttributeID: integer; const _Value: TVector3f);
         procedure glSendUniform1i(_UniformID: integer; const _Value: integer);
   end;
   PShaderBankItem = ^TShaderBankItem;

implementation

uses Dialogs;

// Constructors and Destructors
constructor TShaderBankItem.Create(const _VertexFilename, _FragmentFilename: string);
var
   Stream : TStream;
   PPCharData : PPGLChar;
   PCharData,Log : PAnsiChar;
   CharData : array of ansichar;
   Size : GLInt;
   Compiled : PGLInt;
   Filename: string;
begin
   Counter := 1;
   IsVertexCompiled := false;
   IsFragmentCompiled := false;
   IsLinked := false;
   IsRunning := false;
   IsAuthorized := false;
   VertexID := 0;
   FragmentID := 0;
   ProgramID := 0;
   SetLength(Attributes,0);
   // Let's load the vertex shader first.
   if FileExists(_VertexFilename) then
   begin
      Stream := TFileStream.Create(_VertexFilename,fmOpenRead);
      Size := Stream.Size;
      SetLength(CharData,Size+1);
      PCharData := Addr(CharData[0]);
      PPCharData := Addr(PCharData);
      Stream.Read(CharData[0],Size);
      CharData[High(CharData)] := #0;
      Stream.Free;
      VertexID := glCreateShader(GL_VERTEX_SHADER);
      glShaderSource(VertexID,1,PPCharData,nil);
      SetLength(CharData,0);
      glCompileShader(VertexID);
      GetMem(Compiled,4);
      glGetShaderiv(VertexID,GL_COMPILE_STATUS,Compiled);
      IsVertexCompiled := Compiled^ <> 0;
      FreeMem(Compiled);
      if not IsVertexCompiled then
      begin
         // If compile fails, generate the log.
         // Note: Here compiled will be the size of the error log
         GetMem(Compiled,4);
         glGetShaderiv(VertexID,GL_INFO_LOG_LENGTH,Compiled);
         if Compiled^ > 0 then
         begin
            Filename := copy(_VertexFilename,1,Length(_VertexFilename)-4) + '_error.log';
            Stream := TFileStream.Create(Filename,fmCreate);
            GetMem(Log,Compiled^);
            glGetShaderInfoLog(VertexID,Compiled^,Size,Log);
            Stream.Write(Log^,Size);
            FreeMem(Log);
            Stream.Free;
         end;
         FreeMem(Compiled);
      end;
   end;
   // Let's load the fragment shader.
   if FileExists(_FragmentFilename) then
   begin
      Stream := TFileStream.Create(_FragmentFilename,fmOpenRead);
      Size := Stream.Size;
      SetLength(CharData,Size+1);
      PCharData := Addr(CharData[0]);
      PPCharData := Addr(PCharData);
      Stream.Read(CharData[0],Size);
      CharData[High(CharData)] := #0;
      Stream.Free;
      FragmentID := glCreateShader(GL_FRAGMENT_SHADER);
      glShaderSource(FragmentID,1,PPCharData,nil);
      SetLength(CharData,0);
      glCompileShader(FragmentID);
      GetMem(Compiled,4);
      glGetShaderiv(FragmentID,GL_COMPILE_STATUS,Compiled);
      IsFragmentCompiled := Compiled^ <> 0;
      FreeMem(Compiled);
      if not IsFragmentCompiled then
      begin
         // If compile fails, generate the log.
         // Note: Here compiled will be the size of the error log
         GetMem(Compiled,4);
         glGetShaderiv(FragmentID,GL_INFO_LOG_LENGTH,Compiled);
         if Compiled^ > 0 then
         begin
            Filename := copy(_FragmentFilename,1,Length(_FragmentFilename)-4) + '_error.log';
            Stream := TFileStream.Create(Filename,fmCreate);
            GetMem(Log,Compiled^);
            glGetShaderInfoLog(FragmentID,Compiled^,Size,Log);
            Stream.Write(Log^,Size);
            FreeMem(Log);
            Stream.Free;
         end;
         FreeMem(Compiled);
      end;
   end;
   // Time to create and link the program.
   if IsFragmentCompiled or isVertexCompiled then
   begin
      ProgramID := glCreateProgram();
      if isVertexCompiled then
         glAttachShader(ProgramID,VertexID);
      if isFragmentCompiled then
         glAttachShader(ProgramID,FragmentID);
      glLinkProgram(ProgramID);
      GetMem(Compiled,4);
      glGetProgramiv(ProgramID,GL_LINK_STATUS,Compiled);
      IsLinked := Compiled^ <> 0;
      IsAuthorized := IsLinked;
      FreeMem(Compiled);
      if not IsLinked then
      begin
         // If compile fails, generate the log.
         // Note: Here compiled will be the size of the error log
         GetMem(Compiled,4);
         glGetProgramiv(ProgramID,GL_INFO_LOG_LENGTH,Compiled);
         if Compiled^ > 0 then
         begin
            if IsFragmentCompiled then
               Filename := IncludeTrailingPathDelimiter(ExtractFileDir(_FragmentFilename)) + 'link_error.log'
            else if IsVertexCompiled then
               Filename := IncludeTrailingPathDelimiter(ExtractFileDir(_VertexFilename)) + 'link_error.log';
            Stream := TFileStream.Create(Filename,fmCreate);
            GetMem(Log,Compiled^);
            glGetProgramInfoLog(ProgramID,Compiled^,Size,Log);
            Stream.Write(Log^,Size);
            FreeMem(Log);
            Stream.Free;
         end;
         FreeMem(Compiled);
      end;
   end;
end;

destructor TShaderBankItem.Destroy;
begin
   DeactivateProgram;
   if IsLinked then
   begin
      if IsVertexCompiled then
      begin
         glDetachShader(ProgramID,VertexID);
      end;
      if IsFragmentCompiled then
      begin
         glDetachShader(ProgramID,FragmentID);
      end;
      glDeleteProgram(ProgramID);
   end;
   if IsVertexCompiled then
   begin
      glDeleteShader(VertexID);
   end;
   if IsFragmentCompiled then
   begin
      glDeleteShader(FragmentID);
   end;
   SetLength(Attributes,0);
   inherited Destroy;
end;

// Gets
function TShaderBankItem.GetID : GLInt;
begin
   Result := ProgramID;
end;

function TShaderBankItem.IsProgramLinked: boolean;
begin
   Result := IsLinked;
end;

function TShaderBankItem.IsVertexShaderCompiled: boolean;
begin
   Result := IsVertexCompiled;
end;

function TShaderBankItem.IsFragmentShaderCompiled: boolean;
begin
   Result := IsFragmentCompiled;
end;

// Sets
procedure TShaderBankItem.SetAuthorization(_value: boolean);
begin
   isAuthorized := _value;
end;

// Uses
procedure TShaderBankItem.UseProgram;
var
   i : integer;
   UniformName: Pchar;
begin
   if IsLinked and (not IsRunning) and (isAuthorized) then
   begin
      glUseProgram(ProgramID);
      i := 0;
      while i <= High(Attributes) do
      begin
         glBindAttribLocation(ProgramID,i,PChar(Attributes[i]));
         AttributeLocation[i] := glGetAttribLocation(ProgramID,PChar(Attributes[i]));
         inc(i);
      end;
      i := 0;
      while i <= High(Uniforms) do
      begin
         UniformName := PChar(Uniforms[i]);
         UniformLocation[i] := glGetUniformLocation(ProgramID,UniformName);
         inc(i);
      end;
      IsRunning := true;
   end;
end;

procedure TShaderBankItem.DeactivateProgram;
begin
   if IsRunning then
   begin
      glUseProgram(0);
      IsRunning := false;
   end;
end;

// Adds
procedure TShaderBankItem.AddAttribute(const _name: string);
//var
//   AttributeName : PChar;
begin
   SetLength(Attributes,High(Attributes)+2);
   SetLength(AttributeLocation,High(Attributes)+1);
   Attributes[High(Attributes)] := copy(_name,1,Length(_name));
//   AttributeName := StrCat(PChar(Attributes[High(Attributes)]),#0);
//   AttributeLocation[High(Attributes)] := glGetAttribLocation(ProgramID,PChar(Attributes[High(Attributes)]));
end;

procedure TShaderBankItem.AddUniform(const _name: string);
//var
//   UniformName : PChar;
begin
   SetLength(Uniforms,High(Uniforms)+2);
   SetLength(UniformLocation,High(Uniforms)+1);
   Uniforms[High(Uniforms)] := copy(_name,1,Length(_name));
//   UniformName := StrCat(PChar(Uniforms[High(Uniforms)]),#0);
//   UniformLocation[High(Uniforms)] := glGetUniformLocation(ProgramID,UniformName);
end;

procedure TShaderBankItem.glSendAttribute2f(_AttributeID: integer; const _Value: TVector2f);
begin
   glVertexAttrib2f(AttributeLocation[_AttributeID], _Value.U, _Value.V);
end;

procedure TShaderBankItem.glSendAttribute3f(_AttributeID: integer; const _Value: TVector3f);
begin
   glVertexAttrib3f(AttributeLocation[_AttributeID], _Value.X, _Value.Y, _Value.Z);
end;

procedure TShaderBankItem.glSendUniform1i(_UniformID: integer; const _Value: integer);
begin
   glUniform1i(UniformLocation[_UniformID], _Value);
end;

// Counter
function TShaderBankItem.GetCount : integer;
begin
   Result := Counter;
end;

procedure TShaderBankItem.IncCounter;
begin
   inc(Counter);
end;

procedure TShaderBankItem.DecCounter;
begin
   Dec(Counter);
end;

end.
