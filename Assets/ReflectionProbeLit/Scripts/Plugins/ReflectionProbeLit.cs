using UnityEngine;
using System.Collections;

public class ReflectionProbeLit : MonoBehaviour
{
    protected int resolution = 512;
    public float size = 100f;
    public Vector3 probeSize = Vector3.one * 10f;    
    public LayerMask cullingMask;
    public CameraClearFlags clearFlags = CameraClearFlags.Skybox;
    public Mesh mesh;

    public RenderTexture albedoFront;
    public RenderTexture albedoBack;
    public RenderTexture depthFront;
    public RenderTexture depthBack;
    public RenderTexture normalFront;
    public RenderTexture normalBack;
    public RenderTexture emissionFront;
    public RenderTexture emissionBack;

    public Shader albedoShader;
    public Shader depthShader;
    public Shader normalShader;
    public Shader emissionShader;

    public Material testProbe;

    protected GameObject go;
    protected Camera camera;
    protected MeshFilter meshFilter;
    protected MeshRenderer meshRenderer;
    protected ReflectionProbe reflectionProbe;

    const int invisibleLayer = 31;

    void Awake()
    {
        gameObject.layer = invisibleLayer;

        InitGo();
        InitCamera();
        InitSphere();
        InitReflectionProbe();

        albedoFront = CreateRenderTexture();
        albedoBack = CreateRenderTexture();
        depthFront = CreateRenderTexture();
        depthBack = CreateRenderTexture();
        normalFront = CreateRenderTexture();
        normalBack = CreateRenderTexture();
        emissionFront = CreateRenderTexture();
        emissionBack = CreateRenderTexture();
    }

    void InitGo()
    {
        if (go == null)
        {
            go = new GameObject("Camera");
            go.transform.SetParent(transform);
            go.transform.localPosition = Vector3.zero;
            go.transform.localRotation = Quaternion.identity;
            go.transform.localScale = Vector3.one;
            go.layer = gameObject.layer;
        }
    }

    void InitCamera()
    {        
        camera = go.AddComponent<Camera>();
        camera.enabled = false;
        camera.orthographic = true;
        camera.orthographicSize = size;
        camera.nearClipPlane = 0f;
        camera.farClipPlane = size;
        camera.cullingMask = cullingMask.value;
    }

    void InitSphere()
    {
        meshFilter = go.AddComponent<MeshFilter>();
        meshFilter.mesh = mesh;
        meshFilter.mesh.bounds = new Bounds(Vector3.zero, probeSize);

        meshRenderer = go.AddComponent<MeshRenderer>();
        meshRenderer.sharedMaterial = testProbe;
        meshRenderer.receiveShadows = false;
        meshRenderer.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
        meshRenderer.useLightProbes = false;
        meshRenderer.reflectionProbeUsage = UnityEngine.Rendering.ReflectionProbeUsage.Off;
    }

    void InitReflectionProbe()
    {
        reflectionProbe = go.AddComponent<ReflectionProbe>();
        reflectionProbe.boxProjection = true;
        reflectionProbe.mode = UnityEngine.Rendering.ReflectionProbeMode.Realtime;
        reflectionProbe.refreshMode = UnityEngine.Rendering.ReflectionProbeRefreshMode.EveryFrame;
        reflectionProbe.cullingMask = 1 << invisibleLayer;
        
        reflectionProbe.resolution = resolution;
        reflectionProbe.size = probeSize;
        reflectionProbe.nearClipPlane = 0.01f;
        reflectionProbe.farClipPlane = 1.01f;
        reflectionProbe.timeSlicingMode = UnityEngine.Rendering.ReflectionProbeTimeSlicingMode.NoTimeSlicing;        
    }

    void Start()
    {
        Render();
    }
    
    void OnDestroy()
    {
        albedoFront.Release();
        albedoBack.Release();
        depthFront.Release();
        depthBack.Release();
        normalFront.Release();
        normalBack.Release();
        emissionFront.Release();
        emissionBack.Release();
    }

    RenderTexture CreateRenderTexture(RenderTextureFormat format = RenderTextureFormat.ARGB32, FilterMode filterMode = FilterMode.Point)
    {
        RenderTexture rt = new RenderTexture(resolution, resolution, 16, format);
        rt.useMipMap = false;
        rt.generateMips = false;
        rt.antiAliasing = 1;
        rt.filterMode = filterMode;
        rt.generateMips = false;
        rt.Create();
        return rt;
    }

    void Render()
    {
        meshRenderer.enabled = false;
        Shader.SetGlobalVector("_DP_Params", new Vector4(0f, size, resolution, resolution));

        RenderCamera(albedoFront, albedoShader, true, clearFlags);
        RenderCamera(albedoBack, albedoShader, false, clearFlags);
        RenderCamera(depthFront, depthShader, true, CameraClearFlags.Color, Color.white);
        RenderCamera(depthBack, depthShader, false, CameraClearFlags.Color, Color.white);
        RenderCamera(normalFront, normalShader, true, CameraClearFlags.Color);
        RenderCamera(normalBack, normalShader, false, CameraClearFlags.Color);
        RenderCamera(emissionFront, emissionShader, true, CameraClearFlags.Color);
        RenderCamera(emissionBack, emissionShader, false, CameraClearFlags.Color);

        camera.transform.rotation = Quaternion.identity;

        ApplyTestProbe();
        meshRenderer.enabled = true;
    }

    void RenderCamera(RenderTexture targetTexture, Shader replacementShader, bool front, CameraClearFlags clearFlags, Color backgroundColor = default(Color))
    {
        camera.transform.localPosition = Vector3.zero;
        camera.transform.localScale = Vector3.one;
        if (front)
        { 
            camera.transform.rotation = Quaternion.Euler(0f, 0f, 0f);
        } else {
            camera.transform.rotation = Quaternion.Euler(0f, 180f, 0f);
        }

        camera.clearFlags = clearFlags;
        camera.SetReplacementShader(replacementShader, "RenderType");
        camera.targetTexture = targetTexture;
        camera.backgroundColor = backgroundColor;

        camera.Render();
    }

    void ApplyTestProbe()
    {        
        testProbe.SetTexture("_FrontTexAlbedo", albedoFront);
        testProbe.SetTexture("_BackTexAbledo", albedoBack);
        testProbe.SetTexture("_FrontTexNormal", normalFront);
        testProbe.SetTexture("_BackTexNormal", normalBack);
        testProbe.SetTexture("_FrontTexDepth", depthFront);
        testProbe.SetTexture("_BackTexDepth", depthBack);
        testProbe.SetTexture("_FrontTexEmission", emissionFront);
        testProbe.SetTexture("_BackTexEmission", emissionBack);
    }
}
