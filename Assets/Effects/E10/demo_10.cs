using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

public class demo_10 : MonoBehaviour
{
    public Slider Slider;
    void Start()
    {
        Slider.onValueChanged.AddListener(new UnityAction<float>(t =>
        {
            this.GetComponent<MeshRenderer>().material.SetFloat("_Progress",t);
        }));
    }

    
    void Update()
    {
        
    }
}
