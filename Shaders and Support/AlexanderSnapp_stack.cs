// Aaron Lanterman, July 22, 2021
// Modified example from https://github.com/Unity-Technologies/PostProcessing/wiki/Writing-Custom-Effects

using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

// Warning from https://github.com/Unity-Technologies/PostProcessing/wiki/Writing-Custom-Effects 
// Because of how serialization works in Unity, you have to make sure that the file is named 
// after your settings class name or it won't be serialized properly.
//[SerializeField] camera mainCamera;
//mainCamera.fieldOfView = 20;
// This is the settings class
[Serializable]
[PostProcess(typeof(AlexanderSnappStackRenderer), PostProcessEvent.AfterStack, "Custom/AlexanderSnappStack")]
public sealed class AlexanderSnappStack : PostProcessEffectSettings {
    [Tooltip("Speed of crossfade effect.")]
    public FloatParameter radius = new FloatParameter { value = 2f };
    public FloatParameter vertical = new FloatParameter { value = 9f };
    public FloatParameter horizontal = new FloatParameter { value = 16f };
}

public sealed class AlexanderSnappStackRenderer : PostProcessEffectRenderer<AlexanderSnappStack> {
    public override DepthTextureMode GetCameraFlags() {
        return DepthTextureMode.DepthNormals;
    }

	public override void Render(PostProcessRenderContext context) {
        var sheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/AlexanderSnappStackShader"));
        sheet.properties.SetFloat("_Radius", settings.radius);
        sheet.properties.SetFloat("_Vertical", settings.vertical);
        sheet.properties.SetFloat("_Horizontal", settings.horizontal);
        sheet.properties.SetColor("_FadeColor", Color.black);
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
    
}