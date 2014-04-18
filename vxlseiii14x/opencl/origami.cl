/* 2D Triangle collision detection for Voxel Section Editor III's Texture Atlas Extraction (Origami) 

Coded by: Banshee
*/

float epsilon(float value)
{
	if (fabs(value) < 0.0001)
	{
		return 0;
	}
	else
	{
		return value;
	}
}

int isInOrOutNone(float vlAx, float vlAy, float vlBx, float vlBy, float vX, float vY)
{
	// do determinant.
	float detvvlAvlB = epsilon((vX * vlAy) + (vY * vlBx) + (vlAx * vlBy) - (vX * vlBy) - (vY * vlAx) - (vlAy * vlBx));
	if (detvvlAvlB >= 0)
	{
		if (detvvlAvlB == 0)
		{
			float vlAvlBx = (vlBx - vlAx);
			float vlAvlBy = (vlBy - vlAy);
			float distvlAvlB = sqrt((vlAvlBx * vlAvlBx) + (vlAvlBy * vlAvlBy));
			vlAvlBx = vlAvlBx / distvlAvlB;
			vlAvlBy = vlAvlBy / distvlAvlB;
			// Projection
			float projvvl = epsilon((((vX - vlAx) * vlAvlBx) + ((vY - vlAy) * vlAvlBy)) / distvlAvlB);
			if ((projvvl >= 0) && (epsilon(projvvl - 1) <= 0))
			{
				return 33;  // Hack to remove vertexes at the edges.
			}
			else
			{
				return 1;
			}
		}
		else
		{
			return 1;
		}
	}
	else
	{
		return 0;
	}
}

int isInOrOutVertexA(float vlAx, float vlAy, float vlBx, float vlBy, float vX, float vY)
{
	// do determinant.
	float detvvlAvlB = epsilon((vX * vlAy) + (vY * vlBx) + (vlAx * vlBy) - (vX * vlBy) - (vY * vlAx) - (vlAy * vlBx));
	if (detvvlAvlB >= 0)
	{
		if (detvvlAvlB == 0)
		{
			float vlAvlBx = (vlBx - vlAx);
			float vlAvlBy = (vlBy - vlAy);
			float distvlAvlB = sqrt((vlAvlBx * vlAvlBx) + (vlAvlBy * vlAvlBy));
			vlAvlBx = vlAvlBx / distvlAvlB;
			vlAvlBy = vlAvlBy / distvlAvlB;
			// Projection
			float projvvl = epsilon((((vX - vlAx) * vlAvlBx) + ((vY - vlAy) * vlAvlBy)) / distvlAvlB);
			if ((projvvl > 0) && (epsilon(projvvl - 1) <= 0))
			{
				return 33;  // Hack to remove vertexes at the edges.
			}
			else
			{
				return 1;
			}
		}
		else
		{
			return 1;
		}
	}
	else
	{
		return 0;
	}
}

int isInOrOutVertexB(float vlAx, float vlAy, float vlBx, float vlBy, float vX, float vY)
{
	// do determinant.
	float detvvlAvlB = epsilon((vX * vlAy) + (vY * vlBx) + (vlAx * vlBy) - (vX * vlBy) - (vY * vlAx) - (vlAy * vlBx));
	if (detvvlAvlB >= 0)
	{
		if (detvvlAvlB == 0)
		{
			float vlAvlBx = (vlBx - vlAx);
			float vlAvlBy = (vlBy - vlAy);
			float distvlAvlB = sqrt((vlAvlBx * vlAvlBx) + (vlAvlBy * vlAvlBy));
			vlAvlBx = vlAvlBx / distvlAvlB;
			vlAvlBy = vlAvlBy / distvlAvlB;
			// Projection
			float projvvl = epsilon((((vX - vlAx) * vlAvlBx) + ((vY - vlAy) * vlAvlBy)) / distvlAvlB);
			if ((projvvl >= 0) && (epsilon(projvvl - 1) < 0))
			{
				return 33;  // Hack to remove vertexes at the edges.
			}
			else
			{
				return 1;
			}
		}
		else
		{
			return 1;
		}
	}
	else
	{
		return 0;
	}
}

int isInOrOutEdge(float vlAx, float vlAy, float vlBx, float vlBy, float vX, float vY)
{
	// do determinant.
	float detvvlAvlB = epsilon((vX * vlAy) + (vY * vlBx) + (vlAx * vlBy) - (vX * vlBy) - (vY * vlAx) - (vlAy * vlBx));
	if (detvvlAvlB >= 0)
	{
		if (detvvlAvlB == 0)
		{
			float vlAvlBx = (vlBx - vlAx);
			float vlAvlBy = (vlBy - vlAy);
			float distvlAvlB = sqrt((vlAvlBx * vlAvlBx) + (vlAvlBy * vlAvlBy));
			vlAvlBx = vlAvlBx / distvlAvlB;
			vlAvlBy = vlAvlBy / distvlAvlB;
			// Projection
			float projvvl = epsilon((((vX - vlAx) * vlAvlBx) + ((vY - vlAy) * vlAvlBy)) / distvlAvlB);
			if ((projvvl > 0) && (epsilon(projvvl - 1) < 0))
			{
				return 33;  // Hack to remove vertexes at the edges.
			}
			else
			{
				return 1;
			}
		}
		else
		{
			return 1;
		}
	}
	else
	{
		return 0;
	}
}

/* It should return 1 if there is at least one triangle whose edges collides with the input triangle. */
__kernel void are2DTrianglesColidingEdges(__global float * triA, __global int * edge, __global bool * faceAllowed, __global float * coords, __global int * faces, __global int * output)
{
	int i = get_global_id(0);
	int faceStart = i * 3;
	int v1 = faces[faceStart]*2;
	int v2 = faces[faceStart+1]*2;
	int v3 = faces[faceStart+2]*2;
	int triA1 = edge[0] * 2;
	int triA2 = edge[1] * 2;
	
	int vertexConfig1 = isInOrOutVertexB(triA[0], triA[1], coords[triA1], coords[triA1+1], coords[v1], coords[v1+1]) | (2 * isInOrOutEdge(coords[triA1], coords[triA1+1], coords[triA2], coords[triA2+1], coords[v1], coords[v1+1])) | (4 * isInOrOutVertexA(coords[triA2], coords[triA2+1], triA[0], triA[1], coords[v1], coords[v1+1]));	

	int vertexConfig2 = isInOrOutVertexB(triA[0], triA[1], coords[triA1], coords[triA1+1], coords[v2], coords[v2+1]) | (2 * isInOrOutEdge(coords[triA1], coords[triA1+1], coords[triA2], coords[triA2+1], coords[v2], coords[v2+1])) | (4 * isInOrOutVertexA(coords[triA2], coords[triA2+1], triA[0], triA[1], coords[v2], coords[v2+1]));	

	int vertexConfig3 = isInOrOutVertexB(triA[0], triA[1], coords[triA1], coords[triA1+1], coords[v3], coords[v3+1]) | (2 * isInOrOutEdge(coords[triA1], coords[triA1+1], coords[triA2], coords[triA2+1], coords[v3], coords[v3+1])) | (4 * isInOrOutVertexA(coords[triA2], coords[triA2+1], triA[0], triA[1], coords[v3], coords[v3+1]));	
	
	int vertexConfig4 = isInOrOutNone(coords[v1], coords[v1+1], coords[v2], coords[v2+1], triA[0], triA[1]) | (2 * isInOrOutNone(coords[v2], coords[v2+1], coords[v3], coords[v3+1], triA[0], triA[1])) | (4 * isInOrOutNone(coords[v3], coords[v3+1], coords[v1], coords[v1+1], triA[0], triA[1]));	

	int vertexConfig5 = isInOrOutEdge(coords[v1], coords[v1+1], coords[v2], coords[v2+1], coords[triA1], coords[triA1+1]) | (2 * isInOrOutEdge(coords[v2], coords[v2+1], coords[v3], coords[v3+1], coords[triA1], coords[triA1+1])) | (4 * isInOrOutEdge(coords[v3], coords[v3+1], coords[v1], coords[v1+1], coords[triA1], coords[triA1+1]));	

	int vertexConfig6 = isInOrOutEdge(coords[v1], coords[v1+1], coords[v2], coords[v2+1], coords[triA2], coords[triA2+1]) | (2 * isInOrOutEdge(coords[v2], coords[v2+1], coords[v3], coords[v3+1], coords[triA2], coords[triA2+1])) | (4 * isInOrOutEdge(coords[v3], coords[v3+1], coords[v1], coords[v1+1], coords[triA2], coords[triA2+1]));	
	
	if ( (faceAllowed[i]) && (((vertexConfig1 | vertexConfig2 | vertexConfig3 | vertexConfig4 | vertexConfig5 | vertexConfig6) > 16) || (((vertexConfig1 & vertexConfig2 & vertexConfig3) | (vertexConfig4 & vertexConfig5 & vertexConfig6)) == 0))) 
	{
		output[0] = 1;
	}
}

/* It should return 1 if there is at least one triangle that overlaps the input triangle. If the edges of these triangles just touch the input triangle, it won't overlap it. */
__kernel void are2DTrianglesOverlapping(__global float * triA, __global int * edge, __global bool * faceAllowed, __global float * coords, __global int * faces, __global int * output)
{
	int i = get_global_id(0);
	int faceStart = i * 3;
	int v1 = faces[faceStart]*2;
	int v2 = faces[faceStart+1]*2;
	int v3 = faces[faceStart+2]*2;
	int triA1 = edge[0] * 2;
	int triA2 = edge[1] * 2;

	int vertexConfig1 = isInOrOutEdge(coords[v1], coords[v1+1], coords[v2], coords[v2+1], triA[0], triA[1]) | (2 * isInOrOutEdge(coords[v2], coords[v2+1], coords[v3], coords[v3+1], triA[0], triA[1])) | (4 * isInOrOutEdge(coords[v3], coords[v3+1], coords[v1], coords[v1+1], triA[0], triA[1]));	

	int vertexConfig2 = isInOrOutEdge(coords[v1], coords[v1+1], coords[v2], coords[v2+1], coords[triA1], coords[triA1+1]) | (2 * isInOrOutEdge(coords[v2], coords[v2+1], coords[v3], coords[v3+1], coords[triA1], coords[triA1+1])) | (4 * isInOrOutEdge(coords[v3], coords[v3+1], coords[v1], coords[v1+1], coords[triA1], coords[triA1+1]));	

	int vertexConfig3 = isInOrOutEdge(coords[v1], coords[v1+1], coords[v2], coords[v2+1], coords[triA2], coords[triA2+1]) | (2 * isInOrOutEdge(coords[v2], coords[v2+1], coords[v3], coords[v3+1], coords[triA2], coords[triA2+1])) | (4 * isInOrOutEdge(coords[v3], coords[v3+1], coords[v1], coords[v1+1], coords[triA2], coords[triA2+1]));	

	int vertexConfig4 = isInOrOutEdge(triA[0], triA[1], coords[triA1], coords[triA1+1], coords[v1], coords[v1+1]) | (2 * isInOrOutEdge(coords[triA1], coords[triA1+1], coords[triA2], coords[triA2+1], coords[v1], coords[v1+1])) | (4 * isInOrOutEdge(coords[triA2], coords[triA2+1], triA[0], triA[1], coords[v1], coords[v1+1]));	

	int vertexConfig5 = isInOrOutEdge(triA[0], triA[1], coords[triA1], coords[triA1+1], coords[v2], coords[v2+1]) | (2 * isInOrOutEdge(coords[triA1], coords[triA1+1], coords[triA2], coords[triA2+1], coords[v2], coords[v2+1])) | (4 * isInOrOutEdge(coords[triA2], coords[triA2+1], triA[0], triA[1], coords[v2], coords[v2+1]));	

	int vertexConfig6 = isInOrOutEdge(triA[0], triA[1], coords[triA1], coords[triA1+1], coords[v3], coords[v3+1]) | (2 * isInOrOutEdge(coords[triA1], coords[triA1+1], coords[triA2], coords[triA2+1], coords[v3], coords[v3+1])) | (4 * isInOrOutEdge(coords[triA2], coords[triA2+1], triA[0], triA[1], coords[v3], coords[v3+1]));	
	
	if ( (faceAllowed[i]) && (((vertexConfig1 | vertexConfig2 | vertexConfig3 | vertexConfig4 | vertexConfig5 | vertexConfig6) > 16) || (((vertexConfig1 & vertexConfig2 & vertexConfig3) | (vertexConfig4 & vertexConfig5 & vertexConfig6)) == 0))) 
	{
		output[0] = 1;
	}
}