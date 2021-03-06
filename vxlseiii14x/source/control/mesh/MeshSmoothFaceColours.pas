unit MeshSmoothFaceColours;

interface

uses MeshProcessingBase, Mesh, BasicMathsTypes, BasicDataTypes, NeighborDetector, MeshColourCalculator;

{$INCLUDE source/Global_Conditionals.inc}

type
   TMeshSmoothFaceColours = class (TMeshProcessingBase)
      protected
         procedure MeshSmoothOperation(var _Colours: TAVector4f; const _FaceColours: TAVector4f; const _Vertices: TAVector3f; _NumVertices: integer; const _Faces: auint32; _VerticesPerFace: integer; const _NeighborDetector: TNeighborDetector; const _VertexEquivalences: auint32; var _Calculator: TMeshColourCalculator);
         procedure DoMeshProcessing(var _Mesh: TMesh); override;
      public
         DistanceFunction: TDistanceFunc;
   end;

implementation

uses MeshPluginBase, GLConstants, NeighborhoodDataPlugin, MeshBRepGeometry;

procedure TMeshSmoothFaceColours.DoMeshProcessing(var _Mesh: TMesh);
var
   Calculator : TMeshColourCalculator;
   NeighborhoodPlugin: PMeshPluginBase;
   NeighborDetector: TNeighborDetector;
   VertexEquivalences: auint32;
   NumVertices: integer;
   MyFaces: auint32;
   MyFaceColours: TAVector4f;
begin
   Calculator := TMeshColourCalculator.Create;
   NeighborhoodPlugin := _Mesh.GetPlugin(C_MPL_NEIGHBOOR);
   _Mesh.Geometry.GoToFirstElement;
   if NeighborhoodPlugin <> nil then
   begin
      if TNeighborhoodDataPlugin(NeighborhoodPlugin^).UseQuadFaces then
      begin
         NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).QuadFaceNeighbors;
         MyFaces := TNeighborhoodDataPlugin(NeighborhoodPlugin^).QuadFaces;
         MyFaceColours := TNeighborhoodDataPlugin(NeighborhoodPlugin^).QuadFaceColours;
      end
      else
      begin
         NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).FaceNeighbors;
         _Mesh.Geometry.GoToFirstElement;
         MyFaces := (_Mesh.Geometry.Current^ as TMeshBRepGeometry).Faces;
         MyFaceColours := (_Mesh.Geometry.Current^ as TMeshBRepGeometry).Colours;
      end;
      VertexEquivalences := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexEquivalences;
      NumVertices := TNeighborhoodDataPlugin(NeighborhoodPlugin^).InitialVertexCount;
   end
   else
   begin
      NeighborDetector := TNeighborDetector.Create(C_NEIGHBTYPE_VERTEX_FACE);
      NeighborDetector.BuildUpData(_Mesh.Geometry,High(_Mesh.Vertices)+1);
      VertexEquivalences := nil;
      NumVertices := High(_Mesh.Vertices)+1;
      MyFaces := (_Mesh.Geometry.Current^ as TMeshBRepGeometry).Faces;
      MyFaceColours := (_Mesh.Geometry.Current^ as TMeshBRepGeometry).Colours;
   end;
   MeshSmoothOperation(_Mesh.Colours,MyFaceColours,_Mesh.Vertices,NumVertices,MyFaces,(_Mesh.Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace,NeighborDetector,VertexEquivalences,Calculator);
   if NeighborhoodPlugin = nil then
   begin
      NeighborDetector.Free;
   end;
   Calculator.Free;
   _Mesh.ForceRefresh;
end;

procedure TMeshSmoothFaceColours.MeshSmoothOperation(var _Colours: TAVector4f; const _FaceColours: TAVector4f; const _Vertices: TAVector3f; _NumVertices: integer; const _Faces: auint32; _VerticesPerFace: integer; const _NeighborDetector: TNeighborDetector; const _VertexEquivalences: auint32; var _Calculator: TMeshColourCalculator);
var
   OriginalColours,VertColours : TAVector4f;
begin
   SetLength(OriginalColours,High(_Colours)+1);
   SetLength(VertColours,High(_Vertices)+1);
   BackupVector4f(_Colours,OriginalColours);
   _Calculator.GetVertexColoursFromFaces(VertColours,OriginalColours,_Vertices,_NumVertices,_Faces,_VerticesPerFace,_NeighborDetector,_VertexEquivalences,DistanceFunction);
   _Calculator.GetFaceColoursFromVertexes(VertColours,_Colours,_Faces,_VerticesPerFace);
   FilterAndFixColours(_Colours);
   // Free memory
   SetLength(VertColours,0);
   SetLength(OriginalColours,0);
end;

end.
