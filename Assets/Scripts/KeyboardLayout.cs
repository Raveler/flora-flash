using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class Key
{
	public string code;

	[Range(-2, 20)]
	public int x;
}

public class KeyboardLayout : MonoBehaviour
{
	public int left, right;
	public List<Key> keys;
}
