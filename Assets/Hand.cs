using UnityEngine;

public class Hand : MonoBehaviour {
    public Transform hammerHandle;
    public Sprite[] sprites;
    public bool rightHand = false;

    void Start() {}

    void Update() {
        Vector3 handDir = hammerHandle.position - transform.position;

        transform.rotation = Quaternion.FromToRotation(Vector3.down, handDir);
        GetComponent<SpriteRenderer>().flipX = rightHand ^ handDir.y > 0;

        int spriteIndex =
            Mathf.Clamp((int)(handDir.magnitude * 8), 0, sprites.Length - 1);
        GetComponent<SpriteRenderer>().sprite = sprites[spriteIndex];
    }
}
