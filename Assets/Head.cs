using System.Collections;
using UnityEngine;

public class Head : MonoBehaviour {
    public Sprite blinkSprite;

    void Start() { StartCoroutine(Blink()); }

    void Update() {
        Vector3 mouseDir =
            new Vector3(Input.mousePosition.x / Screen.width * 2.0f - 1.0f,
                        Input.mousePosition.y / Screen.height * 2.0f - 1.0f);
        bool flipped = mouseDir.x < 0;

        float degrees =
            Mathf.Rad2Deg * Mathf.Atan2(mouseDir.y, Mathf.Abs(mouseDir.x));
        degrees = Mathf.Clamp(degrees, -30, 30);
        transform.eulerAngles = new Vector3(0, 0, degrees * (flipped ? - 1 : 1));

        GetComponent<SpriteRenderer>().flipX = flipped;
    }

    IEnumerator Blink() {
        while (true) {
            int waitTime = Random.Range(0, 10);
            yield return new WaitForSeconds(waitTime);

            for (int i = 0; i < 2; i++) {
                Sprite savedSprite = GetComponent<SpriteRenderer>().sprite;
                GetComponent<SpriteRenderer>().sprite = blinkSprite;
                yield return new WaitForSeconds(0.2f);
                GetComponent<SpriteRenderer>().sprite = savedSprite;
                yield return new WaitForSeconds(0.2f);
            }
        }
    }
}
