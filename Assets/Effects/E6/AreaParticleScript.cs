using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[RequireComponent(typeof(ParticleSystem))]
public class AreaParticleScript : MonoBehaviour
{
    private ParticleSystem mParticleSystem;

    private void Awake()
    {
        mParticleSystem = GetComponent<ParticleSystem>();
        if (!mParticleSystem)
        {
            mParticleSystem = this.gameObject.AddComponent<ParticleSystem>();
        }
    }

    public void SetMesh(Mesh mesh)
    {
        var shape = mParticleSystem.shape;
        shape.shapeType = ParticleSystemShapeType.Mesh;
        shape.mesh = mesh;
    }

    void Start()
    {
    }

    void Update()
    {
    }
}