using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Updater : MonoBehaviour
{
    private Material _mat;

    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        _mat = this.GetComponent<ParticleSystemRenderer>().material;
        _mat.SetMatrix("_O2W",this.transform.localToWorldMatrix);
        _mat.SetVector("_Pos",this.transform.position);
        _mat.SetVector("_Scale", this.transform.lossyScale);
    }
}
