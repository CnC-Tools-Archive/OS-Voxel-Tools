unit TextureAtlasExtractorOrigamiParametricDC;

interface

uses TextureAtlasExtractorBase, TextureAtlasExtractorOrigamiParametric,
      BasicMathsTypes, BasicDataTypes, NeighborDetector, MeshPluginBase,
      VertexTransformationUtils;

{$INCLUDE source/Global_Conditionals.inc}

type
   CTextureAtlasExtractorOrigamiParametricDC = class (CTextureAtlasExtractorOrigamiParametric)
      protected
         FMaxDistortionFactor: single;
         procedure SetupAngleFactor(var _Vertices : TAVector3f; var _VertexNormals : TAVector3f; var _VertexNeighbors: TNeighborDetector); override;
         procedure BuildFirstTriangle(_ID,_MeshID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals, _VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; const _FaceNeighbors: TNeighborDetector; _VerticesPerFace: integer; var _VertexUtil: TVertexTransformationUtils; var _TextureSeed: TTextureSeed); override;
         function IsValidUVPoint(const _Vertices: TAVector3f; const _Faces : auint32; var _TexCoords: TAVector2f; _Target,_Edge0,_Edge1,_OriginVert: integer; var _CheckFace: abool; var _UVPosition: TVector2f; _CurrentFace, _PreviousFace, _VerticesPerFace: integer): boolean; override;
         function CalculateDistortionFactor(_value: single): single;
         procedure GetAnglesFromCoordinates(const _Vertices: TAVector3f; _Edge0, _Edge1, _Target: integer; var _Ang0, _Ang1: single);
   end;


implementation

uses GlobalVars, Math, Math3D, ColisionCheck, MeshCurvatureMeasure, IntegerList,
   SysUtils, BasicFunctions;

procedure CTextureAtlasExtractorOrigamiParametricDC.SetupAngleFactor(var _Vertices : TAVector3f; var _VertexNormals : TAVector3f; var _VertexNeighbors: TNeighborDetector);
var
   i: integer;
   Tool: TMeshCurvatureMeasure;
   DistortionFactor: single;
begin
   // Obtain the parametric angle distortion factor for each vertex.
   SetLength(FAngleFactor, High(_Vertices) + 1);
   Tool := TMeshCurvatureMeasure.Create;
   FMaxDistortionFactor := 0;
   for i := Low(FAngleFactor) to High(FAngleFactor) do
   begin
      FAngleFactor[i] := Tool.GetVertexAngleSumFactor(i, _Vertices, _VertexNormals, _VertexNeighbors);
      DistortionFactor := CalculateDistortionFactor(FAngleFactor[i]);
      if DistortionFactor > FMaxDistortionFactor then
      begin
         FMaxDistortionFactor := DistortionFactor;
      end;
   end;
   Tool.Free;
end;

function CTextureAtlasExtractorOrigamiParametricDC.CalculateDistortionFactor(_value: single): single;
begin
   if abs(_Value) >= 1 then
   begin
      Result := abs(_value) - 1;
   end
   else
   begin
      Result := 1 - abs(_value);
   end;
end;

procedure CTextureAtlasExtractorOrigamiParametricDC.GetAnglesFromCoordinates(const _Vertices: TAVector3f; _Edge0, _Edge1, _Target: integer; var _Ang0, _Ang1: single);
const
   C_MIN_ANGLE = pi / 6;
   C_HALF_MIN_ANGLE = C_MIN_ANGLE / 2;
var
   i: integer;
   DirEdge,DirEdge0,DirEdge1: TVector3f;
   AngSum, DistortionSum: single;
   IdealAngles, OriginalAngles: afloat;
   DistortionFactor: afloat;
   IDs: auint32;
begin
   // Set memory
   SetLength(IDs, 3);
   SetLength(OriginalAngles, 3);
   SetLength(IdealAngles, 3);
   SetLength(DistortionFactor, 3);
   IDs[0] := _Edge0;
   IDs[1] := _Edge1;
   IDs[2] := _Target;

   // Gather basic data
   DirEdge := SubtractVector(_Vertices[_Edge1],_Vertices[_Edge0]);
   Normalize(DirEdge);
   DirEdge0 := SubtractVector(_Vertices[_Target],_Vertices[_Edge0]);
   Normalize(DirEdge0);
   DirEdge1 := SubtractVector(_Vertices[_Target],_Vertices[_Edge1]);
   Normalize(DirEdge1);
   OriginalAngles[0] := ArcCos(DotProduct(DirEdge0, DirEdge));
   OriginalAngles[1] := ArcCos(-1 * DotProduct(DirEdge1, DirEdge));
   OriginalAngles[2] := ArcCos(DotProduct(DirEdge0, DirEdge1));
   IdealAngles[0] := OriginalAngles[0] / FAngleFactor[GetVertexLocationID(IDs[0])];
   IdealAngles[1] := OriginalAngles[1] / FAngleFactor[GetVertexLocationID(IDs[1])];
   IdealAngles[2] := OriginalAngles[2] / FAngleFactor[GetVertexLocationID(IDs[2])];
   AngSum := IdealAngles[0] + IdealAngles[1] + IdealAngles[2];
   // Calculate resulting angles.
   if AngSum < pi then
   begin
      // We'll priorize the highest distortion factor.
      AngSum := pi - AngSum;
      DistortionSum := 0;
      for i := 0 to 2 do
      begin
         DistortionFactor[i] := FMaxDistortionFactor - CalculateDistortionFactor(FAngleFactor[GetVertexLocationID(IDs[i])]);
         DistortionSum := DistortionSum + DistortionFactor[i];
      end;
      if DistortionSum > 0 then
      begin
         _Ang0 := IdealAngles[0] + (AngSum * (DistortionFactor[0] / DistortionSum));
         _Ang1 := IdealAngles[1] + (AngSum * (DistortionFactor[1] / DistortionSum));
      end
      else
      begin
         _Ang0 := IdealAngles[0] + (AngSum / 3);
         _Ang1 := IdealAngles[1] + (AngSum / 3);
      end;
      {$ifdef ORIGAMI_TEST}
      AngSum := pi - AngSum;
      {$endif}
   end
   else if AngSum = pi then
   begin
      _Ang0 := (IdealAngles[0] / AngSum) * pi;
      _Ang1 := (IdealAngles[1] / AngSum) * pi;
   end
   else
   begin
      // We'll priorize the highest distortion factor.
      AngSum := AngSum - pi;
      DistortionSum := 0;
      for i := 0 to 2 do
      begin
         DistortionFactor[i] := FMaxDistortionFactor - CalculateDistortionFactor(FAngleFactor[GetVertexLocationID(IDs[i])]);
         DistortionSum := DistortionSum + DistortionFactor[i];
      end;
      if DistortionSum > 0 then
      begin
         _Ang0 := IdealAngles[0] - (AngSum * (DistortionFactor[0] / DistortionSum));
         _Ang1 := IdealAngles[1] - (AngSum * (DistortionFactor[1] / DistortionSum));
      end
      else
      begin
         _Ang0 := IdealAngles[0] - (AngSum / 3);
         _Ang1 := IdealAngles[1] - (AngSum / 3);
      end;
      {$ifdef ORIGAMI_TEST}
      AngSum := AngSum + pi;
      {$endif}
   end;

   // Self-Defense against absurdly deformed triangles.
   if _Ang0 < C_MIN_ANGLE then
   begin
      _Ang0 := C_MIN_ANGLE;
      _Ang1 := _Ang1 - C_HALF_MIN_ANGLE;
   end;
   if _Ang1 < C_MIN_ANGLE then
   begin
      _Ang0 := _Ang0 - C_HALF_MIN_ANGLE;
      _Ang1 := C_MIN_ANGLE;
   end;
   if (pi - (_Ang0 + _Ang1)) < C_MIN_ANGLE then
   begin
      _Ang0 := _Ang0 - C_HALF_MIN_ANGLE;
      _Ang1 := _Ang1 - C_HALF_MIN_ANGLE;
   end;

   // Report result if required.
   {$ifdef ORIGAMI_TEST}
   GlobalVars.OrigamiFile.Add('Triangle with the angles: (' + FloatToStr(OriginalAngles[0]) + ', ' + FloatToStr(OriginalAngles[1]) + ', ' + FloatToStr(OriginalAngles[2]) + ') has been deformed with the angles: (' + FloatToStr(IdealAngles[0]) + ', ' + FloatToStr(IdealAngles[1]) + ', ' + FloatToStr(IdealAngles[2]) + ') and, it generates the following angles: (' + FloatToStr(_Ang0) + ', ' + FloatToStr(_Ang1) + ', ' + FloatToStr(pi - (_Ang0 + _Ang1)) + ') where the factors are respectively ( ' + FloatToStr(FAngleFactor[GetVertexLocationID(_Edge0)]) + ', ' + FloatToStr(FAngleFactor[GetVertexLocationID(_Edge1)]) + ', ' + FloatToStr(FAngleFactor[GetVertexLocationID(_Target)]) + ') and AngleSum is ' + FloatToStr(AngSum) + ' .');
   {$endif}
   // Free memory.
   SetLength(IDs, 0);
   SetLength(IdealAngles, 0);
   SetLength(DistortionFactor, 0);
end;

procedure CTextureAtlasExtractorOrigamiParametricDC.BuildFirstTriangle(_ID,_MeshID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals, _VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; const _FaceNeighbors: TNeighborDetector; _VerticesPerFace: integer; var _VertexUtil: TVertexTransformationUtils; var _TextureSeed: TTextureSeed);
var
   vertex, f, FaceIndex: integer;
   Target,Edge0,Edge1: integer;
   Ang0, Ang1, cosAng0, cosAng1, sinAng0, sinAng1, Edge0Size: single;
   UVPosition: TVector2f;
begin
   // The first triangle is dealt in a different way.
   // We'll project it in the plane XY and the first vertex is on (0,0,0).
   {$ifdef ORIGAMI_TEST}
   GlobalVars.OrigamiFile.Add('Starting Face is ' + IntToStr(_StartingFace) + ' and it is being added now');
   {$endif}
   FaceIndex := _StartingFace * _VerticesPerFace;
   {$ifdef ORIGAMI_TEST}
   GlobalVars.OrigamiFile.Add('Vertex ' + IntToStr(_Faces[FaceIndex]) + ' position is [' + FloatToStr(_Vertices[_Faces[FaceIndex]].X) + ', ' + FloatToStr(_Vertices[_Faces[FaceIndex]].Y) + ', ' + FloatToStr(_Vertices[_Faces[FaceIndex]].Z) + '].');
   GlobalVars.OrigamiFile.Add('Vertex ' + IntToStr(_Faces[FaceIndex+1]) + ' position is [' + FloatToStr(_Vertices[_Faces[FaceIndex+1]].X) + ', ' + FloatToStr(_Vertices[_Faces[FaceIndex+1]].Y) + ', ' + FloatToStr(_Vertices[_Faces[FaceIndex+1]].Z) + '].');
   GlobalVars.OrigamiFile.Add('Vertex ' + IntToStr(_Faces[FaceIndex+2]) + ' position is [' + FloatToStr(_Vertices[_Faces[FaceIndex+2]].X) + ', ' + FloatToStr(_Vertices[_Faces[FaceIndex+2]].Y) + ', ' + FloatToStr(_Vertices[_Faces[FaceIndex+2]].Z) + '].');
   {$endif}
   // First vertex is (1,0).
   vertex := _Faces[FaceIndex];
   if _VertsSeed[vertex] <> -1 then
   begin
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Vertex ' + IntToStr(_StartingFace) + ' is used and it is being cloned as ' + IntToStr(High(_Vertices)+2));
      {$endif}
      // this vertex was used by a previous seed, therefore, we'll clone it
      SetLength(_Vertices,High(_Vertices)+2);
      SetLength(_VertsSeed,High(_Vertices)+1);
      _VertsSeed[High(_VertsSeed)] := _ID;
      SetLength(FVertsLocation,High(_Vertices)+1);
      FVertsLocation[High(_Vertices)] := vertex;  // _VertsLocation works slightly different here than in the non-origami version.
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Face item ' + IntToStr(FaceIndex) + ' has been changed to ' + IntToStr(High(_Vertices)));
      {$endif}
      _Faces[FaceIndex] := High(_Vertices);
      _Vertices[High(_Vertices)].X := _Vertices[vertex].X;
      _Vertices[High(_Vertices)].Y := _Vertices[vertex].Y;
      _Vertices[High(_Vertices)].Z := _Vertices[vertex].Z;
      SetLength(_VertsNormals,High(_Vertices)+1);
      _VertsNormals[High(_Vertices)].X := _VertsNormals[vertex].X;
      _VertsNormals[High(_Vertices)].Y := _VertsNormals[vertex].Y;
      _VertsNormals[High(_Vertices)].Z := _VertsNormals[vertex].Z;
      SetLength(_VertsColours,High(_Vertices)+1);
      _VertsColours[High(_Vertices)].X := _VertsColours[vertex].X;
      _VertsColours[High(_Vertices)].Y := _VertsColours[vertex].Y;
      _VertsColours[High(_Vertices)].Z := _VertsColours[vertex].Z;
      _VertsColours[High(_Vertices)].W := _VertsColours[vertex].W;
      // Get temporarily texture coordinates.
      SetLength(_TextCoords,High(_Vertices)+1);
      _TextCoords[High(_Vertices)].U := 1;
      _TextCoords[High(_Vertices)].V := 0;
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Vertex is ' + IntToStr(vertex) + ' and Position is: [' + FloatToStr(_TextCoords[High(_Vertices)].U) + ' ' + FloatToStr(_TextCoords[High(_Vertices)].V) + ']');
      {$endif}
      // Now update the bounds of the seed.
      if _TextCoords[High(_Vertices)].U < _TextureSeed.MinBounds.U then
         _TextureSeed.MinBounds.U := _TextCoords[High(_Vertices)].U;
      if _TextCoords[High(_Vertices)].U > _TextureSeed.MaxBounds.U then
         _TextureSeed.MaxBounds.U := _TextCoords[High(_Vertices)].U;
      if _TextCoords[High(_Vertices)].V < _TextureSeed.MinBounds.V then
         _TextureSeed.MinBounds.V := _TextCoords[High(_Vertices)].V;
      if _TextCoords[High(_Vertices)].V > _TextureSeed.MaxBounds.V then
         _TextureSeed.MaxBounds.V := _TextCoords[High(_Vertices)].V;
   end
   else
   begin
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Vertex ' + IntToStr(vertex) + ' is new.');
      {$endif}
      // This seed is the first seed to use this vertex.
      _VertsSeed[vertex] := _ID;
      FVertsLocation[vertex] := vertex;
      // Get temporary texture coordinates.
      _TextCoords[vertex].U := 1;
      _TextCoords[vertex].V := 0;
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Vertex is ' + IntToStr(vertex) + ' and Position is: [' + FloatToStr(_TextCoords[vertex].U) + ' ' + FloatToStr(_TextCoords[vertex].V) + ']');
      {$endif}
      // Now update the bounds of the seed.
      if _TextCoords[vertex].U < _TextureSeed.MinBounds.U then
         _TextureSeed.MinBounds.U := _TextCoords[vertex].U;
      if _TextCoords[vertex].U > _TextureSeed.MaxBounds.U then
         _TextureSeed.MaxBounds.U := _TextCoords[vertex].U;
      if _TextCoords[vertex].V < _TextureSeed.MinBounds.V then
         _TextureSeed.MinBounds.V := _TextCoords[vertex].V;
      if _TextCoords[vertex].V > _TextureSeed.MaxBounds.V then
         _TextureSeed.MaxBounds.V := _TextCoords[vertex].V;
   end;

   // Second vertex is (0,0).
   vertex := _Faces[FaceIndex+1];
   if _VertsSeed[vertex] <> -1 then
   begin
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Vertex ' + IntToStr(_StartingFace) + ' is used and it is being cloned as ' + IntToStr(High(_Vertices)+2));
      {$endif}
      // this vertex was used by a previous seed, therefore, we'll clone it
      SetLength(_Vertices,High(_Vertices)+2);
      SetLength(_VertsSeed,High(_Vertices)+1);
      _VertsSeed[High(_VertsSeed)] := _ID;
      SetLength(FVertsLocation,High(_Vertices)+1);
      FVertsLocation[High(_Vertices)] := vertex;  // _VertsLocation works slightly different here than in the non-origami version.
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Face item ' + IntToStr(FaceIndex+1) + ' has been changed to ' + IntToStr(High(_Vertices)));
      {$endif}
      _Faces[FaceIndex+1] := High(_Vertices);
      _Vertices[High(_Vertices)].X := _Vertices[vertex].X;
      _Vertices[High(_Vertices)].Y := _Vertices[vertex].Y;
      _Vertices[High(_Vertices)].Z := _Vertices[vertex].Z;
      SetLength(_VertsNormals,High(_Vertices)+1);
      _VertsNormals[High(_Vertices)].X := _VertsNormals[vertex].X;
      _VertsNormals[High(_Vertices)].Y := _VertsNormals[vertex].Y;
      _VertsNormals[High(_Vertices)].Z := _VertsNormals[vertex].Z;
      SetLength(_VertsColours,High(_Vertices)+1);
      _VertsColours[High(_Vertices)].X := _VertsColours[vertex].X;
      _VertsColours[High(_Vertices)].Y := _VertsColours[vertex].Y;
      _VertsColours[High(_Vertices)].Z := _VertsColours[vertex].Z;
      _VertsColours[High(_Vertices)].W := _VertsColours[vertex].W;
      // Get temporarily texture coordinates.
      SetLength(_TextCoords,High(_Vertices)+1);
      _TextCoords[High(_Vertices)].U := 0;
      _TextCoords[High(_Vertices)].V := 0;
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Vertex is ' + IntToStr(vertex) + ' and Position is: [' + FloatToStr(_TextCoords[High(_Vertices)].U) + ' ' + FloatToStr(_TextCoords[High(_Vertices)].V) + ']');
      {$endif}
      // Now update the bounds of the seed.
      if _TextCoords[High(_Vertices)].U < _TextureSeed.MinBounds.U then
         _TextureSeed.MinBounds.U := _TextCoords[High(_Vertices)].U;
      if _TextCoords[High(_Vertices)].U > _TextureSeed.MaxBounds.U then
         _TextureSeed.MaxBounds.U := _TextCoords[High(_Vertices)].U;
      if _TextCoords[High(_Vertices)].V < _TextureSeed.MinBounds.V then
         _TextureSeed.MinBounds.V := _TextCoords[High(_Vertices)].V;
      if _TextCoords[High(_Vertices)].V > _TextureSeed.MaxBounds.V then
         _TextureSeed.MaxBounds.V := _TextCoords[High(_Vertices)].V;
   end
   else
   begin
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Vertex ' + IntToStr(vertex) + ' is new.');
      {$endif}
      // This seed is the first seed to use this vertex.
      _VertsSeed[vertex] := _ID;
      FVertsLocation[vertex] := vertex;
      // Get temporary texture coordinates.
      _TextCoords[vertex].U := 0;
      _TextCoords[vertex].V := 0;
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Vertex is ' + IntToStr(vertex) + ' and Position is: [' + FloatToStr(_TextCoords[vertex].U) + ' ' + FloatToStr(_TextCoords[vertex].V) + ']');
      {$endif}
      // Now update the bounds of the seed.
      if _TextCoords[vertex].U < _TextureSeed.MinBounds.U then
         _TextureSeed.MinBounds.U := _TextCoords[vertex].U;
      if _TextCoords[vertex].U > _TextureSeed.MaxBounds.U then
         _TextureSeed.MaxBounds.U := _TextCoords[vertex].U;
      if _TextCoords[vertex].V < _TextureSeed.MinBounds.V then
         _TextureSeed.MinBounds.V := _TextCoords[vertex].V;
      if _TextCoords[vertex].V > _TextureSeed.MaxBounds.V then
         _TextureSeed.MaxBounds.V := _TextCoords[vertex].V;
   end;

   // Now, finally we have to figure out the 3rd vertex. That one depends on the angles.
   Target := _Faces[FaceIndex + 2];
   Edge0 := _Faces[FaceIndex];
   Edge1 := _Faces[FaceIndex + 1];

   GetAnglesFromCoordinates(_Vertices, Edge0, Edge1, Target, Ang0, Ang1);

   cosAng0 := cos(Ang0);
   cosAng1 := cos(Ang1);
   sinAng0 := sin(Ang0);
   sinAng1 := sin(Ang1);

   Edge0Size := sinAng1 / ((cosAng0 * sinAng1) + (cosAng1 * sinAng0));

   // Write the UV Position
   UVPosition.U := Edge0Size * cosAng0;
   UVPosition.V := Edge0Size * sinAng0;
   vertex := Target;
   if _VertsSeed[vertex] <> -1 then
   begin
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Vertex ' + IntToStr(_StartingFace) + ' is used and it is being cloned as ' + IntToStr(High(_Vertices)+2));
      {$endif}
      // this vertex was used by a previous seed, therefore, we'll clone it
      SetLength(_Vertices,High(_Vertices)+2);
      SetLength(_VertsSeed,High(_Vertices)+1);
      _VertsSeed[High(_VertsSeed)] := _ID;
      SetLength(FVertsLocation,High(_Vertices)+1);
      FVertsLocation[High(_Vertices)] := vertex;  // _VertsLocation works slightly different here than in the non-origami version.
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Face item ' + IntToStr(FaceIndex+2) + ' has been changed to ' + IntToStr(High(_Vertices)));
      {$endif}
      _Faces[FaceIndex+2] := High(_Vertices);
      _Vertices[High(_Vertices)].X := _Vertices[vertex].X;
      _Vertices[High(_Vertices)].Y := _Vertices[vertex].Y;
      _Vertices[High(_Vertices)].Z := _Vertices[vertex].Z;
      SetLength(_VertsNormals,High(_Vertices)+1);
      _VertsNormals[High(_Vertices)].X := _VertsNormals[vertex].X;
      _VertsNormals[High(_Vertices)].Y := _VertsNormals[vertex].Y;
      _VertsNormals[High(_Vertices)].Z := _VertsNormals[vertex].Z;
      SetLength(_VertsColours,High(_Vertices)+1);
      _VertsColours[High(_Vertices)].X := _VertsColours[vertex].X;
      _VertsColours[High(_Vertices)].Y := _VertsColours[vertex].Y;
      _VertsColours[High(_Vertices)].Z := _VertsColours[vertex].Z;
      _VertsColours[High(_Vertices)].W := _VertsColours[vertex].W;
      // Get temporarily texture coordinates.
      SetLength(_TextCoords,High(_Vertices)+1);
      _TextCoords[High(_Vertices)].U := UVPosition.U;
      _TextCoords[High(_Vertices)].V := UVPosition.V;
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Vertex is ' + IntToStr(vertex) + ' and Position is: [' + FloatToStr(_TextCoords[High(_Vertices)].U) + ' ' + FloatToStr(_TextCoords[High(_Vertices)].V) + ']');
      {$endif}
      // Now update the bounds of the seed.
      if _TextCoords[High(_Vertices)].U < _TextureSeed.MinBounds.U then
         _TextureSeed.MinBounds.U := _TextCoords[High(_Vertices)].U;
      if _TextCoords[High(_Vertices)].U > _TextureSeed.MaxBounds.U then
         _TextureSeed.MaxBounds.U := _TextCoords[High(_Vertices)].U;
      if _TextCoords[High(_Vertices)].V < _TextureSeed.MinBounds.V then
         _TextureSeed.MinBounds.V := _TextCoords[High(_Vertices)].V;
      if _TextCoords[High(_Vertices)].V > _TextureSeed.MaxBounds.V then
         _TextureSeed.MaxBounds.V := _TextCoords[High(_Vertices)].V;
   end
   else
   begin
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Vertex ' + IntToStr(vertex) + ' is new.');
      {$endif}
      // This seed is the first seed to use this vertex.
      _VertsSeed[vertex] := _ID;
      FVertsLocation[vertex] := vertex;
      // Get temporary texture coordinates.
      _TextCoords[vertex].U := UVPosition.U;
      _TextCoords[vertex].V := UVPosition.V;
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Vertex is ' + IntToStr(vertex) + ' and Position is: [' + FloatToStr(_TextCoords[vertex].U) + ' ' + FloatToStr(_TextCoords[vertex].V) + ']');
      {$endif}
      // Now update the bounds of the seed.
      if _TextCoords[vertex].U < _TextureSeed.MinBounds.U then
         _TextureSeed.MinBounds.U := _TextCoords[vertex].U;
      if _TextCoords[vertex].U > _TextureSeed.MaxBounds.U then
         _TextureSeed.MaxBounds.U := _TextCoords[vertex].U;
      if _TextCoords[vertex].V < _TextureSeed.MinBounds.V then
         _TextureSeed.MinBounds.V := _TextCoords[vertex].V;
      if _TextCoords[vertex].V > _TextureSeed.MaxBounds.V then
         _TextureSeed.MaxBounds.V := _TextCoords[vertex].V;
   end;

   // Add neighbour faces to the list.
   f := _FaceNeighbors.GetNeighborFromID(_StartingFace);
   while f <> -1 do
   begin
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Face ' + IntToStr(f) + ' is neighbour of ' + IntToStr(_StartingFace));
      {$endif}
      // do some verification here
      if (_FaceSeeds[f] = -1) then
      begin
         FPreviousFaceList.Add(_StartingFace);
         FFaceList.Add(f);
         {$ifdef ORIGAMI_TEST}
         GlobalVars.OrigamiFile.Add('Face ' + IntToStr(f) + ' has been added to the list');
         {$endif}
      end;
      f := _FaceNeighbors.GetNextNeighbor;
   end;
end;

function CTextureAtlasExtractorOrigamiParametricDC.IsValidUVPoint(const _Vertices: TAVector3f; const _Faces : auint32; var _TexCoords: TAVector2f; _Target,_Edge0,_Edge1,_OriginVert: integer; var _CheckFace: abool; var _UVPosition: TVector2f; _CurrentFace, _PreviousFace, _VerticesPerFace: integer): boolean;
var
   Ang0,Ang1,cosAng0,cosAng1,sinAng0,sinAng1,Edge0Size: single;
   EdgeSizeInMesh,EdgeSizeInUV,SinProjectionSizeInUV,ProjectionSizeInUV: single;
   EdgeDirectionInUV,PositionOfTargetAtEdgeInUV,SinDirectionInUV: TVector2f;
   EdgeDirectionInMesh: TVector3f;
   SourceSide: single;
   i,v: integer;
   ColisionUtil : CColisionCheck;//TVertexTransformationUtils;
begin
   Result := false;
   ColisionUtil := CColisionCheck.Create; //TVertexTransformationUtils.Create;
   // Get edge size in mesh
   EdgeSizeInMesh := VectorDistance(_Vertices[_Edge0],_Vertices[_Edge1]);
   if EdgeSizeInMesh > 0 then
   begin
      // Get the direction of the edge (Edge0 to Edge1) in Mesh and UV space
      EdgeDirectionInMesh := SubtractVector(_Vertices[_Edge1],_Vertices[_Edge0]);
      EdgeDirectionInUV := SubtractVector(_TexCoords[_Edge1],_TexCoords[_Edge0]);
      // Get edge size in UV space.
      EdgeSizeInUV := Sqrt((EdgeDirectionInUV.U * EdgeDirectionInUV.U) + (EdgeDirectionInUV.V * EdgeDirectionInUV.V));
      // Directions must be normalized.
      Normalize(EdgeDirectionInMesh);
      Normalize(EdgeDirectionInUV);

      // Find the angles of the vertexes of the main edge in Mesh.
      GetAnglesFromCoordinates(_Vertices, _Edge0, _Edge1, _Target, Ang0, Ang1);

      cosAng0 := cos(Ang0);
      cosAng1 := cos(Ang1);
      sinAng0 := sin(Ang0);
      sinAng1 := sin(Ang1);

      // We'll now use these angles to find the projection directly in UV.
      Edge0Size := (EdgeSizeInUV * sinAng1) / ((cosAng0 * sinAng1) + (cosAng1 * sinAng0));
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Edge0Size is ' + FloatToStr(Edge0Size) + '.');
      {$endif}
      if (Edge0Size <= 10) and (Edge0Size >= 0.1) then
      begin
         // Get the size of projection of (Vertex - Edge0) at the Edge, in UV already
         ProjectionSizeInUV := Edge0Size * cosAng0;

         // Obtain the position of this projection at the edge, in UV
         PositionOfTargetatEdgeInUV := AddVector(_TexCoords[_Edge0],ScaleVector(EdgeDirectionInUV,ProjectionSizeInUV));

         // Find out the distance between that and the _Target in UV.
         SinProjectionSizeInUV := Edge0Size * sinAng0;
         // Rotate the edgeze in 90' in UV space.
         SinDirectionInUV := Get90RotDirectionFromDirection(EdgeDirectionInUV);
         // We need to make sure that _Target and _OriginVert are at opposite sides
         // the universe, if it is divided by the Edge0 to Edge1.
         SourceSide := Get2DOuterProduct(_TexCoords[_OriginVert],_TexCoords[_Edge0],_TexCoords[_Edge1]);
         if SourceSide > 0 then
         begin
            SinDirectionInUV := ScaleVector(SinDirectionInUV,-1);
         end;
         // Write the UV Position
         _UVPosition := AddVector(PositionOfTargetatEdgeInUV,ScaleVector(SinDirectionInUV,SinProjectionSizeInUV));

         // Let's check if this UV Position will hit another UV project face.
         Result := true;
         // the change in the _AddedFace temporary optimization for the upcoming loop.
         v := 0;
         for i := Low(_CheckFace) to High(_CheckFace) do
         begin
            // If the face was projected in the UV domain.
            if _CheckFace[i] then
            begin
               {$ifdef ORIGAMI_TEST}
               //GlobalVars.OrigamiFile.Add('Face ' + IntToStr(i) + ' has vertexes (' + FloatToStr(_TexCoords[_Faces[v]].U) + ', ' + FloatToStr(_TexCoords[_Faces[v]].V) + '), (' + FloatToStr(_TexCoords[_Faces[v+1]].U) + ', ' + FloatToStr(_TexCoords[_Faces[v+1]].V)  + '), (' + FloatToStr(_TexCoords[_Faces[v+2]].U) + ', ' + FloatToStr(_TexCoords[_Faces[v+2]].V) + ').');
               {$endif}
               // Check if the candidate position is inside this triangle.
               // If it is inside the triangle, then point is not validated. Exit.
               //if VertexUtil.IsPointInsideTriangle(_TexCoords[_Faces[v]],_TexCoords[_Faces[v+1]],_TexCoords[_Faces[v+2]],_UVPosition) then
               if ColisionUtil.Are2DTrianglesColidingEdges(_UVPosition,_TexCoords[_Edge0],_TexCoords[_Edge1],_TexCoords[_Faces[v]],_TexCoords[_Faces[v+1]],_TexCoords[_Faces[v+2]]) then
               begin
                  {$ifdef ORIGAMI_TEST}
                  GlobalVars.OrigamiFile.Add('Vertex textured coordinate (' + FloatToStr(_UVPosition.U) + ', ' + FloatToStr(_UVPosition.V) + ') conflicts with face ' + IntToStr(i) + '.');
                  {$endif}
                  Result := false;
                  ColisionUtil.Free;
                  exit;
               end;
            end;
            inc(v,_VerticesPerFace);
         end;
      end;
   end
   else
   begin
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('New triangle causes too much distortion. Edge size is: ' + FloatToStr(Edge0Size) + '.');
      {$endif}
      Result := false;
   end;
   ColisionUtil.Free;
end;

end.
