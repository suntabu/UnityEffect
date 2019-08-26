using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class Painter : MonoBehaviour
{
    public Texture2D TargetTexture;
    public Texture2D PenTexture;
    public float BrushScale = 1;
    [Range(0.01f, 2f)] public float DrawLerpDamp = 0.02f;

    public Material PenMat, CanvasMat;

    private RenderTexture mRenderTexture1, mRenderTexture2;
    private int mCanvasWidth, mCanvasHeight;
    private bool mIsDrawing, mIsMouseDown;
    private Vector3 mPreMousePosition;
    private Rect mUV = new Rect(0f, 0f, 1f, 1f);

    private void Awake()
    {
        mCanvasWidth = TargetTexture.width;
        mCanvasHeight = TargetTexture.height;

        mRenderTexture1 = RenderTexture.GetTemporary(TargetTexture.width, TargetTexture.height);
        mRenderTexture2 = RenderTexture.GetTemporary(TargetTexture.width, TargetTexture.height);

        PenMat.SetFloat("_BlendSrc", (int) BlendMode.SrcAlpha);
        PenMat.SetFloat("_BlendDst", (int) BlendMode.OneMinusSrcAlpha);

        PenMat.SetTexture("_BrushTex", TargetTexture);


        CanvasMat.SetFloat("_BlendSrc", (int) BlendMode.One);
        CanvasMat.SetFloat("_BlendDst", (int) BlendMode.OneMinusSrcAlpha);

        CanvasMat.SetTexture("_MainTex", mRenderTexture1);

        CreateQuad(CanvasMat);
    }

    void Start()
    {
    }

    Mesh SpriteToMesh(Sprite sprite)
    {
        Mesh mesh = new Mesh();
        mesh.vertices = Array.ConvertAll(sprite.vertices, i => (Vector3) i);
        mesh.uv = sprite.uv;
        mesh.triangles = Array.ConvertAll(sprite.triangles, i => (int) i);

        return mesh;
    }

    private void OnGUI()
    {
        if (GUI.Button(new Rect(10, 10, 100, 100), "hah"))
        {
            var tex = new Texture2D(mCanvasWidth, mCanvasHeight);
            var rect = new Rect(0, 0, mCanvasWidth, mCanvasHeight);
            RenderTexture.active = mRenderTexture1;
            tex.ReadPixels(rect, 0, 0);
            tex.Apply();
            var sprite = Sprite.Create(tex, rect, Vector2.one * 0.5f,
                100, 1, SpriteMeshType.Tight);

            var mesh = SpriteToMesh(sprite);

            var go = new GameObject("hah", typeof(MeshRenderer), typeof(MeshFilter));
            go.transform.SetParent(this.transform);
            go.transform.localScale = Vector3.one;
            go.transform.localPosition = Vector3.zero;

            go.GetComponent<MeshFilter>().mesh = mesh;
            go.GetComponent<MeshRenderer>().material = CanvasMat;
        }
    }

    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            mIsMouseDown = true;
            //Draw once when mouse down.
            //ClickDraw(Input.mousePosition,Camera.main,painterCanvas.penTex,painterCanvas.brushScale,painterCanvas.penMat,painterCanvas.renderTexture);
        }
        else if (Input.GetMouseButton(0))
        {
            if (mIsMouseDown)
            {
                //draw on mouse drag.
                Drawing(Input.mousePosition, Camera.main);
            }
        }
        else if (Input.GetMouseButtonUp(0) && mIsMouseDown)
        {
            EndDraw();
            mIsMouseDown = false;
        }
    }

    /// <summary>
    /// Convert hit point to uv position.
    /// </summary>
    /// <returns>uv position.</returns>
    /// <param name="hitPoint">Hit point is world position</param>
    Vector2 SpriteHitPoint2UV(Vector3 hitPoint)
    {
        Vector3 localPos = transform.InverseTransformPoint(hitPoint);
        localPos *= 100f;
        localPos.x += mCanvasWidth * 0.5f;
        localPos.y += mCanvasHeight * 0.5f;
        return new Vector2(localPos.x / mCanvasWidth, localPos.y / mCanvasHeight);
    }

    public void EndDraw()
    {
        mIsDrawing = false;
    }

    public void Drawing(Vector3 screenPos, Camera camera = null, bool drawOutside = false)
    {
        if (camera == null) camera = Camera.main;
        Vector3 uvPos = SpriteHitPoint2UV(camera.ScreenToWorldPoint(screenPos));
        screenPos = new Vector3(uvPos.x * mCanvasWidth, mCanvasHeight - uvPos.y * mCanvasHeight, 0f);
        if (!mIsDrawing)
        {
            mIsDrawing = true;
            mPreMousePosition = screenPos;
        }

        if (mIsDrawing)
        {
            GL.PushMatrix();
            GL.LoadPixelMatrix(0, mCanvasWidth, mCanvasHeight, 0);
            RenderTexture.active = mRenderTexture1;

            LerpDraw(ref screenPos, ref mPreMousePosition, drawOutside);

            RenderTexture.active = null;
            GL.PopMatrix();
            mPreMousePosition = screenPos;
        }
    }

    bool Intersect(ref Rect a, ref Rect b)
    {
        bool c1 = a.xMin < b.xMax;
        bool c2 = a.xMax > b.xMin;
        bool c3 = a.yMin < b.yMax;
        bool c4 = a.yMax > b.yMin;
        return c1 && c2 && c3 && c4;
    }

    void CreateQuad(Material mat)
    {
        Mesh m = new Mesh();
        m.vertices = new Vector3[]
        {
            new Vector3(mCanvasWidth * 0.005f, mCanvasHeight * 0.005f),
            new Vector3(mCanvasWidth * 0.005f, -mCanvasHeight * 0.005f),
            new Vector3(-mCanvasWidth * 0.005f, -mCanvasHeight * 0.005f),
            new Vector3(-mCanvasWidth * 0.005f, mCanvasHeight * 0.005f)
        };
        m.uv = new Vector2[]
        {
            new Vector2(1, 1),
            new Vector2(1, 0),
            new Vector2(0, 0),
            new Vector2(0, 1)
        };
        m.triangles = new int[] {0, 1, 2, 2, 3, 0};
        m.RecalculateBounds();
        m.RecalculateNormals();

        MeshFilter meshFilter = gameObject.GetComponent<MeshFilter>();
        if (meshFilter == null) meshFilter = gameObject.AddComponent<MeshFilter>();
        meshFilter.mesh = m;

        MeshRenderer rend = gameObject.GetComponent<MeshRenderer>();
        if (rend == null) rend = gameObject.AddComponent<MeshRenderer>();
        rend.material = mat;
//        rend.sortingLayerName = sortingLayerName;
//        rend.sortingOrder = sortingOrder;
    }

    void LerpDraw(ref Vector3 current, ref Vector3 prev, bool drawOutside)
    {
        float distance = Vector2.Distance(current, prev);
        if (distance > 0f)
        {
            Vector2 pos;
            float w = PenTexture.width * BrushScale;
            float h = PenTexture.height * BrushScale;
            float lerpDamp = Mathf.Min(w, h) * DrawLerpDamp;
            mUV.width = mCanvasWidth;
            mUV.height = mCanvasHeight;
            for (float i = 0; i < distance; i += lerpDamp)
            {
                float lDelta = i / distance;
                float lDifx = current.x - prev.x;
                float lDify = current.y - prev.y;
                pos.x = prev.x + (lDifx * lDelta);
                pos.y = prev.y + (lDify * lDelta);
                Rect rect = new Rect(pos.x - w * 0.5f, pos.y - h * 0.5f, w, h);
                if (drawOutside || Intersect(ref mUV, ref rect))
                {
                    PenMat.SetVector("_rect", new Vector4(rect.x, rect.y, rect.width, rect.height));
                    PenMat.SetVector("_canvas",
                        new Vector4(-mCanvasWidth / 2, mCanvasHeight / 2 + transform.localPosition.y * 200,
                            mUV.width, mUV.height));

                    Debug.Log(PenMat.GetVector("_rect") + " -> " + PenMat.GetVector("_canvas"));
                    Graphics.DrawTexture(rect, PenTexture, PenMat);
                }
            }
        }
    }
}