unit ActorActionController;

interface

uses ControllerDataTypes, BaseController, Actor, CommandBase, ControllerObjectItem;

type
   TActorActionController = class (TBaseController)
      // List all potential actions here (this list should be looong!).
      const
         // BuildUp/Modeling related commands
         C_ModelLoad = $10001;
         C_ModelRebuild = $10002;
         C_ModelRebuildLOD = $10003;
         // Mesh manipulation related methods
         C_MeshUnsharpMasking = $10101;
         C_MeshInflate = $10102;
         C_MeshDeflate = $10103;
         // Mesh normals manipulation related methods
         C_MeshRecalculateNormals = $10201;
         C_MeshSetFaceNormals = $10202;
         C_MeshSetVertexNormals = $10203;
         // Mesh colors manipulation related methods
         C_MeshSetFaceColours = $10302;
         C_MeshSetVertexColours = $10303;
         // Mesh smooth related commands
         C_MeshSmoothSBGamesDraft = $10401;
         C_MeshSmoothSBGames = $10402;
         C_MeshSmoothGaussian = $10403;
         C_MeshSmoothMasters = $10404;
         // Mesh normals smooth related commands
         C_MeshSmoothVertexNormals = $10501;
         C_MeshSmoothFaceNormals = $10502;
         // Mesh colors smooth related commands
         C_MeshSmoothVertexColours = $10601;
         C_MeshSmoothFaceColours = $10602;
         // Mesh optimization related commands
         C_MeshOptimization2009 = $10701;
         // Mesh format changes
         C_MeshConvertQuadsToTris = $10801;
         C_MeshConvertQuadsTo48Tris = $10802;
         // Game related attributes
         C_ModelChangeRemappable = $10901;
         // Texture related commands
         C_TextureAtlasExtraction = $10A01;
         C_TextureAtlasExtractionOrigami = $10A02;
         C_TextureAtlasExtractionOrigamiGA = $10A03;
         C_DiffuseTextureGeneration = $10A04;
         C_NormalMappingTextureGeneration = $10A05;
         C_BumpMappingTextureGeneration = $10A06;
         C_DiffuseDebugTextureGeneration = $10A07;

         // Execute goes here.
         procedure ExecuteCommand(_CommandType: integer; _ObjectID: TObjectID; _Parameters: TCommandParams); override;

         // Misc
         procedure TerminateObject(_Item: TControllerObjectItem); override;
      public
         // Constructors and Destructors.
         destructor Destroy; override;

         // Sets.
         procedure SetBaseObject(const _Actor: PActor);

         // Issue commands.
         procedure DoLoadModel(var _Actor: PActor; _Quality: integer);
         procedure DoRebuildModel(var _Actor: PActor; _Quality: integer);
         procedure DoRebuildModelLOD(var _Actor: PActor; _Quality: integer; _LODID: integer);
         procedure DoMeshUnsharpMasking(var _Actor: PActor);
         procedure DoMeshInflate(var _Actor: PActor);
         procedure DoMeshDeflate(var _Actor: PActor);
         procedure DoRecalculateNormals(var _Actor: PActor);
         procedure DoSetFaceNormals(var _Actor: PActor);
         procedure DoSetVertexNormals(var _Actor: PActor);
         procedure DoSetFaceColours(var _Actor: PActor; _DistanceFormula: integer);
         procedure DoSetVertexColours(var _Actor: PActor; _DistanceFormula: integer);
         procedure DoMeshSmoothSBGamesDraft(var _Actor: PActor; _DistanceFormula: integer);
         procedure DoMeshSmoothSBGames(var _Actor: PActor; _DistanceFormula: integer);
         procedure DoMeshSmoothMasters(var _Actor: PActor; _DistanceFormula: integer);
         procedure DoMeshSmoothGaussian(var _Actor: PActor);
         procedure DoSmoothFaceNormals(var _Actor: PActor; _DistanceFormula: integer);
         procedure DoSmoothVertexNormals(var _Actor: PActor; _DistanceFormula: integer);
         procedure DoSmoothFaceColours(var _Actor: PActor; _DistanceFormula: integer);
         procedure DoSmoothVertexColours(var _Actor: PActor; _DistanceFormula: integer);
         procedure DoConvertQuadsToTris(var _Actor: PActor);
         procedure DoConvertQuadsToTris48(var _Actor: PActor);
         procedure DoTextureAtlasExtraction(var _Actor: PActor; _Size: integer; _Angle: single);
         procedure DoTextureAtlasExtractionOrigami(var _Actor: PActor; _Size: integer);
         procedure DoTextureAtlasExtractionOrigamiGA(var _Actor: PActor; _Size: integer);
         procedure DoDiffuseTextureGeneration(var _Actor: PActor; _Size: integer; _MaterialID: integer; _TextureID: integer);
         procedure DoNormalMappingTextureGeneration(var _Actor: PActor; _Size: integer; _MaterialID: integer; _TextureID: integer);
         procedure DoBumpMappingTextureGeneration(var _Actor: PActor; _Size: integer; _MaterialID: integer; _TextureID: integer; _Scale: single);
         procedure DoDiffuseDebugTextureGeneration(var _Actor: PActor; _Size: integer; _MaterialID: integer; _TextureID: integer);
         procedure DoMeshOptimization2009(var _Actor: PActor; _IgnoreColours: boolean; _Angle: single);
         procedure DoModelChangeRemappable(var _Actor: PActor; _Quality: integer; _Colour: integer);
   end;

implementation

uses GlobalVars, ActorActionCommandBase, TextureAtlasExtractorCommand,
   TextureAtlasExtractorOrigamiCommand, TextureAtlasExtractorOrigamiGACommand,
   DiffuseTextureGeneratorCommand, NormalMapTextureGeneratorCommand,
   BumpMapTextureGeneratorCommand, MeshSmoothSBGamesDraftCommand,
   MeshSmoothSBGamesCommand, MeshSmoothGaussianCommand, MeshSmoothMastersCommand,
   MeshUnsharpMaskingCommand, MeshInflateCommand, MeshDeflateCommand,
   MeshSmoothVertexNormalsCommand, MeshSmoothFaceNormalsCommand,
   MeshSmoothVertexColoursCommand, MeshSmoothFaceColoursCommand, ModelLoadCommand,
   MeshConvertQuadsToTrisCommand, MeshConvertQuadsTo48TrisCommand,
   MeshRecalculateNormalsCommand, MeshSetVertexNormalsCommand, ModelRebuildLODCommand,
   MeshSetFaceNormalsCommand, MeshSetVertexColoursCommand, MeshSetFaceColoursCommand,
   ModelRebuildCommand, DiffuseDebugTextureGeneratorCommand,
   MeshOptimization2009Command, ModelChangeRemappableCommand;


// Constructors and Destructors
destructor TActorActionController.Destroy;
var
   Item: TControllerObjectItem;
   i, maxi: integer;
begin
   maxi := Objects.NumItems - 1;
   for i := 0 to maxi do
   begin
      if (Objects.Objects[i].BaseObjectID <> nil) then
      begin
         TActor(Objects.Objects[i].BaseObjectID^).Free;
      end;
   end;
   inherited Destroy;
end;

// Execute goes here.
procedure TActorActionController.ExecuteCommand(_CommandType: integer; _ObjectID: TObjectID; _Parameters: TCommandParams);
var
   Actor: TActor;
   Command : TActorActionCommandBase;
begin
   Actor := TActor(_ObjectID^);
   if Actor = nil then
   begin
      exit;
   end;
   case (_CommandType) of
      C_ModelLoad:
      begin
         Command := TModelLoadCommand.Create(Actor,_Parameters);
      end;
      C_ModelRebuild:
      begin
         Command := TModelRebuildCommand.Create(Actor,_Parameters);
      end;
      C_ModelRebuildLOD:
      begin
         Command := TModelRebuildLODCommand.Create(Actor,_Parameters);
      end;
      C_TextureAtlasExtraction:
      begin
         Command := TTextureAtlasExtractorCommand.Create(Actor,_Parameters);
      end;
      C_TextureAtlasExtractionOrigami:
      begin
         Command := TTextureAtlasExtractorOrigamiCommand.Create(Actor,_Parameters);
      end;
      C_TextureAtlasExtractionOrigamiGA:
      begin
         Command := TTextureAtlasExtractorOrigamiGACommand.Create(Actor,_Parameters);
      end;
      C_DiffuseTextureGeneration:
      begin
         Command := TDiffuseTextureGeneratorCommand.Create(Actor,_Parameters);
      end;
      C_DiffuseDebugTextureGeneration:
      begin
         Command := TDiffuseDebugTextureGeneratorCommand.Create(Actor,_Parameters);
      end;
      C_NormalMappingTextureGeneration:
      begin
         Command := TNormalMapTextureGeneratorCommand.Create(Actor,_Parameters);
      end;
      C_BumpMappingTextureGeneration:
      begin
         Command := TBumpMapTextureGeneratorCommand.Create(Actor,_Parameters);
      end;
      C_MeshSmoothSBGamesDraft:
      begin
         Command := TMeshSmoothSBGamesDraftCommand.Create(Actor,_Parameters);
      end;
      C_MeshSmoothSBGames:
      begin
         Command := TMeshSmoothSBGamesCommand.Create(Actor,_Parameters);
      end;
      C_MeshSmoothGaussian:
      begin
         Command := TMeshSmoothGaussianCommand.Create(Actor,_Parameters);
      end;
      C_MeshSmoothMasters:
      begin
         Command := TMeshSmoothMastersCommand.Create(Actor,_Parameters);
      end;
      C_MeshUnsharpMasking:
      begin
         Command := TMeshUnsharpMaskingCommand.Create(Actor,_Parameters);
      end;
      C_MeshInflate:
      begin
         Command := TMeshInflateCommand.Create(Actor,_Parameters);
      end;
      C_MeshDeflate:
      begin
         Command := TMeshDeflateCommand.Create(Actor,_Parameters);
      end;
      C_MeshRecalculateNormals:
      begin
         Command := TMeshRecalculateNormalsCommand.Create(Actor,_Parameters);
      end;
      C_MeshSetVertexNormals:
      begin
         Command := TMeshSetVertexNormalsCommand.Create(Actor,_Parameters);
      end;
      C_MeshSetFaceNormals:
      begin
         Command := TMeshSetFaceNormalsCommand.Create(Actor,_Parameters);
      end;
      C_MeshSmoothVertexNormals:
      begin
         Command := TMeshSmoothVertexNormalsCommand.Create(Actor,_Parameters);
      end;
      C_MeshSmoothFaceNormals:
      begin
         Command := TMeshSmoothFaceNormalsCommand.Create(Actor,_Parameters);
      end;
      C_MeshSetVertexColours:
      begin
         Command := TMeshSetVertexColoursCommand.Create(Actor,_Parameters);
      end;
      C_MeshSetFaceColours:
      begin
         Command := TMeshSetFaceColoursCommand.Create(Actor,_Parameters);
      end;
      C_MeshSmoothVertexColours:
      begin
         Command := TMeshSmoothVertexColoursCommand.Create(Actor,_Parameters);
      end;
      C_MeshSmoothFaceColours:
      begin
         Command := TMeshSmoothFaceColoursCommand.Create(Actor,_Parameters);
      end;
      C_MeshConvertQuadsToTris:
      begin
         Command := TMeshConvertQuadsToTrisCommand.Create(Actor,_Parameters);
      end;
      C_MeshConvertQuadsTo48Tris:
      begin
         Command := TMeshConvertQuadsTo48TrisCommand.Create(Actor,_Parameters);
      end;
      C_MeshOptimization2009:
      begin
         Command := TMeshOptmization2009Command.Create(Actor,_Parameters);
      end;
      C_ModelChangeRemappable:
      begin
         Command := TModelChangeRemappableCommand.Create(Actor,_Parameters);
      end
      else
      begin
         // do nothing;
         exit;
      end;
   end;
   Command.Execute;
   Command.Free;
   Actor.Refresh;
end;

// Sets.
procedure TActorActionController.SetBaseObject(const _Actor: PActor);
var
   Actor: PActor;
   Item: TControllerObjectItem;
begin
   // Create the base object.
   new(Actor);
   Actor^ := TActor.Create(_Actor^.ShaderBank);
   Actor^.AssignForBackup(_Actor^);

   // Let's find the object.
   Item := Objects.Item[_Actor];

   // Now we set the base object;
   Item.BaseObjectID := Actor;
end;

// Misc
procedure TActorActionController.TerminateObject(_Item: TControllerObjectItem);
begin
   if (_Item.BaseObjectID <> nil) then
   begin
      TActor(_Item.BaseObjectID^).Free;
      _Item.BaseObjectID := nil;
   end;
   inherited TerminateObject(_Item);
end;

// -----------------------------------------------------------------------------
// The set of commands start here.
// -----------------------------------------------------------------------------
procedure TActorActionController.DoLoadModel(var _Actor: PActor; _Quality: integer);
begin
   SendCommand1Int(C_ModelLoad, _Actor, _Quality);
end;

procedure TActorActionController.DoRebuildModel(var _Actor: PActor; _Quality: integer);
begin
   SendCommand1Int(C_ModelRebuild, _Actor, _Quality);
end;

procedure TActorActionController.DoRebuildModelLOD(var _Actor: PActor; _Quality: integer; _LODID: integer);
begin
   SendCommand2Int(C_ModelRebuildLOD, _Actor, _Quality, _LODID);
end;

procedure TActorActionController.DoMeshUnsharpMasking(var _Actor: PActor);
begin
   SendCommandNoParams(C_MeshUnsharpMasking, _Actor);
end;

procedure TActorActionController.DoMeshInflate(var _Actor: PActor);
begin
   SendCommandNoParams(C_MeshInflate, _Actor);
end;

procedure TActorActionController.DoMeshDeflate(var _Actor: PActor);
begin
   SendCommandNoParams(C_MeshDeflate, _Actor);
end;

procedure TActorActionController.DoRecalculateNormals(var _Actor: PActor);
begin
   SendCommandNoParams(C_MeshRecalculateNormals, _Actor);
end;

procedure TActorActionController.DoSetFaceNormals(var _Actor: PActor);
begin
   SendCommandNoParams(C_MeshSetFaceNormals, _Actor);
end;

procedure TActorActionController.DoSetVertexNormals(var _Actor: PActor);
begin
   SendCommandNoParams(C_MeshSetVertexNormals, _Actor);
end;

procedure TActorActionController.DoSetFaceColours(var _Actor: PActor; _DistanceFormula: integer);
begin
   SendCommand1Int(C_MeshSetFaceColours, _Actor, _DistanceFormula);
end;

procedure TActorActionController.DoSetVertexColours(var _Actor: PActor; _DistanceFormula: integer);
begin
   SendCommand1Int(C_MeshSetVertexColours, _Actor, _DistanceFormula);
end;

procedure TActorActionController.DoMeshSmoothSBGamesDraft(var _Actor: PActor; _DistanceFormula: integer);
begin
   SendCommand1Int(C_MeshSmoothSBGamesDraft, _Actor, _DistanceFormula);
end;

procedure TActorActionController.DoMeshSmoothSBGames(var _Actor: PActor; _DistanceFormula: integer);
begin
   SendCommand1Int(C_MeshSmoothSBGames, _Actor, _DistanceFormula);
end;

procedure TActorActionController.DoMeshSmoothMasters(var _Actor: PActor; _DistanceFormula: integer);
begin
   SendCommand1Int(C_MeshSmoothMasters, _Actor, _DistanceFormula);
end;

procedure TActorActionController.DoMeshSmoothGaussian(var _Actor: PActor);
begin
   SendCommandNoParams(C_MeshSmoothGaussian, _Actor);
end;

procedure TActorActionController.DoSmoothFaceNormals(var _Actor: PActor; _DistanceFormula: integer);
begin
   SendCommand1Int(C_MeshSmoothFaceNormals, _Actor, _DistanceFormula);
end;

procedure TActorActionController.DoSmoothVertexNormals(var _Actor: PActor; _DistanceFormula: integer);
begin
   SendCommand1Int(C_MeshSmoothVertexNormals, _Actor, _DistanceFormula);
end;

procedure TActorActionController.DoSmoothFaceColours(var _Actor: PActor; _DistanceFormula: integer);
begin
   SendCommand1Int(C_MeshSmoothFaceColours, _Actor, _DistanceFormula);
end;

procedure TActorActionController.DoSmoothVertexColours(var _Actor: PActor; _DistanceFormula: integer);
begin
   SendCommand1Int(C_MeshSmoothVertexColours, _Actor, _DistanceFormula);
end;

procedure TActorActionController.DoConvertQuadsToTris(var _Actor: PActor);
begin
   SendCommandNoParams(C_MeshConvertQuadsToTris, _Actor);
end;

procedure TActorActionController.DoConvertQuadsToTris48(var _Actor: PActor);
begin
   SendCommandNoParams(C_MeshConvertQuadsTo48Tris, _Actor);
end;

procedure TActorActionController.DoTextureAtlasExtraction(var _Actor: PActor; _Size: integer; _Angle: single);
begin
   SendCommand1Int1Single(C_TextureAtlasExtraction, _Actor, _Size, _Angle);
end;

procedure TActorActionController.DoTextureAtlasExtractionOrigami(var _Actor: PActor; _Size: integer);
begin
   SendCommand1Int(C_TextureAtlasExtractionOrigami, _Actor, _Size);
end;

procedure TActorActionController.DoTextureAtlasExtractionOrigamiGA(var _Actor: PActor; _Size: integer);
begin
   SendCommand1Int(C_TextureAtlasExtractionOrigamiGA, _Actor, _Size);
end;

procedure TActorActionController.DoDiffuseTextureGeneration(var _Actor: PActor; _Size: integer; _MaterialID: integer; _TextureID: integer);
begin
   SendCommand3Int(C_DiffuseTextureGeneration, _Actor, _Size, _MaterialID, _TextureID);
end;

procedure TActorActionController.DoNormalMappingTextureGeneration(var _Actor: PActor; _Size: integer; _MaterialID: integer; _TextureID: integer);
begin
   SendCommand3Int(C_NormalMappingTextureGeneration, _Actor, _Size, _MaterialID, _TextureID);
end;

procedure TActorActionController.DoBumpMappingTextureGeneration(var _Actor: PActor; _Size: integer; _MaterialID: integer; _TextureID: integer; _Scale: single);
begin
   SendCommand3Int1Single(C_NormalMappingTextureGeneration, _Actor, _Size, _MaterialID, _TextureID, _Scale);
end;

procedure TActorActionController.DoDiffuseDebugTextureGeneration(var _Actor: PActor; _Size: integer; _MaterialID: integer; _TextureID: integer);
begin
   SendCommand3Int(C_DiffuseDebugTextureGeneration, _Actor, _Size, _MaterialID, _TextureID);
end;

procedure TActorActionController.DoMeshOptimization2009(var _Actor: PActor; _IgnoreColours: boolean; _Angle: single);
begin
   SendCommand1Bool1Single(C_MeshOptimization2009, _Actor, _IgnoreColours, _Angle);
end;

procedure TActorActionController.DoModelChangeRemappable(var _Actor: PActor; _Quality: integer; _Colour: integer);
begin
   SendCommand2Int(C_ModelChangeRemappable, _Actor, _Quality, _Colour);
end;

end.
