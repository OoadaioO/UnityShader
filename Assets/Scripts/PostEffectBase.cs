using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostEffectBase : MonoBehaviour
{


    // Start is called before the first frame update
    void Start()
    {
        CheckResources();
    }

    private void CheckResources()
    {
        bool isSupport = CheckSupport();

        if (!isSupport)
        {
            NotSupported();
        }
    }

    private bool CheckSupport()
    {
        if(SystemInfo.supportsImageEffects == false || SystemInfo.supportsRenderTextures == false){
            return false;
        }
        return true;
    }

    private void NotSupported()
    {
        enabled = false;
    }

    protected Material CheckShaderAndMaterial(Shader shader, Material material)
    {
        if (shader == null)
        {
            return null;
        }

        if (shader.isSupported && material && material.shader == shader)
        {
            return material;
        }

        if (!shader.isSupported)
        {
            return null;
        }
        else
        {
            material = new Material(shader)
            {
                hideFlags = HideFlags.DontSave
            };
            return material;
        }

    }

}
