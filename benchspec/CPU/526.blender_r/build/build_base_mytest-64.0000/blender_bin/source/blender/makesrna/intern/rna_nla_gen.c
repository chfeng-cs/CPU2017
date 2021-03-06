
/* Automatically generated struct definitions for the Data API.
 * Do not edit manually, changes will be overwritten.           */
#if defined(SPEC)
#include <spec_config.h>
#endif

#define RNA_RUNTIME

#include <float.h>
#include <stdio.h>
#include <limits.h>
#include <string.h>

#include <stddef.h>

#include "MEM_guardedalloc.h"

#include "DNA_ID.h"
#include "DNA_scene_types.h"
#include "BLI_blenlib.h"

#include "BLI_utildefines.h"

#include "BKE_context.h"
#include "BKE_library.h"
#include "BKE_main.h"
#include "BKE_report.h"
#include "RNA_define.h"
#include "RNA_types.h"
#include "rna_internal.h"

extern StructRNA RNA_Struct;
extern StructRNA RNA_Property;
extern StructRNA RNA_BoolProperty;
extern StructRNA RNA_IntProperty;
extern StructRNA RNA_FloatProperty;
extern StructRNA RNA_StringProperty;
extern StructRNA RNA_EnumProperty;
extern StructRNA RNA_EnumPropertyItem;
extern StructRNA RNA_PointerProperty;
extern StructRNA RNA_CollectionProperty;
extern StructRNA RNA_Function;
extern StructRNA RNA_BlenderRNA;
extern StructRNA RNA_UnknownType;
extern StructRNA RNA_AnyType;
extern StructRNA RNA_ID;
extern StructRNA RNA_PropertyGroupItem;
extern StructRNA RNA_PropertyGroup;
extern StructRNA RNA_IDMaterials;
extern StructRNA RNA_Library;
extern StructRNA RNA_Texture;
extern StructRNA RNA_CloudsTexture;
extern StructRNA RNA_WoodTexture;
extern StructRNA RNA_MarbleTexture;
extern StructRNA RNA_MagicTexture;
extern StructRNA RNA_BlendTexture;
extern StructRNA RNA_StucciTexture;
extern StructRNA RNA_NoiseTexture;
extern StructRNA RNA_ImageTexture;
extern StructRNA RNA_EnvironmentMapTexture;
extern StructRNA RNA_MusgraveTexture;
extern StructRNA RNA_VoronoiTexture;
extern StructRNA RNA_DistortedNoiseTexture;
extern StructRNA RNA_PointDensity;
extern StructRNA RNA_PointDensityTexture;
extern StructRNA RNA_VoxelData;
extern StructRNA RNA_VoxelDataTexture;
extern StructRNA RNA_OceanTexData;
extern StructRNA RNA_OceanTexture;
extern StructRNA RNA_TextureSlot;
extern StructRNA RNA_EnvironmentMap;
extern StructRNA RNA_TexMapping;
extern StructRNA RNA_ColorMapping;
extern StructRNA RNA_Action;
extern StructRNA RNA_ActionFCurves;
extern StructRNA RNA_ActionGroups;
extern StructRNA RNA_ActionPoseMarkers;
extern StructRNA RNA_ActionGroup;
extern StructRNA RNA_DopeSheet;
extern StructRNA RNA_AnimData;
extern StructRNA RNA_NlaTracks;
extern StructRNA RNA_AnimDataDrivers;
extern StructRNA RNA_KeyingSet;
extern StructRNA RNA_KeyingSetPaths;
extern StructRNA RNA_KeyingSetPath;
extern StructRNA RNA_KeyingSetInfo;
extern StructRNA RNA_AnimViz;
extern StructRNA RNA_AnimVizOnionSkinning;
extern StructRNA RNA_AnimVizMotionPaths;
extern StructRNA RNA_MotionPath;
extern StructRNA RNA_MotionPathVert;
extern StructRNA RNA_Actuator;
extern StructRNA RNA_ActionActuator;
extern StructRNA RNA_ObjectActuator;
extern StructRNA RNA_CameraActuator;
extern StructRNA RNA_SoundActuator;
extern StructRNA RNA_PropertyActuator;
extern StructRNA RNA_ConstraintActuator;
extern StructRNA RNA_EditObjectActuator;
extern StructRNA RNA_SceneActuator;
extern StructRNA RNA_RandomActuator;
extern StructRNA RNA_MessageActuator;
extern StructRNA RNA_GameActuator;
extern StructRNA RNA_VisibilityActuator;
extern StructRNA RNA_Filter2DActuator;
extern StructRNA RNA_ParentActuator;
extern StructRNA RNA_StateActuator;
extern StructRNA RNA_ArmatureActuator;
extern StructRNA RNA_SteeringActuator;
extern StructRNA RNA_MouseActuator;
extern StructRNA RNA_Armature;
extern StructRNA RNA_ArmatureBones;
extern StructRNA RNA_ArmatureEditBones;
extern StructRNA RNA_Bone;
extern StructRNA RNA_EditBone;
extern StructRNA RNA_BoidRule;
extern StructRNA RNA_BoidRuleGoal;
extern StructRNA RNA_BoidRuleAvoid;
extern StructRNA RNA_BoidRuleAvoidCollision;
extern StructRNA RNA_BoidRuleFollowLeader;
extern StructRNA RNA_BoidRuleAverageSpeed;
extern StructRNA RNA_BoidRuleFight;
extern StructRNA RNA_BoidState;
extern StructRNA RNA_BoidSettings;
extern StructRNA RNA_Brush;
extern StructRNA RNA_BrushCapabilities;
extern StructRNA RNA_SculptToolCapabilities;
extern StructRNA RNA_ImapaintToolCapabilities;
extern StructRNA RNA_BrushTextureSlot;
extern StructRNA RNA_OperatorStrokeElement;
extern StructRNA RNA_Camera;
extern StructRNA RNA_ClothSettings;
extern StructRNA RNA_ClothCollisionSettings;
extern StructRNA RNA_CurveMapPoint;
extern StructRNA RNA_CurveMap;
extern StructRNA RNA_CurveMapPoints;
extern StructRNA RNA_CurveMapping;
extern StructRNA RNA_ColorRampElement;
extern StructRNA RNA_ColorRamp;
extern StructRNA RNA_ColorRampElements;
extern StructRNA RNA_Histogram;
extern StructRNA RNA_Scopes;
extern StructRNA RNA_ColorManagedDisplaySettings;
extern StructRNA RNA_ColorManagedViewSettings;
extern StructRNA RNA_ColorManagedInputColorspaceSettings;
extern StructRNA RNA_ColorManagedSequencerColorspaceSettings;
extern StructRNA RNA_Constraint;
extern StructRNA RNA_ConstraintTarget;
extern StructRNA RNA_ChildOfConstraint;
extern StructRNA RNA_PythonConstraint;
extern StructRNA RNA_StretchToConstraint;
extern StructRNA RNA_FollowPathConstraint;
extern StructRNA RNA_LockedTrackConstraint;
extern StructRNA RNA_ActionConstraint;
extern StructRNA RNA_CopyScaleConstraint;
extern StructRNA RNA_MaintainVolumeConstraint;
extern StructRNA RNA_CopyLocationConstraint;
extern StructRNA RNA_CopyRotationConstraint;
extern StructRNA RNA_CopyTransformsConstraint;
extern StructRNA RNA_FloorConstraint;
extern StructRNA RNA_TrackToConstraint;
extern StructRNA RNA_KinematicConstraint;
extern StructRNA RNA_RigidBodyJointConstraint;
extern StructRNA RNA_ClampToConstraint;
extern StructRNA RNA_LimitDistanceConstraint;
extern StructRNA RNA_LimitScaleConstraint;
extern StructRNA RNA_LimitRotationConstraint;
extern StructRNA RNA_LimitLocationConstraint;
extern StructRNA RNA_TransformConstraint;
extern StructRNA RNA_ShrinkwrapConstraint;
extern StructRNA RNA_DampedTrackConstraint;
extern StructRNA RNA_SplineIKConstraint;
extern StructRNA RNA_PivotConstraint;
extern StructRNA RNA_FollowTrackConstraint;
extern StructRNA RNA_CameraSolverConstraint;
extern StructRNA RNA_ObjectSolverConstraint;
extern StructRNA RNA_Context;
extern StructRNA RNA_Controller;
extern StructRNA RNA_ExpressionController;
extern StructRNA RNA_PythonController;
extern StructRNA RNA_AndController;
extern StructRNA RNA_OrController;
extern StructRNA RNA_NorController;
extern StructRNA RNA_NandController;
extern StructRNA RNA_XorController;
extern StructRNA RNA_XnorController;
extern StructRNA RNA_Curve;
extern StructRNA RNA_CurveSplines;
extern StructRNA RNA_SurfaceCurve;
extern StructRNA RNA_TextCurve;
extern StructRNA RNA_TextBox;
extern StructRNA RNA_TextCharacterFormat;
extern StructRNA RNA_SplinePoint;
extern StructRNA RNA_BezierSplinePoint;
extern StructRNA RNA_Spline;
extern StructRNA RNA_SplinePoints;
extern StructRNA RNA_SplineBezierPoints;
extern StructRNA RNA_DynamicPaintCanvasSettings;
extern StructRNA RNA_DynamicPaintSurfaces;
extern StructRNA RNA_DynamicPaintBrushSettings;
extern StructRNA RNA_DynamicPaintSurface;
extern StructRNA RNA_FCurve;
extern StructRNA RNA_FCurveKeyframePoints;
extern StructRNA RNA_FCurveModifiers;
extern StructRNA RNA_Keyframe;
extern StructRNA RNA_FCurveSample;
extern StructRNA RNA_DriverTarget;
extern StructRNA RNA_DriverVariable;
extern StructRNA RNA_Driver;
extern StructRNA RNA_ChannelDriverVariables;
extern StructRNA RNA_FModifier;
extern StructRNA RNA_FModifierGenerator;
extern StructRNA RNA_FModifierFunctionGenerator;
extern StructRNA RNA_FModifierEnvelope;
extern StructRNA RNA_FModifierEnvelopeControlPoints;
extern StructRNA RNA_FModifierEnvelopeControlPoint;
extern StructRNA RNA_FModifierCycles;
extern StructRNA RNA_FModifierPython;
extern StructRNA RNA_FModifierLimits;
extern StructRNA RNA_FModifierNoise;
extern StructRNA RNA_FModifierStepped;
extern StructRNA RNA_FluidSettings;
extern StructRNA RNA_DomainFluidSettings;
extern StructRNA RNA_FluidMeshVertex;
extern StructRNA RNA_FluidFluidSettings;
extern StructRNA RNA_ObstacleFluidSettings;
extern StructRNA RNA_InflowFluidSettings;
extern StructRNA RNA_OutflowFluidSettings;
extern StructRNA RNA_ParticleFluidSettings;
extern StructRNA RNA_ControlFluidSettings;
extern StructRNA RNA_GreasePencil;
extern StructRNA RNA_GreasePencilLayers;
extern StructRNA RNA_GPencilLayer;
extern StructRNA RNA_GPencilFrames;
extern StructRNA RNA_GPencilFrame;
extern StructRNA RNA_GPencilStrokes;
extern StructRNA RNA_GPencilStroke;
extern StructRNA RNA_GPencilStrokePoints;
extern StructRNA RNA_GPencilStrokePoint;
extern StructRNA RNA_Group;
extern StructRNA RNA_GroupObjects;
extern StructRNA RNA_RenderSlot;
extern StructRNA RNA_RenderSlots;
extern StructRNA RNA_Image;
extern StructRNA RNA_ImageUser;
extern StructRNA RNA_Key;
extern StructRNA RNA_ShapeKey;
extern StructRNA RNA_ShapeKeyPoint;
extern StructRNA RNA_ShapeKeyCurvePoint;
extern StructRNA RNA_ShapeKeyBezierPoint;
extern StructRNA RNA_Lamp;
extern StructRNA RNA_LampTextureSlots;
extern StructRNA RNA_PointLamp;
extern StructRNA RNA_AreaLamp;
extern StructRNA RNA_SpotLamp;
extern StructRNA RNA_SunLamp;
extern StructRNA RNA_LampSkySettings;
extern StructRNA RNA_HemiLamp;
extern StructRNA RNA_LampTextureSlot;
extern StructRNA RNA_Lattice;
extern StructRNA RNA_LatticePoint;
extern StructRNA RNA_LineStyleModifier;
extern StructRNA RNA_LineStyleColorModifier;
extern StructRNA RNA_LineStyleColorModifier_AlongStroke;
extern StructRNA RNA_LineStyleColorModifier_DistanceFromCamera;
extern StructRNA RNA_LineStyleColorModifier_DistanceFromObject;
extern StructRNA RNA_LineStyleColorModifier_Material;
extern StructRNA RNA_LineStyleAlphaModifier;
extern StructRNA RNA_LineStyleAlphaModifier_AlongStroke;
extern StructRNA RNA_LineStyleAlphaModifier_DistanceFromCamera;
extern StructRNA RNA_LineStyleAlphaModifier_DistanceFromObject;
extern StructRNA RNA_LineStyleAlphaModifier_Material;
extern StructRNA RNA_LineStyleThicknessModifier;
extern StructRNA RNA_LineStyleThicknessModifier_AlongStroke;
extern StructRNA RNA_LineStyleThicknessModifier_DistanceFromCamera;
extern StructRNA RNA_LineStyleThicknessModifier_DistanceFromObject;
extern StructRNA RNA_LineStyleThicknessModifier_Material;
extern StructRNA RNA_LineStyleThicknessModifier_Calligraphy;
extern StructRNA RNA_LineStyleGeometryModifier;
extern StructRNA RNA_LineStyleGeometryModifier_Sampling;
extern StructRNA RNA_LineStyleGeometryModifier_BezierCurve;
extern StructRNA RNA_LineStyleGeometryModifier_SinusDisplacement;
extern StructRNA RNA_LineStyleGeometryModifier_SpatialNoise;
extern StructRNA RNA_LineStyleGeometryModifier_PerlinNoise1D;
extern StructRNA RNA_LineStyleGeometryModifier_PerlinNoise2D;
extern StructRNA RNA_LineStyleGeometryModifier_BackboneStretcher;
extern StructRNA RNA_LineStyleGeometryModifier_TipRemover;
extern StructRNA RNA_LineStyleGeometryModifier_Polygonalization;
extern StructRNA RNA_LineStyleGeometryModifier_GuidingLines;
extern StructRNA RNA_LineStyleGeometryModifier_Blueprint;
extern StructRNA RNA_LineStyleGeometryModifier_2DOffset;
extern StructRNA RNA_LineStyleGeometryModifier_2DTransform;
extern StructRNA RNA_FreestyleLineStyle;
extern StructRNA RNA_LineStyleTextureSlots;
extern StructRNA RNA_LineStyleColorModifiers;
extern StructRNA RNA_LineStyleAlphaModifiers;
extern StructRNA RNA_LineStyleThicknessModifiers;
extern StructRNA RNA_LineStyleGeometryModifiers;
extern StructRNA RNA_LineStyleTextureSlot;
extern StructRNA RNA_BlendData;
extern StructRNA RNA_BlendDataCameras;
extern StructRNA RNA_BlendDataScenes;
extern StructRNA RNA_BlendDataObjects;
extern StructRNA RNA_BlendDataMaterials;
extern StructRNA RNA_BlendDataNodeTrees;
extern StructRNA RNA_BlendDataMeshes;
extern StructRNA RNA_BlendDataLamps;
extern StructRNA RNA_BlendDataLibraries;
extern StructRNA RNA_BlendDataScreens;
extern StructRNA RNA_BlendDataWindowManagers;
extern StructRNA RNA_BlendDataImages;
extern StructRNA RNA_BlendDataLattices;
extern StructRNA RNA_BlendDataCurves;
extern StructRNA RNA_BlendDataMetaBalls;
extern StructRNA RNA_BlendDataFonts;
extern StructRNA RNA_BlendDataTextures;
extern StructRNA RNA_BlendDataBrushes;
extern StructRNA RNA_BlendDataWorlds;
extern StructRNA RNA_BlendDataGroups;
extern StructRNA RNA_BlendDataTexts;
extern StructRNA RNA_BlendDataSpeakers;
extern StructRNA RNA_BlendDataSounds;
extern StructRNA RNA_BlendDataArmatures;
extern StructRNA RNA_BlendDataActions;
extern StructRNA RNA_BlendDataParticles;
extern StructRNA RNA_BlendDataGreasePencils;
extern StructRNA RNA_BlendDataMovieClips;
extern StructRNA RNA_BlendDataMasks;
extern StructRNA RNA_BlendDataLineStyles;
extern StructRNA RNA_Material;
extern StructRNA RNA_MaterialTextureSlots;
extern StructRNA RNA_TexPaintSlot;
extern StructRNA RNA_MaterialRaytraceMirror;
extern StructRNA RNA_MaterialRaytraceTransparency;
extern StructRNA RNA_MaterialVolume;
extern StructRNA RNA_MaterialHalo;
extern StructRNA RNA_MaterialSubsurfaceScattering;
extern StructRNA RNA_MaterialTextureSlot;
extern StructRNA RNA_MaterialStrand;
extern StructRNA RNA_MaterialPhysics;
extern StructRNA RNA_MaterialGameSettings;
extern StructRNA RNA_Mesh;
extern StructRNA RNA_MeshVertices;
extern StructRNA RNA_MeshEdges;
extern StructRNA RNA_MeshTessFaces;
extern StructRNA RNA_MeshLoops;
extern StructRNA RNA_MeshPolygons;
extern StructRNA RNA_UVLoopLayers;
extern StructRNA RNA_TessfaceUVTextures;
extern StructRNA RNA_UVTextures;
extern StructRNA RNA_VertexColors;
extern StructRNA RNA_LoopColors;
extern StructRNA RNA_FloatProperties;
extern StructRNA RNA_IntProperties;
extern StructRNA RNA_StringProperties;
extern StructRNA RNA_MeshSkinVertexLayer;
extern StructRNA RNA_MeshSkinVertex;
extern StructRNA RNA_MeshVertex;
extern StructRNA RNA_VertexGroupElement;
extern StructRNA RNA_MeshEdge;
extern StructRNA RNA_MeshTessFace;
extern StructRNA RNA_MeshLoop;
extern StructRNA RNA_MeshPolygon;
extern StructRNA RNA_MeshUVLoopLayer;
extern StructRNA RNA_MeshUVLoop;
extern StructRNA RNA_MeshTextureFaceLayer;
extern StructRNA RNA_MeshTextureFace;
extern StructRNA RNA_MeshTexturePolyLayer;
extern StructRNA RNA_MeshTexturePoly;
extern StructRNA RNA_MeshColorLayer;
extern StructRNA RNA_MeshColor;
extern StructRNA RNA_MeshLoopColorLayer;
extern StructRNA RNA_MeshLoopColor;
extern StructRNA RNA_MeshFloatPropertyLayer;
extern StructRNA RNA_MeshFloatProperty;
extern StructRNA RNA_MeshIntPropertyLayer;
extern StructRNA RNA_MeshIntProperty;
extern StructRNA RNA_MeshStringPropertyLayer;
extern StructRNA RNA_MeshStringProperty;
extern StructRNA RNA_MetaElement;
extern StructRNA RNA_MetaBall;
extern StructRNA RNA_MetaBallElements;
extern StructRNA RNA_Modifier;
extern StructRNA RNA_SubsurfModifier;
extern StructRNA RNA_LatticeModifier;
extern StructRNA RNA_CurveModifier;
extern StructRNA RNA_BuildModifier;
extern StructRNA RNA_MirrorModifier;
extern StructRNA RNA_DecimateModifier;
extern StructRNA RNA_WaveModifier;
extern StructRNA RNA_ArmatureModifier;
extern StructRNA RNA_HookModifier;
extern StructRNA RNA_SoftBodyModifier;
extern StructRNA RNA_BooleanModifier;
extern StructRNA RNA_ArrayModifier;
extern StructRNA RNA_EdgeSplitModifier;
extern StructRNA RNA_DisplaceModifier;
extern StructRNA RNA_UVProjectModifier;
extern StructRNA RNA_UVProjector;
extern StructRNA RNA_SmoothModifier;
extern StructRNA RNA_CastModifier;
extern StructRNA RNA_MeshDeformModifier;
extern StructRNA RNA_ParticleSystemModifier;
extern StructRNA RNA_ParticleInstanceModifier;
extern StructRNA RNA_ExplodeModifier;
extern StructRNA RNA_ClothModifier;
extern StructRNA RNA_CollisionModifier;
extern StructRNA RNA_BevelModifier;
extern StructRNA RNA_ShrinkwrapModifier;
extern StructRNA RNA_FluidSimulationModifier;
extern StructRNA RNA_MaskModifier;
extern StructRNA RNA_SimpleDeformModifier;
extern StructRNA RNA_WarpModifier;
extern StructRNA RNA_MultiresModifier;
extern StructRNA RNA_SurfaceModifier;
extern StructRNA RNA_SmokeModifier;
extern StructRNA RNA_SolidifyModifier;
extern StructRNA RNA_ScrewModifier;
extern StructRNA RNA_UVWarpModifier;
extern StructRNA RNA_VertexWeightEditModifier;
extern StructRNA RNA_VertexWeightMixModifier;
extern StructRNA RNA_VertexWeightProximityModifier;
extern StructRNA RNA_DynamicPaintModifier;
extern StructRNA RNA_OceanModifier;
extern StructRNA RNA_RemeshModifier;
extern StructRNA RNA_SkinModifier;
extern StructRNA RNA_LaplacianSmoothModifier;
extern StructRNA RNA_TriangulateModifier;
extern StructRNA RNA_MeshCacheModifier;
extern StructRNA RNA_LaplacianDeformModifier;
extern StructRNA RNA_WireframeModifier;
extern StructRNA RNA_NlaTrack;
extern StructRNA RNA_NlaStrips;
extern StructRNA RNA_NlaStrip;
extern StructRNA RNA_NodeSocket;
extern StructRNA RNA_NodeSocketInterface;
extern StructRNA RNA_Node;
extern StructRNA RNA_NodeInputs;
extern StructRNA RNA_NodeOutputs;
extern StructRNA RNA_NodeLink;
extern StructRNA RNA_NodeInternalSocketTemplate;
extern StructRNA RNA_NodeInternal;
extern StructRNA RNA_ShaderNode;
extern StructRNA RNA_CompositorNode;
extern StructRNA RNA_TextureNode;
extern StructRNA RNA_NodeTree;
extern StructRNA RNA_Nodes;
extern StructRNA RNA_NodeLinks;
extern StructRNA RNA_NodeTreeInputs;
extern StructRNA RNA_NodeTreeOutputs;
extern StructRNA RNA_NodeSocketStandard;
extern StructRNA RNA_NodeSocketInterfaceStandard;
extern StructRNA RNA_NodeSocketFloat;
extern StructRNA RNA_NodeSocketInterfaceFloat;
extern StructRNA RNA_NodeSocketFloatUnsigned;
extern StructRNA RNA_NodeSocketInterfaceFloatUnsigned;
extern StructRNA RNA_NodeSocketFloatPercentage;
extern StructRNA RNA_NodeSocketInterfaceFloatPercentage;
extern StructRNA RNA_NodeSocketFloatFactor;
extern StructRNA RNA_NodeSocketInterfaceFloatFactor;
extern StructRNA RNA_NodeSocketFloatAngle;
extern StructRNA RNA_NodeSocketInterfaceFloatAngle;
extern StructRNA RNA_NodeSocketFloatTime;
extern StructRNA RNA_NodeSocketInterfaceFloatTime;
extern StructRNA RNA_NodeSocketInt;
extern StructRNA RNA_NodeSocketInterfaceInt;
extern StructRNA RNA_NodeSocketIntUnsigned;
extern StructRNA RNA_NodeSocketInterfaceIntUnsigned;
extern StructRNA RNA_NodeSocketIntPercentage;
extern StructRNA RNA_NodeSocketInterfaceIntPercentage;
extern StructRNA RNA_NodeSocketIntFactor;
extern StructRNA RNA_NodeSocketInterfaceIntFactor;
extern StructRNA RNA_NodeSocketBool;
extern StructRNA RNA_NodeSocketInterfaceBool;
extern StructRNA RNA_NodeSocketVector;
extern StructRNA RNA_NodeSocketInterfaceVector;
extern StructRNA RNA_NodeSocketVectorTranslation;
extern StructRNA RNA_NodeSocketInterfaceVectorTranslation;
extern StructRNA RNA_NodeSocketVectorDirection;
extern StructRNA RNA_NodeSocketInterfaceVectorDirection;
extern StructRNA RNA_NodeSocketVectorVelocity;
extern StructRNA RNA_NodeSocketInterfaceVectorVelocity;
extern StructRNA RNA_NodeSocketVectorAcceleration;
extern StructRNA RNA_NodeSocketInterfaceVectorAcceleration;
extern StructRNA RNA_NodeSocketVectorEuler;
extern StructRNA RNA_NodeSocketInterfaceVectorEuler;
extern StructRNA RNA_NodeSocketVectorXYZ;
extern StructRNA RNA_NodeSocketInterfaceVectorXYZ;
extern StructRNA RNA_NodeSocketColor;
extern StructRNA RNA_NodeSocketInterfaceColor;
extern StructRNA RNA_NodeSocketString;
extern StructRNA RNA_NodeSocketInterfaceString;
extern StructRNA RNA_NodeSocketShader;
extern StructRNA RNA_NodeSocketInterfaceShader;
extern StructRNA RNA_NodeSocketVirtual;
extern StructRNA RNA_CompositorNodeTree;
extern StructRNA RNA_ShaderNodeTree;
extern StructRNA RNA_TextureNodeTree;
extern StructRNA RNA_NodeFrame;
extern StructRNA RNA_NodeGroup;
extern StructRNA RNA_NodeGroupInput;
extern StructRNA RNA_NodeGroupOutput;
extern StructRNA RNA_NodeReroute;
extern StructRNA RNA_ShaderNodeOutput;
extern StructRNA RNA_ShaderNodeMaterial;
extern StructRNA RNA_ShaderNodeRGB;
extern StructRNA RNA_ShaderNodeValue;
extern StructRNA RNA_ShaderNodeMixRGB;
extern StructRNA RNA_ShaderNodeValToRGB;
extern StructRNA RNA_ShaderNodeRGBToBW;
extern StructRNA RNA_ShaderNodeTexture;
extern StructRNA RNA_ShaderNodeNormal;
extern StructRNA RNA_ShaderNodeGamma;
extern StructRNA RNA_ShaderNodeBrightContrast;
extern StructRNA RNA_ShaderNodeGeometry;
extern StructRNA RNA_ShaderNodeMapping;
extern StructRNA RNA_ShaderNodeVectorCurve;
extern StructRNA RNA_ShaderNodeRGBCurve;
extern StructRNA RNA_ShaderNodeCameraData;
extern StructRNA RNA_ShaderNodeLampData;
extern StructRNA RNA_ShaderNodeMath;
extern StructRNA RNA_ShaderNodeVectorMath;
extern StructRNA RNA_ShaderNodeSqueeze;
extern StructRNA RNA_ShaderNodeExtendedMaterial;
extern StructRNA RNA_ShaderNodeInvert;
extern StructRNA RNA_ShaderNodeSeparateRGB;
extern StructRNA RNA_ShaderNodeCombineRGB;
extern StructRNA RNA_ShaderNodeHueSaturation;
extern StructRNA RNA_ShaderNodeOutputMaterial;
extern StructRNA RNA_ShaderNodeOutputLamp;
extern StructRNA RNA_ShaderNodeOutputWorld;
extern StructRNA RNA_ShaderNodeOutputLineStyle;
extern StructRNA RNA_ShaderNodeFresnel;
extern StructRNA RNA_ShaderNodeLayerWeight;
extern StructRNA RNA_ShaderNodeMixShader;
extern StructRNA RNA_ShaderNodeAddShader;
extern StructRNA RNA_ShaderNodeAttribute;
extern StructRNA RNA_ShaderNodeAmbientOcclusion;
extern StructRNA RNA_ShaderNodeBackground;
extern StructRNA RNA_ShaderNodeHoldout;
extern StructRNA RNA_ShaderNodeBsdfAnisotropic;
extern StructRNA RNA_ShaderNodeBsdfDiffuse;
extern StructRNA RNA_ShaderNodeBsdfGlossy;
extern StructRNA RNA_ShaderNodeBsdfGlass;
extern StructRNA RNA_ShaderNodeBsdfRefraction;
extern StructRNA RNA_ShaderNodeBsdfTranslucent;
extern StructRNA RNA_ShaderNodeBsdfTransparent;
extern StructRNA RNA_ShaderNodeBsdfVelvet;
extern StructRNA RNA_ShaderNodeBsdfToon;
extern StructRNA RNA_ShaderNodeBsdfHair;
extern StructRNA RNA_ShaderNodeSubsurfaceScattering;
extern StructRNA RNA_ShaderNodeVolumeAbsorption;
extern StructRNA RNA_ShaderNodeVolumeScatter;
extern StructRNA RNA_ShaderNodeEmission;
extern StructRNA RNA_ShaderNodeNewGeometry;
extern StructRNA RNA_ShaderNodeLightPath;
extern StructRNA RNA_ShaderNodeLightFalloff;
extern StructRNA RNA_ShaderNodeObjectInfo;
extern StructRNA RNA_ShaderNodeParticleInfo;
extern StructRNA RNA_ShaderNodeHairInfo;
extern StructRNA RNA_ShaderNodeWireframe;
extern StructRNA RNA_ShaderNodeWavelength;
extern StructRNA RNA_ShaderNodeBlackbody;
extern StructRNA RNA_ShaderNodeBump;
extern StructRNA RNA_ShaderNodeNormalMap;
extern StructRNA RNA_ShaderNodeTangent;
extern StructRNA RNA_ShaderNodeScript;
extern StructRNA RNA_ShaderNodeTexImage;
extern StructRNA RNA_ShaderNodeTexEnvironment;
extern StructRNA RNA_ShaderNodeTexSky;
extern StructRNA RNA_ShaderNodeTexGradient;
extern StructRNA RNA_ShaderNodeTexNoise;
extern StructRNA RNA_ShaderNodeTexMagic;
extern StructRNA RNA_ShaderNodeTexWave;
extern StructRNA RNA_ShaderNodeTexMusgrave;
extern StructRNA RNA_ShaderNodeTexVoronoi;
extern StructRNA RNA_ShaderNodeTexChecker;
extern StructRNA RNA_ShaderNodeTexBrick;
extern StructRNA RNA_ShaderNodeTexCoord;
extern StructRNA RNA_ShaderNodeVectorTransform;
extern StructRNA RNA_ShaderNodeSeparateHSV;
extern StructRNA RNA_ShaderNodeCombineHSV;
extern StructRNA RNA_ShaderNodeUVMap;
extern StructRNA RNA_ShaderNodeUVAlongStroke;
extern StructRNA RNA_ShaderNodeSeparateXYZ;
extern StructRNA RNA_ShaderNodeCombineXYZ;
extern StructRNA RNA_CompositorNodeViewer;
extern StructRNA RNA_CompositorNodeRGB;
extern StructRNA RNA_CompositorNodeValue;
extern StructRNA RNA_CompositorNodeMixRGB;
extern StructRNA RNA_CompositorNodeValToRGB;
extern StructRNA RNA_CompositorNodeRGBToBW;
extern StructRNA RNA_CompositorNodeNormal;
extern StructRNA RNA_CompositorNodeCurveVec;
extern StructRNA RNA_CompositorNodeCurveRGB;
extern StructRNA RNA_CompositorNodeAlphaOver;
extern StructRNA RNA_CompositorNodeBlur;
extern StructRNA RNA_CompositorNodeFilter;
extern StructRNA RNA_CompositorNodeMapValue;
extern StructRNA RNA_CompositorNodeMapRange;
extern StructRNA RNA_CompositorNodeTime;
extern StructRNA RNA_CompositorNodeVecBlur;
extern StructRNA RNA_CompositorNodeSepRGBA;
extern StructRNA RNA_CompositorNodeSepHSVA;
extern StructRNA RNA_CompositorNodeSetAlpha;
extern StructRNA RNA_CompositorNodeHueSat;
extern StructRNA RNA_CompositorNodeImage;
extern StructRNA RNA_CompositorNodeRLayers;
extern StructRNA RNA_CompositorNodeComposite;
extern StructRNA RNA_CompositorNodeOutputFile;
extern StructRNA RNA_CompositorNodeOutputFileFileSlots;
extern StructRNA RNA_CompositorNodeOutputFileLayerSlots;
extern StructRNA RNA_CompositorNodeTexture;
extern StructRNA RNA_CompositorNodeTranslate;
extern StructRNA RNA_CompositorNodeZcombine;
extern StructRNA RNA_CompositorNodeCombRGBA;
extern StructRNA RNA_CompositorNodeDilateErode;
extern StructRNA RNA_CompositorNodeInpaint;
extern StructRNA RNA_CompositorNodeDespeckle;
extern StructRNA RNA_CompositorNodeRotate;
extern StructRNA RNA_CompositorNodeScale;
extern StructRNA RNA_CompositorNodeSepYCCA;
extern StructRNA RNA_CompositorNodeCombYCCA;
extern StructRNA RNA_CompositorNodeSepYUVA;
extern StructRNA RNA_CompositorNodeCombYUVA;
extern StructRNA RNA_CompositorNodeDiffMatte;
extern StructRNA RNA_CompositorNodeColorSpill;
extern StructRNA RNA_CompositorNodeChromaMatte;
extern StructRNA RNA_CompositorNodeChannelMatte;
extern StructRNA RNA_CompositorNodeFlip;
extern StructRNA RNA_CompositorNodeSplitViewer;
extern StructRNA RNA_CompositorNodeMapUV;
extern StructRNA RNA_CompositorNodeIDMask;
extern StructRNA RNA_CompositorNodeDoubleEdgeMask;
extern StructRNA RNA_CompositorNodeDefocus;
extern StructRNA RNA_CompositorNodeDisplace;
extern StructRNA RNA_CompositorNodeCombHSVA;
extern StructRNA RNA_CompositorNodeMath;
extern StructRNA RNA_CompositorNodeLumaMatte;
extern StructRNA RNA_CompositorNodeBrightContrast;
extern StructRNA RNA_CompositorNodeGamma;
extern StructRNA RNA_CompositorNodeInvert;
extern StructRNA RNA_CompositorNodeNormalize;
extern StructRNA RNA_CompositorNodeCrop;
extern StructRNA RNA_CompositorNodeDBlur;
extern StructRNA RNA_CompositorNodeBilateralblur;
extern StructRNA RNA_CompositorNodePremulKey;
extern StructRNA RNA_CompositorNodeGlare;
extern StructRNA RNA_CompositorNodeTonemap;
extern StructRNA RNA_CompositorNodeLensdist;
extern StructRNA RNA_CompositorNodeLevels;
extern StructRNA RNA_CompositorNodeColorMatte;
extern StructRNA RNA_CompositorNodeDistanceMatte;
extern StructRNA RNA_CompositorNodeColorBalance;
extern StructRNA RNA_CompositorNodeHueCorrect;
extern StructRNA RNA_CompositorNodeMovieClip;
extern StructRNA RNA_CompositorNodeTransform;
extern StructRNA RNA_CompositorNodeStabilize;
extern StructRNA RNA_CompositorNodeMovieDistortion;
extern StructRNA RNA_CompositorNodeBoxMask;
extern StructRNA RNA_CompositorNodeEllipseMask;
extern StructRNA RNA_CompositorNodeBokehImage;
extern StructRNA RNA_CompositorNodeBokehBlur;
extern StructRNA RNA_CompositorNodeSwitch;
extern StructRNA RNA_CompositorNodeColorCorrection;
extern StructRNA RNA_CompositorNodeMask;
extern StructRNA RNA_CompositorNodeKeyingScreen;
extern StructRNA RNA_CompositorNodeKeying;
extern StructRNA RNA_CompositorNodeTrackPos;
extern StructRNA RNA_CompositorNodePixelate;
extern StructRNA RNA_CompositorNodePlaneTrackDeform;
extern StructRNA RNA_CompositorNodeCornerPin;
extern StructRNA RNA_CompositorNodeSunBeams;
extern StructRNA RNA_TextureNodeOutput;
extern StructRNA RNA_TextureNodeChecker;
extern StructRNA RNA_TextureNodeTexture;
extern StructRNA RNA_TextureNodeBricks;
extern StructRNA RNA_TextureNodeMath;
extern StructRNA RNA_TextureNodeMixRGB;
extern StructRNA RNA_TextureNodeRGBToBW;
extern StructRNA RNA_TextureNodeValToRGB;
extern StructRNA RNA_TextureNodeImage;
extern StructRNA RNA_TextureNodeCurveRGB;
extern StructRNA RNA_TextureNodeInvert;
extern StructRNA RNA_TextureNodeHueSaturation;
extern StructRNA RNA_TextureNodeCurveTime;
extern StructRNA RNA_TextureNodeRotate;
extern StructRNA RNA_TextureNodeViewer;
extern StructRNA RNA_TextureNodeTranslate;
extern StructRNA RNA_TextureNodeCoordinates;
extern StructRNA RNA_TextureNodeDistance;
extern StructRNA RNA_TextureNodeCompose;
extern StructRNA RNA_TextureNodeDecompose;
extern StructRNA RNA_TextureNodeValToNor;
extern StructRNA RNA_TextureNodeScale;
extern StructRNA RNA_TextureNodeAt;
extern StructRNA RNA_TextureNodeTexVoronoi;
extern StructRNA RNA_TextureNodeTexBlend;
extern StructRNA RNA_TextureNodeTexMagic;
extern StructRNA RNA_TextureNodeTexMarble;
extern StructRNA RNA_TextureNodeTexClouds;
extern StructRNA RNA_TextureNodeTexWood;
extern StructRNA RNA_TextureNodeTexMusgrave;
extern StructRNA RNA_TextureNodeTexNoise;
extern StructRNA RNA_TextureNodeTexStucci;
extern StructRNA RNA_TextureNodeTexDistNoise;
extern StructRNA RNA_ShaderNodeGroup;
extern StructRNA RNA_CompositorNodeGroup;
extern StructRNA RNA_TextureNodeGroup;
extern StructRNA RNA_NodeCustomGroup;
extern StructRNA RNA_NodeOutputFileSlotFile;
extern StructRNA RNA_NodeOutputFileSlotLayer;
extern StructRNA RNA_NodeInstanceHash;
extern StructRNA RNA_Object;
extern StructRNA RNA_ObjectModifiers;
extern StructRNA RNA_ObjectConstraints;
extern StructRNA RNA_VertexGroups;
extern StructRNA RNA_ParticleSystems;
extern StructRNA RNA_GameObjectSettings;
extern StructRNA RNA_ObjectBase;
extern StructRNA RNA_VertexGroup;
extern StructRNA RNA_MaterialSlot;
extern StructRNA RNA_DupliObject;
extern StructRNA RNA_LodLevel;
extern StructRNA RNA_PointCache;
extern StructRNA RNA_PointCaches;
extern StructRNA RNA_CollisionSettings;
extern StructRNA RNA_EffectorWeights;
extern StructRNA RNA_FieldSettings;
extern StructRNA RNA_GameSoftBodySettings;
extern StructRNA RNA_SoftBodySettings;
extern StructRNA RNA_PackedFile;
extern StructRNA RNA_ParticleTarget;
extern StructRNA RNA_SPHFluidSettings;
extern StructRNA RNA_ParticleHairKey;
extern StructRNA RNA_ParticleKey;
extern StructRNA RNA_ChildParticle;
extern StructRNA RNA_Particle;
extern StructRNA RNA_ParticleDupliWeight;
extern StructRNA RNA_ParticleSystem;
extern StructRNA RNA_ParticleSettingsTextureSlot;
extern StructRNA RNA_ParticleSettings;
extern StructRNA RNA_ParticleSettingsTextureSlots;
extern StructRNA RNA_Pose;
extern StructRNA RNA_BoneGroups;
extern StructRNA RNA_PoseBone;
extern StructRNA RNA_PoseBoneConstraints;
extern StructRNA RNA_IKParam;
extern StructRNA RNA_Itasc;
extern StructRNA RNA_BoneGroup;
extern StructRNA RNA_GameProperty;
extern StructRNA RNA_GameBooleanProperty;
extern StructRNA RNA_GameIntProperty;
extern StructRNA RNA_GameFloatProperty;
extern StructRNA RNA_GameTimerProperty;
extern StructRNA RNA_GameStringProperty;
extern StructRNA RNA_RenderEngine;
extern StructRNA RNA_RenderResult;
extern StructRNA RNA_RenderLayer;
extern StructRNA RNA_RenderPass;
extern StructRNA RNA_BakePixel;
extern StructRNA RNA_RigidBodyWorld;
extern StructRNA RNA_RigidBodyObject;
extern StructRNA RNA_RigidBodyConstraint;
extern StructRNA RNA_Scene;
extern StructRNA RNA_SceneBases;
extern StructRNA RNA_SceneObjects;
extern StructRNA RNA_KeyingSets;
extern StructRNA RNA_KeyingSetsAll;
extern StructRNA RNA_TimelineMarkers;
extern StructRNA RNA_ToolSettings;
extern StructRNA RNA_UnifiedPaintSettings;
extern StructRNA RNA_MeshStatVis;
extern StructRNA RNA_UnitSettings;
extern StructRNA RNA_ImageFormatSettings;
extern StructRNA RNA_SceneGameData;
extern StructRNA RNA_SceneGameRecastData;
extern StructRNA RNA_TransformOrientation;
extern StructRNA RNA_SelectedUvElement;
extern StructRNA RNA_FFmpegSettings;
extern StructRNA RNA_RenderSettings;
extern StructRNA RNA_RenderLayers;
extern StructRNA RNA_BakeSettings;
extern StructRNA RNA_SceneRenderLayer;
extern StructRNA RNA_FreestyleLineSet;
extern StructRNA RNA_FreestyleModuleSettings;
extern StructRNA RNA_FreestyleSettings;
extern StructRNA RNA_FreestyleModules;
extern StructRNA RNA_Linesets;
extern StructRNA RNA_Screen;
extern StructRNA RNA_Area;
extern StructRNA RNA_AreaSpaces;
extern StructRNA RNA_Region;
extern StructRNA RNA_View2D;
extern StructRNA RNA_PaletteColor;
extern StructRNA RNA_Palette;
extern StructRNA RNA_PaintCurve;
extern StructRNA RNA_Paint;
extern StructRNA RNA_Sculpt;
extern StructRNA RNA_UvSculpt;
extern StructRNA RNA_VertexPaint;
extern StructRNA RNA_ImagePaint;
extern StructRNA RNA_ParticleEdit;
extern StructRNA RNA_ParticleBrush;
extern StructRNA RNA_Sensor;
extern StructRNA RNA_AlwaysSensor;
extern StructRNA RNA_NearSensor;
extern StructRNA RNA_MouseSensor;
extern StructRNA RNA_KeyboardSensor;
extern StructRNA RNA_PropertySensor;
extern StructRNA RNA_ArmatureSensor;
extern StructRNA RNA_ActuatorSensor;
extern StructRNA RNA_DelaySensor;
extern StructRNA RNA_CollisionSensor;
extern StructRNA RNA_RadarSensor;
extern StructRNA RNA_RandomSensor;
extern StructRNA RNA_RaySensor;
extern StructRNA RNA_MessageSensor;
extern StructRNA RNA_JoystickSensor;
extern StructRNA RNA_SequenceColorBalanceData;
extern StructRNA RNA_SequenceElement;
extern StructRNA RNA_SequenceProxy;
extern StructRNA RNA_SequenceColorBalance;
extern StructRNA RNA_SequenceCrop;
extern StructRNA RNA_SequenceTransform;
extern StructRNA RNA_Sequence;
extern StructRNA RNA_SequenceModifiers;
extern StructRNA RNA_SequenceEditor;
extern StructRNA RNA_Sequences;
extern StructRNA RNA_ImageSequence;
extern StructRNA RNA_SequenceElements;
extern StructRNA RNA_MetaSequence;
extern StructRNA RNA_SceneSequence;
extern StructRNA RNA_MovieSequence;
extern StructRNA RNA_MovieClipSequence;
extern StructRNA RNA_MaskSequence;
extern StructRNA RNA_SoundSequence;
extern StructRNA RNA_EffectSequence;
extern StructRNA RNA_AddSequence;
extern StructRNA RNA_AdjustmentSequence;
extern StructRNA RNA_AlphaOverSequence;
extern StructRNA RNA_AlphaUnderSequence;
extern StructRNA RNA_ColorSequence;
extern StructRNA RNA_CrossSequence;
extern StructRNA RNA_GammaCrossSequence;
extern StructRNA RNA_GlowSequence;
extern StructRNA RNA_MulticamSequence;
extern StructRNA RNA_MultiplySequence;
extern StructRNA RNA_OverDropSequence;
extern StructRNA RNA_SpeedControlSequence;
extern StructRNA RNA_SubtractSequence;
extern StructRNA RNA_TransformSequence;
extern StructRNA RNA_WipeSequence;
extern StructRNA RNA_GaussianBlurSequence;
extern StructRNA RNA_SequenceModifier;
extern StructRNA RNA_ColorBalanceModifier;
extern StructRNA RNA_CurvesModifier;
extern StructRNA RNA_HueCorrectModifier;
extern StructRNA RNA_BrightContrastModifier;
extern StructRNA RNA_SmokeDomainSettings;
extern StructRNA RNA_SmokeFlowSettings;
extern StructRNA RNA_SmokeCollSettings;
extern StructRNA RNA_Space;
extern StructRNA RNA_SpaceImageEditor;
extern StructRNA RNA_SpaceUVEditor;
extern StructRNA RNA_SpaceSequenceEditor;
extern StructRNA RNA_SpaceTextEditor;
extern StructRNA RNA_FileSelectParams;
extern StructRNA RNA_SpaceFileBrowser;
extern StructRNA RNA_SpaceOutliner;
extern StructRNA RNA_BackgroundImage;
extern StructRNA RNA_SpaceView3D;
extern StructRNA RNA_BackgroundImages;
extern StructRNA RNA_RegionView3D;
extern StructRNA RNA_SpaceProperties;
extern StructRNA RNA_SpaceDopeSheetEditor;
extern StructRNA RNA_SpaceGraphEditor;
extern StructRNA RNA_SpaceNLA;
extern StructRNA RNA_SpaceTimeline;
extern StructRNA RNA_SpaceConsole;
extern StructRNA RNA_ConsoleLine;
extern StructRNA RNA_SpaceInfo;
extern StructRNA RNA_SpaceUserPreferences;
extern StructRNA RNA_NodeTreePath;
extern StructRNA RNA_SpaceNodeEditor;
extern StructRNA RNA_SpaceNodeEditorPath;
extern StructRNA RNA_SpaceLogicEditor;
extern StructRNA RNA_SpaceClipEditor;
extern StructRNA RNA_Speaker;
extern StructRNA RNA_TextLine;
extern StructRNA RNA_Text;
extern StructRNA RNA_TimelineMarker;
extern StructRNA RNA_Sound;
extern StructRNA RNA_UILayout;
extern StructRNA RNA_Panel;
extern StructRNA RNA_UIList;
extern StructRNA RNA_Header;
extern StructRNA RNA_Menu;
extern StructRNA RNA_ThemeFontStyle;
extern StructRNA RNA_ThemeStyle;
extern StructRNA RNA_ThemeWidgetColors;
extern StructRNA RNA_ThemeWidgetStateColors;
extern StructRNA RNA_ThemePanelColors;
extern StructRNA RNA_ThemeGradientColors;
extern StructRNA RNA_ThemeUserInterface;
extern StructRNA RNA_ThemeSpaceGeneric;
extern StructRNA RNA_ThemeSpaceGradient;
extern StructRNA RNA_ThemeSpaceListGeneric;
extern StructRNA RNA_ThemeView3D;
extern StructRNA RNA_ThemeGraphEditor;
extern StructRNA RNA_ThemeFileBrowser;
extern StructRNA RNA_ThemeNLAEditor;
extern StructRNA RNA_ThemeDopeSheet;
extern StructRNA RNA_ThemeImageEditor;
extern StructRNA RNA_ThemeSequenceEditor;
extern StructRNA RNA_ThemeProperties;
extern StructRNA RNA_ThemeTextEditor;
extern StructRNA RNA_ThemeTimeline;
extern StructRNA RNA_ThemeNodeEditor;
extern StructRNA RNA_ThemeOutliner;
extern StructRNA RNA_ThemeInfo;
extern StructRNA RNA_ThemeUserPreferences;
extern StructRNA RNA_ThemeConsole;
extern StructRNA RNA_ThemeLogicEditor;
extern StructRNA RNA_ThemeClipEditor;
extern StructRNA RNA_ThemeBoneColorSet;
extern StructRNA RNA_Theme;
extern StructRNA RNA_UserSolidLight;
extern StructRNA RNA_WalkNavigation;
extern StructRNA RNA_UserPreferences;
extern StructRNA RNA_Addons;
extern StructRNA RNA_PathCompareCollection;
extern StructRNA RNA_UserPreferencesView;
extern StructRNA RNA_UserPreferencesEdit;
extern StructRNA RNA_UserPreferencesInput;
extern StructRNA RNA_UserPreferencesFilePaths;
extern StructRNA RNA_UserPreferencesSystem;
extern StructRNA RNA_Addon;
extern StructRNA RNA_AddonPreferences;
extern StructRNA RNA_PathCompare;
extern StructRNA RNA_VectorFont;
extern StructRNA RNA_Operator;
extern StructRNA RNA_OperatorProperties;
extern StructRNA RNA_OperatorMousePath;
extern StructRNA RNA_OperatorFileListElement;
extern StructRNA RNA_Macro;
extern StructRNA RNA_OperatorMacro;
extern StructRNA RNA_Event;
extern StructRNA RNA_Timer;
extern StructRNA RNA_UIPopupMenu;
extern StructRNA RNA_UIPieMenu;
extern StructRNA RNA_Window;
extern StructRNA RNA_WindowManager;
extern StructRNA RNA_KeyConfigurations;
extern StructRNA RNA_KeyConfig;
extern StructRNA RNA_KeyMaps;
extern StructRNA RNA_KeyMap;
extern StructRNA RNA_KeyMapItems;
extern StructRNA RNA_KeyMapItem;
extern StructRNA RNA_World;
extern StructRNA RNA_WorldTextureSlots;
extern StructRNA RNA_WorldLighting;
extern StructRNA RNA_WorldMistSettings;
extern StructRNA RNA_WorldTextureSlot;
extern StructRNA RNA_MovieClip;
extern StructRNA RNA_MovieClipProxy;
extern StructRNA RNA_MovieClipUser;
extern StructRNA RNA_MovieClipScopes;
extern StructRNA RNA_MovieTrackingSettings;
extern StructRNA RNA_MovieTrackingCamera;
extern StructRNA RNA_MovieTrackingMarker;
extern StructRNA RNA_MovieTrackingTrack;
extern StructRNA RNA_MovieTrackingMarkers;
extern StructRNA RNA_MovieTrackingPlaneMarker;
extern StructRNA RNA_MovieTrackingPlaneTrack;
extern StructRNA RNA_MovieTrackingPlaneMarkers;
extern StructRNA RNA_MovieTrackingTracks;
extern StructRNA RNA_MovieTrackingPlaneTracks;
extern StructRNA RNA_MovieTrackingObjectTracks;
extern StructRNA RNA_MovieTrackingObjectPlaneTracks;
extern StructRNA RNA_MovieTrackingStabilization;
extern StructRNA RNA_MovieTrackingReconstructedCameras;
extern StructRNA RNA_MovieReconstructedCamera;
extern StructRNA RNA_MovieTrackingReconstruction;
extern StructRNA RNA_MovieTrackingObject;
extern StructRNA RNA_MovieTrackingDopesheet;
extern StructRNA RNA_MovieTracking;
extern StructRNA RNA_MovieTrackingObjects;
extern StructRNA RNA_MaskParent;
extern StructRNA RNA_MaskSplinePointUW;
extern StructRNA RNA_MaskSplinePoint;
extern StructRNA RNA_MaskSpline;
extern StructRNA RNA_MaskSplines;
extern StructRNA RNA_MaskSplinePoints;
extern StructRNA RNA_MaskLayer;
extern StructRNA RNA_Mask;
extern StructRNA RNA_MaskLayers;

#include "rna_nla.c"

#pragma GCC diagnostic ignored "-Wunused-parameter"

/* Autogenerated Functions */


CollectionPropertyRNA rna_NlaTrack_rna_properties;
PointerPropertyRNA rna_NlaTrack_rna_type;
CollectionPropertyRNA rna_NlaTrack_strips;
StringPropertyRNA rna_NlaTrack_name;
BoolPropertyRNA rna_NlaTrack_active;
BoolPropertyRNA rna_NlaTrack_is_solo;
BoolPropertyRNA rna_NlaTrack_select;
BoolPropertyRNA rna_NlaTrack_mute;
BoolPropertyRNA rna_NlaTrack_lock;


CollectionPropertyRNA rna_NlaStrips_rna_properties;
PointerPropertyRNA rna_NlaStrips_rna_type;

extern FunctionRNA rna_NlaStrips_new_func;
extern StringPropertyRNA rna_NlaStrips_new_name;
extern IntPropertyRNA rna_NlaStrips_new_start;
extern PointerPropertyRNA rna_NlaStrips_new_action;
extern PointerPropertyRNA rna_NlaStrips_new_strip;

extern FunctionRNA rna_NlaStrips_remove_func;
extern PointerPropertyRNA rna_NlaStrips_remove_strip;



CollectionPropertyRNA rna_NlaStrip_rna_properties;
PointerPropertyRNA rna_NlaStrip_rna_type;
StringPropertyRNA rna_NlaStrip_name;
EnumPropertyRNA rna_NlaStrip_type;
EnumPropertyRNA rna_NlaStrip_extrapolation;
EnumPropertyRNA rna_NlaStrip_blend_type;
FloatPropertyRNA rna_NlaStrip_frame_start;
FloatPropertyRNA rna_NlaStrip_frame_end;
FloatPropertyRNA rna_NlaStrip_blend_in;
FloatPropertyRNA rna_NlaStrip_blend_out;
BoolPropertyRNA rna_NlaStrip_use_auto_blend;
PointerPropertyRNA rna_NlaStrip_action;
FloatPropertyRNA rna_NlaStrip_action_frame_start;
FloatPropertyRNA rna_NlaStrip_action_frame_end;
FloatPropertyRNA rna_NlaStrip_repeat;
FloatPropertyRNA rna_NlaStrip_scale;
CollectionPropertyRNA rna_NlaStrip_fcurves;
CollectionPropertyRNA rna_NlaStrip_modifiers;
CollectionPropertyRNA rna_NlaStrip_strips;
FloatPropertyRNA rna_NlaStrip_influence;
FloatPropertyRNA rna_NlaStrip_strip_time;
BoolPropertyRNA rna_NlaStrip_use_animated_influence;
BoolPropertyRNA rna_NlaStrip_use_animated_time;
BoolPropertyRNA rna_NlaStrip_use_animated_time_cyclic;
BoolPropertyRNA rna_NlaStrip_active;
BoolPropertyRNA rna_NlaStrip_select;
BoolPropertyRNA rna_NlaStrip_mute;
BoolPropertyRNA rna_NlaStrip_use_reverse;
BoolPropertyRNA rna_NlaStrip_use_sync_length;

static PointerRNA NlaTrack_rna_properties_get(CollectionPropertyIterator *iter)
{
	return rna_builtin_properties_get(iter);
}

void NlaTrack_rna_properties_begin(CollectionPropertyIterator *iter, PointerRNA *ptr)
{

	memset(iter, 0, sizeof(*iter));
	iter->parent = *ptr;
	iter->prop = (PropertyRNA *)&rna_NlaTrack_rna_properties;

	rna_builtin_properties_begin(iter, ptr);

	if (iter->valid)
		iter->ptr = NlaTrack_rna_properties_get(iter);
}

void NlaTrack_rna_properties_next(CollectionPropertyIterator *iter)
{
	rna_builtin_properties_next(iter);

	if (iter->valid)
		iter->ptr = NlaTrack_rna_properties_get(iter);
}

void NlaTrack_rna_properties_end(CollectionPropertyIterator *iter)
{
	rna_iterator_listbase_end(iter);
}

int NlaTrack_rna_properties_lookup_string(PointerRNA *ptr, const char *key, PointerRNA *r_ptr)
{
	return rna_builtin_properties_lookup_string(ptr, key, r_ptr);
}

PointerRNA NlaTrack_rna_type_get(PointerRNA *ptr)
{
	return rna_builtin_type_get(ptr);
}

static PointerRNA NlaTrack_strips_get(CollectionPropertyIterator *iter)
{
	return rna_pointer_inherit_refine(&iter->parent, &RNA_NlaStrip, rna_iterator_listbase_get(iter));
}

void NlaTrack_strips_begin(CollectionPropertyIterator *iter, PointerRNA *ptr)
{
	NlaTrack *data = (NlaTrack *)(ptr->data);

	memset(iter, 0, sizeof(*iter));
	iter->parent = *ptr;
	iter->prop = (PropertyRNA *)&rna_NlaTrack_strips;

	rna_iterator_listbase_begin(iter, &data->strips, NULL);

	if (iter->valid)
		iter->ptr = NlaTrack_strips_get(iter);
}

void NlaTrack_strips_next(CollectionPropertyIterator *iter)
{
	rna_iterator_listbase_next(iter);

	if (iter->valid)
		iter->ptr = NlaTrack_strips_get(iter);
}

void NlaTrack_strips_end(CollectionPropertyIterator *iter)
{
	rna_iterator_listbase_end(iter);
}

int NlaTrack_strips_lookup_int(PointerRNA *ptr, int index, PointerRNA *r_ptr)
{
	int found = 0;
	CollectionPropertyIterator iter;

	NlaTrack_strips_begin(&iter, ptr);

	if (iter.valid) {
		ListBaseIterator *internal = &iter.internal.listbase;
		if (internal->skip) {
			while (index-- > 0 && iter.valid) {
				rna_iterator_listbase_next(&iter);
			}
			found = (index == -1 && iter.valid);
		}
		else {
			while (index-- > 0 && internal->link)
				internal->link = internal->link->next;
			found = (index == -1 && internal->link);
		}
		if (found) *r_ptr = NlaTrack_strips_get(&iter);
	}

	NlaTrack_strips_end(&iter);

	return found;
}

int NlaTrack_strips_lookup_string(PointerRNA *ptr, const char *key, PointerRNA *r_ptr)
{
	extern int NlaStrip_name_length(PointerRNA *);
	extern void NlaStrip_name_get(PointerRNA *, char *);

	bool found = false;
	CollectionPropertyIterator iter;
	char namebuf[1024];
	char *name;

	NlaTrack_strips_begin(&iter, ptr);

	while (iter.valid) {
		if (iter.ptr.data) {
			int namelen = NlaStrip_name_length(&iter.ptr);
			if (namelen < 1024) {
				NlaStrip_name_get(&iter.ptr, namebuf);
				if (strcmp(namebuf, key) == 0) {
					found = true;
					*r_ptr = iter.ptr;
					break;
				}
			}
			else {
				name = MEM_mallocN(namelen+1, "name string");
				NlaStrip_name_get(&iter.ptr, name);
				if (strcmp(name, key) == 0) {
					MEM_freeN(name);

					found = true;
					*r_ptr = iter.ptr;
					break;
				}
				else {
					MEM_freeN(name);
				}
			}
		}
		NlaTrack_strips_next(&iter);
	}
	NlaTrack_strips_end(&iter);

	return found;
}

void NlaTrack_name_get(PointerRNA *ptr, char *value)
{
	NlaTrack *data = (NlaTrack *)(ptr->data);
	BLI_strncpy_utf8(value, data->name, 64);
}

int NlaTrack_name_length(PointerRNA *ptr)
{
	NlaTrack *data = (NlaTrack *)(ptr->data);
	return strlen(data->name);
}

void NlaTrack_name_set(PointerRNA *ptr, const char *value)
{
	NlaTrack *data = (NlaTrack *)(ptr->data);
	BLI_strncpy_utf8(data->name, value, 64);
}

int NlaTrack_active_get(PointerRNA *ptr)
{
	NlaTrack *data = (NlaTrack *)(ptr->data);
	return (((data->flag) & 1) != 0);
}

int NlaTrack_is_solo_get(PointerRNA *ptr)
{
	NlaTrack *data = (NlaTrack *)(ptr->data);
	return (((data->flag) & 8) != 0);
}

void NlaTrack_is_solo_set(PointerRNA *ptr, int value)
{
	rna_NlaTrack_solo_set(ptr, value);
}

int NlaTrack_select_get(PointerRNA *ptr)
{
	NlaTrack *data = (NlaTrack *)(ptr->data);
	return (((data->flag) & 2) != 0);
}

void NlaTrack_select_set(PointerRNA *ptr, int value)
{
	NlaTrack *data = (NlaTrack *)(ptr->data);
	if (value) data->flag |= 2;
	else data->flag &= ~2;
}

int NlaTrack_mute_get(PointerRNA *ptr)
{
	NlaTrack *data = (NlaTrack *)(ptr->data);
	return (((data->flag) & 4) != 0);
}

void NlaTrack_mute_set(PointerRNA *ptr, int value)
{
	NlaTrack *data = (NlaTrack *)(ptr->data);
	if (value) data->flag |= 4;
	else data->flag &= ~4;
}

int NlaTrack_lock_get(PointerRNA *ptr)
{
	NlaTrack *data = (NlaTrack *)(ptr->data);
	return (((data->flag) & 16) != 0);
}

void NlaTrack_lock_set(PointerRNA *ptr, int value)
{
	NlaTrack *data = (NlaTrack *)(ptr->data);
	if (value) data->flag |= 16;
	else data->flag &= ~16;
}

static PointerRNA NlaStrips_rna_properties_get(CollectionPropertyIterator *iter)
{
	return rna_builtin_properties_get(iter);
}

void NlaStrips_rna_properties_begin(CollectionPropertyIterator *iter, PointerRNA *ptr)
{

	memset(iter, 0, sizeof(*iter));
	iter->parent = *ptr;
	iter->prop = (PropertyRNA *)&rna_NlaStrips_rna_properties;

	rna_builtin_properties_begin(iter, ptr);

	if (iter->valid)
		iter->ptr = NlaStrips_rna_properties_get(iter);
}

void NlaStrips_rna_properties_next(CollectionPropertyIterator *iter)
{
	rna_builtin_properties_next(iter);

	if (iter->valid)
		iter->ptr = NlaStrips_rna_properties_get(iter);
}

void NlaStrips_rna_properties_end(CollectionPropertyIterator *iter)
{
	rna_iterator_listbase_end(iter);
}

int NlaStrips_rna_properties_lookup_string(PointerRNA *ptr, const char *key, PointerRNA *r_ptr)
{
	return rna_builtin_properties_lookup_string(ptr, key, r_ptr);
}

PointerRNA NlaStrips_rna_type_get(PointerRNA *ptr)
{
	return rna_builtin_type_get(ptr);
}

static PointerRNA NlaStrip_rna_properties_get(CollectionPropertyIterator *iter)
{
	return rna_builtin_properties_get(iter);
}

void NlaStrip_rna_properties_begin(CollectionPropertyIterator *iter, PointerRNA *ptr)
{

	memset(iter, 0, sizeof(*iter));
	iter->parent = *ptr;
	iter->prop = (PropertyRNA *)&rna_NlaStrip_rna_properties;

	rna_builtin_properties_begin(iter, ptr);

	if (iter->valid)
		iter->ptr = NlaStrip_rna_properties_get(iter);
}

void NlaStrip_rna_properties_next(CollectionPropertyIterator *iter)
{
	rna_builtin_properties_next(iter);

	if (iter->valid)
		iter->ptr = NlaStrip_rna_properties_get(iter);
}

void NlaStrip_rna_properties_end(CollectionPropertyIterator *iter)
{
	rna_iterator_listbase_end(iter);
}

int NlaStrip_rna_properties_lookup_string(PointerRNA *ptr, const char *key, PointerRNA *r_ptr)
{
	return rna_builtin_properties_lookup_string(ptr, key, r_ptr);
}

PointerRNA NlaStrip_rna_type_get(PointerRNA *ptr)
{
	return rna_builtin_type_get(ptr);
}

void NlaStrip_name_get(PointerRNA *ptr, char *value)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	BLI_strncpy_utf8(value, data->name, 64);
}

int NlaStrip_name_length(PointerRNA *ptr)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	return strlen(data->name);
}

void NlaStrip_name_set(PointerRNA *ptr, const char *value)
{
	rna_NlaStrip_name_set(ptr, value);
}

int NlaStrip_type_get(PointerRNA *ptr)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	return (int)(data->type);
}

int NlaStrip_extrapolation_get(PointerRNA *ptr)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	return (int)(data->extendmode);
}

void NlaStrip_extrapolation_set(PointerRNA *ptr, int value)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	data->extendmode = value;
}

int NlaStrip_blend_type_get(PointerRNA *ptr)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	return (int)(data->blendmode);
}

void NlaStrip_blend_type_set(PointerRNA *ptr, int value)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	data->blendmode = value;
}

float NlaStrip_frame_start_get(PointerRNA *ptr)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	return (float)(data->start);
}

void NlaStrip_frame_start_set(PointerRNA *ptr, float value)
{
	rna_NlaStrip_start_frame_set(ptr, value);
}

float NlaStrip_frame_end_get(PointerRNA *ptr)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	return (float)(data->end);
}

void NlaStrip_frame_end_set(PointerRNA *ptr, float value)
{
	rna_NlaStrip_end_frame_set(ptr, value);
}

float NlaStrip_blend_in_get(PointerRNA *ptr)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	return (float)(data->blendin);
}

void NlaStrip_blend_in_set(PointerRNA *ptr, float value)
{
	rna_NlaStrip_blend_in_set(ptr, value);
}

float NlaStrip_blend_out_get(PointerRNA *ptr)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	return (float)(data->blendout);
}

void NlaStrip_blend_out_set(PointerRNA *ptr, float value)
{
	rna_NlaStrip_blend_out_set(ptr, value);
}

int NlaStrip_use_auto_blend_get(PointerRNA *ptr)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	return (((data->flag) & 1024) != 0);
}

void NlaStrip_use_auto_blend_set(PointerRNA *ptr, int value)
{
	rna_NlaStrip_use_auto_blend_set(ptr, value);
}

PointerRNA NlaStrip_action_get(PointerRNA *ptr)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	return rna_pointer_inherit_refine(ptr, &RNA_Action, data->act);
}

void NlaStrip_action_set(PointerRNA *ptr, PointerRNA value)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);

	if (data->act)
		id_us_min((ID *)data->act);
	if (value.data)
		id_us_plus((ID *)value.data);

	data->act = value.data;
}

float NlaStrip_action_frame_start_get(PointerRNA *ptr)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	return (float)(data->actstart);
}

void NlaStrip_action_frame_start_set(PointerRNA *ptr, float value)
{
	rna_NlaStrip_action_start_frame_set(ptr, value);
}

float NlaStrip_action_frame_end_get(PointerRNA *ptr)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	return (float)(data->actend);
}

void NlaStrip_action_frame_end_set(PointerRNA *ptr, float value)
{
	rna_NlaStrip_action_end_frame_set(ptr, value);
}

float NlaStrip_repeat_get(PointerRNA *ptr)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	return (float)(data->repeat);
}

void NlaStrip_repeat_set(PointerRNA *ptr, float value)
{
	rna_NlaStrip_repeat_set(ptr, value);
}

float NlaStrip_scale_get(PointerRNA *ptr)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	return (float)(data->scale);
}

void NlaStrip_scale_set(PointerRNA *ptr, float value)
{
	rna_NlaStrip_scale_set(ptr, value);
}

static PointerRNA NlaStrip_fcurves_get(CollectionPropertyIterator *iter)
{
	return rna_pointer_inherit_refine(&iter->parent, &RNA_FCurve, rna_iterator_listbase_get(iter));
}

void NlaStrip_fcurves_begin(CollectionPropertyIterator *iter, PointerRNA *ptr)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);

	memset(iter, 0, sizeof(*iter));
	iter->parent = *ptr;
	iter->prop = (PropertyRNA *)&rna_NlaStrip_fcurves;

	rna_iterator_listbase_begin(iter, &data->fcurves, NULL);

	if (iter->valid)
		iter->ptr = NlaStrip_fcurves_get(iter);
}

void NlaStrip_fcurves_next(CollectionPropertyIterator *iter)
{
	rna_iterator_listbase_next(iter);

	if (iter->valid)
		iter->ptr = NlaStrip_fcurves_get(iter);
}

void NlaStrip_fcurves_end(CollectionPropertyIterator *iter)
{
	rna_iterator_listbase_end(iter);
}

int NlaStrip_fcurves_lookup_int(PointerRNA *ptr, int index, PointerRNA *r_ptr)
{
	int found = 0;
	CollectionPropertyIterator iter;

	NlaStrip_fcurves_begin(&iter, ptr);

	if (iter.valid) {
		ListBaseIterator *internal = &iter.internal.listbase;
		if (internal->skip) {
			while (index-- > 0 && iter.valid) {
				rna_iterator_listbase_next(&iter);
			}
			found = (index == -1 && iter.valid);
		}
		else {
			while (index-- > 0 && internal->link)
				internal->link = internal->link->next;
			found = (index == -1 && internal->link);
		}
		if (found) *r_ptr = NlaStrip_fcurves_get(&iter);
	}

	NlaStrip_fcurves_end(&iter);

	return found;
}

static PointerRNA NlaStrip_modifiers_get(CollectionPropertyIterator *iter)
{
	return rna_pointer_inherit_refine(&iter->parent, &RNA_FModifier, rna_iterator_listbase_get(iter));
}

void NlaStrip_modifiers_begin(CollectionPropertyIterator *iter, PointerRNA *ptr)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);

	memset(iter, 0, sizeof(*iter));
	iter->parent = *ptr;
	iter->prop = (PropertyRNA *)&rna_NlaStrip_modifiers;

	rna_iterator_listbase_begin(iter, &data->modifiers, NULL);

	if (iter->valid)
		iter->ptr = NlaStrip_modifiers_get(iter);
}

void NlaStrip_modifiers_next(CollectionPropertyIterator *iter)
{
	rna_iterator_listbase_next(iter);

	if (iter->valid)
		iter->ptr = NlaStrip_modifiers_get(iter);
}

void NlaStrip_modifiers_end(CollectionPropertyIterator *iter)
{
	rna_iterator_listbase_end(iter);
}

int NlaStrip_modifiers_lookup_int(PointerRNA *ptr, int index, PointerRNA *r_ptr)
{
	int found = 0;
	CollectionPropertyIterator iter;

	NlaStrip_modifiers_begin(&iter, ptr);

	if (iter.valid) {
		ListBaseIterator *internal = &iter.internal.listbase;
		if (internal->skip) {
			while (index-- > 0 && iter.valid) {
				rna_iterator_listbase_next(&iter);
			}
			found = (index == -1 && iter.valid);
		}
		else {
			while (index-- > 0 && internal->link)
				internal->link = internal->link->next;
			found = (index == -1 && internal->link);
		}
		if (found) *r_ptr = NlaStrip_modifiers_get(&iter);
	}

	NlaStrip_modifiers_end(&iter);

	return found;
}

static PointerRNA NlaStrip_strips_get(CollectionPropertyIterator *iter)
{
	return rna_pointer_inherit_refine(&iter->parent, &RNA_NlaStrip, rna_iterator_listbase_get(iter));
}

void NlaStrip_strips_begin(CollectionPropertyIterator *iter, PointerRNA *ptr)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);

	memset(iter, 0, sizeof(*iter));
	iter->parent = *ptr;
	iter->prop = (PropertyRNA *)&rna_NlaStrip_strips;

	rna_iterator_listbase_begin(iter, &data->strips, NULL);

	if (iter->valid)
		iter->ptr = NlaStrip_strips_get(iter);
}

void NlaStrip_strips_next(CollectionPropertyIterator *iter)
{
	rna_iterator_listbase_next(iter);

	if (iter->valid)
		iter->ptr = NlaStrip_strips_get(iter);
}

void NlaStrip_strips_end(CollectionPropertyIterator *iter)
{
	rna_iterator_listbase_end(iter);
}

int NlaStrip_strips_lookup_int(PointerRNA *ptr, int index, PointerRNA *r_ptr)
{
	int found = 0;
	CollectionPropertyIterator iter;

	NlaStrip_strips_begin(&iter, ptr);

	if (iter.valid) {
		ListBaseIterator *internal = &iter.internal.listbase;
		if (internal->skip) {
			while (index-- > 0 && iter.valid) {
				rna_iterator_listbase_next(&iter);
			}
			found = (index == -1 && iter.valid);
		}
		else {
			while (index-- > 0 && internal->link)
				internal->link = internal->link->next;
			found = (index == -1 && internal->link);
		}
		if (found) *r_ptr = NlaStrip_strips_get(&iter);
	}

	NlaStrip_strips_end(&iter);

	return found;
}

int NlaStrip_strips_lookup_string(PointerRNA *ptr, const char *key, PointerRNA *r_ptr)
{
	extern int NlaStrip_name_length(PointerRNA *);
	extern void NlaStrip_name_get(PointerRNA *, char *);

	bool found = false;
	CollectionPropertyIterator iter;
	char namebuf[1024];
	char *name;

	NlaStrip_strips_begin(&iter, ptr);

	while (iter.valid) {
		if (iter.ptr.data) {
			int namelen = NlaStrip_name_length(&iter.ptr);
			if (namelen < 1024) {
				NlaStrip_name_get(&iter.ptr, namebuf);
				if (strcmp(namebuf, key) == 0) {
					found = true;
					*r_ptr = iter.ptr;
					break;
				}
			}
			else {
				name = MEM_mallocN(namelen+1, "name string");
				NlaStrip_name_get(&iter.ptr, name);
				if (strcmp(name, key) == 0) {
					MEM_freeN(name);

					found = true;
					*r_ptr = iter.ptr;
					break;
				}
				else {
					MEM_freeN(name);
				}
			}
		}
		NlaStrip_strips_next(&iter);
	}
	NlaStrip_strips_end(&iter);

	return found;
}

float NlaStrip_influence_get(PointerRNA *ptr)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	return (float)(data->influence);
}

void NlaStrip_influence_set(PointerRNA *ptr, float value)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	data->influence = CLAMPIS(value, 0.0f, 1.0f);
}

float NlaStrip_strip_time_get(PointerRNA *ptr)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	return (float)(data->strip_time);
}

void NlaStrip_strip_time_set(PointerRNA *ptr, float value)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	data->strip_time = value;
}

int NlaStrip_use_animated_influence_get(PointerRNA *ptr)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	return (((data->flag) & 32) != 0);
}

void NlaStrip_use_animated_influence_set(PointerRNA *ptr, int value)
{
	rna_NlaStrip_animated_influence_set(ptr, value);
}

int NlaStrip_use_animated_time_get(PointerRNA *ptr)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	return (((data->flag) & 64) != 0);
}

void NlaStrip_use_animated_time_set(PointerRNA *ptr, int value)
{
	rna_NlaStrip_animated_time_set(ptr, value);
}

int NlaStrip_use_animated_time_cyclic_get(PointerRNA *ptr)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	return (((data->flag) & 128) != 0);
}

void NlaStrip_use_animated_time_cyclic_set(PointerRNA *ptr, int value)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	if (value) data->flag |= 128;
	else data->flag &= ~128;
}

int NlaStrip_active_get(PointerRNA *ptr)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	return (((data->flag) & 1) != 0);
}

int NlaStrip_select_get(PointerRNA *ptr)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	return (((data->flag) & 2) != 0);
}

void NlaStrip_select_set(PointerRNA *ptr, int value)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	if (value) data->flag |= 2;
	else data->flag &= ~2;
}

int NlaStrip_mute_get(PointerRNA *ptr)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	return (((data->flag) & 4096) != 0);
}

void NlaStrip_mute_set(PointerRNA *ptr, int value)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	if (value) data->flag |= 4096;
	else data->flag &= ~4096;
}

int NlaStrip_use_reverse_get(PointerRNA *ptr)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	return (((data->flag) & 2048) != 0);
}

void NlaStrip_use_reverse_set(PointerRNA *ptr, int value)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	if (value) data->flag |= 2048;
	else data->flag &= ~2048;
}

int NlaStrip_use_sync_length_get(PointerRNA *ptr)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	return (((data->flag) & 512) != 0);
}

void NlaStrip_use_sync_length_set(PointerRNA *ptr, int value)
{
	NlaStrip *data = (NlaStrip *)(ptr->data);
	if (value) data->flag |= 512;
	else data->flag &= ~512;
}


struct NlaStrip *NlaStrips_new(struct NlaTrack *_self, bContext *C, ReportList *reports, const char * name, int start, struct bAction *action)
{
	return rna_NlaStrip_new(_self, C, reports, name, start, action);
}

void NlaStrips_new_call(bContext *C, ReportList *reports, PointerRNA *_ptr, ParameterList *_parms)
{
	struct NlaTrack *_self;
	const char * name;
	int start;
	struct bAction *action;
	struct NlaStrip *strip;
	char *_data, *_retdata;
	
	_self = (struct NlaTrack *)_ptr->data;
	_data = (char *)_parms->data;
	name = *((const char * *)_data);
#if defined(SPEC_ILP32)
	_data += 4;
#else
	_data += 8;
#endif
	start = *((int *)_data);
	_data += 4;
	action = *((struct bAction **)_data);
#if defined(SPEC_ILP32)
	_data += 4;
#else
	_data += 8;
#endif
	_retdata = _data;
	
	strip = rna_NlaStrip_new(_self, C, reports, name, start, action);
	*((struct NlaStrip **)_retdata) = strip;
}

void NlaStrips_remove(struct NlaTrack *_self, bContext *C, ReportList *reports, struct PointerRNA *strip)
{
	rna_NlaStrip_remove(_self, C, reports, strip);
}

void NlaStrips_remove_call(bContext *C, ReportList *reports, PointerRNA *_ptr, ParameterList *_parms)
{
	struct NlaTrack *_self;
	struct PointerRNA *strip;
	char *_data;
	
	_self = (struct NlaTrack *)_ptr->data;
	_data = (char *)_parms->data;
	strip = *((struct PointerRNA **)_data);
	
	rna_NlaStrip_remove(_self, C, reports, strip);
}

/* Repeated prototypes to detect errors */

struct NlaStrip *rna_NlaStrip_new(struct NlaTrack *_self, bContext *C, ReportList *reports, const char * name, int start, struct bAction *action);
void rna_NlaStrip_remove(struct NlaTrack *_self, bContext *C, ReportList *reports, struct PointerRNA *strip);


/* NLA Track */
CollectionPropertyRNA rna_NlaTrack_rna_properties = {
	{(PropertyRNA *)&rna_NlaTrack_rna_type, NULL,
	-1, "rna_properties", 128, "Properties",
	"RNA property collection",
	0, "*",
	PROP_COLLECTION, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 0, NULL, NULL,
	0, -1, NULL},
	NlaTrack_rna_properties_begin, NlaTrack_rna_properties_next, NlaTrack_rna_properties_end, NlaTrack_rna_properties_get, NULL, NULL, NlaTrack_rna_properties_lookup_string, NULL, &RNA_Property
};

PointerPropertyRNA rna_NlaTrack_rna_type = {
	{(PropertyRNA *)&rna_NlaTrack_strips, (PropertyRNA *)&rna_NlaTrack_rna_properties,
	-1, "rna_type", 8912896, "RNA",
	"RNA type definition",
	0, "*",
	PROP_POINTER, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 0, NULL, NULL,
	0, -1, NULL},
	NlaTrack_rna_type_get, NULL, NULL, NULL,&RNA_Struct
};

CollectionPropertyRNA rna_NlaTrack_strips = {
	{(PropertyRNA *)&rna_NlaTrack_name, (PropertyRNA *)&rna_NlaTrack_rna_type,
	-1, "strips", 0, "NLA Strips",
	"NLA Strips on this NLA-track",
	0, "*",
	PROP_COLLECTION, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 0, NULL, NULL,
	0, -1, &RNA_NlaStrips},
	NlaTrack_strips_begin, NlaTrack_strips_next, NlaTrack_strips_end, NlaTrack_strips_get, NULL, NlaTrack_strips_lookup_int, NlaTrack_strips_lookup_string, NULL, &RNA_NlaStrip
};

StringPropertyRNA rna_NlaTrack_name = {
	{(PropertyRNA *)&rna_NlaTrack_active, (PropertyRNA *)&rna_NlaTrack_strips,
	-1, "name", 262145, "Name",
	"",
	0, "*",
	PROP_STRING, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {64, 0, 0}, 0,
	NULL, 239665152, NULL, NULL,
	0, -1, NULL},
	NlaTrack_name_get, NlaTrack_name_length, NlaTrack_name_set, NULL, NULL, NULL, 64, ""
};

BoolPropertyRNA rna_NlaTrack_active = {
	{(PropertyRNA *)&rna_NlaTrack_is_solo, (PropertyRNA *)&rna_NlaTrack_name,
	-1, "active", 2, "Active",
	"NLA Track is active",
	0, "*",
	PROP_BOOLEAN, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 239665152, NULL, NULL,
	0, -1, NULL},
	NlaTrack_active_get, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL
};

BoolPropertyRNA rna_NlaTrack_is_solo = {
	{(PropertyRNA *)&rna_NlaTrack_select, (PropertyRNA *)&rna_NlaTrack_active,
	-1, "is_solo", 3, "Solo",
	"NLA Track is evaluated itself (i.e. active Action and all other NLA Tracks in the same AnimData block are disabled)",
	0, "*",
	PROP_BOOLEAN, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 239665152, NULL, NULL,
	0, -1, NULL},
	NlaTrack_is_solo_get, NlaTrack_is_solo_set, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL
};

BoolPropertyRNA rna_NlaTrack_select = {
	{(PropertyRNA *)&rna_NlaTrack_mute, (PropertyRNA *)&rna_NlaTrack_is_solo,
	-1, "select", 3, "Select",
	"NLA Track is selected",
	0, "*",
	PROP_BOOLEAN, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 239665152, NULL, NULL,
	0, -1, NULL},
	NlaTrack_select_get, NlaTrack_select_set, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL
};

BoolPropertyRNA rna_NlaTrack_mute = {
	{(PropertyRNA *)&rna_NlaTrack_lock, (PropertyRNA *)&rna_NlaTrack_select,
	-1, "mute", 3, "Muted",
	"NLA Track is not evaluated",
	0, "*",
	PROP_BOOLEAN, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 239665152, NULL, NULL,
	0, -1, NULL},
	NlaTrack_mute_get, NlaTrack_mute_set, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL
};

BoolPropertyRNA rna_NlaTrack_lock = {
	{NULL, (PropertyRNA *)&rna_NlaTrack_mute,
	-1, "lock", 3, "Locked",
	"NLA Track is locked",
	0, "*",
	PROP_BOOLEAN, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 239665152, NULL, NULL,
	0, -1, NULL},
	NlaTrack_lock_get, NlaTrack_lock_set, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL
};

StructRNA RNA_NlaTrack = {
	{(ContainerRNA *)&RNA_NlaStrips, (ContainerRNA *)&RNA_WireframeModifier,
	NULL,
	{(PropertyRNA *)&rna_NlaTrack_rna_properties, (PropertyRNA *)&rna_NlaTrack_lock}},
	"NlaTrack", NULL, NULL, 4, "NLA Track",
	"A animation layer containing Actions referenced as NLA strips",
	"*", 116,
	(PropertyRNA *)&rna_NlaTrack_name, (PropertyRNA *)&rna_NlaTrack_rna_properties,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	{NULL, NULL}
};

/* Nla Strips */
CollectionPropertyRNA rna_NlaStrips_rna_properties = {
	{(PropertyRNA *)&rna_NlaStrips_rna_type, NULL,
	-1, "rna_properties", 128, "Properties",
	"RNA property collection",
	0, "*",
	PROP_COLLECTION, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 0, NULL, NULL,
	0, -1, NULL},
	NlaStrips_rna_properties_begin, NlaStrips_rna_properties_next, NlaStrips_rna_properties_end, NlaStrips_rna_properties_get, NULL, NULL, NlaStrips_rna_properties_lookup_string, NULL, &RNA_Property
};

PointerPropertyRNA rna_NlaStrips_rna_type = {
	{NULL, (PropertyRNA *)&rna_NlaStrips_rna_properties,
	-1, "rna_type", 8912896, "RNA",
	"RNA type definition",
	0, "*",
	PROP_POINTER, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 0, NULL, NULL,
	0, -1, NULL},
	NlaStrips_rna_type_get, NULL, NULL, NULL,&RNA_Struct
};

StringPropertyRNA rna_NlaStrips_new_name = {
	{(PropertyRNA *)&rna_NlaStrips_new_start, NULL,
	-1, "name", 262149, "",
	"Name for the NLA Strips",
	0, "*",
	PROP_STRING, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 0, NULL, NULL,
	0, -1, NULL},
	NULL, NULL, NULL, NULL, NULL, NULL, 0, "NlaStrip"
};

IntPropertyRNA rna_NlaStrips_new_start = {
	{(PropertyRNA *)&rna_NlaStrips_new_action, (PropertyRNA *)&rna_NlaStrips_new_name,
	-1, "start", 7, "Start Frame",
	"Start frame for this strip",
	0, "*",
	PROP_INT, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 0, NULL, NULL,
	0, -1, NULL},
	NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
	INT_MIN, INT_MAX, INT_MIN, INT_MAX, 1, 0, NULL
};

PointerPropertyRNA rna_NlaStrips_new_action = {
	{(PropertyRNA *)&rna_NlaStrips_new_strip, (PropertyRNA *)&rna_NlaStrips_new_start,
	-1, "action", 8650756, "",
	"Action to assign to this strip",
	0, "*",
	PROP_POINTER, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 0, NULL, NULL,
	0, -1, NULL},
	NULL, NULL, NULL, NULL,&RNA_Action
};

PointerPropertyRNA rna_NlaStrips_new_strip = {
	{NULL, (PropertyRNA *)&rna_NlaStrips_new_action,
	-1, "strip", 8388616, "",
	"New NLA Strip",
	0, "*",
	PROP_POINTER, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 0, NULL, NULL,
	0, -1, NULL},
	NULL, NULL, NULL, NULL,&RNA_NlaStrip
};

FunctionRNA rna_NlaStrips_new_func = {
	{(FunctionRNA *)&rna_NlaStrips_remove_func, NULL,
	NULL,
	{(PropertyRNA *)&rna_NlaStrips_new_name, (PropertyRNA *)&rna_NlaStrips_new_strip}},
	"new", 24, "Add a new Action-Clip strip to the track",
	NlaStrips_new_call,
	(PropertyRNA *)&rna_NlaStrips_new_strip
};

PointerPropertyRNA rna_NlaStrips_remove_strip = {
	{NULL, NULL,
	-1, "strip", 264196, "",
	"NLA Strip to remove",
	0, "*",
	PROP_POINTER, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 0, NULL, NULL,
	0, -1, NULL},
	NULL, NULL, NULL, NULL,&RNA_NlaStrip
};

FunctionRNA rna_NlaStrips_remove_func = {
	{NULL, (FunctionRNA *)&rna_NlaStrips_new_func,
	NULL,
	{(PropertyRNA *)&rna_NlaStrips_remove_strip, (PropertyRNA *)&rna_NlaStrips_remove_strip}},
	"remove", 24, "Remove a NLA Strip",
	NlaStrips_remove_call,
	NULL
};

StructRNA RNA_NlaStrips = {
	{(ContainerRNA *)&RNA_NlaStrip, (ContainerRNA *)&RNA_NlaTrack,
	NULL,
	{(PropertyRNA *)&rna_NlaStrips_rna_properties, (PropertyRNA *)&rna_NlaStrips_rna_type}},
	"NlaStrips", NULL, NULL, 4, "Nla Strips",
	"Collection of Nla Strips",
	"*", 17,
	NULL, (PropertyRNA *)&rna_NlaStrips_rna_properties,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	{(FunctionRNA *)&rna_NlaStrips_new_func, (FunctionRNA *)&rna_NlaStrips_remove_func}
};

/* NLA Strip */
CollectionPropertyRNA rna_NlaStrip_rna_properties = {
	{(PropertyRNA *)&rna_NlaStrip_rna_type, NULL,
	-1, "rna_properties", 128, "Properties",
	"RNA property collection",
	0, "*",
	PROP_COLLECTION, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 0, NULL, NULL,
	0, -1, NULL},
	NlaStrip_rna_properties_begin, NlaStrip_rna_properties_next, NlaStrip_rna_properties_end, NlaStrip_rna_properties_get, NULL, NULL, NlaStrip_rna_properties_lookup_string, NULL, &RNA_Property
};

PointerPropertyRNA rna_NlaStrip_rna_type = {
	{(PropertyRNA *)&rna_NlaStrip_name, (PropertyRNA *)&rna_NlaStrip_rna_properties,
	-1, "rna_type", 8912896, "RNA",
	"RNA type definition",
	0, "*",
	PROP_POINTER, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 0, NULL, NULL,
	0, -1, NULL},
	NlaStrip_rna_type_get, NULL, NULL, NULL,&RNA_Struct
};

StringPropertyRNA rna_NlaStrip_name = {
	{(PropertyRNA *)&rna_NlaStrip_type, (PropertyRNA *)&rna_NlaStrip_rna_type,
	-1, "name", 262145, "Name",
	"",
	0, "*",
	PROP_STRING, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {64, 0, 0}, 0,
	NULL, 239665152, NULL, NULL,
	0, -1, NULL},
	NlaStrip_name_get, NlaStrip_name_length, NlaStrip_name_set, NULL, NULL, NULL, 64, ""
};

static EnumPropertyItem rna_NlaStrip_type_items[5] = {
	{0, "CLIP", 0, "Action Clip", "NLA Strip references some Action"},
	{1, "TRANSITION", 0, "Transition", "NLA Strip \'transitions\' between adjacent strips"},
	{2, "META", 0, "Meta", "NLA Strip acts as a container for adjacent strips"},
	{3, "SOUND", 0, "Sound Clip", "NLA Strip representing a sound event for speakers"},
	{0, NULL, 0, NULL, NULL}
};

EnumPropertyRNA rna_NlaStrip_type = {
	{(PropertyRNA *)&rna_NlaStrip_extrapolation, (PropertyRNA *)&rna_NlaStrip_name,
	-1, "type", 2, "Type",
	"Type of NLA Strip",
	0, "*",
	PROP_ENUM, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 239665152, NULL, NULL,
	0, -1, NULL},
	NlaStrip_type_get, NULL, NULL, NULL, NULL, NULL, rna_NlaStrip_type_items, 4, 0
};

static EnumPropertyItem rna_NlaStrip_extrapolation_items[4] = {
	{2, "NOTHING", 0, "Nothing", "Strip has no influence past its extents"},
	{0, "HOLD", 0, "Hold", "Hold the first frame if no previous strips in track, and always hold last frame"},
	{1, "HOLD_FORWARD", 0, "Hold Forward", "Only hold last frame"},
	{0, NULL, 0, NULL, NULL}
};

EnumPropertyRNA rna_NlaStrip_extrapolation = {
	{(PropertyRNA *)&rna_NlaStrip_blend_type, (PropertyRNA *)&rna_NlaStrip_type,
	-1, "extrapolation", 3, "Extrapolation",
	"Action to take for gaps past the strip extents",
	0, "*",
	PROP_ENUM, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 239665152, NULL, NULL,
	0, -1, NULL},
	NlaStrip_extrapolation_get, NlaStrip_extrapolation_set, NULL, NULL, NULL, NULL, rna_NlaStrip_extrapolation_items, 3, 0
};

static EnumPropertyItem rna_NlaStrip_blend_type_items[5] = {
	{0, "REPLACE", 0, "Replace", "Result strip replaces the accumulated results by amount specified by influence"},
	{1, "ADD", 0, "Add", "Weighted result of strip is added to the accumulated results"},
	{2, "SUBTRACT", 0, "Subtract", "Weighted result of strip is removed from the accumulated results"},
	{3, "MULTIPLY", 0, "Multiply", "Weighted result of strip is multiplied with the accumulated results"},
	{0, NULL, 0, NULL, NULL}
};

EnumPropertyRNA rna_NlaStrip_blend_type = {
	{(PropertyRNA *)&rna_NlaStrip_frame_start, (PropertyRNA *)&rna_NlaStrip_extrapolation,
	-1, "blend_type", 3, "Blending",
	"Method used for combining strip\'s result with accumulated result",
	0, "*",
	PROP_ENUM, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 239665152, NULL, NULL,
	0, -1, NULL},
	NlaStrip_blend_type_get, NlaStrip_blend_type_set, NULL, NULL, NULL, NULL, rna_NlaStrip_blend_type_items, 4, 0
};

FloatPropertyRNA rna_NlaStrip_frame_start = {
	{(PropertyRNA *)&rna_NlaStrip_frame_end, (PropertyRNA *)&rna_NlaStrip_blend_type,
	-1, "frame_start", 3, "Start Frame",
	"",
	0, "*",
	PROP_FLOAT, PROP_TIME | PROP_UNIT_TIME, NULL, 0, {0, 0, 0}, 0,
	rna_NlaStrip_transform_update, 0, NULL, NULL,
	0, -1, NULL},
	NlaStrip_frame_start_get, NlaStrip_frame_start_set, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, -10000.0f, 10000.0f, -FLT_MAX, FLT_MAX, 10.0f, 3, 0.0f, NULL
};

FloatPropertyRNA rna_NlaStrip_frame_end = {
	{(PropertyRNA *)&rna_NlaStrip_blend_in, (PropertyRNA *)&rna_NlaStrip_frame_start,
	-1, "frame_end", 3, "End Frame",
	"",
	0, "*",
	PROP_FLOAT, PROP_TIME | PROP_UNIT_TIME, NULL, 0, {0, 0, 0}, 0,
	rna_NlaStrip_transform_update, 0, NULL, NULL,
	0, -1, NULL},
	NlaStrip_frame_end_get, NlaStrip_frame_end_set, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, -10000.0f, 10000.0f, -FLT_MAX, FLT_MAX, 10.0f, 3, 0.0f, NULL
};

FloatPropertyRNA rna_NlaStrip_blend_in = {
	{(PropertyRNA *)&rna_NlaStrip_blend_out, (PropertyRNA *)&rna_NlaStrip_frame_end,
	-1, "blend_in", 3, "Blend In",
	"Number of frames at start of strip to fade in influence",
	0, "*",
	PROP_FLOAT, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 239665152, NULL, NULL,
	0, -1, NULL},
	NlaStrip_blend_in_get, NlaStrip_blend_in_set, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, -10000.0f, 10000.0f, -FLT_MAX, FLT_MAX, 10.0f, 3, 0.0f, NULL
};

FloatPropertyRNA rna_NlaStrip_blend_out = {
	{(PropertyRNA *)&rna_NlaStrip_use_auto_blend, (PropertyRNA *)&rna_NlaStrip_blend_in,
	-1, "blend_out", 3, "Blend Out",
	"",
	0, "*",
	PROP_FLOAT, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 239665152, NULL, NULL,
	0, -1, NULL},
	NlaStrip_blend_out_get, NlaStrip_blend_out_set, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, -10000.0f, 10000.0f, -FLT_MAX, FLT_MAX, 10.0f, 3, 0.0f, NULL
};

BoolPropertyRNA rna_NlaStrip_use_auto_blend = {
	{(PropertyRNA *)&rna_NlaStrip_action, (PropertyRNA *)&rna_NlaStrip_blend_out,
	-1, "use_auto_blend", 3, "Auto Blend In/Out",
	"Number of frames for Blending In/Out is automatically determined from overlapping strips",
	0, "*",
	PROP_BOOLEAN, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 239665152, NULL, NULL,
	0, -1, NULL},
	NlaStrip_use_auto_blend_get, NlaStrip_use_auto_blend_set, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL
};

PointerPropertyRNA rna_NlaStrip_action = {
	{(PropertyRNA *)&rna_NlaStrip_action_frame_start, (PropertyRNA *)&rna_NlaStrip_use_auto_blend,
	-1, "action", 8388673, "Action",
	"Action referenced by this strip",
	0, "*",
	PROP_POINTER, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 239665152, rna_NlaStrip_action_editable, NULL,
	0, -1, NULL},
	NlaStrip_action_get, NlaStrip_action_set, NULL, rna_Action_id_poll,&RNA_Action
};

FloatPropertyRNA rna_NlaStrip_action_frame_start = {
	{(PropertyRNA *)&rna_NlaStrip_action_frame_end, (PropertyRNA *)&rna_NlaStrip_action,
	-1, "action_frame_start", 3, "Action Start Frame",
	"First frame from action to use",
	0, "*",
	PROP_FLOAT, PROP_TIME | PROP_UNIT_TIME, NULL, 0, {0, 0, 0}, 0,
	NULL, 239665152, NULL, NULL,
	0, -1, NULL},
	NlaStrip_action_frame_start_get, NlaStrip_action_frame_start_set, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, -10000.0f, 10000.0f, -FLT_MAX, FLT_MAX, 10.0f, 3, 0.0f, NULL
};

FloatPropertyRNA rna_NlaStrip_action_frame_end = {
	{(PropertyRNA *)&rna_NlaStrip_repeat, (PropertyRNA *)&rna_NlaStrip_action_frame_start,
	-1, "action_frame_end", 3, "Action End Frame",
	"Last frame from action to use",
	0, "*",
	PROP_FLOAT, PROP_TIME | PROP_UNIT_TIME, NULL, 0, {0, 0, 0}, 0,
	NULL, 239665152, NULL, NULL,
	0, -1, NULL},
	NlaStrip_action_frame_end_get, NlaStrip_action_frame_end_set, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, -10000.0f, 10000.0f, -FLT_MAX, FLT_MAX, 10.0f, 3, 0.0f, NULL
};

FloatPropertyRNA rna_NlaStrip_repeat = {
	{(PropertyRNA *)&rna_NlaStrip_scale, (PropertyRNA *)&rna_NlaStrip_action_frame_end,
	-1, "repeat", 3, "Repeat",
	"Number of times to repeat the action range",
	0, "*",
	PROP_FLOAT, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 239665152, NULL, NULL,
	0, -1, NULL},
	NlaStrip_repeat_get, NlaStrip_repeat_set, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.1000000015f, 1000.0f, 0.1000000015f, 1000.0f, 10.0f, 3, 0.0f, NULL
};

FloatPropertyRNA rna_NlaStrip_scale = {
	{(PropertyRNA *)&rna_NlaStrip_fcurves, (PropertyRNA *)&rna_NlaStrip_repeat,
	-1, "scale", 3, "Scale",
	"Scaling factor for action",
	0, "*",
	PROP_FLOAT, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 239665152, NULL, NULL,
	0, -1, NULL},
	NlaStrip_scale_get, NlaStrip_scale_set, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.0001000000f, 1000.0f, 0.0001000000f, 1000.0f, 10.0f, 3, 0.0f, NULL
};

CollectionPropertyRNA rna_NlaStrip_fcurves = {
	{(PropertyRNA *)&rna_NlaStrip_modifiers, (PropertyRNA *)&rna_NlaStrip_scale,
	-1, "fcurves", 0, "F-Curves",
	"F-Curves for controlling the strip\'s influence and timing",
	0, "*",
	PROP_COLLECTION, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 0, NULL, NULL,
	0, -1, NULL},
	NlaStrip_fcurves_begin, NlaStrip_fcurves_next, NlaStrip_fcurves_end, NlaStrip_fcurves_get, NULL, NlaStrip_fcurves_lookup_int, NULL, NULL, &RNA_FCurve
};

CollectionPropertyRNA rna_NlaStrip_modifiers = {
	{(PropertyRNA *)&rna_NlaStrip_strips, (PropertyRNA *)&rna_NlaStrip_fcurves,
	-1, "modifiers", 0, "Modifiers",
	"Modifiers affecting all the F-Curves in the referenced Action",
	0, "*",
	PROP_COLLECTION, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 0, NULL, NULL,
	0, -1, NULL},
	NlaStrip_modifiers_begin, NlaStrip_modifiers_next, NlaStrip_modifiers_end, NlaStrip_modifiers_get, NULL, NlaStrip_modifiers_lookup_int, NULL, NULL, &RNA_FModifier
};

CollectionPropertyRNA rna_NlaStrip_strips = {
	{(PropertyRNA *)&rna_NlaStrip_influence, (PropertyRNA *)&rna_NlaStrip_modifiers,
	-1, "strips", 0, "NLA Strips",
	"NLA Strips that this strip acts as a container for (if it is of type Meta)",
	0, "*",
	PROP_COLLECTION, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 0, NULL, NULL,
	0, -1, NULL},
	NlaStrip_strips_begin, NlaStrip_strips_next, NlaStrip_strips_end, NlaStrip_strips_get, NULL, NlaStrip_strips_lookup_int, NlaStrip_strips_lookup_string, NULL, &RNA_NlaStrip
};

FloatPropertyRNA rna_NlaStrip_influence = {
	{(PropertyRNA *)&rna_NlaStrip_strip_time, (PropertyRNA *)&rna_NlaStrip_strips,
	-1, "influence", 8195, "Influence",
	"Amount the strip contributes to the current result",
	0, "*",
	PROP_FLOAT, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 239665152, NULL, NULL,
	offsetof(NlaStrip, influence), 4, NULL},
	NlaStrip_influence_get, NlaStrip_influence_set, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.0f, 1.0f, 0.0f, 1.0f, 10.0f, 3, 0.0f, NULL
};

FloatPropertyRNA rna_NlaStrip_strip_time = {
	{(PropertyRNA *)&rna_NlaStrip_use_animated_influence, (PropertyRNA *)&rna_NlaStrip_influence,
	-1, "strip_time", 8195, "Strip Time",
	"Frame of referenced Action to evaluate",
	0, "*",
	PROP_FLOAT, PROP_TIME | PROP_UNIT_TIME, NULL, 0, {0, 0, 0}, 0,
	NULL, 239665152, NULL, NULL,
	offsetof(NlaStrip, strip_time), 4, NULL},
	NlaStrip_strip_time_get, NlaStrip_strip_time_set, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, -10000.0f, 10000.0f, -FLT_MAX, FLT_MAX, 10.0f, 3, 0.0f, NULL
};

BoolPropertyRNA rna_NlaStrip_use_animated_influence = {
	{(PropertyRNA *)&rna_NlaStrip_use_animated_time, (PropertyRNA *)&rna_NlaStrip_strip_time,
	-1, "use_animated_influence", 3, "Animated Influence",
	"Influence setting is controlled by an F-Curve rather than automatically determined",
	0, "*",
	PROP_BOOLEAN, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 239665152, NULL, NULL,
	0, -1, NULL},
	NlaStrip_use_animated_influence_get, NlaStrip_use_animated_influence_set, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL
};

BoolPropertyRNA rna_NlaStrip_use_animated_time = {
	{(PropertyRNA *)&rna_NlaStrip_use_animated_time_cyclic, (PropertyRNA *)&rna_NlaStrip_use_animated_influence,
	-1, "use_animated_time", 3, "Animated Strip Time",
	"Strip time is controlled by an F-Curve rather than automatically determined",
	0, "*",
	PROP_BOOLEAN, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 239665152, NULL, NULL,
	0, -1, NULL},
	NlaStrip_use_animated_time_get, NlaStrip_use_animated_time_set, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL
};

BoolPropertyRNA rna_NlaStrip_use_animated_time_cyclic = {
	{(PropertyRNA *)&rna_NlaStrip_active, (PropertyRNA *)&rna_NlaStrip_use_animated_time,
	-1, "use_animated_time_cyclic", 3, "Cyclic Strip Time",
	"Cycle the animated time within the action start & end",
	0, "*",
	PROP_BOOLEAN, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	rna_NlaStrip_transform_update, 0, NULL, NULL,
	0, -1, NULL},
	NlaStrip_use_animated_time_cyclic_get, NlaStrip_use_animated_time_cyclic_set, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL
};

BoolPropertyRNA rna_NlaStrip_active = {
	{(PropertyRNA *)&rna_NlaStrip_select, (PropertyRNA *)&rna_NlaStrip_use_animated_time_cyclic,
	-1, "active", 2, "Active",
	"NLA Strip is active",
	0, "*",
	PROP_BOOLEAN, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 239665152, NULL, NULL,
	0, -1, NULL},
	NlaStrip_active_get, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL
};

BoolPropertyRNA rna_NlaStrip_select = {
	{(PropertyRNA *)&rna_NlaStrip_mute, (PropertyRNA *)&rna_NlaStrip_active,
	-1, "select", 3, "Select",
	"NLA Strip is selected",
	0, "*",
	PROP_BOOLEAN, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 239665152, NULL, NULL,
	0, -1, NULL},
	NlaStrip_select_get, NlaStrip_select_set, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL
};

BoolPropertyRNA rna_NlaStrip_mute = {
	{(PropertyRNA *)&rna_NlaStrip_use_reverse, (PropertyRNA *)&rna_NlaStrip_select,
	-1, "mute", 3, "Muted",
	"NLA Strip is not evaluated",
	0, "*",
	PROP_BOOLEAN, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 239665152, NULL, NULL,
	0, -1, NULL},
	NlaStrip_mute_get, NlaStrip_mute_set, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL
};

BoolPropertyRNA rna_NlaStrip_use_reverse = {
	{(PropertyRNA *)&rna_NlaStrip_use_sync_length, (PropertyRNA *)&rna_NlaStrip_mute,
	-1, "use_reverse", 3, "Reversed",
	"NLA Strip is played back in reverse order (only when timing is automatically determined)",
	0, "*",
	PROP_BOOLEAN, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 239665152, NULL, NULL,
	0, -1, NULL},
	NlaStrip_use_reverse_get, NlaStrip_use_reverse_set, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL
};

BoolPropertyRNA rna_NlaStrip_use_sync_length = {
	{NULL, (PropertyRNA *)&rna_NlaStrip_use_reverse,
	-1, "use_sync_length", 3, "Sync Action Length",
	"Update range of frames referenced from action after tweaking strip and its keyframes",
	0, "*",
	PROP_BOOLEAN, PROP_NONE | PROP_UNIT_NONE, NULL, 0, {0, 0, 0}, 0,
	NULL, 239665152, NULL, NULL,
	0, -1, NULL},
	NlaStrip_use_sync_length_get, NlaStrip_use_sync_length_set, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL
};

StructRNA RNA_NlaStrip = {
	{(ContainerRNA *)&RNA_NodeSocket, (ContainerRNA *)&RNA_NlaStrips,
	NULL,
	{(PropertyRNA *)&rna_NlaStrip_rna_properties, (PropertyRNA *)&rna_NlaStrip_use_sync_length}},
	"NlaStrip", NULL, NULL, 4, "NLA Strip",
	"A container referencing an existing Action",
	"*", 116,
	(PropertyRNA *)&rna_NlaStrip_name, (PropertyRNA *)&rna_NlaStrip_rna_properties,
	NULL,
	NULL,
	NULL,
	rna_NlaStrip_path,
	NULL,
	NULL,
	NULL,
	NULL,
	{NULL, NULL}
};

