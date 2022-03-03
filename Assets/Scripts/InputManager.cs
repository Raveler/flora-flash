using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using Random = UnityEngine.Random;

public class InputManager : MonoBehaviour
{
	public KeyboardLayout layout; // inspector

	public RenderQuad quadPrefab; // inspector

	public List<string> audioStrings; // inspector

	private float cooldownTime = 0.0f;

	private float beepCooldown = 0.0f;


	public void Update()
	{
		float dt = Time.deltaTime;

		if (beepCooldown > 0) beepCooldown -= dt;

		if (cooldownTime > 0)
		{
			cooldownTime -= dt;
			return;
		}

		if (Input.anyKeyDown)
		{
			foreach (KeyCode code in Enum.GetValues(typeof(KeyCode)))
			{
				if (Input.GetKeyDown(code))
				{
					char c = (char)code;


					bool keyFound = GetX(c, out float x);
					if (keyFound)
					{
						Debug.Log("Found " + c + " with keyfound " + keyFound + " and x " + x);
						Flash(x);
					}
				}
			}
		}
	}

	private void Flash(float x)
	{
		float y = UnityEngine.Random.Range(0.0f, 1.0f);

		RenderQuad quad = Instantiate(quadPrefab);
		quad.Create(x, y);

		cooldownTime = 0.05f;

		if (beepCooldown <= 0)
		{
			Beep();
			beepCooldown = 0.4f;
		}
	}

	private void Beep()
	{
		if (audioStrings.Count > 0)
		{
			SfxrSynth synth = new SfxrSynth();
			int idx = UnityEngine.Random.Range(0, audioStrings.Count);
			string audio = RandomizeAudio(audioStrings[idx]);
			synth.parameters.SetSettingsString(audio);
			synth.Play();
		}
	}

	private string RandomizeAudio(string s)
	{
		// 0,.5,,.0348,.5362,.3492,.3,.4404,,,,,,,,,,,,,,,,,,1,,,,,,
		string[] split = s.Split(',');
		for (int i = 2; i < split.Length; ++i)
		{
			if (split[i].Length == 0) continue;
			if (float.TryParse(split[i], out float v)) {
				float d = 0.2f;
				float multiplier = Random.Range(1 - d, 1 + d);
				split[i] = "" + Mathf.Clamp01(v * multiplier);
			}
		}

		// volume
		split[1] = "0.1";

		return string.Join(",", split);
	}

	private bool GetX(char c, out float x)
	{
		Key key = layout.keys.FirstOrDefault(k => Char.ToLower(k.code[0]) == Char.ToLower(c));
		x = 0.0f;
		if (key == null) return false;

		x = Mathf.InverseLerp(layout.left, layout.right, key.x);
		return true;
	}

	private readonly Dictionary<char, KeyCode> _keycodeCache = new Dictionary<char, KeyCode>();
	private KeyCode GetKeyCode(char character)
	{
		// Get from cache if it was taken before to prevent unnecessary enum parse
		KeyCode code;
		if (_keycodeCache.TryGetValue(character, out code)) return code;
		// Cast to it's integer value
		int alphaValue = character;
		code = (KeyCode)Enum.Parse(typeof(KeyCode), alphaValue.ToString());
		_keycodeCache.Add(character, code);
		return code;
	}
}