using UnityEngine;

public class CameraFollowObject : MonoBehaviour {
    public Transform target;

    void Start() {
        GetComponent<Camera>().transparencySortMode =
            TransparencySortMode.Orthographic;
    }

    void FixedUpdate() {
        Vector3 moveVec =
            target.position - GetComponent<Camera>().transform.position;
        moveVec.z = 0;
        GetComponent<Camera>().transform.position +=
            moveVec * Time.fixedDeltaTime * 4.0f;
    }
}
