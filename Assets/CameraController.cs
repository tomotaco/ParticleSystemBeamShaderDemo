using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour {
    const float speedMax = 10.0f;
    const float speedAngle = 3.0f;
    Vector2 halfSizeScreen;

    Rigidbody RB;
    Quaternion yaw = Quaternion.identity;
    float pitch = 0.0f;
    float axisFB = 0.0f;

    // Use this for initialization
    void Start()
    {
        this.RB = GetComponent<Rigidbody>();
        this.halfSizeScreen = new Vector2(Screen.width * 0.5f, Screen.height * 0.5f);
    }

    // Update is called once per frame
    void Update()
    {
        float h = Input.GetAxis("Horizontal");
        float v = Input.GetAxis("Vertical");
        bool buttonF = Input.GetKey("z");
        bool buttonB = Input.GetKey("x");
        if (buttonF) {
            axisFB += 0.1f;
            if (1.0f <= axisFB) {
                axisFB = 1.0f;
            }
        } else if (buttonB) {
            axisFB -= 0.1f;
            if (axisFB <= -1.0f) {
                axisFB = -1.0f;
            }
        } else {
            axisFB *= 0.5f;
        }

        this.RB.AddForce(this.yaw * new Vector3(speedMax * h, speedMax * v, speedMax * this.axisFB) - this.RB.velocity, ForceMode.VelocityChange);

        // マウスの位置が画面中央にある時は向きは変更しない。
        // 画面の上下端1/4のエリアにあるときに向きを変更
        var mousePos = Input.mousePosition;
        //		Debug.Log("mosuePos=" + mousePos.ToString() + ", width=" + Screen.width.ToString() + ", height=" + Screen.height.ToString());
        float ratioH = (mousePos.x - halfSizeScreen.x) / halfSizeScreen.x;
        float ratioV = (mousePos.y - halfSizeScreen.y) / halfSizeScreen.y;
        //		Debug.Log("ratioH = " + ratioH.ToString() + ", " + "ratioV = " + ratioV.ToString());

        // 左右の回転
        if (0.5f < Mathf.Abs(ratioH)) {
            this.yaw *= Quaternion.AngleAxis(speedAngle * (ratioH - Mathf.Sign(ratioH) * 0.5f), Vector3.up);
        }
        // 上下の回転(プラスマイナス45度まで)
        if (0.5f < Mathf.Abs(ratioV)) {
            pitch += speedAngle * (ratioV - Mathf.Sign(ratioV) * 0.5f);
            if (pitch < -45.0f) {
                pitch = -45.0f;
            } else if (45.0f < pitch) {
                pitch = 45.0f;
            }
        }
        this.RB.MoveRotation(yaw * Quaternion.AngleAxis(pitch, Vector3.left));

    }
}
