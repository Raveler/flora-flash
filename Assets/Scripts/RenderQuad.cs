using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RenderQuad : MonoBehaviour
{
	public new MeshRenderer renderer; // inspector

	public List<string> audioStrings; // inspector

	private float timeLeft;

	private Material material;
	private new Camera camera;


    public void Create(float x, float y)
    {
		camera = Camera.main;

		material = renderer.material;

		timeLeft = Random.Range(0.5f, 1.0f);

		material.SetFloat("_FlashDuration", timeLeft);
		material.SetFloat("_StartAnimationTime", Time.time);
		material.SetVector("_FlashUV", new Vector4(x, y, 0, 0));

		float radius = new Vector2(Screen.width, Screen.height).magnitude * 0.7f;
		material.SetFloat("_FlashRadius", radius);

		Color color = Color.HSVToRGB(x, 1, 1);
		material.SetColor("_FlashColor", color);

		Resize();
	}


	public void Update()
	{
		Resize();

		timeLeft -= Time.deltaTime;

		if (timeLeft < 0)
		{
			DestroyImmediate(material);
			Destroy(gameObject);
		}
	}

	private void Resize()
	{
		float h = camera.orthographicSize * 2;
		float w = h * camera.aspect;
		transform.localScale = new Vector3(w, h, 1);
	}
}
