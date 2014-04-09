(***********************************************************************************************************************)
(* defines that are defined here will usable in all modules, as these all include this file!                           *)
(***********************************************************************************************************************)

//{$DEFINE DEBUG_NORMALS} // disabled for now
//{$DEFINE DEBUG_FILE}
{$DEFINE SPEED_TEST}       // to check speed mesh operations.
//{$DEFINE MESH_TEST}       // to mesh values for UFF's final graduation project
//{$DEFINE SMOOTH_TEST}      // to smooth values for UFF's master dissertation project
{$DEFINE ORIGAMI_TEST}     // to test the origami texture atlas extraction.
//{$DEFINE ORIGAMI_COLISION_TEST} // to test origami colision with GA.
//{$DEFINE ORIGAMI_PROJECTION_TEST} // to test origami projection with GA.
//{$DEFINE ORIGAMI_ROTATION_TEST} // to test origami projection with GA.
//{$DEFINE OPTIMIZATION_INFO} // it adds analysis for the mesh optimization operations.
//{$DEFINE TEXTURE_DEBUG}

(***********************************************************************************************************************)
(* flags (bounds checking, optimisation etc) defined here will apply to all modules, as these all include this file!   *)
(***********************************************************************************************************************)

{$OPTIMIZATION OFF} // DEBUG SETTING!

{// $DEFINE TIB_PLUGIN}

{$DEFINE VOXEL_SUPPORT}    // Enable voxel rendering support for the Rendering Engine.

// This activates and deactivates Plasamdroids new project system. (Basically, the create VXL and HVA system)
{$DEFINE PLASMA_PROJECT}