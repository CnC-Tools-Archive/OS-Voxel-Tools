unit DiffuseDebugTextureGenerator;

interface

uses TextureGeneratorBase, BasicMathsTypes, BasicDataTypes, Windows, Graphics,
   Abstract2DImageData;

type
   CDiffuseDebugTextureGenerator = class (CTextureGeneratorBase)
      protected
         // Generate Textures
         function GenerateDiffuseTexture(const _Faces: auint32; const _VertsColours: TAVector4f; const _TextCoords: TAVector2f; _VerticesPerFace, _Size: integer; var _AlphaMap: TByteMap): TBitmap;
         procedure PaintMeshDebugTexture(const _Faces: auint32; const _VertsColours: TAVector4f; const _TexCoords: TAVector2f; _VerticesPerFace: integer; var _Buffer: TAbstract2DImageData; var _WeightBuffer: TAbstract2DImageData);
      public
         procedure Execute(); override;
   end;

implementation

uses GlobalVars, BasicFunctions, TriangleFiller, TextureBankItem, dglOpenGL,
   ImageRGBAData, ImageGreyData, GLConstants, MeshBRepGeometry, Mesh;

procedure CDiffuseDebugTextureGenerator.Execute();
var
   i, TexIndex : integer;
   Buffer: TAbstract2DImageData;
   WeightBuffer: TAbstract2DImageData;
   TextureImage : TAbstract2DImageData;
   DiffuseTexture : PTextureBankItem;
begin
   Buffer := T2DImageRGBAData.Create(FSize,FSize);
   WeightBuffer := T2DImageGreyData.Create(FSize,FSize);
   for i := Low(FLOD.Mesh) to High(FLOD.Mesh) do
   begin
      FLOD.Mesh[i].Geometry.GoToFirstElement;
      PaintMeshDebugTexture((FLOD.Mesh[i].Geometry.Current^ as TMeshBRepGeometry).Faces,FLOD.Mesh[i].Colours,FLOD.Mesh[i].TexCoords,(FLOD.Mesh[i].Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace,Buffer,WeightBuffer);
   end;
   TextureImage := GetColouredImageDataFromBuffer(Buffer,WeightBuffer);
   Buffer.Free;
   WeightBuffer.Free;
   // Now we generate a texture that will be used by all meshes.
   glActiveTexture(GL_TEXTURE0 + FTextureID);
   TexIndex := -1;
   if FMaterialID <= High(FLOD.Mesh[0].Materials) then
   begin
      TexIndex := FLOD.Mesh[0].Materials[FMaterialID].GetTextureID(C_TTP_DIFFUSE);
   end;
   if TexIndex = -1 then
   begin
      DiffuseTexture := GlobalVars.TextureBank.Add(TextureImage);
      // Now we add this diffuse texture to all meshes.
      for i := Low(FLOD.Mesh) to High(FLOD.Mesh) do
      begin
         FLOD.Mesh[i].AddTextureToMesh(FMaterialID,C_TTP_DIFFUSE,C_SHD_PHONG_1TEX,DiffuseTexture);
      end;
      GlobalVars.TextureBank.Delete(DiffuseTexture^.GetID);
   end
   else
   begin
      DiffuseTexture := FLOD.Mesh[0].Materials[FMaterialID].Texture[TexIndex];
      DiffuseTexture^.ReplaceTexture(TextureImage);
   end;
   // Free memory.
   TextureImage.Free;
end;

procedure CDiffuseDebugTextureGenerator.PaintMeshDebugTexture(const _Faces: auint32; const _VertsColours: TAVector4f; const _TexCoords: TAVector2f; _VerticesPerFace: integer; var _Buffer: TAbstract2DImageData; var _WeightBuffer: TAbstract2DImageData);
var
   i,LastFace : cardinal;
   Filler: CTriangleFiller;
begin
   LastFace := ((High(_Faces)+1) div _VerticesPerFace) - 1;
   Filler := CTriangleFiller.Create;
   for i := 0 to LastFace do
   begin
      Filler.PaintDebugTriangle(_Buffer,_WeightBuffer,_TexCoords[_Faces[(i * _VerticesPerFace)]],_TexCoords[_Faces[(i * _VerticesPerFace)+1]],_TexCoords[_Faces[(i * _VerticesPerFace)+2]]);
   end;
   Filler.Free;
end;

function CDiffuseDebugTextureGenerator.GenerateDiffuseTexture(const _Faces: auint32; const _VertsColours: TAVector4f; const _TextCoords: TAVector2f; _VerticesPerFace, _Size: integer; var _AlphaMap: TByteMap): TBitmap;
var
   Buffer: T2DFrameBuffer;
   WeightBuffer: TWeightBuffer;
   Size,i,LastFace : cardinal;
   Filler: CTriangleFiller;
begin
   Size := GetPow2Size(_Size);
   Filler := CTriangleFiller.Create;
   SetupFrameBuffer(Buffer,WeightBuffer,Size);
   LastFace := ((High(_Faces)+1) div _VerticesPerFace) - 1;
   for i := 0 to LastFace do
   begin
      Filler.PaintDebugTriangle(Buffer,WeightBuffer,_TextCoords[_Faces[(i * _VerticesPerFace)]],_TextCoords[_Faces[(i * _VerticesPerFace)+1]],_TextCoords[_Faces[(i * _VerticesPerFace)+2]]);
   end;
   Result := GetColouredBitmapFromFrameBuffer(Buffer,WeightBuffer,_AlphaMap);
   DisposeFrameBuffer(Buffer,WeightBuffer);
   Filler.Free;
end;

end.
