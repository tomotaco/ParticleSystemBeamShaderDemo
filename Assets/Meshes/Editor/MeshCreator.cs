using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[InitializeOnLoad]
public class MeshCreator
{
    static readonly string nameAsset4 = "Assets/Meshes/mesh4Vertices.asset";

    static MeshCreator()
    {
        Debug.Log("MeshCreator::MeshCreator()");
        if (!System.IO.File.Exists(nameAsset4)) {
            Debug.Log("Creating: " + nameAsset4);
            var mesh4Vertices = createMesh4Vertices();
            AssetDatabase.CreateAsset(mesh4Vertices, nameAsset4);
        } else {
            Debug.Log("Already exists: " + nameAsset4);
        }
    }

    static Mesh createMesh4Vertices()
    {
        var mesh = new Mesh();
        Vector3[] vertices = {
            new Vector3(0.0f, 0.0f, 0.0f),
            new Vector3(0.0f, 0.0f, 0.0f),
            new Vector3(0.0f, 0.0f, 0.0f),
            new Vector3(0.0f, 0.0f, 0.0f)
        };
        Vector2[] uvs = {
            new Vector2(0.0f, 0.0f),
            new Vector2(0.0f, 1.0f),
            new Vector2(1.0f, 1.0f),
            new Vector2(1.0f, 0.0f)
        };
        int[] triangles = { 0, 1, 2, 0, 2, 3 };
        mesh.vertices = vertices;
        mesh.uv = uvs;
        mesh.triangles = triangles;

        return mesh;
    }
}
