unit VoxelModelizer;

// Warning: DEPRECATED!

// Voxel Modelizer was an experience to create a method based
// on marching cubes to transform voxel based data into polygonal models.

// It has failed and it is deprecated. VXLSE III does not use it.
// The code is here just in case somebody get any idea from it... or not.

// It was insane and ate far too much RAM while the current method does a
// much better job using a ridiculous amount of RAM.

interface

uses VoxelMap, BasicDataTypes, VoxelModelizerItem, BasicConstants, ThreeDMap,
   Palette, FaceQueue;

type
   TVoxelModelizer = class
      private
         FItems : array of TVoxelModelizerItem;
         PVoxelMap : PVoxelMap;
         PSemiSurfacesMap : P3DIntGrid;
         FNumVertexes : integer;
         function GetNormals(_V1,_V2,_V3: TVector3f): TVector3f;
         function CopyMap(const _Map: T3DIntGrid): T3DIntGrid;
      public
         // Constructors and Destructors
         constructor Create(const _VoxelMap : TVoxelMap; const _SemiSurfaces: T3DIntGrid; var _Vertexes: TAVector3f; var _Faces: auint32; var _Normals: TAVector3f; var _Colours: TAVector4f; const _Palette: TPalette; const _ColourMap: TVoxelMap);
         destructor Destroy; override;
         // Misc
         procedure GenerateItemsMap(var FMap : T3DIntGrid);
   end;

implementation

constructor TVoxelModelizer.Create(const _VoxelMap : TVoxelMap; const _SemiSurfaces: T3DIntGrid; var _Vertexes: TAVector3f; var _Faces: auint32; var _Normals: TAVector3f; var _Colours: TAVector4f; const _Palette: TPalette; const _ColourMap: TVoxelMap);
var
   FMap : T3DIntGrid;
   x, y, z, i, pos, NumFaces: integer;
   Size : TVector3i;
   FVertexMap: T3DIntGrid;
   ModelMap: T3DMap;
   Vertexes: TAVector3i;
   Normal : TVector3f;
   Face: PFaceData;
begin
   // Prepare basic variables.
   PVoxelMap := @_VoxelMap;
   PSemiSurfacesMap := @_SemiSurfaces;
   // Store VertexMap size for ModelMap.
   Size.X := ((PVoxelMap^.GetMaxX + 1)*C_VP_HIGH)+1;
   Size.Y := ((PVoxelMap^.GetMaxY + 1)*C_VP_HIGH)+1;
   Size.Z := ((PVoxelMap^.GetMaxZ + 1)*C_VP_HIGH)+1;
   // Prepare other map types.
   SetLength(FVertexMap,Size.X,Size.Y,Size.Z);
   for x := Low(FVertexMap) to High(FVertexMap) do
      for y := Low(FVertexMap[x]) to High(FVertexMap[x]) do
         for z := Low(FVertexMap[x,y]) to High(FVertexMap[x,y]) do
            FVertexMap[x,y,z] := -1;
   // Write faces and vertexes for each item of the map.
   GenerateItemsMap(FMap);
   FNumVertexes := 0;
   for x := Low(FMap) to High(FMap) do
      for y := Low(FMap[x]) to High(FMap[x]) do
         for z := Low(FMap[x,y]) to High(FMap[x,y]) do
         begin
            if FMap[x,y,z] <> -1 then
            begin
               FItems[FMap[x,y,z]] := TVoxelModelizerItem.Create(PVoxelMap^,PSemiSurfacesMap^,FVertexMap,x,y,z,FNumVertexes,_Palette,_ColourMap);
            end;
         end;
   // Get rid of FMap and create Model Map.
   x := High(FMap);
   while x >= 0 do
   begin
      y := High(FMap[x]);
      while y >= 0 do
      begin
         SetLength(FMap[x,y],0);
         dec(y);
      end;
      SetLength(FMap[x],0);
      dec(x);
   end;
   SetLength(FMap,0);
   // Confirm the vertex list.
   SetLength(_Vertexes,FNumVertexes);
   SetLength(Vertexes,FNumVertexes); // internal vertex list for future operations
   for x := Low(FVertexMap) to High(FVertexMap) do
      for y := Low(FVertexMap[x]) to High(FVertexMap[x]) do
         for z := Low(FVertexMap[x,y]) to High(FVertexMap[x,y]) do
         begin
            if FVertexMap[x,y,z] <> -1 then
            begin
               _Vertexes[FVertexMap[x,y,z]].X := (x-1) / C_VP_HIGH;
               _Vertexes[FVertexMap[x,y,z]].Y := (y-1) / C_VP_HIGH;
               _Vertexes[FVertexMap[x,y,z]].Z := (z-1) / C_VP_HIGH;
               Vertexes[FVertexMap[x,y,z]].X := x;
               Vertexes[FVertexMap[x,y,z]].Y := y;
               Vertexes[FVertexMap[x,y,z]].Z := z;
            end;
         end;
   // Wipe the VertexMap.
   x := High(FVertexMap);
   while x >= 0 do
   begin
      y := High(FVertexMap[x]);
      while y >= 0 do
      begin
         SetLength(FVertexMap[x,y],0);
         dec(y);
      end;
      SetLength(FVertexMap[x],0);
      dec(x);
   end;
   SetLength(FVertexMap,0);
   // Paint the faces in the 3D Map.
   ModelMap := T3DMap.Create(Size.X,Size.Y,Size.Z);
   for i := Low(FItems) to High(FItems) do
   begin
      Face := FItems[i].Faces.GetFirstElement;
      while Face <> nil do
      begin
         ModelMap.PaintFace(Vertexes[Face^.V1],Vertexes[Face^.V2],Vertexes[Face^.V3],1);
         Face := Face^.Next;
      end;
   end;
   // Classify the voxels from the 3D Map as in, out or surface.
   ModelMap.GenerateSelfSurfaceMap;
   // Check every face to ensure that it is in the surface. Cut the ones inside
   // the volume.
   NumFaces := 0;
   for i := Low(FItems) to High(FItems) do
   begin
      Face := FItems[i].Faces.GetFirstElement;
      while Face <> nil do
      begin
//         if ModelMap.IsFaceValid(Vertexes[Face^.V1],Vertexes[Face^.V2],Vertexes[Face^.V3],C_INSIDE_VOLUME) then
//         begin
            Face^.Location := NumFaces*3;
            inc(NumFaces);
//         end;
         Face := Face^.Next;
      end;
   end;
   // Generate the final faces array.
   SetLength(_Faces,NumFaces*3);
   SetLength(_Colours,NumFaces);
   SetLength(_Normals,NumFaces);
   for i := Low(FItems) to High(FItems) do
   begin
      Face := FItems[i].Faces.GetFirstElement;
      while Face <> nil do
      begin
         if Face^.location > -1 then
         begin
            pos := Face^.location div 3;
            // Calculate the normals from each face.
            Normal := GetNormals(_Vertexes[Face^.V1],_Vertexes[Face^.V2],_Vertexes[Face^.V3]);
            // Use 'raycasting' procedure to ensure that the vertexes are ordered correctly (anti-clockwise)
            if not ModelMap.IsFaceNormalsCorrect(Vertexes[Face^.V1],Vertexes[Face^.V2],Vertexes[Face^.V3],Normal) then
            begin
               Normal := GetNormals(_Vertexes[Face^.V3],_Vertexes[Face^.V2],_Vertexes[Face^.V1]);
               _Faces[Face^.location] := Face^.v3;
               _Faces[Face^.location+1] := Face^.v2;
               _Faces[Face^.location+2] := Face^.v1;
            end
            else
            begin
               _Faces[Face^.location] := Face^.v1;
               _Faces[Face^.location+1] := Face^.v2;
               _Faces[Face^.location+2] := Face^.v3;
            end;
            // Set normals value
            _Normals[pos].X := Normal.X;
            _Normals[pos].Y := Normal.Y;
            _Normals[pos].Z := Normal.Z;
            // Set a colour for each face.
            _Colours[pos].X := FItems[i].Colour.X;
            _Colours[pos].Y := FItems[i].Colour.Y;
            _Colours[pos].Z := FItems[i].Colour.Z;
            _Colours[pos].W := FItems[i].Colour.W;
         end;
         Face := Face^.Next;
      end;
   end;

   // Free memory
   ModelMap.Free;
   SetLength(Vertexes,0);
end;

destructor TVoxelModelizer.Destroy;
var
   x : integer;
begin
   for x := Low(FItems) to High(FItems) do
   begin
      FItems[x].Free;
   end;
   SetLength(FItems,0);
   inherited Destroy;
end;

procedure TVoxelModelizer.GenerateItemsMap(var FMap : T3DIntGrid);
var
   x, y, z: integer;
   NumItems : integer;
begin
   NumItems := 0;
   // Find out the regions where we will have meshes.
   SetLength(FMap,PVoxelMap^.GetMaxX+1,PVoxelMap^.GetMaxY+1,PVoxelMap^.GetMaxZ+1);
   for x := Low(FMap) to High(FMap) do
      for y := Low(FMap[x]) to High(FMap[x]) do
         for z := Low(FMap[x,y]) to High(FMap[x,y]) do
         begin
            if (PVoxelMap^.Map[x,y,z] > C_OUTSIDE_VOLUME) and (PVoxelMap^.Map[x,y,z] < C_INSIDE_VOLUME) then
            begin
               FMap[x,y,z] := NumItems;
               inc(NumItems);
            end
            else
            begin
               FMap[x,y,z] := -1;
            end;
         end;
   SetLength(FItems,NumItems);
end;

function TVoxelModelizer.GetNormals(_V1,_V2,_V3: TVector3f): TVector3f;
begin
   Result.X := ((_V3.Y - _V2.Y) * (_V1.Z - _V2.Z)) - ((_V1.Y - _V2.Y) * (_V3.Z - _V2.Z));
   Result.Y := ((_V3.Z - _V2.Z) * (_V1.X - _V2.X)) - ((_V1.Z - _V2.Z) * (_V3.X - _V2.X));
   Result.Z := ((_V3.X - _V2.X) * (_V1.Y - _V2.Y)) - ((_V1.X - _V2.X) * (_V3.Y - _V2.Y));
end;

function TVoxelModelizer.CopyMap(const _Map: T3DIntGrid): T3DIntGrid;
var
   x, y, z: integer;
begin
   SetLength(Result,High(_Map)+1,High(_Map[0])+1,High(_Map[0,0])+1);
   for x := Low(_Map) to High(_Map) do
      for y := Low(_Map[0]) to High(_Map[0]) do
         for z := Low(_Map[0,0]) to High(_Map[0,0]) do
         begin
            Result[x,y,z] := _Map[x,y,z];
         end;
end;

end.
