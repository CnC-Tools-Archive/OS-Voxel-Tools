unit VH_Display;

interface

Uses Windows,SysUtils,OpenGl15,Math3d,VH_Types,Voxel,VH_Voxel,VH_Global,Normals,HVA,Math;

{$define DEBUG_VOXEL_BOUNDS}

Procedure DrawBox(Position,Color : TVector3f; Size : TVector3f; const VoxelBox: TVoxelBox); overload;
Procedure DrawBox(Position: TVector3f; Color : TVector4f; Size : TVector3f; const VoxelBox: TVoxelBox); overload;
Procedure DrawBox(_CameraPosition, _BoxPosition, _CameraRotation, _BoxSize : TVector3f); overload;

Procedure DrawBoundingBox(const _Voxel: PVoxel; const _HVA: PHVA; const _Section, _Frame: integer; const _UnitShift: TVector3f; const _Rotation: single); overload;
Procedure DrawBoundingBox(_CameraPosition, _CenterPosition, _CameraRotation, _BoundingSize : TVector3f); overload;

Procedure DrawBullet(_BulletPosition, _BulletSize : TVector3f);

Procedure DrawVoxel(const PVxl : PVoxel; const Vxl : TVoxel; Var VoxelBoxes : TVoxelBoxs; VoxelBox_No : integer; HVAOpen : boolean; const HVA : THVA; HVAFrame : Integer);
Procedure DrawVoxels(ShiftX,ShiftY,ShiftZ,Rot : Extended);
Procedure DrawWorld;

Procedure DrawGround(Tex : Integer; Position,Rotation,Color : TVector3f; Size : single);
procedure DrawSkyBox(Rotation,Rotation2 : TVector3f);

Procedure DrawCenterLines(_CameraPosition, _CenterPosition, _CameraRotation : TVector3f);
Procedure DrawSectionCenterLines(const _Voxel: PVoxel; const _HVA: PHVA; const _Section, _Frame: integer; const _UnitShift: TVector3f; const _Rotation: single);
Procedure BuildSkyBox;

procedure BuildFont;
procedure KillFont;
procedure glPrint(const text : pchar);

function GetPow2Size(Size : Cardinal) : Cardinal;

implementation

Uses Textures;

procedure DoNormals(Normal : Integer);
var
   N : integer;
begin
   N := Normal;

   if N = -1 then
   begin
      glNormal3f(0,0,0);
      exit;
   end;

   if VoxelFile.Section[0].Tailer.Unknown = 4 then
      if N > 243 then
         N := 243;

   if VoxelFile.Section[0].Tailer.Unknown = 2 then
      if N > 35 then
         N := 35;

   if N < 0 then
      N := 0;

   if VoxelFile.Section[0].Tailer.Unknown = 2 then
      glNormal3f(TSNormals[trunc(N)].X{*1.2}, TSNormals[trunc(N)].Y{*1.2}, TSNormals[trunc(N)].Z{*1.2})
   else
      glNormal3f(RA2Normals[trunc(N)].X{*1.2}, RA2Normals[trunc(N)].Y{*1.2}, RA2Normals[trunc(N)].Z{*1.2});
end;

Procedure DrawBox(Position,Color : TVector3f; Size : TVector3f; const VoxelBox: TVoxelBox);
var
   Color4f: TVector4f;
begin
   Color4f.X := Color.X;
   Color4f.Y := Color.Y;
   Color4f.Z := Color.Z;
   Color4f.W := 0;
   DrawBox(Position, Color4f, Size, VoxelBox);
end;

Procedure DrawBox(Position: TVector3f; Color : TVector4f; Size : TVector3f; const VoxelBox: TVoxelBox);
var
   East,West,South,North,Ceil,Floor : single;
begin
   East := Position.X + Size.X;
   West := Position.X - Size.X;
   Ceil := Position.Y + Size.Y;
   Floor := Position.Y - Size.Y;
   South := Position.Z + Size.Z;
   North := Position.Z - Size.Z;

   glBegin(GL_QUADS);

      glColor4f(Color.X,Color.Y,Color.Z,Color.W);			// Set The Color
      DoNormals(VoxelBox.Normal);


      if VoxelBox.Faces[1] then
      begin
		   glVertex3f(East, Ceil, North);			// Top Right Of The Quad (Top)
		   glVertex3f(West, Ceil, North);			// Top Left Of The Quad (Top)
         glVertex3f(West, Ceil, South);			// Bottom Left Of The Quad (Top)
	   	glVertex3f(East, Ceil, South);			// Bottom Right Of The Quad (Top)
      end;

      if VoxelBox.Faces[2] then
      begin
		   glVertex3f(East, Floor, South);			// Top Right Of The Quad (Bottom)
		   glVertex3f(West, Floor, South);			// Top Left Of The Quad (Bottom)
		   glVertex3f(West, Floor, North);			// Bottom Left Of The Quad (Bottom)
		   glVertex3f(East, Floor, North);			// Bottom Right Of The Quad (Bottom)
	   end;

      if VoxelBox.Faces[3] then
      begin
		   glVertex3f(East, Ceil, South);			// Top Right Of The Quad (Front)
		   glVertex3f(West, Ceil, South);			// Top Left Of The Quad (Front)
	   	glVertex3f(West, Floor,South);			// Bottom Left Of The Quad (Front)
		   glVertex3f(East, Floor,South);			// Bottom Right Of The Quad (Front)
      end;

      if VoxelBox.Faces[4] then
      begin
		   glVertex3f(East, Floor,North);			// Bottom Left Of The Quad (Back)
		   glVertex3f(West, Floor,North);			// Bottom Right Of The Quad (Back)
		   glVertex3f(West, Ceil, North);			// Top Right Of The Quad (Back)
		   glVertex3f(East, Ceil, North);			// Top Left Of The Quad (Back)
      end;

      if VoxelBox.Faces[5] then
      begin
		   glVertex3f(West, Ceil, South);			// Top Right Of The Quad (Left)
		   glVertex3f(West, Ceil, North);			// Top Left Of The Quad (Left)
		   glVertex3f(West, Floor,North);			// Bottom Left Of The Quad (Left)
		   glVertex3f(West, Floor,South);			// Bottom Right Of The Quad (Left)
      end;

      if VoxelBox.Faces[6] then
      begin
	   	glVertex3f( East, Ceil, North);			// Top Right Of The Quad (Right)
		   glVertex3f( East, Ceil, South);			// Top Left Of The Quad (Right)
		   glVertex3f( East, Floor,South);			// Bottom Left Of The Quad (Right)
		   glVertex3f( East, Floor,North);			// Bottom Right Of The Quad (Right)
      end;
   glEnd();
end;

Procedure DrawVoxel(const PVxl : PVoxel; const Vxl : TVoxel; Var VoxelBoxes : TVoxelBoxs; VoxelBox_No : integer; HVAOpen : boolean; const HVA : THVA; HVAFrame : Integer);
var
   x,s : integer;
   Scale,FinalScale,Offset, BulletPosition, TurretTranslate, TurretScale : TVector3f;
begin
   if VoxelBox_No < 1 then exit;

   for s := 0 to VoxelBoxes.NumSections-1 do
      If ((CurrentSection = s) and (PVxl = CurrentSectionVoxel)) or (DrawAllOfVoxel) or (CurrentSection = -1) then
      begin
         GETMinMaxBounds(Vxl,s,Scale,Offset);
         inc(VoxelsUsed,VoxelBoxes.Sections[s].NumBoxs);
         FinalScale := ScaleVector(Scale,Size);

         If (VoxelBoxes.Sections[s].List < 1) or RebuildLists then
         begin
            if (VoxelBoxes.Sections[s].List > 0) then
               glDeleteLists(VoxelBoxes.Sections[s].List,1);
            VoxelBoxes.Sections[s].List := glGenLists(1);
            glNewList(VoxelBoxes.Sections[s].List, GL_COMPILE);
            glPushMatrix;
            for x := 0 to VoxelBoxes.Sections[s].NumBoxs-1 do
            begin
               DrawBox(GetPosWithSize(ScaleVector3f(VoxelBoxes.Sections[s].Boxs[x].Position,Scale),Size),GetVXLColorWithSelection(Vxl,VoxelBoxes.Sections[s].Boxs[x].Color,VoxelBoxes.Sections[s].Boxs[x].Normal,VoxelBoxes.Sections[s].Boxs[x].Section),FinalScale,VoxelBoxes.Sections[s].Boxs[x]);
            end;
            glPopMatrix;
            glEndList;
            glColor3f(1,1,1);
         end;

         glPushMatrix;
            ApplyMatrix(HVA,Vxl,FinalScale,s,HVAFrame);
            glTranslatef(Offset.X*Size*2, Offset.Y*Size*2, Offset.Z*Size*2);
            if (Vxl = VoxelTurret) or (Vxl = VoxelBarrel) then
               glTranslatef(TurretOffset.X * Size * 2 * LeptonSize,TurretOffset.Y * Size * 2 * LeptonSize,TurretOffset.Z * Size * 2 * LeptonSize);
            glCallList(VoxelBoxes.Sections[s].List);
            //if DrawPrimaryFireFLH and (((Vxl = VoxelFile) and (s = (VoxelBoxes.NumSections-1)) and (VoxelBarrel = nil)) or ((VoxelBarrel <> nil) and (Vxl = VoxelTurret))) then
            if DrawPrimaryFireFLH and (Vxl = VoxelFile) and (s = (VoxelBoxes.NumSections-1)) then
            begin
               BulletPosition.X := (PrimaryFireFLH.X + TurretOffset.X) * FinalScale.X * 2 * LeptonSize;
               BulletPosition.Y := PrimaryFireFLH.Y * FinalScale.Y * 2 * LeptonSize;  // This is a 2.5D trick.
               BulletPosition.Z := PrimaryFireFLH.Z * FinalScale.Z * 2 * LeptonSize;  // This is a 2.5D trick.
               BulletPosition := AddVector(BulletPosition, SetVector((Vxl.Section[s].Tailer.XSize * FinalScale.X) - Size, (Vxl.Section[s].Tailer.YSize * FinalScale.Y) - Size, -1 * Size));
               glDisable(GL_CULL_FACE);
               glDisable(GL_LIGHTING);
               DrawBullet(BulletPosition, SetVector(Size * 2 * BulletSize, Size * 2 * BulletSize, Size * 2 * BulletSize));
               glEnable(GL_LIGHTING);
               glEnable(GL_CULL_FACE);
            end;
         glPopMatrix;
      end;

end;

Procedure DrawVoxels(ShiftX,ShiftY,ShiftZ,Rot : Extended);
begin
   glPushMatrix;
   VoxelsUsed := 0;
   // Temporary code:
   HVAFile.HigherLevel := nil;

   glLoadIdentity;
   glTranslatef(CameraCenter.X,CameraCenter.Y, Depth);

   glRotatef(XRot, 1, 0, 0);
   glRotatef(YRot, 0, 0, 1);

   //glTranslatef(UnitShift.X+(x*15)-(2*15), UnitShift.Y+(y*15)-(2*15),0);
   glTranslatef(ShiftX,ShiftY,ShiftZ);

   glRotatef(Rot, 0, 0, 1);

   DrawVoxel(@VoxelFile,VoxelFile,VoxelBoxes,VoxelBox_No,True,HVAFile,HVAFrame);

   glPushMatrix;

   glRotatef(VXLTurretRotation.X, 0, 0, 1);

      If DrawTurret then
      begin
         // Temporary code:
         HVATurret.HigherLevel := @HVAFile;
         DrawVoxel(@VoxelTurret,VoxelTurret,VoxelBoxesT,VoxelBox_NoT,True,HVATurret,HVAFrameT);
      end;
      If DrawBarrel then
      begin
         // Temporary code:
         HVABarrel.HigherLevel := @HVATurret;
         DrawVoxel(@VoxelBarrel,VoxelBarrel,VoxelBoxesB,VoxelBox_NoB,True,HVABarrel,HVAFrameB);
      end;
   glPopMatrix;

   If RebuildLists then
      RebuildLists := False;

   glPopMatrix;
end;

Procedure DrawTexture(Texture : Cardinal; X,Y : Single; Width,Height,AWidth,AHeight : Cardinal; XOff : Cardinal = 0; YOff : Cardinal = 0; XOffWidth : Cardinal = Cardinal(-1); YOffHeight : Cardinal = Cardinal(-1));
var
   TexCoordX,
   TexCoordY,
   TexCoordOffX,
   TexCoordOffY : Single;
begin
   //glDisable(GL_CULL_FACE);
   if XOffWidth = Cardinal(-1) then
      XOffWidth    := Width;
   if YOffHeight = Cardinal(-1) then
      YOffHeight   := Height;
   TexCoordX    := XOffWidth/AWidth;
   TexCoordY    := YOffHeight/AHeight;
   TexCoordOffX := XOff/AWidth;
   TexCoordOffY := YOff/AHeight;
   glBindTexture(GL_TEXTURE_2D, Texture);
   glBegin(GL_QUADS);
      //1
      glTexCoord2f(TexCoordOffX, TexCoordOffY);
      glVertex2f(X, Y);
      //2
      glTexCoord2f(TexCoordOffX+TexCoordX, TexCoordOffY);
      glVertex2f(X+Width, Y);
      //3
      glTexCoord2f(TexCoordOffX+TexCoordX, TexCoordOffY+TexCoordY);
      glVertex2f(X+Width, Y+Height);
      //4
      glTexCoord2f(TexCoordOffX, TexCoordOffY+TexCoordY);
      glVertex2f(X, Y+Height);
   glEnd;
 //glEnable(GL_CULL_FACE);
end;

function GetPow2Size(Size : Cardinal) : Cardinal;
var
   Step : Byte;
begin
   Step   := 0;
   Repeat
      Result := Trunc(Power(2,Step));
      inc(Step);
   Until (Result >= Size) or (Result >= 4096);
   if Result > 4096 then
      Result := 4096;
end;

Procedure DrawWorld;
begin
   if FUpdateWorld then
   begin
	  FUpdateWorld := False;

	  if ColoursOnly then
      begin
         glDisable(GL_LIGHT0);
         glDisable(GL_LIGHTING);
         glDisable(GL_COLOR_MATERIAL);
      end
      else
      begin
         glEnable(GL_LIGHT0);
         glLightfv(GL_LIGHT0, GL_AMBIENT, @LightAmb);				// Set The Ambient Lighting For Light0
         glLightfv(GL_LIGHT0, GL_DIFFUSE, @LightDif);				// Set The Diffuse Lighting For Light0
         glEnable(GL_LIGHTING);
         glEnable(GL_COLOR_MATERIAL);
         glNormal3f(0,0,0);
	  end;

      if (UnitCount = 4) or (UnitCount = 8) then
      begin
         DrawVoxels(UnitShift.X-UnitSpace,UnitShift.Y,UnitShift.Z,UnitRot);
         DrawVoxels(UnitShift.X+UnitSpace,UnitShift.Y,UnitShift.Z,UnitRot+180);
         DrawVoxels(UnitShift.X,UnitShift.Y-UnitSpace,UnitShift.Z,UnitRot+90);
         DrawVoxels(UnitShift.X,UnitShift.Y+UnitSpace,UnitShift.Z,UnitRot-90);
         if UnitCount = 8 then
         begin
            DrawVoxels(UnitShift.X-UnitSpace,UnitShift.Y-UnitSpace,UnitShift.Z,UnitRot+45);
            DrawVoxels(UnitShift.X+UnitSpace,UnitShift.Y+UnitSpace,UnitShift.Z,UnitRot+45+180);
            DrawVoxels(UnitShift.X+UnitSpace,UnitShift.Y-UnitSpace,UnitShift.Z,UnitRot-45-180);
            DrawVoxels(UnitShift.X-UnitSpace,UnitShift.Y+UnitSpace,UnitShift.Z,UnitRot-45);
         end;
      end
      else
         DrawVoxels(UnitShift.X,UnitShift.Y,UnitShift.Z,UnitRot);


      glDisable(GL_CULL_FACE);
      glEnable(GL_TEXTURE_2D);
      glColor3f(1,1,1);

      If Not LightGround then
      begin
         glDisable(GL_LIGHT0);
         glDisable(GL_LIGHTING);
         glDisable(GL_COLOR_MATERIAL);
      end
      else
      begin
         glEnable(GL_LIGHT0);
         glLightfv(GL_LIGHT0, GL_AMBIENT, @LightAmb);				// Set The Ambient Lighting For Light0
         glLightfv(GL_LIGHT0, GL_DIFFUSE, @LightDif);				// Set The Diffuse Lighting For Light0
         glEnable(GL_LIGHTING);
         glEnable(GL_COLOR_MATERIAL);
         glNormal3f(0,0,0);
      end;

      if Ground_Tex_Draw then
         DrawGround(GroundTex.Tex,SetVector(CameraCenter.X,CameraCenter.Y,Depth),SetVector(XRot,0,YRot),SetVector(1,1,1),GSize);

      if DrawSky then
         DrawSkyBox(SetVector(XRot,0,YRot),SetVector(-90,0,180));

      If Not LightGround then
      begin
         glEnable(GL_LIGHT0);
         glLightfv(GL_LIGHT0, GL_AMBIENT, @LightAmb);				// Set The Ambient Lighting For Light0
         glLightfv(GL_LIGHT0, GL_DIFFUSE, @LightDif);				// Set The Diffuse Lighting For Light0
         glEnable(GL_LIGHTING);
         glEnable(GL_COLOR_MATERIAL);
         glNormal3f(0,0,0);
      end;

      glDisable(GL_TEXTURE_2D);
      glEnable(GL_CULL_FACE);

      If DrawCenter then
         DrawCenterLines(SetVector(CameraCenter.X,CameraCenter.Y, Depth),SetVector(0,0,0),SetVector(XRot,0,YRot));

      If DrawSectionCenter then
      begin
         DrawSectionCenterLines(CurrentVoxel, CurrentHVA, CurrentVoxelSection, GetCurrentFrame(), UnitShift, UnitRot);
      end;

      if Highlight then
      begin
         DrawBoundingBox(CurrentVoxel, CurrentHVA, CurrentVoxelSection, GetCurrentFrame(), UnitShift, UnitRot);
      end;

      glEnable(GL_TEXTURE_2D);

      if FTexture = 0 then
         glGenTextures(1, @FTexture);
      glBindTexture(GL_TEXTURE_2D, FTexture);

      glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 0, 0, GetPow2Size(SCREEN_WIDTH),GetPow2Size(SCREEN_HEIGHT), 0);


      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

      glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
   end;

   glDisable(GL_LIGHT0);
   glDisable(GL_LIGHTING);
   glDisable(GL_COLOR_MATERIAL);
   glDisable(GL_CULL_FACE);
   glDisable(GL_DEPTH_TEST);
   glMatrixMode(GL_PROJECTION);
   glPushMatrix;
      glLoadIdentity;
      glOrtho(0,SCREEN_WIDTH,0,SCREEN_HEIGHT,-1,1);
      glMatrixMode(GL_MODELVIEW);
      glPushMatrix;
         glLoadIdentity;
         glEnable(GL_TEXTURE_2D);
         glColor3f(1,1,1);
         DrawTexture(FTexture,0,0,SCREEN_WIDTH,SCREEN_HEIGHT,GetPow2Size(SCREEN_WIDTH),GetPow2Size(SCREEN_HEIGHT));

         glDisable(GL_TEXTURE_2D);

         If (Not ScreenShot.Take) and (Not ScreenShot.TakeAnimation) and (Not ScreenShot.CaptureAnimation) and (Not ScreenShot.Take360DAnimation) then
        Begin
           glColor3f(FontColor.X,FontColor.Y,FontColor.Z);

		   if ShowVoxelCount then
		   begin
              glRasterPos2i(1,2);
              glPrint(pchar('Voxels Used: ' + inttostr(VoxelsUsed)));
		   end;

		   glRasterPos2i(1,SCREEN_HEIGHT-9);
           glPrint(pchar('FPS: ' + inttostr(gTimer.GetAverageFPS)));

           if DebugMode then
           begin
              glRasterPos2i(1,13);
              glPrint(pchar('Depth: ' + inttostr(trunc(Depth))));

              glRasterPos2i(1,SCREEN_HEIGHT-29);
              glPrint(pchar('XRot:' + floattostr(XRot)));

              glRasterPos2i(1,SCREEN_HEIGHT-39);
              glPrint(pchar('YRot:' + floattostr(YRot)));
           end;
        end;

        glMatrixMode(GL_PROJECTION);
      glPopMatrix;
      glMatrixMode(GL_MODELVIEW);
   glPopMatrix;
   glEnable(GL_DEPTH_TEST);
   glEnable(GL_CULL_FACE);
end;

procedure BuildFont;			                // Build Our Bitmap Font
var
   font: HFONT;                	                // Windows Font ID
begin
   base := glGenLists(256);       	                // Storage For 96 Characters
   SelectObject(H_DC, font);		       	        // Selects The Font We Want

   font := CreateFont(9, 0,0,0, FW_NORMAL, 0, 0, 0, OEM_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY	, FF_DONTCARE + DEFAULT_PITCH, 'Terminal');
   SelectObject(H_DC, font);
   wglUseFontBitmaps(H_DC, 0, 127, base);
end;

procedure KillFont;     		                // Delete The Font
begin
   glDeleteLists(base, 256); 		                // Delete All 96 Characters
end;

procedure glPrint(const text : pchar);	                // Custom GL "Print" Routine
begin
   if (text = '') then   			        // If There's No Text
      Exit;					        // Do Nothing

   glPushAttrib(GL_LIST_BIT);				// Pushes The Display List Bits
   glListBase(base);					// Sets The Base Character
   glCallLists(length(text), GL_UNSIGNED_BYTE, text);	// Draws The Display List Text
   glPopAttrib();								// Pops The Display List Bits
end;

Procedure DrawGround(Tex : Integer; Position,Rotation,Color : TVector3f; Size : single);
var
   P : TVector3f;
   w,h,tx,ty : single;
   TexId : integer;
begin
   glLoadIdentity();                                       // Reset The View

   glTranslatef(Position.X, Position.Y, Position.Z);
   glNormal3f(0,0,0);

   glRotatef(Rotation.Y, 0, 1, 0);
   glRotatef(Rotation.X, 1, 0, 0);
   glRotatef(Rotation.Z, 0, 0, 1);

   P := GetPosWithSize(SetVector(0, 0, GroundHeightOffset),0.1);

   glTranslatef(P.X,P.Y,P.Z);


   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);

   glBindTexture(GL_TEXTURE_2D, Tex);
   TexId := GetTexInfoNo(Tex);

   w := 1;
   h := 1;

   if (TileGround) and (TexId <> -1) then
   begin
      w := ((Size*2)/0.1)/TexInfo[TexId].Width;
      h := ((Size*2)/0.1)/TexInfo[TexId].Height;
   end;

   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

   TX := 0;
   TY := 0;

   if (TexId <> -1) then
   begin
      TX := TexShiftX*(10/TexInfo[TexId].Width);
      TY := TexShiftY*(10/TexInfo[TexId].Height);
   end;

   glBegin(GL_QUADS);

   glColor3f(Color.X,Color.Y,Color.Z);			// Set The Color
	glTexCoord2f(TX+0.0,TY+0.0); glVertex3f( -Size, -Size, 0);			// Top Right Of The Quad (Front)
	glTexCoord2f(TX+w,  TY+0.0); glVertex3f(Size, -Size, 0);			// Top Left Of The Quad (Front)
	glTexCoord2f(TX+w,  TY+h);   glVertex3f(Size,Size, 0);			// Bottom Left Of The Quad (Front)
	glTexCoord2f(TX+0.0,TY+h);   glVertex3f( -Size,Size, 0);			// Bottom Right Of The Quad (Front)
   glEnd();
end;

Procedure BuildSkyBox;
var
   px,py,pz : GLfloat;
begin
  // left, back und top sind falsch
   px := (- SkySize.X  / 2);//+pos.x;
   py := (- SkySize.Y / 2);//+pos.y;
   pz := (- SkySize.Z / 2);//+pos.z;

   SkyList := glGenLists(1);
   glNewList(SkyList, GL_COMPILE);
      // Back
      glNormal3f(0,0,0);
      glBindTexture(GL_TEXTURE_2D, SkyTexList[SkyTex].Textures[3]);

      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

      glBegin(GL_QUADS);
         glTexCoord2f(1, 0); glVertex3f(px + SkySize.X, py,             pz);
         glTexCoord2f(1, 1); glVertex3f(px + SkySize.X, py + SkySize.Y, pz);
         glTexCoord2f(0, 1); glVertex3f(px,             py + SkySize.Y, pz);
         glTexCoord2f(0, 0); glVertex3f(px,             py,             pz);
      glEnd;
      // Front
      glBindTexture(GL_TEXTURE_2D, SkyTexList[SkyTex].Textures[2]);

      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

      glBegin(GL_QUADS);
         glTexCoord2f(1, 0); glVertex3f(px,	           py,             pz + SkySize.Z);
         glTexCoord2f(1, 1); glVertex3f(px,             py + SkySize.Y, pz + SkySize.Z);
         glTexCoord2f(0, 1); glVertex3f(px + SkySize.X, py + SkySize.Y, pz + SkySize.Z);
         glTexCoord2f(0, 0); glVertex3f(px + SkySize.X, py,             pz + SkySize.Z);
      glEnd;
      // Bottom
      glBindTexture(GL_TEXTURE_2D, SkyTexList[SkyTex].Textures[5]);

      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

      glBegin(GL_QUADS);
         glTexCoord2f(1, 1); glVertex3f(px,	           py, pz);
         glTexCoord2f(1, 0); glVertex3f(px,	           py, pz + SkySize.Z);
         glTexCoord2f(0, 0); glVertex3f(px + SkySize.X, py, pz + SkySize.Z);
         glTexCoord2f(0, 1); glVertex3f(px + SkySize.X, py, pz);
      glEnd;
      // Top
      glBindTexture(GL_TEXTURE_2D, SkyTexList[SkyTex].Textures[4]);

      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

      glBegin(GL_QUADS);
         glTexCoord2f(0, 0); glVertex3f(px+SkySize.X, py + SkySize.Y, pz);
         glTexCoord2f(1, 0); glVertex3f(px+SkySize.X, py + SkySize.Y, pz + SkySize.Z);
         glTexCoord2f(1, 1); glVertex3f(px,           py + SkySize.Y, pz + SkySize.Z);
         glTexCoord2f(0, 1); glVertex3f(px,           py + SkySize.Y, pz);
      glEnd;
      // Left
      glBindTexture(GL_TEXTURE_2D, SkyTexList[SkyTex].Textures[1]);


      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

      glBegin(GL_QUADS);
         glTexCoord2f(1, 1); glVertex3f(px, py + SkySize.Y, pz);
         glTexCoord2f(0, 1); glVertex3f(px, py + SkySize.Y, pz + SkySize.Z);
         glTexCoord2f(0, 0); glVertex3f(px, py,             pz + SkySize.Z);
         glTexCoord2f(1, 0); glVertex3f(px, py,             pz);
      glEnd;

      // Right
      glBindTexture(GL_TEXTURE_2D, SkyTexList[SkyTex].Textures[0]);

      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

      glBegin(GL_QUADS);
         glTexCoord2f(0, 0); glVertex3f(px + SkySize.X, py,             pz);
         glTexCoord2f(1, 0); glVertex3f(px + SkySize.X, py,             pz + SkySize.Z);
         glTexCoord2f(1, 1); glVertex3f(px + SkySize.X, py + SkySize.Y, pz + SkySize.Z);
         glTexCoord2f(0, 1); glVertex3f(px + SkySize.X, py + SkySize.Y, pz);
      glEnd;
   glEndList;

end;

procedure DrawSkyBox(Rotation,Rotation2 : TVector3f);
begin
   if SkyList = -1 then
   begin
      BuildSkyBox;
   end;

   glLoadIdentity;
   glMatrixMode(GL_MODELVIEW);
   glPushMatrix;
   glTranslatef(0, 0, Depth);
   glRotatef(Rotation.Y, 0, 1, 0);
   glRotatef(Rotation.X, 1, 0, 0);
   glRotatef(Rotation.Z, 0, 0, 1);
   glTranslatef(SkyPos.X, SkyPos.y, SkyPos.Z);
   glRotatef(Rotation2.Y, 0, 1, 0);
   glRotatef(Rotation2.X, 1, 0, 0);
   glRotatef(Rotation2.Z, 0, 0, 1);
   glCallList(SkyList);

   glPopMatrix;
end;

Procedure DrawBox(_CameraPosition, _BoxPosition, _CameraRotation, _BoxSize : TVector3f);
var
   x,y,z : GLfloat;
begin
   // Reset The View.
   glLoadIdentity();

   // Camera.
   glTranslatef(_CameraPosition.X, _CameraPosition.Y, _CameraPosition.Z);

   glRotatef(_CameraRotation.Y, 0, 1, 0);
   glRotatef(_CameraRotation.X, 1, 0, 0);
   glRotatef(_CameraRotation.Z, 0, 0, 1);

   // Ensure that box ix centralized at _BoxPosition.
   x := -_BoxSize.x /2;
   y := -_BoxSize.y /2;
   z := -_BoxSize.z /2;

   glTranslatef(_BoxPosition.X, _BoxPosition.Y, _BoxPosition.Z);

   // Draw Box.
   glNormal3f(0,0,0);
   glBegin(GL_QUADS);
      glVertex3f(x + _BoxSize.X, y,               z);
      glVertex3f(x + _BoxSize.X, y + _BoxSize.Y,  z);
      glVertex3f(x,              y + _BoxSize.Y,  z);
      glVertex3f(x,              y,               z);

      glVertex3f(x,	           y,              z + _BoxSize.Z);
      glVertex3f(x,              y + _BoxSize.Y, z + _BoxSize.Z);
      glVertex3f(x + _BoxSize.X, y + _BoxSize.Y, z + _BoxSize.Z);
      glVertex3f(x + _BoxSize.X, y,              z + _BoxSize.Z);

      glVertex3f(x,	           y, z);
      glVertex3f(x,	           y, z + _BoxSize.Z);
      glVertex3f(x + _BoxSize.X, y, z + _BoxSize.Z);
      glVertex3f(x + _BoxSize.X, y, z);

      glVertex3f(x + _BoxSize.X, y + _BoxSize.Y, z);
      glVertex3f(x + _BoxSize.X, y + _BoxSize.Y, z + _BoxSize.Z);
      glVertex3f(x,              y + _BoxSize.Y, z + _BoxSize.Z);
      glVertex3f(x,              y + _BoxSize.Y, z);

      glVertex3f(x, y + _BoxSize.Y, z);
      glVertex3f(x, y + _BoxSize.Y, z + _BoxSize.Z);
      glVertex3f(x, y,              z + _BoxSize.Z);
      glVertex3f(x, y,              z);

      glVertex3f(x + _BoxSize.X, y,              z);
      glVertex3f(x + _BoxSize.X, y,              z + _BoxSize.Z);
      glVertex3f(x + _BoxSize.X, y + _BoxSize.Y, z + _BoxSize.Z);
      glVertex3f(x + _BoxSize.X, y + _BoxSize.Y, z);
   glEnd;
end;

Procedure DrawBullet(_BulletPosition, _BulletSize : TVector3f);
var
   East,West,South,North,Ceil,Floor : single;
begin
   // Ensure that box ix centralized at _BoxPosition.
   East := _BulletPosition.X + _BulletSize.X/2;
   West := _BulletPosition.X - _BulletSize.X/ 2;
   Ceil := _BulletPosition.Y + _BulletSize.Y/2;
   Floor := _BulletPosition.Y - _BulletSize.Y/2;
   South := _BulletPosition.Z + _BulletSize.Z/2;
   North := _BulletPosition.Z - _BulletSize.Z/2;

   glColor4f(1, 1, 1, 1);
   glNormal3f(0, 0, 0);

   glBegin(GL_TRIANGLES);
      glVertex3f(_BulletPosition.X, _BulletPosition.Y, North);
	   glVertex3f(West, _BulletPosition.Y, _BulletPosition.Z);
      glVertex3f(_BulletPosition.X, Ceil, _BulletPosition.Z);

	   glVertex3f(_BulletPosition.X, _BulletPosition.Y, North);
      glVertex3f(West, _BulletPosition.Y, _BulletPosition.Z);
      glVertex3f(_BulletPosition.X, Floor, _BulletPosition.Z);

	   glVertex3f(West, _BulletPosition.Y, _BulletPosition.Z);
      glVertex3f(_BulletPosition.X, _BulletPosition.Y, South);
      glVertex3f(_BulletPosition.X, Ceil, _BulletPosition.Z);

      glVertex3f(West, _BulletPosition.Y, _BulletPosition.Z);
	   glVertex3f(_BulletPosition.X, _BulletPosition.Y, South);
      glVertex3f(_BulletPosition.X, Floor, _BulletPosition.Z);

	   glVertex3f(East, _BulletPosition.Y, _BulletPosition.Z);
      glVertex3f(_BulletPosition.X, _BulletPosition.Y, North);
      glVertex3f(_BulletPosition.X, Ceil, _BulletPosition.Z);

      glVertex3f(East, _BulletPosition.Y, _BulletPosition.Z);
	   glVertex3f(_BulletPosition.X, _BulletPosition.Y, North);
      glVertex3f(_BulletPosition.X, Floor, _BulletPosition.Z);

      glVertex3f(_BulletPosition.X, _BulletPosition.Y, South);
	   glVertex3f(East, _BulletPosition.Y, _BulletPosition.Z);
      glVertex3f(_BulletPosition.X, Ceil, _BulletPosition.Z);

	   glVertex3f(_BulletPosition.X, _BulletPosition.Y, South);
      glVertex3f(East, _BulletPosition.Y, _BulletPosition.Z);
      glVertex3f(_BulletPosition.X, Floor, _BulletPosition.Z);
   glEnd();
end;

Procedure DrawCenterLines(_CameraPosition, _CenterPosition, _CameraRotation : TVector3f);
begin
   If Axis = 2 then
      glColor4f(1,1,1,1)
   else
      glColor4f(0,0,1,1);
   DrawBox(_CameraPosition, _CenterPosition, _CameraRotation, SetVector(30, Size * 2, Size * 2));

   If Axis = 1 then
      glColor4f(1,1,1,1)
   else
      glColor4f(0,1,0,1);
   DrawBox(_CameraPosition, _CenterPosition, _CameraRotation, SetVector(Size * 2, Size * 2, 30));

   If Axis = 0 then
      glColor4f(1,1,1,1)
   else
      glColor4f(1,0,0,1);
   DrawBox(_CameraPosition, _CenterPosition, _CameraRotation, SetVector(Size * 2, 30, Size * 2));
end;

Procedure DrawBoundingBox(_CameraPosition, _CenterPosition, _CameraRotation, _BoundingSize : TVector3f);
begin
   glColor4f(1,1,1,0.2);
   DrawBox(_CameraPosition, _CenterPosition, _CameraRotation, _BoundingSize);
end;

Procedure DrawBoundingBox(const _Voxel: PVoxel; const _HVA: PHVA; const _Section, _Frame: integer; const _UnitShift: TVector3f; const _Rotation: single);
var
   StartPosition, CenterPosition, BoundingBoxSize: TVector3f;
begin
   StartPosition := GetSectionStartPosition(_Voxel, _HVA, _Section, _Frame, _UnitShift, TurretOffset, _Rotation, Size);
   CenterPosition := GetSectionCenterPosition(_Voxel, _HVA, _Section, _Frame, _UnitShift, TurretOffset, _Rotation, Size);
   BoundingBoxSize.X := (CenterPosition.X - StartPosition.X) * 2;
   BoundingBoxSize.Y := (CenterPosition.Y - StartPosition.Y) * 2;
   BoundingBoxSize.Z := (CenterPosition.Z - StartPosition.Z) * 2;
   DrawBoundingBox(SetVector(CameraCenter.X,CameraCenter.Y, Depth), CenterPosition, SetVector(XRot,0,YRot), BoundingBoxSize);
end;

Procedure DrawSectionCenterLines(const _Voxel: PVoxel; const _HVA: PHVA; const _Section, _Frame: integer; const _UnitShift: TVector3f; const _Rotation: single);
var
   Position: TVector3f;
begin
   Position := GetSectionCenterPosition(_Voxel, _HVA, _Section, _Frame, _UnitShift, TurretOffset, _Rotation, Size);
   DrawCenterLines(SetVector(CameraCenter.X,CameraCenter.Y, Depth), Position, SetVector(XRot,0,YRot));
end;

end.
