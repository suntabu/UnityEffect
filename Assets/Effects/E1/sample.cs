using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;



public class sample : MonoBehaviour
{
    public Slider slider1, slider2, slider3;

    public RawImage image;
    
    void Start()
    {
        var mat = image.material;
        
        slider1.onValueChanged.AddListener(new UnityAction<float>(t =>
        {
            mat.SetFloat("_LightWidth",t);
        }));
        
        slider2.onValueChanged.AddListener(new UnityAction<float>(t =>
        {
            mat.SetFloat("_LightAngle",(t - 0.5f) * 2 * 90);
        }));
        
        slider3.onValueChanged.AddListener(new UnityAction<float>(t =>
        {
            mat.SetFloat("_LightRange",(t - 0.5f) * 2.5f);
        }));
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}