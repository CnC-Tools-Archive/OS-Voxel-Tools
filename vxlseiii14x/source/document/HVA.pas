unit HVA;

// HVA Unit By Banshee, from Stucuk's code.
// Written using the tibsun-hva.doc by The Profound Eol
{$INCLUDE source/Global_Conditionals.inc}

interface

uses dialogs,sysutils,dglOpenGL, Voxel, Geometry, BasicMathsTypes, math3d,
   BasicFunctions;

type
   THVA_Main_Header = record
      FilePath: array[1..16] of Char;  // ASCIIZ string
      N_Frames,                        // Number of animation frames
      N_Sections : Longword;           // Number of voxel sections described
   end;

   TSectionName = array[1..16] of Char; // ASCIIZ string - name of section
   TTransformMatrix = array[1..3,1..4] of Single;

   THVAData = record
      SectionName : TSectionName;
   end;

   PHVA = ^THVA;
   THVA = class
         Header : THVA_Main_Header;
         Data : array of THVAData;
         TransformMatrices : array of TTransformMatrix;
         p_Voxel : PVoxel;
      private
         procedure ClearMemory;
         procedure MakeABlankHVA;
         function LoadFromFile(const _Filename : string): boolean;
         procedure ClearFrame(_Number : integer);
         procedure ClearTM(_Number : integer);
         Function CorrectAngle(_Angle : Single) : Single;
         procedure CopyTM(Source, Dest : integer);
         procedure CopyFrameTM(Source, Dest : integer);
      public
         // Constructors/Destructors
         Constructor Create(); overload;
         constructor Create(const _Filename : string; _pVoxel : PVoxel); overload;
         constructor Create(const _HVA: THVA); overload;
         Destructor Destroy; override;
         // I/O stuff
         procedure Clear;
         procedure LoadFile(const _Filename : string; _pVoxel : PVoxel);
         Procedure SaveFile(const _Filename : string);
         procedure WestwoodToOpenGLCoordinates;
         procedure OpenGLToWestwoodCoordinates;
         // Frame Operations
         procedure AddBlankFrame;
         Procedure InsertFrame(FrameNumber : integer);
         Procedure CopyFrame(FrameNumber : integer);
         Procedure DeleteFrame(FrameNumber : Integer);
         // Section Operations
         procedure AddBlankSection;
         Procedure InsertSection(_SectionNumber : integer);
         Procedure CopySection(_Source,_Dest : integer); overload;
         Procedure CopySection(_Source,_Dest : integer; const HVA: THVA); overload;
         Procedure DeleteSection(_SectionNumber : Integer);
         // Gets
         Function GetMatrix(_Section,_Frames : Integer) : TMatrix; overload;
         Procedure GetMatrix(var _Res : TTransformMatrix; _Section,_Frames : Integer); overload;
         Function GetTMValue(_Row,_Col,_Section,_Frames : integer) : single;
         Function GetPosition(_Frame,_Section : Integer) : TVector3f;
         Function GetAngle_RAD(_Section,_Frames : Integer) : TVector3f;
         Function GetAngle_DEG(_Section,_Frames : Integer) : TVector3f;
         Function GetAngle_DEG_Correct(_Section,_Frames : Integer) : TVector3f;
         // Sets
         Procedure SetMatrix(const _M : TMatrix; _Frame,_Section : Integer); overload;
         Procedure SetMatrix(const _M : TTransformMatrix; _Frame,_Section : Integer); overload;
         Procedure SetTMValue(_Frame,_Section,_Row,_Col : Integer; _Value : single);
         Procedure SetPosition(_Frame,_Section : Integer; _Position : TVector3f);
         Function SetAngle(_Section,_Frames : Integer; _x,_y,_z : single) : TVector3f;
         // Miscelaneous
         Procedure ApplyMatrix(_VoxelScale : TVector3f; _Section : Integer; _Frame: integer);
         Procedure MovePosition(_Frame,_Section : Integer; _X,_Y,_Z : single);
         // Assign
         procedure Assign(const _HVA: THVA);
   end;

   THVAVOXEL = (HVhva,HVvoxel);

implementation

///////////////////////////////////////////////////////////
//////// New HVA Engine Rock And Roll HERE ////////////////
///////////////////////////////////////////////////////////
Constructor THVA.Create();
begin
   p_Voxel := nil;
   MakeABlankHVA;
end;

Constructor THVA.Create (const _Filename : string; _pVoxel : PVoxel);
begin
   LoadFile(_Filename,_pVoxel);
end;

constructor THVA.Create(const _HVA: THVA);
begin
   Assign(_HVA);
end;

Destructor THVA.Destroy;
begin
   ClearMemory;
   inherited Destroy;
end;

procedure THVA.ClearMemory;
begin
   SetLength(TransformMatrices,0);
end;

procedure THVA.Clear;
begin
   ClearMemory;
   MakeABlankHVA;
end;

// Gives the default settings for invalid HVAs
procedure THVA.MakeABlankHVA;
var
   x,i : byte;
begin
   Header.N_Frames := 0;
   if (p_Voxel <> nil) then
   begin
      Header.N_Sections := p_Voxel^.Header.NumSections;
   end
   else
   begin
      Header.N_Sections := 1;
   end;
   Setlength(Data,Header.N_Sections);

   for x := 1 to 16 do
      Header.FilePath[x] := #0;


   if (p_Voxel <> nil) then
   begin
      for i := 0 to p_Voxel^.Header.NumSections-1 do
         for x := 1 to 16 do
            Data[i].SectionName[x] := p_Voxel^.section[i].Header.Name[x];
   end;
   AddBlankFrame;
end;

Procedure THVA.SaveFile(const _Filename : string);
var
   f : file;
   wrote,x : integer;
begin
   OpenGLToWestwoodCoordinates;
   //SetCharArray('',HVAFile.Header.FilePath);
   for x := 1 to 16 do
      Header.FilePath[x] := #0;

   AssignFile(F,_Filename);  // Open file
   Rewrite(F,1); // Goto first byte?

   BlockWrite(F,Header,Sizeof(THVA_Main_Header),wrote); // Write Header

   {$ifdef DEBUG_HVA_FILE}
   Showmessage(_Filename);
   showmessage(inttostr(Header.N_Sections));
   showmessage(inttostr(Header.N_Frames));
   showmessage(inttostr(wrote));
   {$endif}

   For x := 0 to High(Data) do
      BlockWrite(F,Data[x].SectionName,Sizeof(TSectionName),wrote);

  {$ifdef DEBUG_HVA_FILE}
  showmessage(inttostr(wrote));
  {$endif}

   For x := 0 to High(TransformMatrices) do
      BlockWrite(F,TransformMatrices[x],Sizeof(TTransformMatrix),wrote);

   {$ifdef DEBUG_HVA_FILE}
   showmessage(inttostr(wrote));
   {$endif}

   CloseFile(f);
   WestwoodToOpenGLCoordinates;
end;

procedure THVA.LoadFile(const _Filename : string; _pVoxel : PVoxel);
begin
   p_Voxel := _pVoxel;
   ClearMemory;
   if not LoadFromFile(_Filename) then MakeABlankHVA;
end;

function THVA.LoadFromFile(const _Filename: String): boolean;
var
   f : file;
   x: integer;
begin
   Result := false;
   if not FileExists(_Filename) then exit;

   AssignFile(F,_Filename);  // Open file
   Reset(F,1); // Goto first byte?

   BlockRead(F,Header,Sizeof(THVA_Main_Header)); // Read Header

   SetLength(Data,Header.N_Sections);

   For x := 0 to High(Data) do
      BlockRead(F,Data[x].SectionName,Sizeof(TSectionName));

   SetLength(TransformMatrices,Header.N_Frames*Header.N_Sections);

   For x := 0 to High(TransformMatrices) do
      BlockRead(F,TransformMatrices[x],Sizeof(TTransformMatrix));

   CloseFile(f);
   If Header.N_Frames < 1 then
      exit;
   WestwoodToOpenGLCoordinates;
   Result := True;
end;

// This function converts the Westwood coordinates into OpenGL's
// (x,y,z) becomes (y,z,x)
procedure THVA.WestwoodToOpenGLCoordinates;
var
   i : integer;
   Temp: single;
begin
   for i := Low(TransformMatrices) to High(TransformMatrices) do
   begin
      Temp := TransformMatrices[i][1][1];
      TransformMatrices[i][1][1] := TransformMatrices[i][2][2];
      TransformMatrices[i][2][2] := TransformMatrices[i][3][3];
      TransformMatrices[i][3][3] := Temp;
      Temp := TransformMatrices[i][1][2];
      TransformMatrices[i][1][2] := TransformMatrices[i][2][3];
      TransformMatrices[i][2][3] := TransformMatrices[i][3][1];
      TransformMatrices[i][3][1] := Temp;
      Temp := TransformMatrices[i][1][3];
      TransformMatrices[i][1][3] := TransformMatrices[i][2][1];
      TransformMatrices[i][2][1] := TransformMatrices[i][3][2];
      TransformMatrices[i][3][2] := Temp;
      Temp := TransformMatrices[i][1][4];
      TransformMatrices[i][1][4] := TransformMatrices[i][2][4];
      TransformMatrices[i][2][4] := TransformMatrices[i][3][4];
      TransformMatrices[i][3][4] := Temp;
   end;
end;

// This function converts the OpenGL coordinates into Westwood's
// (x,y,z) becomes (z,x,y)
procedure THVA.OpenGLToWestwoodCoordinates;
var
   i : integer;
   Temp: single;
begin
   for i := Low(TransformMatrices) to High(TransformMatrices) do
   begin
      Temp := TransformMatrices[i][1][1];
      TransformMatrices[i][1][1] := TransformMatrices[i][3][3];
      TransformMatrices[i][3][3] := TransformMatrices[i][2][2];
      TransformMatrices[i][2][2] := Temp;
      Temp := TransformMatrices[i][1][2];
      TransformMatrices[i][1][2] := TransformMatrices[i][3][1];
      TransformMatrices[i][3][1] := TransformMatrices[i][2][3];
      TransformMatrices[i][2][3] := Temp;
      Temp := TransformMatrices[i][1][3];
      TransformMatrices[i][1][3] := TransformMatrices[i][3][2];
      TransformMatrices[i][3][2] := TransformMatrices[i][2][1];
      TransformMatrices[i][2][1] := Temp;
      Temp := TransformMatrices[i][1][4];
      TransformMatrices[i][1][4] := TransformMatrices[i][3][4];
      TransformMatrices[i][3][4] := TransformMatrices[i][2][4];
      TransformMatrices[i][2][4] := Temp;
   end;
end;

// Frame Operations
procedure THVA.AddBlankFrame;
begin
   inc(Header.N_Frames);
   SetLength(TransformMatrices,Header.N_Frames*Header.N_Sections);
   ClearFrame(Header.N_Frames-1);
end;

Procedure THVA.InsertFrame(FrameNumber : integer);
var
   x,i : integer;
   TransformMatricesTemp : array of TTransformMatrix;
begin
   // Prepare a temporary Transformation Matrix Copy.
   SetLength(TransformMatricesTemp,Header.N_Frames*Header.N_Sections);

   // Copy the transformation matrixes from the HVA to the temp
   for x := 0 to Header.N_Frames-1 do
      for i := 0 to Header.N_Sections-1 do
         GetMatrix(TransformMatricesTemp[x*Header.N_Sections+i],i,x);

   // Increase the ammount of frames from the HVA.
   AddBlankFrame;

   // Copy all info from the frames till the current frame.
   if FrameNumber > 0 then
      for x := 0 to FrameNumber do
         for i := 0 to Header.N_Sections-1 do
            SetMatrix(TransformMatricesTemp[x*Header.N_Sections+i],x,i);

   // Create new frames for the selected frame.
   ClearFrame(FrameNumber);

   // Copy the final part.
   if FrameNumber+1 < Header.N_Frames-1 then
      for x := FrameNumber+2 to Header.N_Frames-1 do
         for i := 0 to Header.N_Sections-1 do
            SetMatrix(TransformMatricesTemp[(x-1)*Header.N_Sections+i],x,i);
end;

Procedure THVA.CopyFrame(FrameNumber : integer);
begin
   InsertFrame(FrameNumber);

   CopyFrameTM(FrameNumber,FrameNumber+1);
end;

Procedure THVA.DeleteFrame(FrameNumber : Integer);
var
   x,i : integer;
   TransformMatricesTemp : array of TTransformMatrix;
begin
   // Prepare a temporary Transformation Matrix Copy.
   SetLength(TransformMatricesTemp,Header.N_Frames*Header.N_Sections);

   // Copy the transformation matrixes from the HVA to the temp
   for x := 0 to Header.N_Frames-1 do
      for i := 0 to Header.N_Sections-1 do
         GetMatrix(TransformMatricesTemp[x*Header.N_Sections+i],i,x);

   // Copy all info from the frames till the current frame.
   if FrameNumber > 0 then
      for x := 0 to FrameNumber do
         for i := 0 to Header.N_Sections-1 do
            SetMatrix(TransformMatricesTemp[x*Header.N_Sections+i],x,i);

   // Decrease the ammount of frames from the HVA.
   Dec(Header.N_Frames);
   SetLength(TransformMatrices,Header.N_Frames*Header.N_Sections);

   // Copy the final part.
   for x := FrameNumber+1 to Header.N_Frames-1 do
      for i := 0 to Header.N_Sections-1 do
         SetMatrix(TransformMatricesTemp[x*Header.N_Sections+i],x-1,i);
end;

// The number received here must be the frame as the user see.
// starting from frame #1.
procedure THVA.ClearFrame(_Number : Integer);
var
   x : integer;
begin
   for x := 0 to Header.N_Sections-1 do
      ClearTM(_Number*Header.N_Sections+x);
end;


// Section Operations
procedure THVA.AddBlankSection;
begin
   InsertSection(Header.N_Sections);
end;

procedure THVA.InsertSection(_SectionNumber : integer);
var
   i,f,s,oldNumSections : integer;
begin
   oldNumSections := Header.N_Sections;
   inc(Header.N_Sections);
   SetLength(TransformMatrices,Header.N_Frames*Header.N_Sections);
   i := High(TransformMatrices);
   f := Header.N_Frames - 1;
   while f >= 0 do
   begin
      s := oldNumSections - 1;
      // copy frames that are after the added one.
      while s >= _SectionNumber do
      begin
         CopyTM((f * oldNumSections) + s,i);
         dec(s);
         dec(i);
      end;
      // make a blank current one for the inserted section.
      ClearTM(i);
      dec(i);
      dec(s);
      // copy frames that are before the added one.
      while s >= 0 do
      begin
         CopyTM((f * oldNumSections) + s,i);
         dec(s);
         dec(i);
      end;
      dec(f);
   end;
   // Now we add the data part:
   SetLength(Data,Header.N_Sections);
   i := Header.N_Sections-1;
   while i > _SectionNumber do
   begin
      for s := 1 to 16 do
      begin
         Data[i].SectionName[s] := Data[i-1].SectionName[s];
      end;
      dec(i);
   end;
end;

procedure THVA.CopySection(_Source,_Dest : integer);
var
   f : integer;
begin
   for f := 0 to (Header.N_frames - 1) do
   begin
      CopyTM((f * Header.N_Sections) + _Source,(f * Header.N_Sections) +  _Dest);
   end;
   for f := 1 to 16 do
   begin
      Data[_Dest].SectionName[f] := Data[_Source].SectionName[f];
   end;
end;

Procedure THVA.CopySection(_Source,_Dest : integer; const HVA: THVA);
var
   f,y,z : integer;
begin
   for f := 0 to (Header.N_frames - 1) do
   begin
      for y := 1 to 3 do
         for z := 1 to 4 do
            TransformMatrices[(f * Header.N_Sections) + _Dest,y,z] := HVA.TransformMatrices[(f * Header.N_Sections) +  _Source,y,z];
   end;
   for f := 1 to 16 do
   begin
      Data[_Dest].SectionName[f] := HVA.Data[_Source].SectionName[f];
   end;
end;

procedure THVA.DeleteSection(_SectionNumber : Integer);
var
   TempTMs : array of TTransformMatrix;
   i,f,s,y,z,OldNumSections : integer;
begin
   // The method below might be a bit stupid, but does its job.
   // Let's backup the existing TransformationMatrices.
   SetLength(TempTMs,High(TransformMatrices)+1);
   for i := Low(TempTMs) to High(TempTMs) do
   begin
      for y := 1 to 3 do
         for z := 1 to 4 do
            TempTMs[i,y,z] := TransformMatrices[i,y,z];
   end;
   // Now we mess up with the TransformMatrices.
   OldNumSections := Header.N_Sections;
   dec(Header.N_Sections);
   SetLength(TransformMatrices,Header.N_Frames*Header.N_Sections);
   f := 0;
   i := 0;
   while f < Header.N_Frames do
   begin
      s := 0;
      // copy all previous sections.
      while s < _SectionNumber do
      begin
         for y := 1 to 3 do
            for z := 1 to 4 do
               TransformMatrices[i,y,z] := TempTMs[(f*OldNumSections)+s,y,z];
         inc(s);
         inc(i);
      end;
      // ignore current section
      inc(s);
      // copy all sections after it.
      while s < OldNumSections do
      begin
         for y := 1 to 3 do
            for z := 1 to 4 do
               TransformMatrices[i,y,z] := TempTMs[(f*OldNumSections)+s,y,z];
         inc(s);
         inc(i);
      end;
      inc(f);
   end;
   // Let's update the data content
   i := _SectionNumber;
   while i < Header.N_Sections do
   begin
      for s := 1 to 16 do
      begin
         Data[i].SectionName[s] := Data[i+1].SectionName[s];
      end;
      inc(i);
   end;
   SetLength(Data,Header.N_Sections);
end;


procedure THVA.ClearTM(_Number : Integer);
var
   x,y : integer;
begin
   for x := 1 to 3 do
      for y := 1 to 4 do
         TransformMatrices[_Number][x][y] := 0;

   TransformMatrices[_Number][1][1] := 1;
   TransformMatrices[_Number][2][2] := 1;
   TransformMatrices[_Number][3][3] := 1;
end;

Function THVA.GetTMValue(_Row,_Col,_Section,_Frames : integer) : single;
begin
   Result := TransformMatrices[_Frames*Header.N_Sections+_Section][_Row][_Col];
end;

Function THVA.GetMatrix(_Section,_Frames : Integer) : TMatrix;
var
   x,y : integer;
begin
   Result := IdentityMatrix;

   for x := 1 to 3 do
      for y := 1 to 4 do
         Result[x-1][y-1] := GetTMValue(x,y,_Section,_Frames);
end;

Procedure THVA.GetMatrix(var _Res : TTransformMatrix; _Section,_Frames : Integer);
var
   x,y : integer;
begin
   for x := 1 to 3 do
      for y := 1 to 4 do
         _Res[x][y] := GetTMValue(x,y,_Section,_Frames);
end;

Procedure THVA.SetMatrix(const _M : TMatrix; _Frame,_Section : Integer);
var
   x,y : integer;
begin
   for x := 1 to 3 do
      for y := 1 to 4 do
         TransformMatrices[_Frame*Header.N_Sections+_Section][x][y] := _m[x-1][y-1];
end;

Procedure THVA.SetMatrix(const _M : TTransformMatrix; _Frame,_Section : Integer);
var
   x,y : integer;
begin
   for x := 1 to 3 do
      for y := 1 to 4 do
         TransformMatrices[_Frame*Header.N_Sections+_Section][x][y] := _m[x][y];
end;

Procedure THVA.ApplyMatrix(_VoxelScale : TVector3f; _Section : Integer; _Frame: integer);
var
   Matrix : TGLMatrixf4;
   Scale : single;
begin
   if _Section = -1 then
   begin
      Exit;
   end;

   if p_Voxel <> nil then
      Scale := p_Voxel^.Section[_Section].Tailer.Det
   else
      Scale := 1/12;

   if Header.N_Sections > 0 then
   begin
      Matrix[0,0] := GetTMValue(1,1,_Section,_Frame);
      Matrix[0,1] := GetTMValue(2,1,_Section,_Frame);
      Matrix[0,2] := GetTMValue(3,1,_Section,_Frame);
      Matrix[0,3] := 0;

      Matrix[1,0] := GetTMValue(1,2,_Section,_Frame);
      Matrix[1,1] := GetTMValue(2,2,_Section,_Frame);
      Matrix[1,2] := GetTMValue(3,2,_Section,_Frame);
      Matrix[1,3] := 0;

      Matrix[2,0] := GetTMValue(1,3,_Section,_Frame);
      Matrix[2,1] := GetTMValue(2,3,_Section,_Frame);
      Matrix[2,2] := GetTMValue(3,3,_Section,_Frame);
      Matrix[2,3] := 0;

      Matrix[3,0] := (GetTMValue(1,4,_Section,_Frame)* Scale) * _VoxelScale.X;
      Matrix[3,1] := (GetTMValue(2,4,_Section,_Frame)* Scale) * _VoxelScale.Y;
      Matrix[3,2] := (GetTMValue(3,4,_Section,_Frame)* Scale) * _VoxelScale.Z;
      Matrix[3,3] := 1;
   end
   else
   begin
      Matrix[0,0] := 1;
      Matrix[0,1] := 0;
      Matrix[0,2] := 0;
      Matrix[0,3] := 0;

      Matrix[1,0] := 0;
      Matrix[1,1] := 1;
      Matrix[1,2] := 0;
      Matrix[1,3] := 0;

      Matrix[2,0] := 0;
      Matrix[2,1] := 0;
      Matrix[2,2] := 1;
      Matrix[2,3] := 0;

      Matrix[3,0] := 0;
      Matrix[3,1] := 0;
      Matrix[3,2] := 0;
      Matrix[3,3] := 1;
   end;

   glMultMatrixf(@Matrix[0,0]);
end;

Procedure THVA.MovePosition(_Frame,_Section : Integer; _X,_Y,_Z : single);
var
   HVAD : integer;
begin
   HVAD := _Frame*Header.N_Sections+_Section;

   TransformMatrices[HVAD][1][4] := TransformMatrices[HVAD][1][4] + (_X);
   TransformMatrices[HVAD][2][4] := TransformMatrices[HVAD][2][4] + (_Y);
   TransformMatrices[HVAD][3][4] := TransformMatrices[HVAD][3][4] + (_Z);
end;

Procedure THVA.SetPosition(_Frame,_Section : Integer; _Position : TVector3f);
var
   HVAD : integer;
   Det : single;
begin
   HVAD := _Frame*Header.N_Sections+_Section;
   Det := p_Voxel^.Section[_Section].Tailer.Det;

   TransformMatrices[HVAD][1][4] := _Position.X / Det;
   TransformMatrices[HVAD][2][4] := _Position.Y / Det;
   TransformMatrices[HVAD][3][4] := _Position.Z / Det;
end;

Function THVA.GetPosition(_Frame,_Section : Integer) : TVector3f;
var
   HVAD : integer;
   Det : single;
begin
   HVAD := _Frame*Header.N_Sections+_Section;
   Det := p_Voxel^.Section[_Section].Tailer.Det;

   Result := SetVector(0,0,0);

   if TransformMatrices[HVAD][1][4] > 0 then
      Result.X := TransformMatrices[HVAD][1][4] * Det;
   if TransformMatrices[HVAD][2][4] > 0 then
      Result.Y := TransformMatrices[HVAD][2][4] * Det;
   if TransformMatrices[HVAD][3][4] > 0 then
      Result.Z := TransformMatrices[HVAD][3][4] * Det;
end;

Function THVA.GetAngle_RAD(_Section,_Frames : Integer) : TVector3f;
var
   M : TMatrix;
   T : TTransformations;
begin
   M := GetMatrix(_Section,_Frames);

   MatrixDecompose(M,T);

   Result.X := T[ttRotateX];
   Result.Y := T[ttRotateY];
   Result.Z := T[ttRotateZ];
end;

Function THVA.GetAngle_DEG(_Section,_Frames : Integer) : TVector3f;
var
   Angles : TVector3f;
begin
   Angles := GetAngle_RAD(_Section,_Frames);

   Result.X := RadToDeg(Angles.X);
   Result.Y := RadToDeg(Angles.Y);
   Result.Z := RadToDeg(Angles.Z);
end;

Function THVA.GetAngle_DEG_Correct(_Section,_Frames : Integer) : TVector3f;
var
   Angles : TVector3f;
begin
   Angles := GetAngle_RAD(_Section,_Frames);

   Result.X := CorrectAngle(RadToDeg(Angles.X));
   Result.Y := CorrectAngle(RadToDeg(Angles.Y));
   Result.Z := CorrectAngle(RadToDeg(Angles.Z));
end;

Function THVA.CorrectAngle(_Angle : Single) : Single;
var
   Ang90 : single;
begin
   Ang90 := Pi/2;
   If _Angle < (-Ang90) then
      _Angle := Pi + _Angle
   else if _Angle > Ang90 then
      _Angle := Ang90 - _Angle;

   Result := _Angle;
end;

Procedure THVA.SetTMValue(_Frame,_Section,_Row,_Col : Integer; _Value : single);
begin
   TransformMatrices[_Frame*Header.N_Sections+_Section][_Row][_Col] := _Value;
end;

Function THVA.SetAngle(_Section,_Frames : Integer; _x,_y,_z : single) : TVector3f;
var
   M : TMatrix;
begin
   M := GetMatrix(_Section,_Frames);

   M := Pitch(M,DegtoRad(_X));
   M := Turn(M,DegtoRad(_Y));
   M := Roll(M,DegtoRad(_Z));

   SetMatrix(M,_Frames,_Section);
end;

procedure THVA.CopyFrameTM(Source, Dest : integer);
var
   y,z,i : integer;
begin
   for i := 0 to Header.N_Sections-1 do
      for y := 1 to 3 do
         for z := 1 to 4 do
            TransformMatrices[(Dest)*Header.N_Sections+i][y][z] := TransformMatrices[(Source)*Header.N_Sections+i][y][z];
end;

procedure THVA.CopyTM(Source, Dest : integer);
var
   y,z : integer;
begin
   for y := 1 to 3 do
      for z := 1 to 4 do
         TransformMatrices[Dest,y,z] := TransformMatrices[Source,y,z];
end;


// Assign
procedure THVA.Assign(const _HVA: THVA);
var
   i,j,k: integer;
begin
   for i := 1 to 16 do
      Header.FilePath[i] := _HVA.Header.FilePath[i];
   Header.N_Frames := _HVA.Header.N_Frames;
   Header.N_Sections := _HVA.Header.N_Sections;
   SetLength(Data,High(_HVA.Data)+1);
   for i := Low(Data) to High(Data) do
   begin
      for j := 1 to 16 do
         Data[i].SectionName[j] := _HVA.Data[i].SectionName[j];
   end;
   p_Voxel := _HVA.p_Voxel;
   SetLength(TransformMatrices,High(_HVA.TransformMatrices)+1);
   for i := Low(TransformMatrices) to High(TransformMatrices) do
   begin
      for j := 1 to 3 do
         for k := 1 to 4 do
            TransformMatrices[i][j][k] := _HVA.TransformMatrices[i][j][k];
   end;
end;


end.
