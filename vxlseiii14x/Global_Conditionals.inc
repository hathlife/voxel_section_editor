(***********************************************************************************************************************)
(* defines that are defined here will usable in all modules, as these all include this file!                           *)
(***********************************************************************************************************************)

//{$DEFINE DEBUG_NORMALS} // disabled for now
//{$DEFINE DEBUG_FILE}
{$DEFINE SPEED_TEST}       // to check speed for UFF's final graduation project
//{$DEFINE MESH_TEST}       // to mesh values for UFF's final graduation project
{$DEFINE MESH_CORRECT}
//{$DEFINE MESH_SUBDIVISION}
//{$DEFINE OPTIMIZATION_INFO} // it adds analysis for the mesh optimization operations.
//{$DEFINE TEXTURE_DEBUG}

(***********************************************************************************************************************)
(* flags (bounds checking, optimisation etc) defined here will apply to all modules, as these all include this file!   *)
(***********************************************************************************************************************)

{$OPTIMIZATION OFF} // DEBUG SETTING!

{// $DEFINE TIB_PLUGIN}

// This activates and deactivates Plasamdroids new project system. (Basically, the create VXL and HVA system)
{$DEFINE PLASMA_PROJECT}