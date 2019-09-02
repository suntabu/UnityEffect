using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[RequireComponent(typeof(ParticleSystem))]
public class AreaParticleScript : MonoBehaviour
{
    public Material ParticleMat;

    private ParticleSystem mParticleSystem;
    private ParticleSystemRenderer mParticleRenderer;
    private Painter mPainter;

    private void Awake()
    {
        mParticleSystem = GetComponent<ParticleSystem>();
        if (!mParticleSystem)
        {
            mParticleSystem = this.gameObject.AddComponent<ParticleSystem>();
        }

        mParticleRenderer = mParticleSystem.GetComponent<ParticleSystemRenderer>();
    }

    void Start()
    {
        var mesh = this.transform.parent.GetComponent<MeshFilter>().mesh;
        SetMesh(mesh);

        mPainter = this.transform.parent.GetComponent<Painter>();

        ParticleMat.SetTexture("_MaskTex", null);
        ParticleMat.SetTexture("_BrushTex", mPainter.mRenderTexture1);
        
        ParticleMat.SetVector("_canvas",
            new Vector4(-mPainter.mCanvasWidth / 2, mPainter.mCanvasHeight / 2 + transform.localPosition.y * 200,
                mPainter.mCanvasWidth, mPainter.mCanvasHeight));
        Debug.Log(  " -> " + ParticleMat.GetVector("_canvas"));
        mParticleRenderer.material = ParticleMat;
    }

    public void SetMesh(Mesh mesh)
    {
        var shape = mParticleSystem.shape;
        shape.shapeType = ParticleSystemShapeType.Mesh;
        shape.meshShapeType = ParticleSystemMeshShapeType.Triangle;
        shape.mesh = mesh;
    }


    void Update()
    {
    }
}