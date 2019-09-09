using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class FloatingImage : Image, IDragHandler, IBeginDragHandler, IEndDragHandler
{
    public Action<Transform> OnAdhereLeft, OnAdhereRight, OnAdhereUp, OnAdhereDown;

    public Texture2D LeftTex, RightTex, UpTex, DownTex;


    private Vector2 lastMousePos = Vector2.zero;

    public void OnDrag(PointerEventData eventData)
    {
        if (lastMousePos != Vector2.zero)
        {
            var delta = eventData.position - lastMousePos;
            this.rectTransform.anchoredPosition += delta;
        }
        
        lastMousePos = eventData.position;
    }

    public void OnBeginDrag(PointerEventData eventData)
    {
    }

    public void OnEndDrag(PointerEventData eventData)
    {
        lastMousePos = Vector2.zero;
        AdhereEdge();
    }

    private void AdhereEdge()
    {
        var container = this.rectTransform.parent as RectTransform;
        if (!container)
        {
            return;
        }

        var rect = container.rect;
        var halfWidth = rect.width * 0.5f;
        var halfHeight = rect.height * 0.5f;

        var position = this.rectTransform.anchoredPosition;

        var toLeft = new Vector2(-halfWidth, position.y);
        var toRight = new Vector2(halfWidth, position.y);
        var toUp = new Vector2(position.x, halfHeight);
        var toDown = new Vector2(position.x, -halfHeight);

        if (position.x <= 0)
        {
            if (position.y <= 0)
            {
                if (Vector2.Distance(toLeft, position) <= Vector2.Distance(toDown, position))
                {
                    StartCoroutine(Move(toLeft, OnAdhereLeft));
                }
                else
                {
                    StartCoroutine(Move(toDown, OnAdhereDown));
                }
            }
            else
            {
                if (Vector2.Distance(toLeft, position) <= Vector2.Distance(toUp, position))
                {
                    StartCoroutine(Move(toLeft, OnAdhereLeft));
                }
                else
                {
                    StartCoroutine(Move(toUp, OnAdhereUp));
                }
            }
        }
        else
        {
            if (position.y <= 0)
            {
                if (Vector2.Distance(toRight, position) <= Vector2.Distance(toDown, position))
                {
                    StartCoroutine(Move(toRight, OnAdhereRight));
                }
                else
                {
                    StartCoroutine(Move(toDown, OnAdhereDown));
                }
            }
            else
            {
                if (Vector2.Distance(toRight, position) <= Vector2.Distance(toUp, position))
                {
                    StartCoroutine(Move(toRight, OnAdhereRight));
                }
                else
                {
                    StartCoroutine(Move(toUp, OnAdhereUp));
                }
            }
        }
    }


    IEnumerator Move(Vector2 target, Action<Transform> callback)
    {
        yield return null;
        var t = 0f;
        while (t >= 1)
        {
            t += Time.deltaTime * 2;
            this.rectTransform.anchoredPosition = Vector2.Lerp(this.rectTransform.anchoredPosition, target, t);
        }

        this.rectTransform.anchoredPosition = target;

        if (callback != null)
        {
            callback(this.rectTransform);
        }
    }
}